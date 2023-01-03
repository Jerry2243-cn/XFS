import UIKit
import Alamofire
func fetchChannels(completion:@escaping([String]?)->()){
    AF.request(
        serverAddress + "/getChannels"
    ).response{ data in
        if data.error == nil{
            switch data.result{
            case .success(let json):
                if (json as! [[String : AnyObject]]?) != nil{
                    debugPrint(json)
                }
                
            default:
                completion(nil)
            }
        }else{
            completion(nil)
        }
    }
}

fetchChannels { s in
    if let strings = s{
        
    }
}
