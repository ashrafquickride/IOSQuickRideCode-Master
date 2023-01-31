//
//  RiderRejectRegularRideNotificationToPassengerHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 07/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RiderRejectRegularRideNotificationToPassengerHandler: RideNotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let regularPassengerRide = self.getPassengerRideObject (userNotification: clientNotification) else {
                return handler(false)
            }
            return handler(regularPassengerRide.status == Ride.RIDE_STATUS_REQUESTED)
        }
        
    }
    private func getPassengerRideObject (userNotification : UserNotification) -> RegularPassengerRide? {
      AppDelegate.getAppDelegate().log.debug("getPassengerRideObject()")
        var passengerRideObj: RegularPassengerRide?
        let notificationDynamicParams : String? = userNotification.msgObjectJson
        if (notificationDynamicParams != nil) {
            let notificationDynamicDataObj = Mapper<RiderRejectRegularRideNotificationDynamicData>().map(JSONString: notificationDynamicParams!)! as RiderRejectRegularRideNotificationDynamicData
            passengerRideObj = MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId: Double(notificationDynamicDataObj.passengerRideId!)!)
        }
        return passengerRideObj
    }
    
    override func handlePositiveAction(userNotification:UserNotification, viewController : UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
      
        let passengerRide = getPassengerRideObject (userNotification: userNotification)
        if (passengerRide != nil) {
          let recurringRideViewController  = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.recurringRideViewController) as! RecurringRideViewController
            recurringRideViewController.initializeDataBeforePresentingView(ride : passengerRide!, isFromRecurringRideCreation: false)
            
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: recurringRideViewController, animated: false)
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handleTap()")

        handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
}

public class RiderRejectRegularRideNotificationDynamicData : NSObject,Mappable {
    var passengerRideId : String?
    var riderUserId : String?
    var riderGender : String?
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        passengerRideId <- map[Ride.FLD_ID]
        riderUserId <- map["phone"]
        riderGender <- map["gender"]
    }
    public override var description: String {
        return "passengerRideId: \(String(describing: self.passengerRideId))," + "riderUserId: \(String(describing: self.riderUserId))," + "riderGender: \(String(describing: self.riderGender)),"
    }
}
