//
//  PostObject.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/12/12.
//

import Foundation

struct PostNote: Codable{
    var id = -1
    var title:String?
    var content:String?
    var coverPhoto = ""
    var coverPhotoDescribe:String?
    var photos:[Photo] = []
    var poi:POI?
    var topic:String?
    var ratio = 0.0
    var likeNumber = 0
    var starNumber = 0
    var commentNumber = 0
    var token = Server.shared().token
}

struct PostComment: Codable{
    var noteId:Int?
    var content:String?
    var replyId = -1
    var superCommentId = -1
    var token = Server.shared().token
}
