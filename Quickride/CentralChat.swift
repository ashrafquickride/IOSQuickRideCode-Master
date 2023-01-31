//
//  CentralChat.swift
//  Quickride
//
//  Created by Halesh on 19/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

struct CentralChat {
    
    var name: String?
    var imageURI: String?
    var lastMessage: String?
    var lastUpdateTime: Double?
    var unreadCount: Int?
    var chatType: String?
    var uniqueId: Double?
    var sourceApplication: String? // using only for personal chat to identify project QR/Bazaary/Taxi
    
    static let PERSONAL_CHAT = "PERSONAL_CHAT"
    static let USER_GROUP_CHAT = "USER_GROUP_CHAT"
    static let RIDE_JOIN_GROUP_CHAT = "RIDE_JOIN_GROUP_CHAT"
    
    init(name: String?,imageURI: String?,lastMessage: String?,lastUpdateTime: Double?,unreadCount: Int?,chatType: String,uniqueId: Double?){
        self.name = name
        self.imageURI = imageURI
        self.lastMessage = lastMessage
        self.lastUpdateTime = lastUpdateTime
        self.unreadCount = unreadCount
        self.chatType = chatType
        self.uniqueId = uniqueId
    }
    
    public var description: String {
        return "name: \(String(describing: self.name))," + "imageURI: \(String(describing: self.imageURI))," + " lastMessage: \( String(describing: self.lastMessage))," + " lastUpdateTime: \(String(describing: self.lastUpdateTime))," + " unreadCount: \(String(describing: self.unreadCount)),"
            + " chatType: \(String(describing: self.chatType))," + "uniqueId: \(String(describing: self.uniqueId)),"
    }
}
