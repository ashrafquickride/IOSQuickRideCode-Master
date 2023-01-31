//
//  SupportNotification.swift
//  Quickride
//
//  Created by Vinutha on 6/14/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class SupportNotification : NSObject,Mappable {
    
    var url: String?
    var className: String?
    var storyBoardName: String?
    var deeplink: String?
    
    static let TAXI_INTERNAL_DEEPLINK_HOMEPAGE = "quickride://taxihomepage"
    static let TAXI_INTERNAL_DEEPLINK_NEWRIDE = "quickride://newtaxiride"
    static let QUICK_JOB_INTERNAL_DEEPLINK = "quickride://quickjobs"

    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        self.url <- map["URL"]
        self.className <- map["iosClassName"]
        self.storyBoardName <- map["storyBoardName"]
        self.deeplink <- map["deeplink"]
    }
    public override var description: String {
        return "url: \(String(describing: self.url))," + "className: \(String(describing: self.className))," + " storyBoardName: \( String(describing: self.storyBoardName))," + "deeplink: \(String(describing: self.deeplink)),"
    }
}

