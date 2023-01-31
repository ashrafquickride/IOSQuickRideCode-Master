//
//  RiderPickedUpPassengerNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 06/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RiderPickedUpPassengerNotificationHandler: RideNotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty,
                  let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance(), let rideId = Double(groupValue) else {
                return handler(false)
            }
            
            if let _  = myActiveRidesCache.getPassengerRide(passengerRideId: rideId){
                return handler(true)
            }
            return handler(false)
        }
        
    }
    

    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handleTap(userNotification: userNotification, viewController: viewController)
        let  rideData = Mapper<RideData>().map(JSONString: userNotification.msgObjectJson!)
        if rideData == nil{
            return
        }
        let myActiveRidesCache = MyActiveRidesCache.singleCacheInstance
        if myActiveRidesCache == nil {
            return
        }
        let passengerRide = myActiveRidesCache!.getPassengerRide(passengerRideId: Double(rideData!.rideId!)!)
        if passengerRide == nil || passengerRide?.rideNotes == nil{
            return
        }
        let riderRideId = passengerRide!.riderRideId
        if riderRideId == 0{
            return
        }
        super.navigateToLiveRideView(riderRideId: riderRideId)
    }
    class RideData :Mappable{
        var rideId : String?
        var rideType : String?
        required init?(map: Map) {
            
        }
        func mapping(map: Map) {
            rideId <- map["id"]
            rideType <- map["rideType"]
        }
    }
}
