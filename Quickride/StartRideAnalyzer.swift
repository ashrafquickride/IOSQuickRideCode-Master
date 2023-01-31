//
//  StartRideAnalyzer.swift
//  Quickride
//
//  Created by QuickRideMac on 25/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class StartRideAnalyzer {
    
    func analyzeRides()
    {
      AppDelegate.getAppDelegate().log.debug("analyzeRides()")
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache == nil{
            return
        }
        let currentDate = NSDate()
        analyzeRiderRides(myActiveRidesCache: myActiveRidesCache!,currentDate: currentDate);
        analyzePassengerRides(myActiveRidesCache: myActiveRidesCache!,currentDate: currentDate);
    }
    
    func analyzeRiderRides( myActiveRidesCache : MyActiveRidesCache, currentDate : NSDate)
    {
      AppDelegate.getAppDelegate().log.debug("analyzeRiderRides()")
        let riderRideList = myActiveRidesCache.getActiveRiderRides().values
        for riderRide in riderRideList{
            if Ride.RIDE_STATUS_SCHEDULED == riderRide.status || Ride.RIDE_STATUS_DELAYED == riderRide.status && riderRide.noOfPassengers > 0 && riderRide.startTime <= currentDate.timeIntervalSince1970*1000{
                sendNotificationToUserToStartRide(ride: riderRide);
            }
        }
    }
    
    func sendNotificationToUserToStartRide(ride : RiderRide){
      AppDelegate.getAppDelegate().log.debug("sendNotificationToUserToStartRide()")
        var notificationDescription = Strings.ride_scheduled_from+ride.startAddress+" "+Strings.to+" "+ride.endAddress
        
        notificationDescription = notificationDescription+" "+Strings.at+" "+DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aaa)!
        notificationDescription = notificationDescription+Strings.remind_to_start_ontime
        
        let notificationMsg = UserNotification(type : UserNotification.NOT_TYPE_RIDER_TO_START_RIDE_VOICE_NOTIFICATION,title : Strings.start_ride,priority: UserNotification.PRIORITY_MAX,description: notificationDescription,  groupName: UserNotification.NOT_GRP_RIDER_RIDE,  groupValue: StringUtils.getStringFromDouble(decimalNumber : ride.rideId), msgClassName: "String.class", msgObject: StringUtils.getStringFromDouble(decimalNumber : ride.rideId),isActionRequired: true,iconUri: nil,isAckRequired: false,backUpMsg: nil,sendFrom : ride.userId)
        
        
        notificationMsg.uniqueId = NSDate().timeIntervalSince1970*1000
        let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notificationMsg)
        if notificationHandler != nil{
            notificationHandler!.handleNewUserNotification(clientNotification: notificationMsg)
        }
    }
    
    func analyzePassengerRides( myActiveRidesCache : MyActiveRidesCache, currentDate : NSDate){
      AppDelegate.getAppDelegate().log.debug("analyzePassengerRides()")
        let passengerRideList = myActiveRidesCache.getActivePassengerRides().values
        for passengerRide in passengerRideList{
            var pickUpTime = passengerRide.pickupTime
            if pickUpTime == 0.0{
                pickUpTime = passengerRide.startTime
            }
            if Ride.RIDE_STATUS_SCHEDULED == passengerRide.status || Ride.RIDE_STATUS_DELAYED == passengerRide.status && pickUpTime <= currentDate.timeIntervalSince1970*1000{
                getRiderStatusOfRideAndSendNotification(passengerRide: passengerRide)
            }
        }
    }
    
    func getRiderStatusOfRideAndSendNotification(passengerRide: PassengerRide){
        AppDelegate.getAppDelegate().log.debug("getRiderStatusOfRideAndSendNotification()")
        RideServicesClient.getRideStatus(rideId: passengerRide.riderRideId, rideType: Ride.RIDER_RIDE) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let status = responseObject!["resultData"]
                if status != nil && Ride.RIDE_STATUS_STARTED == status as! String{
                    self.sendNotificationToUserToCheckInRide(ride: passengerRide);
                }
            }
        }
    }
    func sendNotificationToUserToCheckInRide(ride : PassengerRide){
      AppDelegate.getAppDelegate().log.debug("sendNotificationToUserToCheckInRide()")
        let notificationDescription = Strings.rider_started_ride_please_checkin
        let clientNotificationData = UserNotification(type : UserNotification.NOT_TYPE_RE_PASSENGER_TO_CHECKIN_RIDE,title : Strings.checkin_ride,priority: UserNotification.PRIORITY_MAX,description: notificationDescription,  groupName: UserNotification.NOT_GRP_PASSENGER_RIDE,  groupValue: StringUtils.getStringFromDouble(decimalNumber : ride.rideId), msgClassName: "String.class", msgObject: StringUtils.getStringFromDouble(decimalNumber: ride.rideId),isActionRequired: true,iconUri: nil,isAckRequired: false,backUpMsg: nil,sendFrom : ride.riderId)
        clientNotificationData.uniqueId = NSDate().timeIntervalSince1970*1000
        let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: clientNotificationData)
        if notificationHandler != nil{
            notificationHandler!.handleNewUserNotification(clientNotification: clientNotificationData)
        }
        
    }
    
}
