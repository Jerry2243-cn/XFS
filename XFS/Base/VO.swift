//
//  VO.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/14.
//

import Foundation

struct Note: Codable{
    var id = -1
    var title:String?
    var content:String?
    var coverPhoto = ""
    var ratio = 0.0
    var coverPhotoDescribe:String?
    var photos:[Photo] = []
    var poi:POI?
    var user = User()
    var topic:Topic?
    var createTime = ""
    var updateTime = ""
    var likeNumber = 0
    var starNumber = 0
    var commentNumber = 0
    var views = 0
    var liked = false
    var star = false
}

struct Photo: Codable{
    var url = ""
    var orderNumber = 0
}

struct User: Codable,Equatable{
    var id = -1
    var username = ""
    var password:String?
    var nickname = ""
    var avatar:String?
    var phoneNumber:String?
    var sex:String?
    var intro:String?
    var birthday:String?
    var fellow = false
    var fans = 0
    var fellowNumber = 0
    var likes = 0
}

struct Topic: Codable{
    var name = ""
    var channel:String?
}

struct POI: Comparable, Codable{
    
    public static func == (lhs: POI, rhs: POI) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude && lhs.name == rhs.name
    }
    
    public static func < (lhs: POI, rhs: POI) -> Bool {
        if lhs.latitude < rhs.latitude {
            return true
        }
        if lhs.latitude == rhs.latitude {
            return lhs.longitude < rhs.longitude
        }
        return false
    }
    var id = ""
    var name:String = ""
    var address:String?
    var city:String = ""
    var latitude:Double = 0
    var longitude:Double = 0
    
}
