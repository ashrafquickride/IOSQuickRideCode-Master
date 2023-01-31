//
//  AppVersion.swift
//  Quickride
//
//  Created by QuickRideMac on 02/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias AppVersionCompletionHandler = (_ appVersion : AppVersion?) -> Void
class AppVersion : NSObject, Mappable {
    
    var userID : Double?
    var androidAppVersion : Double?
    var iosAppVersion : Double?
    var appName : String?
    
    

    init(userID : Double,  androidAppVersion :Double,  iosAppVersion:Double, appName : String)
    {
        self.userID = userID
        self.androidAppVersion = androidAppVersion
        self.iosAppVersion = iosAppVersion
        self.appName = appName
    }
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        self.userID <- map["userID"]
        self.androidAppVersion <- map["androidAppVersion"]
        self.iosAppVersion <- map["iosAppVersion"]
        self.appName <- map["appName"]
    }
    public override var description: String {
        return "userID: \(String(describing: self.userID))," + "androidAppVersion: \(String(describing: self.androidAppVersion))," + " iosAppVersion: \( String(describing: self.iosAppVersion))," + " appName: \(String(describing: self.appName)),"
    }
    
}
