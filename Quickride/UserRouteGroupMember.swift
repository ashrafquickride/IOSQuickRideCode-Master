//
//  UserRouteGroupMember.swift
//  Quickride
//
//  Created by QuickRideMac on 12/15/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserRouteGroupMember : NSObject, Mappable {
    var id : Double?
    var userId : Double?
    var groupId : Double?
    var groupName : String?
    var memberType : String?
    var gender : String?
    var imageURI : String?

    var userName : String?
    var supportCall : String?
    var noOfReviews : Int?
    var memberCount : Int?
    var rating : Float?
    var verificationStatus : Bool?
    var companyName : String?
    var profileVerificationData : ProfileVerificationData?
    
    static let ID = "id"
    static let USER_ID = "userId";
    static let GROUP_NAME = "groupName"
    static let GROUP_ID = "groupId"
    static let MEMBER_TYPE = "memberType"
    static let MEMBER_TYPE_MEMBER = "MEMBER"
    static let MEMBER_TYPE_ADMIN = "ADMIN"
    
    required internal init? (map:Map){
        
    }
    override init()
    {
        
    }

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        groupId <- map["groupId"]
        groupName <- map["groupName"]
        memberType <- map["memberType"]
        gender <- map["gender"]
        imageURI <- map["imageURI"]
        userName <- map["userName"]
        supportCall <- map["supportCall"]
        noOfReviews <- map["noOfReviews"]
        memberCount <- map["memberCount"]
        rating <- map["rating"]
        verificationStatus <- map["verificationStatus"]
        companyName <- map["companyName"]
        profileVerificationData <- map["profileVerificationData"]
    }
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["id"] = StringUtils.getStringFromDouble(decimalNumber: self.id)
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber: self.userId)
        params["groupId"] = StringUtils.getStringFromDouble(decimalNumber: self.groupId)
        params["groupName"] = self.groupName
        params["memberType"] = self.memberType
        params["gender"] = self.gender
        params["imageURI"] = self.imageURI
        params["userName"] = self.userName
        params["supportCall"] = self.supportCall
        params["noOfReviews"] = String(describing: self.noOfReviews)
        params["memberCount"] = String(describing: self.memberCount)
        params["rating"] = String(describing: self.rating)
        params["verificationStatus"] = String(describing: self.verificationStatus)
        params["companyName"] = self.companyName
        return params
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " groupId: \( String(describing: self.groupId))," + " groupName: \(String(describing: self.groupName))," + " memberType: \(String(describing: self.memberType)),"
            + " gender: \(String(describing: self.gender))," + "imageURI: \(String(describing: self.imageURI))," + "userName:\(String(describing: self.userName))," + "supportCall:\(String(describing: self.supportCall))," + "noOfReviews:\(String(describing: self.noOfReviews))," + "memberCount:\(String(describing: self.memberCount))," + "rating: \(String(describing: self.rating))," + "verificationStatus:\(String(describing: self.verificationStatus))," + "companyName: \(String(describing: self.companyName)),"
    }

}
