//
//  UserRouteGroup.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 27/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserRouteGroup : NSObject, Mappable{
    var id : Double?
    var groupName : String?
    var creatorId : Double?
    var fromLocationAddress : String?
    var toLocationAddress : String?
    var fromLocationLatitude : Double?
    var fromLocationLongitude : Double?
    var toLocationLatitude : Double?
    var toLocationLongitude : Double?
    var imageURI : String?
    var memberCount : Int?
    var appName : String?
    
    static let ID = "id"
    var  GROUP_NAME = "groupName" 
    var  CREATOR_ID = "creatorId" 
    static let FROM_LOC_ADDRESS = "fromLocationAddress"
    static let TO_LOCATION_ADDRESS = "toLocationAddress"
    static let FROM_LOC_LATITUDE = "fromLocationLatitude"
    static let FROM_LOC_LONGITUDE = "fromLocationLongitude"
    static let TO_LOC_LATITUDE = "toLocationLatitude"
    static let TO_LOC_LONGITUDE = "toLocationLongitude"
    var IMAGE_URI = "imageURI"
    var MEMBER_COUNT = "memberCount"
    
    override init(){
        
    }
    required init?(map:Map){
    }
    
    init(groupName:String,  creatorId:Double, fromLocationAddress:String, toLocationAddress:String, fromLocationLatitude:Double, fromLocationLongitude:Double, toLocationLatitude:Double, toLocationLongitude:Double, memberCount:Int, appName : String)
    {
        self.groupName = groupName
        self.creatorId = creatorId
        self.fromLocationAddress = fromLocationAddress
        self.toLocationAddress = toLocationAddress
        self.fromLocationLatitude = fromLocationLatitude
        self.fromLocationLongitude = fromLocationLongitude
        self.toLocationLatitude = toLocationLatitude
        self.toLocationLongitude = toLocationLongitude
        self.memberCount = memberCount
        self.appName = appName
    }
    func mapping(map: Map) {
        id <- map["id"]
        groupName <- map["groupName"]
        creatorId <- map["creatorId"]
        fromLocationAddress <- map["fromLocationAddress"]
        toLocationAddress <- map["toLocationAddress"]
        fromLocationLatitude <- map["fromLocationLatitude"]
        fromLocationLongitude <- map["fromLocationLongitude"]
        toLocationLatitude <- map["toLocationLatitude"]
        toLocationLongitude <- map["toLocationLongitude"]
        imageURI <- map["imageURI"]
        memberCount <- map["memberCount"]
        appName <- map["appName"]
    }
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["id"] = StringUtils.getStringFromDouble(decimalNumber : self.id)
        params["groupName"] = self.groupName
        params["creatorId"] =  StringUtils.getStringFromDouble(decimalNumber : self.creatorId)
        params["fromLocationAddress"] = self.fromLocationAddress
        params["toLocationAddress"] = self.toLocationAddress
        params["fromLocationLatitude"] = String(self.fromLocationLatitude!)
        params["fromLocationLongitude"] = String(self.fromLocationLongitude!)
        params["toLocationLatitude"] = String(self.toLocationLatitude!)
        params["toLocationLongitude"] = String(self.toLocationLongitude!)
        params["imageURI"] = self.imageURI
        params["memberCount"] = String(describing: self.memberCount)
        params["appName"] = self.appName
        return params
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "groupName: \(String(describing: self.groupName))," + " creatorId: \( String(describing: self.creatorId))," + " fromLocationAddress: \(String(describing: self.fromLocationAddress))," + " toLocationAddress: \(String(describing: self.toLocationAddress)),"
            + " fromLocationLatitude: \(String(describing: self.fromLocationLatitude))," + "fromLocationLongitude: \(String(describing: self.fromLocationLongitude))," + "toLocationLatitude:\(String(describing: self.toLocationLatitude))," + "toLocationLongitude:\(String(describing: self.toLocationLongitude))," + "imageURI:\(String(describing: self.imageURI))," + "memberCount:\(String(describing: self.memberCount))," + "appName: \(String(describing: self.appName)),"
    }
}
