//
//  VO.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/14.
//

import Foundation

struct Note: Codable{
    var title = ""
    var content = ""
    var coverPhoto = ""
    var coverPhotoDescribe = ""
    var photos:[Photo] = []
    var poi = POI()
    var user = User()
    var topic = Topic()
    var createTime = ""
    var updateTime = ""
    var likeNumber = 0
    var starNumber = 0
    var commentNumber = 0
    var views = 0
}

struct Photo: Codable{
    var url = ""
    var orderNumber = 0
}

struct User: Codable{
    var id = -1
    var username = ""
    var password = ""
}

struct Topic: Codable{
    var name = ""
}

struct POI: Comparable, Codable{
    
    public static func == (lhs: POI, rhs: POI) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longtitude == rhs.longtitude
    }
    
    public static func < (lhs: POI, rhs: POI) -> Bool {
        if lhs.latitude < rhs.latitude {
            return true
        }
        if lhs.latitude == rhs.latitude {
            return lhs.longtitude < rhs.longtitude
        }
        return false
    }
    
    var name:String = ""
    var address:String = ""
    var city:String = ""
    var latitude:Double = 0
    var longtitude:Double = 0
    
}
