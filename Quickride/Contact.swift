//
//  Contact.swift
//  Quickride
//
//  Created by QuickRideMac on 07/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class Contact: NSObject, Mappable {
    
    static let NEW_USER = "NEW_USER"
    static let RIDE_PARTNER = "RIDE_PARTNER"
    static let CONTACT = "CONTACT"
    static let FLD_CONTACT_ID = "contactId"
    static let FLD_USER_ID = "userId"
    static let FLD_FAV_PARTNER = "isFavPartner"
    static let AUTOCONFIRM_FAVOURITE = "FAVOURITE"
    static let AUTOCONFIRM_UNFAVOURITE = "UNFAVOURITE"
    static let AUTOCONFIRM_DEFAULT = "DEFAULT"
    static let RIDE_COMPLETED_RIDE_PARTNER = "RIDE_COMPLETED_RIDE_PARTNER"
    
    var userId : Double?
    var contactId : String?
    var contactName : String = ""
    var contactGender = User.USER_GENDER_MALE
    var contactType = Contact.RIDE_PARTNER
    var contactImageURI : String?
    var contactNo : Double?
    var supportCall : String = UserProfile.SUPPORT_CALL_ALWAYS
    var refreshedDate : NSDate?
    var enableChatAndCall : Bool = true
    var autoConfirmStatus = Contact.AUTOCONFIRM_DEFAULT
    var defaultRole: String?
    var status: String? //used only for invite by contact
    var companyName : String?
    var updateTime: Double = 0
    var contactStatus : String?
    var lastResponseTime : Int64 = 0
    override init(){
        
    }
    required init?(map: Map) {
        
    }
    
    init( userId : Double, contactId : String, contactName : String, contactGender : String?, contactType : String, imageURI : String?, supportCall : String?,contactNo : Double?,defaultRole: String) {
        self.userId = userId
        self.contactId = contactId
        self.contactName = contactName
        self.contactType = contactType
        if contactGender != nil{
            self.contactGender = contactGender!
        }
        if supportCall != nil{
            self.supportCall = supportCall!
        }
        if contactNo != nil{
            self.contactNo = contactNo
        }
        if imageURI != nil{
            self.contactImageURI = imageURI!
        }
        self.defaultRole = defaultRole
        
    }
    init(contactId : String, contactName : String){
        self.contactId = contactId
        self.contactName = contactName
    }
    
    
    func mapping(map: Map) {
        self.contactId <- map["contactId"]
        self.contactName <- map["contactName"]
        self.contactImageURI <- map["contactImageURI"]
        self.contactGender <- map["contactGender"]
        self.contactType <- map["contactType"]
        self.supportCall <- map["supportCall"]
        self.contactNo <- map["contactNo"]
        self.enableChatAndCall <- map["enableChatAndCall"]
        self.autoConfirmStatus <- map["autoConfirmStatus"]
        self.defaultRole <- map["defaultRole"]
        self.companyName <- map["companyName"]
        self.updateTime <- map["updateTime"]
        self.contactStatus <- map["contactStatus"]
        self.lastResponseTime <- map["lastResponseTime"]
    }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "contactId: \(String(describing: self.contactId))," + " contactName: \( String(describing: self.contactName))," + " contactGender: \(String(describing: self.contactGender))," + " contactType: \(String(describing: self.contactType)),"
            + " contactImageURI: \(String(describing: self.contactImageURI))," + "contactNo: \(String(describing: self.contactNo))," + "supportCall:\(String(describing: self.supportCall))," + "refreshedDate:\(String(describing: self.refreshedDate))," + "enableChatAndCall:\(String(describing: self.enableChatAndCall))," + "defaultRole:\(String(describing: self.defaultRole)),"
    }
}
