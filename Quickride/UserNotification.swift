//
//  UserNotification.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class UserNotification : Mappable {
    
    var notificationId : Int?
    var time : Double?
    var type : String?
    var priority : Int = 1
    var msgClassName : String?
    var msgObjectJson : String?
    var rideStatus : RideStatus?
    var groupName : String?
    var groupValue : String?
    var title : String?
    var description : String?
    var iconUri : String?
    var isActionRequired  : Bool = false
    var isActionTaken : Bool = false
    var isBigPictureRequired : Bool = false
    var isAckRequired = false
    var uniqueID : String?
    var sendFrom : Double = 0.0
    var sendTo = 0.0
    var expiry = 0.0
    fileprivate var expiryString : String?
    var payloadType: String?
    var invite : RideInvitation?
  
    var uniqueId : Double?
    var status : String = UserNotification.NOT_STATUS_OPEN
    public static let NOT_STATUS_RECEIVED = "RECEIVED"
    public static let NOT_STATUS_CLOSED = "CLOSED"
    public static let NOT_STATUS_OPEN = "OPEN"
    public static let STATUS_READ = "READ"
    
    public static let  ID  : String = "Id"
    public static let  TIME  : String = "Time"
    public static let  TYPE  : String = "Type"
    public static let  TITLE  : String = "Title"
    public static let  PRIORITY  : String = "Priority"
    public static let  MSG_CLASS_NAME  : String =  "MsgClassName"
    public static let  MSG_OBJECT_JSON  : String =  "MsgObject"
    public static let  DESCRIPTION  : String =  "Description"
    public static let  GRPNAME  : String =  "Group"
    public static let  GRPVALUE  : String =  "GroupValue"
    public static let  IS_ACTION_REQUIRED  : String =  "IsActionRequired"
    public static let  IS_ACTION_TAKEN  : String =  "IsActionTaken"
    public static let  ACTION_LABLE  : String =  "ACTION_LABLE"
    public static let  DEST_FRAGMENT  : String =  "DEST_FRAGMENT"
    public static let  NOT_GRP_ACCOUNT  : String =  "Account"
    public static let  NOT_GRP_RIDEENGINE  : String =  "Ride"
    public static let  NOT_GRP_RIDEMGMT  : String =  "Ride"
    public static let  NOT_GRP_CHAT  : String =  "GroupChat"
    public static let  NOT_USER_GRP_CHAT  : String =  "UserGroupChat"
    public static let  NOT_GRP_RIDER_RIDE  : String =  "RiderRide"
    public static let  NOT_GRP_PASSENGER_RIDE  : String =  "PassengerRide"
    public static let  NOT_GRP_USER  : String =  "user"
    public static let  UNIQUE_ID = "Unique_Id";
    public static let  STATUS = "notification_status";
    public static let  RIDE_RESCHEDULE_SUGGESTIONS = "rideRescheduleSuggestions";
    public static let  NOT_TYPE_RE_PART_LOC_UPDATE  : String =  "RE_PARTICIPANT_LOC_UPDATE"
    public static let  NOT_TYPE_RE_LOC_REQUIRED  : String =  "RE_PARTICIPANT_LOC_REQUIRED"
    public static let  NOT_TYPE_RE_RIDE_STATUS  : String =  "RE_RIDE_STATUS"
    public static let  NOT_TYPE_RE_PASSENGER_REMINDER  : String =  "RE_PASSENGER_REMINDER"
    public static let  NOT_TYPE_RE_RIDER_REMINDER  : String =  "RE_RIDER_REMINDER"
    public static let  NOT_TYPE_RM_RIDER_INVITATION  : String =  "RM_RIDER_INVITATION"
    public static let  NOT_TYPE_RM_RIDER_INVITATION_STATUS  : String =  "RM_RIDER_INVITATION_STATUS"
    public static let  NOT_TYPE_RM_PASSENGER_INVITATION  : String =  "RM_PASSENGER_INVITATION"
    public static let  NOT_TYPE_RM_PASSENGER_INVITATION_STATUS  : String =  "RM_PASSENGER_INVITATION_STATUS"
    public static let  NOT_TYPE_RM_PASSENGER_JOIN_RIDE_RIDER  : String =  "RM_PASSENGER_JOIN_RIDE_RIDER"
    public static let  NOT_TYPE_RM_PASSENGER_JOIN_RIDE_PASSENGER  : String =  "RM_PASSENGER_JOIN_RIDE_PASSENGER"
    public static let  NOT_TYPE_RM_PASSENGER_UNJOIN  : String =  "RM_PASSENGER_UNJOIN"
    public static let  NOT_TYPE_RM_RIDE_CANCELLED  : String =  "RM_RIDE_CANCELLED"
    public static let  NOT_TYPE_RM_RIDE_CANCELLED_BY_SYSTEM  : String =  "RM_RIDE_CANCELLED_BY_SYSTEM"
    public static let  NOT_TYPE_ACCOUNT_LOW_FUNDS  : String =  "ACCOUNT_LOW_FUNDS"
    public static let  NOT_TYPE_RE_RIDE_PARTICIPANT_STATUS_UPDATE  : String =  "RE_RIDE_PARTICIPANT_STATUS_UPDATE"
    public static let  NOT_TYPE_USER_MGMT_PROFILE_UPDATE  : String =  "USER_MGMT_PROFILE_UPDATE"
    public static let  NOT_TYPE_ACCOUNT_TRANSACTION  : String =  "ACCOUNT_TRANSACTION"
    public static let  NOT_TYPE_LOW_BALANCE_REMAINDER : String = "NOT_TYPE_LOW_BALANCE_REMAINDER"
    public static let  NOT_TYPE_GROUP_CHAT  : String =  "GROUP_CHAT"
    public static let  NOT_TYPE_USER_GROUP_CHAT  : String =  "USER_GROUP_CHAT"
    public static let  NOT_TYPE_PERSONAL_CHAT = "PERSONAL_CHAT"
    public static let NOT_PERSONAL_CHAT = "PersonalChat"
    public static let  NOT_TYPE_RE_PASSENGER_TO_CHECKIN_RIDE  : String =  "RE_PASSENGER_TO_START_RIDE"
    public static let  NOT_TYPE_RE_PASSENGER_TO_CHECKOUT_RIDE  : String =  "RE_PASSENGER_TO_STOP_RIDE"
    public static let  NOT_TYPE_RE_RIDER_TO_START_RIDE  : String =  "RE_RIDER_TO_START_RIDE"
    public static let  NOT_TYPE_RE_RIDER_TO_STOP_RIDE  : String =  "RE_RIDER_TO_STOP_RIDE"
    public static let  NOT_TYPE_USER_CUSTOM_NOTIFICATION  : String =  "NOT_TYPE_USER_CUSTOM_NOTIFICATION"
    public static let  NOT_TYPE_RM_RIDE_RESCHEDULED : String = "NOT_TYPE_RM_RIDE_RESCHEDULED"
    public static let  NOT_TYPE_REGULAR_PASSENGER_RIDE_INSTANCE_CREATION = "NOT_TYPE_REGULAR_PASSENGER_RIDE_INSTANCE_CREATION"
    public static let  NOT_TYPE_REGULAR_RIDER_RIDE_INSTANCE_CREATION = "NOT_TYPE_REGULAR_RIDER_RIDE_INSTANCE_CREATION"
    public static let  NOT_TYPE_REGULAR_PASSENGER_INSTANCE_CREATION = "NOT_TYPE_REGULAR_PASSENGER_INSTANCE_CREATION"
    public static let  NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_RIDER = "NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_RIDER"
    public static let  NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PASSEGER = "NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PASSEGER"
    public static let NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PAST_RIDER = "NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PAST_RIDER"
    public static let NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PAST_PASSEGER = "NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PAST_PASSEGER"
    public static let NOT_TYPE_RM_PASSENGER_JOIN_REGULAR_RIDE_PASSENGER = "NOT_TYPE_RM_PASSENGER_JOIN_REGULAR_RIDE_PASSENGER"
    public static let NOT_TYPE_RM_PASSENGER_JOIN_REGULAR_RIDE_RIDER = "NOT_TYPE_RM_PASSENGER_JOIN_REGULAR_RIDE_RIDER"
    public static let NOT_TYPE_RM_REGULAR_RIDE_REJECT = "NOT_TYPE_RM_REGULAR_RIDE_REJECT"
    public static let NOT_TYPE_REGULAR_RIDER_RIDE_REMINDER = "NOT_TYPE_REGULAR_RIDER_RIDE_REMINDER"
    public static let NOT_TYPE_REGULAR_PASSENGER_RIDE_REMINDER = "NOT_TYPE_REGULAR_PASSENGER_RIDE_REMINDER"
    public static let NOT_TYPE_RM_CONTACT_INVITATION = "NOT_TYPE_RM_CONTACT_INVITATION"
    public static let NOT_TYPE_RM_GROUP_INVITATION = "NOT_TYPE_RM_GROUP_INVITATION"
    public static let NOT_TYPE_RM_REGULAR_PASSENGER_UNJOIN = "RM_REGULAR_PASSENGER_UNJOIN"
    public static let NOT_TYPE_RM_REGULAR_RIDE_CANCELLED = "RM_REGULAR_RIDE_CANCELLED"
    public static let NOT_TYPE_GROUP_MATCH_NOTIFICATION_TO_USER = "NOT_TYPE_GROUP_MATCH_NOTIFICATION_TO_USER"
    public static let NOT_TYPE_RM_RIDER_REJECT_REGULAR_RIDE = "NOT_TYPE_RM_RIDER_REJECT_REGULAR_RIDE"
    public static let NOT_TYPE_RM_PASSENGER_REJECT_REGULAR_RIDE = "NOT_TYPE_RM_PASSENGER_REJECT_REGULAR_RIDE";
    public static let NOT_TYPE_RIDER_TO_CREATE_REGULAR_RIDE = "NOT_TYPE_RIDER_TO_CREATE_REGULAR_RIDE"
    public static let NOT_TYPE_CREATE_PASSENGER_RIDE_TO_RIDER = "NOT_TYPE_CREATE_PASSENGER_RIDE_TO_RIDER"
    public static let NOT_TYPE_PASSENGER_TO_CREATE_REGULAR_RIDE = "NOT_TYPE_PASSENGER_TO_CREATE_REGULAR_RIDE"
    public static let NOT_TYPE_CREATE_RIDE_REMAINDER = "NOT_TYPE_CREATE_RIDE_REMAINDER"
    public static let NOT_TYPE_CREATE_FIRST_RIDE_REMAINDER = "NOT_TYPE_CREATE_FIRST_RIDE_REMAINDER"
    public static let NOT_TYPE_RIDER_TO_START_RIDE_VOICE_NOTIFICATION = "RIDER_TO_START_RIDE_VOICE_NOTIFICATION"
    public static let  NOT_TYPE_RIDER_PICKED_UP_PASSENGER = "NOT_TYPE_RIDER_PICKEDUP_PASSENGER"
    public static let  NOT_TYPE_SYSTEM_STARTED_PASSENGER_RIDE = "NOT_TYPE_SYSTEM_STARTED_PASSENGER_RIDE"
    public static let NOT_TYPE_RM_INVITATION_TO_OLD_USER = "NOT_TYPE_RM_INVITATION_TO_OLD_USER"
    public static let NOT_TYPE_RE_RIDE_DELAYED_SECOND_ALERT_TO_RIDER = "RE_RIDE_DELAYED_SECOND_ALERT_TO_RIDER"
    public static let NOT_TYPE_RE_PASSENGER_TO_CHECKIN_RESEND_ALERT_RIDE = "RE_PASSENGER_TO_CHECKIN_RESEND_ALERT_RIDE";
    public static let NOT_TYPE_RM_RIDE_FARE_CHNG_INVTN_TO_MDRTR = "RM_RIDE_FARE_CHNG_INVTN_TO_MDRTR"

    public static let NOT_TYPE_USER_TO_CREATE_RIDE = "NOT_TYPE_USER_TO_CREATE_RIDE";
    public static let NOT_TYPE_MQTT_MESSAGE = "NOT_TYPE_MQTT_MESSAGE"
    public static let MQTT_TOPIC_NAME = "MQTT_TOPIC_NAME"
    public static let NOT_TYPE_RM_RIDER_INVITATION_WITH_REQUESTED_FARE = "RM_RIDER_INVITATION_REQ_FARE"
    public static let NOT_TYPE_EMAIL_VERIFICATION_EXIPRED_REMINDER = "EMAIL_VERIFICATION_EXIPRED_REMINDER"
    public static let NOT_TYPE_RE_RIDER_ROUTE_DEVIATION_ALERT = "NOT_TYPE_RE_RIDER_ROUTE_DEVIATION_ALERT";
    public static let NOT_TYPE_RE_PASSENGER_EMERGENCY_INITIATED_DUE_TO_NOT_CHECKOUT_RIDE = "RE_EMER_INITATE_FOR_PASS_NOT_CHECKED_OUT"
    public static let NOT_TYPE_AMOUNT_TRANSFER_REQUEST_REJECT = "AMOUNT_TRANSFER_REQUEST_REJECT"
    public static let NOT_TYPE_REFUND_REQUEST_REJECT = "REFUND_REQUEST_REJECT";
    public static let NOT_TYPE_RE_RIDER_ROUTE_DEVIATION_ACK = "NOT_TYPE_RE_RIDER_ROUTE_DEVIATION_ACK"
    public static let NOT_TYPE_AMOUNT_TRANSFER_REQUEST = "AMOUNT_TRANSFER_REQUEST"
    public static let NOT_TYPE_RM_PASSENGER_CHANGE_PICKUP_DROP_RIDER  : String = "RM_PASSENGER_CHANGE_PICKUP_DROP_RIDER"
    public static let NOT_TYPE_RE_ENABLE_LOCATION_REMINDER  : String = "RE_RIDER_LOCATION_ENABLE_REMINDER"
    public static let NOT_TYPE_RE_PASSENGER_REMINDER_RIDE_MATCHER = "RE_PASSENGER_REMINDER_RIDE_MATCHER"
    public static let NOT_TYPE_RE_RIDER_TO_START_RIDE_REMAINDER = "RE_RIDER_TO_START_RIDE_REMAINDER"
    public static let NOT_TYPE_USER_GROUP_JOIN_REQUEST_TO_ADMIN = "NOT_TYPE_USER_GROUP_JOIN_REQUEST_TO_ADMIN"
    public static let NOT_TYPE_USER_GROUP_JOIN = "NOT_TYPE_USER_GROUP_JOIN"
    public static let NOT_TYPE_USER_GROUP_REMOVE = "NOT_TYPE_USER_GROUP_REMOVE"
    public static let NOT_TYPE_USER_GROUP_REJECT = "NOT_TYPE_USER_GROUP_REJECT"
    public static let NOT_TYPE_RE_RIDER_PICKUP_PASSENGER = "RE_RIDER_PICKUP_PASSENGER"
    public static let NOT_TYPE_PROFILE_VERIFICATION_CANCELLATION = "NOT_TYPE_PROFILE_VERIFICATION_CANCELLATION_FOR_INAPPROPRIATE_USER"
    public static let NOT_GRP_EMAIL_VERIFY = "EMAIL_VERIFY"
    public static let NOT_TYPE_IMAGE_NOTIFICATION = "IMAGE_NOTIFICATION"
    public static let NOT_TYPE_LINKED_WALLET_EXPIRED = "NOT_TYPE_LINKED_WALLET_EXPIRED"
    public static let NOT_TYPE_RIDE_PASS_EXPIRE = "NOT_TYPE_RIDE_PASS_EXPIRE"
    public static let NOT_TYPE_SUBSCRIPTION_REMINDER = "NOT_TYPE_SUBSCRIPTION_REMINDER"
    public static let NOT_TYPE_REFUND = "REFUND"
    public static let NOT_STATUS_UPDATE = "StatusUpdate"
    public static let NOT_TYPE_MESSAGE_TO_USERS = "NOT_TYPE_MESSAGE_TO_USERS"
    public static let NOT_TYPE_FIREBASE_NOT = "Firebase"
    public static let NOT_TYPE_UPDATE_USER_APP_RETAINED_TIME = "NOT_TYPE_UPDATE_USER_APP_RETAINED_TIME"
    public static let NOT_TYPE_OFFER_EXPIRE_REMINDER = "OFFER_EXPIRE_REMINDER"
    public static let NOT_TYPE_OFFER_APPLIED = "OFFER_APPLIED"
    public static let NOT_TYPE_HIGH_BALANCE_REMAINDER = "NOT_TYPE_HIGH_BALANCE_REMAINDER"
    public static let RM_RIDE_CANCELLATION_SUGGESTION = "RM_RIDE_CANCELLATION_SUGGESTION"
    public static let NOT_TYPE_RESCHEDULE_RIDE_TO_PASSEGER = "NOT_TYPE_RESCHEDULE_RIDE_TO_PASSEGER"
    public static let NOT_TYPE_RESCHEDULE_RIDE_TO_RIDER = "NOT_TYPE_RESCHEDULE_RIDE_TO_RIDER"
    public static let NOT_TYPE_PENDING_INVITES_REMINDER_TO_ASSURED_RIDER = "NOT_TYPE_PENDING_INVITES_REMINDER_TO_ASSURED_RIDER"
    public static let NOT_TYPE_RIDER_INITIATE_PENDING_BILL_FOR_RIDE = "NOT_TYPE_RIDER_INITIATE_PENDING_BILL_FOR_RIDE"
    public static let NOT_TYPE_RM_RIDE_INVITE_REJECT_BY_MODERATOR  = "RM_RIDE_INVITE_REJECT_BY_MODERATOR"
    public static let NOT_TYPE_RM_RIDER_INVITATION_TO_MODERATOR = "RM_RIDER_INVITATION_TO_MODERATOR"
    public static let NOT_TYPE_RM_RIDER_INVITATION_WITH_REQUESTED_FARE_TO_MODERATOR = "RM_RIDE_FARE_CHNG_INVTN_TO_MDRTR"
    public static let NOT_TYPE_INACTIVE_USERS_WITH_REGULAR_RIDE = "NOT_TYPE_INACTIVE_USERS_WITH_REGULAR_RIDE"
    public static let NOT_TYPE_REACHED_NEXT_LEVEL_IN_REFERRAL = "NOT_TYPE_REACHED_NEXT_LEVEL_IN_REFERRAL"
    public static let NOT_TYPE_REFUND_REQUEST = "REFUND_REQUEST"
    public static let NOT_TYPE_ENDORSEMENT_REQUEST = "NOT_TYPE_ENDORSEMENT_REQUEST"
    public static let NOT_TYPE_ENDORSEMENT_ACCEPT = "NOT_TYPE_ENDORSEMENT_ACCEPT"
    public static let NOT_TYPE_VERIFICATION = "NOT_TYPE_VERIFICATION" // When company id verification or mail verification status changed
    public static let NOT_TYPE_VERIFICATION_PENDING = "NOT_TYPE_VERIFICATION_PENDING" // remind when verified email not an organisation email or company not added in our db but otp verified
    public static let NOT_TYPE_CANCEL_PARENT_RELAY_RIDE = "NOT_TYPE_CANCEL_PARENT_RELAY_RIDE"
    public static let NOT_TYPE_CANCEL_RELAY_RIDE_LEGS = "NOT_TYPE_CANCEL_RELAY_RIDE_LEGS"
    public static let NOT_TYPE_RIDE_MATCHES_FOUND_NOTIFICATION_TO_PASSEGER = "NOT_TYPE_RIDE_MATCHES_FOUND_NOTIFICATION_TO_PASSEGER"
    public static let NOT_TYPE_RIDE_MATCHES_FOUND_NOTIFICATION_TO_RIDER = "NOT_TYPE_RIDE_MATCHES_FOUND_NOTIFICATION_TO_RIDER"
    
    //MARK: TAXI
    static let NOT_TYPE_TAXI_POOL_YET_TO_CONFIRM = "NOT_TYPE_TAXI_POOL_YET_TO_CONFIRM"
    static let NOT_TYPE_TAXI_POOL_CONFIRM = "NOT_TYPE_TAXI_POOL_CONFIRM"
    static let NOT_TYPE_TAXI_ALLOTTED = "NOT_TYPE_TAXI_ALLOTTED"
    static let NOT_TYPE_TAXI_STARTED = "NOT_TYPE_TAXI_STARTED"
    static let NOT_TYPE_TAXI_DELAYED = "NOT_TYPE_TAXI_DELAYED"
    static let NOT_TYPE_TAXI_NOT_ALLOTED = "NOT_TYPE_TAXI_NOT_ALLOTED"
    static let NOT_TYPE_TAXI_POOL_USER_UNJOIN = "NOT_TYPE_TAXI_POOL_USER_UNJOIN"
    static let NOT_TYPE_TAXI_POOL_NOT_CONFIRMED = "NOT_TYPE_TAXI_POOL_NOT_CONFIRMED"
    static let NOT_TYPE_TAXI_COMPLETED = "NOT_TYPE_TAXI_COMPLETED"
    static let NOT_GRP_TAXI_POOL = "NOT_GRP_TAXI_POOL"
    static let NOT_JOIN_TAXI_POOL = "NOT_JOIN_TAXI_POOL"
    static let NOT_TAXI_INVITE = "NOT_TAXI_INVITE"
    static let NOT_TYPE_DRIVER_REACHED_TO_PICKUP = "NOT_TYPE_DRIVER_REACHED_TO_PICKUP"
    static let NOT_TYPE_TAXI_DRIVER_CANCELLED = "NOT_TYPE_TAXI_DRIVER_CANCELLED"
    static let NOT_TYPE_TAXI_OPERTOR_CANCELLED_RIDE = "NOT_TYPE_TAXI_OPERTOR_CANCELLED_RIDE"
    static let NOT_TYPE_QT_FEEDBACK_REMINDER = "NOT_TYPE_QT_FEEDBACK_REMINDER"
    static let NOT_GRP_QT_TAXI_BOOKING_DETAILS_UPDATED_NOTIFICATION = "NOT_TYPE_QT_TAXI_BOOKING_DETAILS_UPDATED_NOTIFICATION"
    static let NOT_TYPE_NPS_REVIEW_REMINDER = "NOT_TYPE_NPS_REVIEW_REMINDER"
    static let NOT_TYPE_QT_END_ODOMETER_DETAILS = "NOT_TYPE_QT_END_ODOMETER_DETAILS"
    static let NOT_TYPE_QT_START_ODOMETER_DETAILS = "NOT_TYPE_QT_START_ODOMETER_DETAILS"
    
    static let NOT_TYPE_QT_ADDITIONAL_PAYMENT_DETAILS_REJECTED_TO_CUSTOMER = "NOT_TYPE_QT_ADDITIONAL_PAYMENT_DETAILS_REJECTED_TO_CUSTOMER"
    static let NOT_TYPE_QT_EXTRA_FARE_DETAILS_ADDED_TO_CUSTOMER = "NOT_TYPE_QT_EXTRA_FARE_DETAILS_ADDED_TO_CUSTOMER"
    static let NOT_TYPE_QT_EXTRA_FARE_DETAILS_CANCELLED_TO_CUSTOMER = "NOT_TYPE_QT_EXTRA_FARE_DETAILS_CANCELLED_TO_CUSTOMER"
    static let NOT_TYPE_QT_FARE_CHANGE_BY_OPERATOR_TO_CUSTOMER = "NOT_TYPE_QT_FARE_CHANGE_BY_OPERATOR_TO_CUSTOMER"
    static let NOT_TYPE_REFUND_INITIATED = "NOT_TYPE_REFUND_INITIATED"
    static let NOT_TYPE_QT_RISKY_RIDE_NOTIFICATION = "NOT_TYPE_QT_RISKY_RIDE_NOTIFICATION"
    static let NOT_TYPE_RM_RIDER_ACCEPTED_PAYMENT_PENDING  = "RM_RIDER_ACCEPTED_PAYMENT_PENDING"
    
    //MARK: Quickshare Notifications
    //seller
    public static let NOT_TYPE_QS_PRODUCT_LIVE = "NOT_TYPE_QS_PRODUCT_LIVE"
    public static let NOT_TYPE_QS_ORDER_RECEIVED = "NOT_TYPE_QS_ORDER_RECEIVED"
    public static let NOT_TYPE_QS_PAYMENT_RECEIVED = "NOT_TYPE_QS_PAYMENT_RECEIVED"
    public static let NOT_TYPE_QS_PRODUCT_RETURN_REMAINDER_SELLER = "NOT_TYPE_QS_PRODUCT_RETURN_REMAINDER_SELLER"
    public static let NOT_TYPE_QS_PRODUCT_REJECTED = "NOT_TYPE_QS_PRODUCT_REJECTED"
    public static let NOT_TYPE_QS_PICK_UP_REMAINDER_SELLER = "NOT_TYPE_QS_PICK_UP_REMAINDER_SELLER"
    public static let NOT_TYPE_QS_PRODUCT_COMMENT_TO_SELLER = "NOT_TYPE_QS_PRODUCT_COMMENT_TO_SELLER"
    public static let NOT_TYPE_QS_ORDER_COMPLETED_TO_SELLER = "NOT_TYPE_QS_ORDER_COMPLETED_TO_SELLER"
    public static let NOT_TYPE_QS_PRODUCT_REQUEST_COMMENT_TO_SELLER = "NOT_TYPE_QS_PRODUCT_REQUEST_COMMENT_TO_SELLER"
    
    //buyer
    public static let NOT_TYPE_QS_REQUEST_ACCEPTED = "NOT_TYPE_QS_REQUEST_ACCEPTED"
    public static let NOT_TYPE_QS_PRODUCT_DELIVERED = "NOT_TYPE_QS_PRODUCT_DELIVERED"
    public static let NOT_TYPE_QS_PRODUCT_RETURN_REMAINDER_BUYER = "NOT_TYPE_QS_PRODUCT_RETURN_REMAINDER_BUYER"
    public static let NOT_TYPE_QS_REQUEST_REJECTED = "NOT_TYPE_QS_REQUEST_REJECTED"
    public static let NOT_TYPE_QS_PRODUCT_DELETED = "NOT_TYPE_QS_PRODUCT_DELETED"
    public static let NOT_TYPE_QS_NEW_PRODUCT_FOUND = "NOT_TYPE_QS_NEW_PRODUCT_FOUND"
    public static let NOT_TYPE_QS_PRODUCT_COMMENT_TO_BUYER = "NOT_TYPE_QS_PRODUCT_COMMENT_TO_BUYER"
    public static let NOT_TYPE_QS_ORDER_COMPLETED_TO_BUYER = "NOT_TYPE_QS_ORDER_COMPLETED_TO_BUYER"
    public static let NOT_TYPE_QS_PRODUCT_REQUEST_COMMENT_TO_BUYER = "NOT_TYPE_QS_PRODUCT_REQUEST_COMMENT_TO_BUYER"
    
    
    //MARK: Quickjobs Notifications
    public static let JOB_REFERRER = "JOB_REFERRER"
    public static let JOB_SEEKER = "JOB_SEEKER"
    
    //MARK: TAXIPOOL
    static let NOT_TAXI_INVITE_BY_CONTACT = "NOT_TAXI_INVITE_BY_CONTACT"
    static let NOT_TAXI_INVITE_REJECT = "NOT_TAXI_INVITE_REJECT"
    
    
    public static let PRIORITY_MIN : Int = -2
    public static let PRIORITY_LOW : Int = -1
    public static let PRIORITY_HIGH : Int = 1
    public static let PRIORITY_MAX : Int = 2
    public static let DEFAULT_EXPIRY_TIME_FOR_NOTIFICATION = 6

    public static let USER_NOTIFICATION_CLASS_NAME : String = "com.disha.quickride.domain.model.notification.UserNotification"
    
    init(){
        
    }
    public init(type : String,title : String,priority: Int,description: String,  groupName: String,  groupValue: String, msgClassName: String, msgObject: String,isActionRequired: Bool,iconUri: String?,isAckRequired: Bool,backUpMsg: String?,sendFrom : Double){
        self.type = type
        self.title = title
        self.priority = priority
        self.description = description
        self.msgClassName = msgClassName
        self.msgObjectJson = msgObject
        self.groupName = groupName
        self.groupValue = groupValue
        self.isActionRequired = isActionRequired
        self.iconUri = iconUri
        self.isAckRequired = isAckRequired
        self.sendFrom = sendFrom
    }
    
  public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        notificationId <- map["id"]
        time <- map["time"]
        iconUri <- map["iconUri"]
        type <- map["type"]
        priority <- map["priority"]
        msgClassName  <- map["msgClassName"]
        msgObjectJson  <- map["msgObjectJson"]
        groupName <- map["groupName"]
        groupValue <- map["groupValue"]
        title <- map["title"]
        description <- map["description"]
        isActionRequired <- map["isActionRequired"]
        isActionTaken <- map["isActionTaken"]
        isBigPictureRequired <- map["isBigPictureRequired"]
        uniqueId <- map["uniqueId"]
        isAckRequired <- map["isAckRequired"]
        status <- map["status"]
        self.uniqueID <- map["uniqueID"]
        rideStatus <- map["rideStatus"]
        self.sendFrom <- map["sendFrom"]
        expiry <- map["expiryTime"]
        if expiry == 0{
             expiryString <- map["expiryTime"]
            if let expiryTime = AppUtil.createNSDate(dateString: expiryString)?.getTimeStamp(){
                self.expiry = expiryTime
            }
           
        }
        payloadType <- map["payloadType"]
        sendTo <- map["sendTo"]
        invite <- map["invite"]
    }
    
    func isNotificationExpired() -> Bool{
        if self.status == UserNotification.NOT_STATUS_CLOSED{
            return true
        }
        if self.expiry != 0 && Double(self.expiry) < NSDate().timeIntervalSince1970*1000{
            return true
        }
        
        if Double(self.time!)  < NSDate().addHours(hoursToAdd: -UserNotification.DEFAULT_EXPIRY_TIME_FOR_NOTIFICATION).timeIntervalSince1970
        {
            return true
        }
        return false
    }
    
}
