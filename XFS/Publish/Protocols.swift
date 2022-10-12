//
//  Protocols.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/9.
//

import Foundation

protocol TopicSelectViewControllerDelegate {
    func updateTopic(channel: String, topic: String)
}

protocol POIViewControllerDelegate {
    func updateLocation(title: String, address: String)
}
