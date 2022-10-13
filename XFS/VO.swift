//
//  VO.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/14.
//

import Foundation

struct POI: Comparable{
    static func < (lhs: POI, rhs: POI) -> Bool {
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
    var latitude:Double = 0
    var longtitude:Double = 0
    
}
