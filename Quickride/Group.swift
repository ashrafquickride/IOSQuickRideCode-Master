//
//  Circle.swift
//  Quickride
//
//  Created by KNM Rao on 23/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class Group : Mappable{
    
    
    var id : Double = 0
    var name : String?
    var description : String?
    var type = String()
    var creatorId : Double = 0
    var category = String()
    var imageURI : String?
    var url : String?
    var creationTime : Double = 0.0
    var members : [GroupMember] = [GroupMember]()
    var currentUserStatus : String?
    var requestedUserId : Double = 0
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var address : String?
    var lastRefreshedTime = NSDate()
    var companyCode : String?
    
    
    static let USER_GROUP_TYPE_PUBLIC = "PUBLIC"
    static let USER_GROUP_TYPE_PRIVATE = "PRIVATE"
    
    static let USER_GROUP_CATEGORY_COMMUNITY = "COMMUNITY"
    static let USER_GROUP_CATEGORY_CORPORATE = "CORPORATE"
    static let USER_GROUP_CATEGORY_GENERAL = "GENERAL"
    
    static let ID = "id"
    static let FLD_IDS_BULK = "ids"
    static let GROUP_NAME="name"
    
    static let DESCRIPTION="description"
    static let CREATOR_ID="creatorId"
    static let IMAGE_URI="imageURI"
    static let MEMBER_COUNT="memberCount"
    static let CATEGORY = "category"
    static let GROUP_TYPE="type"
    static let GROUP_URL="url"
    static let GROUP_SEARCH_IDENTIFIER="searchIdentifier"
    static let LATITUDE = "latitude"
    static let LONGITUDE = "longitude"
    static let ADDRESS = "address"
    static let COMPANY_CODE = "companyCode"
    
    
    init(){
        
    }
    init ( name : String,imageURI : String?, description : String,  type :String,  creatorId : Double,url :String?,category : String,latitude : Double,longitude : Double,address : String?,creationTime : Double,companyCode : String?) {
        
        self.name = name
        self.imageURI = imageURI
        self.description = description
        self.type = type
        self.creatorId = creatorId
        self.url = url
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.creationTime = creationTime
        self.companyCode = companyCode
    }
   
    func getParams() -> [String:String]{
        var params = [String:String]()
        params[Group.ID] =  StringUtils.getStringFromDouble(decimalNumber: id)
        params[Group.GROUP_NAME] = name
        params[Group.DESCRIPTION] = description
        params[Group.CREATOR_ID] = StringUtils.getStringFromDouble(decimalNumber: creatorId)
        params[Group.GROUP_TYPE] = type
        params[Group.CATEGORY] = category
        params[Group.LATITUDE] = String(describing: latitude)
        params[Group.LONGITUDE] = String(describing: longitude)
        
        if imageURI != nil && !imageURI!.isEmpty{
            params[Group.IMAGE_URI] = imageURI
        }
        if companyCode != nil && !companyCode!.isEmpty{
            params[Group.COMPANY_CODE] = companyCode!

        }
        if address != nil && !address!.isEmpty {
            params[Group.ADDRESS] = address!
        }
        
        if url != nil{
            params[Group.GROUP_URL] = url!
        }
    

        return params
    }
    
    func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.description <- map["description"]
        self.type <- map["type"]
        self.creatorId <- map["creatorId"]
        self.imageURI <- map["imageURI"]
        self.url <- map["url"]
        self.creationTime <- map["creationTime"]
        self.members <- map["members"]
        self.currentUserStatus <- map["currentUserStatus"]
        self.requestedUserId <- map["requestedUserId"]
        self.category <- map["category"]
        self.address <- map["address"]
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
        self.companyCode <- map["companyCode"]
    }

    required init?(map: Map) {
        
    }
    func getConfirmedMembersOfAGroup() -> [GroupMember]{
        var confirmedMembers = [GroupMember]()
        for member in members{
            if member.status == GroupMember.MEMBER_STATUS_CONFIRMED{
                confirmedMembers.append(member)
            }
        }
      return confirmedMembers
    }
    
    func removeCurrentUserAndPendingMembers() -> [GroupMember]{
        var filteredGrpMembers = [GroupMember]()
        for member in members{
            
            if member.userId == Double(QRSessionManager.getInstance()!.getUserId()) || member.status == GroupMember.MEMBER_STATUS_PENDING{
                continue
            }
           filteredGrpMembers.append(member)
        }
    return filteredGrpMembers
    }
 
}
