//
//  QuickRideMessageEntity.swift
//  Quickride
//
//  Created by QuickRideMac on 02/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
public class QuickRideMessageEntity: NSObject,Mappable {
    
    
    var msgObjType : String?
    var uniqueID : String?
    var payloadType : String?
    
    static let UNIQUE_ID = "uniqueID"
    static let QUICKRIDE_MESSAGE_ENTITY_CLASS_NAME = "com.disha.quickride.domain.model.QuickRideMessageEntity"
    static let USER_PROFILE_ENTITY = "pro"
    static let RIDE_STATUS_ENTITY = "ridests"
    static let INVITE_STATUS_ENTITY = "invsts"
    static let CHAT_ENTITY = "chat"
    static let ACCOUNT_ENTITY = "acc"
    static let USER_NOTIFICATION_ENTITY = "noti"
    static let RIDER_RIDE_INSTNACE_ENTITY = "riderinst"
    static let PASSENGER_RIDE_INSTANCE_ENTITY = "psgrinst"
    static let RIDE_PREFERENCES_INSTANCE_ENTITY = "ridePref";
    static let LOCATION_ENTITY = "location";
    static let VEHICLE_ENTITY = "vehicle";
    static let RIDE_VEHICLE_ENTITY = "rideVehi";
    static let RIDEPARTICIPANT_ENTITY = "rideptnt";
    static let BLOCKED_USER_LISTNER_ENTITY = "blockeduser";
    static let PROFILE_VERIFICATION_DATA_LISTENER_ENTITY = "proverification";
    static let USER_ENTITY = "user"
    static let LINKED_WALLET_ENTITY = "linkedWallet"
    static let FREEZE_RIDE_STATUS_LISTNER_ENTITY = "freezeridest"
    static let GROUP_CHAT_ENTITY = "gpchat"
    static let SECURITY_PREFERENCES_INSTANCE_ENTITY = "securityprefinst";
    static let LINKED_WALLET_TRANSACTION_STATUS_ENTITY = "linkedwallettransactionst"
    static let RIDE_MODERATION_STATUS_ENTITY = "rideModerationsts"
    static let RIDE_UPDATE_ENTITY = "rideUpdate"
    static let TAXI_RIDE_PASSENGER_STATUS = "taxiRidePsgrSts"
    static let TAXI_RIDE_GROUP_STATUS = "taxiRideGroupSts"
    static let TAXI_RIDE_GROUP_SUGGESTION_UPDATE = "taxiRideGroupSuggestionUpdate"
    static let TAXIPOOL_INVITE_STATUS = "taxiInvite"
    static let CALL_CREDIT_DETAILS_UPDATE = "callCreditDetailsUpdate"
    static let NEW_TAXI_RIDE_CREATED = "newTaxiRideCreated"
    static let TAXI_PAYMENT_STATUS_UPDATE = "paymentStatusUpdate"
    static let TAXI_RIDE_PAYMENT_STATUS_UPDATE = "taxiRidePaymentStatus"
    static let DRIVER_ALLOCATION_STATUS = "driverAllocationStatus"
    


    //Quick Share Event updates
    static let PRODUCT_COMMENTS_ENTITY = "productComment"
    static let PRODUCT_ORDER_EVENT_ENTITY = "productOrder"
    
    public static let PAYLOAD_PARTIAL = "partial"
    public static let PAYLOAD_FULL = "full"
    
    override init(){
        self.uniqueID = NSUUID().uuidString
    }
    required public init?(map: Map) {
        
    }
    func getParams() -> [String:String]{
        var params :[String:String] = [String:String]()
        params[QuickRideMessageEntity.UNIQUE_ID] = uniqueID
        return params
    }
    public func mapping(map: Map) {
        self.uniqueID <- map["uniqueID"]
        msgObjType <- map["msgObjType"]
        payloadType <- map["payloadType"]
    }
}
