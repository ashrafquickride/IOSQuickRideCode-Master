//
//  UserNotificationSetting.swift
//  Quickride
//
//  Created by KNM Rao on 12/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
public class UserNotificationSetting : NSObject, Mappable
{
  var userId : Double?
  var rideMatch : Bool = false
  var rideStatus : Bool = false
  var regularRideNotification : Bool = false
  var rideCreated : Bool = false
  var routeGroupSuggestions : Bool = false
  var reminderToCreateRide : Bool = false
  var conversationMessages : Bool = false
  var walletUpdates : Bool = false
  var playVoiceForNotifications = false
  var dontDisturbFromTime : String = "2200"
  var dontDisturbToTime : String = "0600"
  var locationUpdateSuggestions = true
  var rideRescheduleSuggestions = true
    
  static let RIDE_MATCH : String = "rideMatch"
  static let RIDE_STATUS : String = "rideStatus"
  static let REGULAR_RIDE_NOTIFICATION : String = "regularRideNotification"
  static let RIDE_CREATED : String = "rideCreated"
  static let ROUTE_GROUP_SUGGESTIONS : String = "routeGroupSuggestions"
  static let REMINDER_TO_CREATE_RIDE : String = "reminderToCreateRide"
  static let CONVERSATION_MESSAGES : String = "conversationMessages"
  static let WALLET_UPDATES : String = "walletUpdates"
  static let DONT_DISTURB_FROM_TIME : String = "dontDisturbFromTime"
  static let DONT_DISTURB_TO_TIME : String = "dontDisturbToTime"
  static let LOCATION_UPDATE_SUGGESTIONS = "locationUpdateSuggestions"
  static let RIDE_RESCHEDULE_SUGGESTIONS = "rideRescheduleSuggestions"

    
    
    init(userId : Double,rideMatch : Bool,rideStatus : Bool,regularRideNotification : Bool,rideCreated : Bool,reminderToCreateRide : Bool,routeGroupSuggestions : Bool, conversationMessages : Bool,walletUpdates : Bool,playVoiceForNotifications : Bool,dontDisturbFromTime : String,dontDisturbToTime : String, locationUpdateSuggestions: Bool, rideRescheduleSuggestions: Bool) {
        self.userId = userId
        self.conversationMessages = conversationMessages
        self.regularRideNotification = regularRideNotification
        self.reminderToCreateRide = reminderToCreateRide
        self.rideCreated = rideCreated
        self.rideMatch = rideMatch
        self.rideStatus = rideStatus
        self.routeGroupSuggestions = routeGroupSuggestions
        self.walletUpdates = walletUpdates
        self.dontDisturbFromTime = dontDisturbFromTime
        self.dontDisturbToTime = dontDisturbToTime
        self.playVoiceForNotifications = playVoiceForNotifications
        self.locationUpdateSuggestions = locationUpdateSuggestions
        self.rideRescheduleSuggestions = rideRescheduleSuggestions
  }
  override init() {
    
  }
  public required init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    self.userId <- map["userId"]
    self.rideMatch <- map["rideMatch"]
    self.rideStatus <- map["rideStatus"]
    self.rideCreated <- map["rideCreated"]
    self.routeGroupSuggestions <- map["routeGroupSuggestions"]
    self.reminderToCreateRide <- map["reminderToCreateRide"]
    self.conversationMessages <- map["conversationMessages"]
    self.regularRideNotification <- map["regularRideNotification"]
    self.walletUpdates <- map["walletUpdates"]
    self.dontDisturbFromTime <- map["dontDisturbFromTime"]
    self.dontDisturbToTime <- map["dontDisturbToTime"]
    self.playVoiceForNotifications <- map["playVoiceForNotifications"]
    self.locationUpdateSuggestions <- map["locationUpdateSuggestions"]
    self.rideRescheduleSuggestions <- map["rideRescheduleSuggestions"]
  }
  
  func getParams() -> [String : String] {
    AppDelegate.getAppDelegate().log.debug("getParams()")
    var params : [String : String] = [String : String]()
    params["phone"] = StringUtils.getStringFromDouble(decimalNumber : self.userId!)
    params["rideMatch"] = String(self.rideMatch)
    params["rideStatus"] =  String(self.rideStatus)
    params["rideCreated"] = String(self.rideCreated)
    params["routeGroupSuggestions"] = String(self.routeGroupSuggestions)
    params["reminderToCreateRide"] = String(self.reminderToCreateRide)
    params["conversationMessages"] = String(self.conversationMessages)
    params["regularRideNotification"] = String(self.regularRideNotification)
    params["walletUpdates"] = String(self.walletUpdates)
    params["walletUpdates"] = String(self.walletUpdates)
    params["playVoiceForNotifications"] = String(self.playVoiceForNotifications)
    let fromTime = AppUtil.getTimeAndDateFromTimeStamp(date: DateUtils.getDateTimeInUTC(date: DateUtils.getDateFromString(date: dontDisturbFromTime, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), format: DateUtils.DATE_FORMAT_HH_mm_ss)
    params["dontDisturbFromTime"] = DateUtils.getDateStringFromString(date: fromTime, requiredFormat: DateUtils.TIME_FORMAT_HHmm, currentFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
    let toTime = AppUtil.getTimeAndDateFromTimeStamp(date: DateUtils.getDateTimeInUTC(date: DateUtils.getDateFromString(date: dontDisturbToTime, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), format: DateUtils.DATE_FORMAT_HH_mm_ss)
    params["dontDisturbToTime"] = DateUtils.getDateStringFromString(date: toTime, requiredFormat: DateUtils.TIME_FORMAT_HHmm, currentFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
    params["locationUpdateSuggestions"] = String(locationUpdateSuggestions)
    params["rideRescheduleSuggestions"] = String(rideRescheduleSuggestions)
    return params
  }
  func isNotificationAllowedPeriod(date :NSDate) -> Bool{
    var fromTime = DateUtils.getDateFromString(date: dontDisturbFromTime, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
    
    fromTime = getDateWithHoursAndMins(date: fromTime!)
    var toTime = DateUtils.getDateFromString(date: dontDisturbToTime, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
    toTime = getDateWithHoursAndMins(date: toTime!)
    if date.isGreaterThanDate(dateToCompare: fromTime!) && date.isGreaterThanDate(dateToCompare: toTime!){
      return false
    }else{
      return true
    }
  }
  func getDateWithHoursAndMins(date : NSDate) -> NSDate{
    let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
    var currentDateComponents = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: date as Date)
    let requireDateComponents = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: date as Date)
    
    // Change the time to 9:30:00 in your locale
    currentDateComponents.hour = requireDateComponents.hour
    currentDateComponents.minute = requireDateComponents.minute
    currentDateComponents.second = requireDateComponents.second
    return date
  }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "rideMatch: \(String(describing: self.rideMatch))," + " rideStatus: \( String(describing: self.rideStatus))," + " regularRideNotification: \(String(describing: self.regularRideNotification))," + " rideCreated: \(String(describing: self.rideCreated)),"
            + " routeGroupSuggestions: \(self.routeGroupSuggestions)," + "rideCreated: \(String(describing: self.rideCreated))," + "routeGroupSuggestions:\(self.routeGroupSuggestions)," + "reminderToCreateRide:\(self.reminderToCreateRide)," + "conversationMessages:\(String(describing: self.conversationMessages))," + "playVoiceForNotifications:\(String(describing: self.playVoiceForNotifications))," + "dontDisturbFromTime: \(String(describing: self.dontDisturbFromTime))," + "dontDisturbToTime: \( String(describing: self.dontDisturbToTime))," + "locationUpdateSuggestions: \(String(describing: self.locationUpdateSuggestions))," + "rideRescheduleSuggestions: \( String(describing: self.rideRescheduleSuggestions)),"
    }
}
