//
//  PassengerJoinedRegularRideGotCancelledHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 09/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class PassengerJoinedRegularRideGotCancelledHandler: RideNotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty, let rideId = Double(groupValue) else {
                return handler(false)
            }
            if let regularPassengerRide =  MyRegularRidesCache.getInstance().getRegularPassengerRideConnectedToRegularRiderRideId(riderRideId: rideId) {
                return handler(true)
            }else if let regularPassengerRide =  MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId: rideId){
                return handler(true)
            }
            return handler(false)
        }
        
    }


    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handleTap()")
        let riderRideId = self.getRegularRiderRideId(userNotification : userNotification)
        
        var regularPassengerRide =  MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId: riderRideId!)
        if regularPassengerRide == nil {
            regularPassengerRide = MyRegularRidesCache.getInstance().getRegularPassengerRideConnectedToRegularRiderRideId(riderRideId: riderRideId!)
        }
        if regularPassengerRide == nil {
            return
        }
        let recurringRideViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.recurringRideViewController) as! RecurringRideViewController
        
        recurringRideViewController.initializeDataBeforePresentingView(ride : regularPassengerRide!, isFromRecurringRideCreation: false)
        
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: recurringRideViewController, animated: false)
        
    }
    private func getRegularRiderRideId (userNotification : UserNotification) -> Double? {
      AppDelegate.getAppDelegate().log.debug("getRegularRiderRideId()")
        var riderRideId: Double?
        let notificationDynamicParams : String? = userNotification.msgObjectJson
        if (notificationDynamicParams != nil) {
            let notificationDynamicDataObj = Mapper<PassengerJoinedRegularRideNotificationToRiderDynamicData>().map(JSONString: notificationDynamicParams!)! as PassengerJoinedRegularRideNotificationToRiderDynamicData

            riderRideId = Double(notificationDynamicDataObj.regularRiderRideId!)
        }
        return riderRideId
    }
}
public class PassengerJoinedRegularRideGotCancelledDynamicData : NSObject,Mappable {
    var regularRiderRideId : String?
    var userId : String?
    var userGender : String?
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        regularRiderRideId <- map[Ride.FLD_ID]
        userId <- map["phone"]
        userGender <- map["gender"]
    }
    public override var description: String {
        return "regularRiderRideId: \(String(describing: self.regularRiderRideId))," + "userId: \(String(describing: self.userId))," + "userGender: \(String(describing: self.userGender)),"
    }
}
