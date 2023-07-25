//
//  Server.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/11/16.
//

import Foundation
import Alamofire
import SwiftyJSON

class Server{
    
    private static var instance:Server?
    var token:String
    
    private init(){
        if let token = UserDefaults.standard.object(forKey: userDefaultsTokenKey) as? String{
            self.token = token
        }else{
            self.token = ""
        }
    }
    
    static func shared() -> Server{
        if let instance = self.instance{
            return instance
        }
        self.instance = Server()
        return self.instance!
    }
    
    func request(REST:String, method:HTTPMethod, data:Data?, completion:@escaping(Any?)->()){
        AF.request(
            serverAddress + REST,
            method: method,
            parameters: data,
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) { response in
            switch response.result{
            case .success(let data):
                completion(data["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
     
    func postNoteToServer(data:PostNote, resoult: @escaping (String?)->()){
        AF.request(
            serverAddress + "/postNote",
            method: .post,
            parameters: data,
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                resoult(channels["response"])
            case .failure(_):
                resoult(nil)
            }
        }
    }
    
    func signIn(user:User, completion:@escaping(String?)->()){
        AF.request(
            serverAddress + "/signIn",
            method: .post,
            parameters: user,
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success"{
                    completion("注册成功")
                }else if res["response"] == "already exist"{
                    completion("用户名已存在")
                }else{
                    completion(nil)
                }
                
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func login(usr:String, pwd:String, completion:@escaping(String?)->()){
        let req = [
            "username" : usr,
            "password" : pwd
        ]
        AF.request(
            serverAddress + "/login",
            method: .post,
            parameters: req,
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success" {
                    self.token = res["token"] ?? ""
                    UserDefaults.standard.set(self.token, forKey: userDefaultsTokenKey)
                    completion("登录成功")
                }else{
                    completion("用户名或密码错误")
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchUser(completion:@escaping(User?)->()){
        AF.request(
            serverAddress + "/getUser",
            method: .post,
            parameters: ["token" : token ],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : User].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                completion(res["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func login(completion:@escaping(String?)->()){
        AF.request(
            serverAddress + "/loginWithToken",
            method: .post,
            parameters: ["token" : token ],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success" {
                    completion("登录成功")
                    self.token = res["token"]!
                    UserDefaults.standard.set(self.token, forKey: userDefaultsTokenKey)
                }else{
                    completion("token无效")
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchChannelsfromServer(completion:@escaping([String]?)->()){
        AF.request(
            serverAddress + "/getChannels"
        ).responseDecodable(of:[String : [String]].self) { data in
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchTopicsByChannel(channel:String, completion:@escaping([String]?)->()){
        AF.request(
            "\(serverAddress)/getTopics",
            method: .post,
            parameters: ["channel" : "\(channel)" ],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [String]].self) { data in
//            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchNotesByChannel(channel:String, page:Int, completion:@escaping([Note]?)->()){
        AF.request(
            "\(serverAddress)/getNotes?page=\(page)",
            method: .post,
            parameters: ["token" : token, "channel" : "\(channel)" ],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Note]].self) { data in
//            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchNotesByUser(userId:Int?, page:Int, completion:@escaping([Note]?)->()){
        AF.request(
            "\(serverAddress)/getMyNotes?page=\(page)",
            method: .post,
            parameters: ["token" : token, "userId" :  "\(userId ?? -1)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Note]].self) { data in
//            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchNotesByCity(page:Int, completion:@escaping([Note]?)->()){
        guard let city = appDelegate.myPOI?.city else{
            completion(nil)
            return
        }
        let url = "\(serverAddress)/getCityNotes?page=\(page)"
        AF.request(
            url,
            method: .post,
            parameters: ["token" : token , "city" : city],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Note]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func likeNote(noteId:Int, completion:@escaping(String?)->()?){
        AF.request(
            serverAddress + "/likeNote",
            method: .post,
            parameters: ["token" : token ,"noteId" : "\(noteId)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success" {
                    completion("操作成功")
                }else{
                    completion("操作失败")
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func starNote(noteId:Int, completion:@escaping(String?)->()?){
        AF.request(
            serverAddress + "/starNote",
            method: .post,
            parameters: ["token" : token ,"noteId" : "\(noteId)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success" {
                    completion("操作成功")
                }else{
                    completion("操作失败")
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fellowUser(userId:Int, completion:@escaping(String?)->()){
        AF.request(
            serverAddress + "/fellowUser",
            method: .post,
            parameters: ["token" : token ,"fellowUserId" : "\(userId)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success" {
                    completion("操作成功")
                }else{
                    completion("操作失败")
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchLikedNotes(userId:Int?, page:Int, completion:@escaping([Note]?)->()){
        let url = "\(serverAddress)/getLikeNotes?page=\(page)"
        AF.request(
            url,
            method: .post,
            parameters: ["token" : token, "userId" : "\(userId ?? -1)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Note]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchStarNotes(userId:Int?, page:Int, completion:@escaping([Note]?)->()){
        let url = "\(serverAddress)/getStarNotes?page=\(page)"
        AF.request(
            url,
            method: .post,
            parameters: ["token" : token, "userId" : "\(userId ?? -1)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Note]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func searchNotes(keyword:String, page:Int, completion:@escaping([Note]?)->()){
        let url = "\(serverAddress)/searchNotes?page=\(page)"
        AF.request(
            url,
            method: .post,
            parameters: ["token" : token, "keyword" : "\(keyword)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Note]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchFellowNotes(page:Int, completion:@escaping([Note]?)->()){
        let url = "\(serverAddress)/getFellowUserNotes?page=\(page)"
        AF.request(
            url,
            method: .post,
            parameters: ["token" : token],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Note]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func deleteNote(noteId:Int, completion:@escaping(String?)->()){
        AF.request(
            serverAddress + "/deleteNote",
            method: .post,
            parameters: ["token" : token ,"noteId" : "\(noteId)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success" {
                    completion("操作成功")
                }else{
                    completion("操作失败")
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func postCommentToServer(data:PostComment, resoult: @escaping (Int?)->()){
        AF.request(
            serverAddress + "/postComment",
            method: .post,
            parameters: data,
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : Int].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                resoult(channels["response"])
            case .failure(_):
                resoult(nil)
            }
        }
    }
    
    func fetchCommentsFromServer(noteId:Int, page:Int, completion: @escaping ([Comment]?)->()){
        AF.request(
            "\(serverAddress)/getComments?page=\(page)",
            method: .post,
            parameters: ["token" : token, "noteId" : "\(noteId)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Comment]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func deleteComment(commentId:Int, completion:@escaping(String?)->()){
        AF.request(
            serverAddress + "/deleteComment",
            method: .post,
            parameters: ["token" : token ,"commentId" : "\(commentId)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success" {
                    completion("操作成功")
                }else{
                    completion("操作失败")
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchTopicsFromServer(completion: @escaping ([Topic]?)->()){
        AF.request(
            "\(serverAddress)/getAllTopics"
        ).responseDecodable(of:[String : [Topic]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func fetchtopicNotes(topic:String, page:Int, completion:@escaping([Note]?)->()){
        let url = "\(serverAddress)/getTopicNotes?page=\(page)"
        AF.request(
            url,
            method: .post,
            parameters: ["token" : token, "topic" : topic],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [Note]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func noteAddView(noteId:Int, completion:@escaping(String?)->()){
        AF.request(
            serverAddress + "/noteAddView",
            method: .post,
            parameters: ["token" : token ,"noteId" : "\(noteId)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : String].self) {data in
            debugPrint(data)
            switch data.result{
            case .success(let res):
                if res["response"] == "success" {
                    completion("操作成功")
                }else{
                    completion("操作失败")
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func searchUsers(keyword:String, page:Int, completion:@escaping([User]?)->()){
        let url = "\(serverAddress)/searchUsers?page=\(page)"
        AF.request(
            url,
            method: .post,
            parameters: ["token" : token, "keyword" : "\(keyword)"],
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of:[String : [User]].self) { data in
            debugPrint(data)
            switch data.result{
            case .success(let channels):
                completion(channels["response"])
            case .failure(_):
                completion(nil)
            }
        }
    }
}
