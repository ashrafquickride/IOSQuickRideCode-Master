//
//  Blog.swift
//  Quickride
//
//  Created by iDisha on 17/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class Blog: NSObject, Mappable{
    var id = 0
    var blogImageUri: String?
    var blogTitle: String?
    var linkUrl: String?
    var lastDisplayedTime: Double?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        self.id <- map["id"]
        self.blogImageUri <- map["blogImageUri"]
        self.blogTitle <- map["blogTitle"]
        self.linkUrl <- map["linkUrl"]
        self.lastDisplayedTime <- map["lastDisplayedTime"]
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "blogImageUri: \(String(describing: self.blogImageUri))," + " blogTitle: \(String(describing: self.blogTitle))," + " linkUrl: \(String(describing: self.linkUrl))," + " lastDisplayedTime: \(String(describing: self.lastDisplayedTime)),"
    }
}
