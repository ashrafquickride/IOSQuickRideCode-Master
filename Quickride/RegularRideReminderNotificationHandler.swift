//
//  RegularRideReminderNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 07/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RegularRideReminderNotificationHandler: NotificationHandler{
    
    var userNotification : UserNotification?
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            let params = self.getActionParams(userNotification: clientNotification)
            guard let rideIdStr = params[Ride.FLD_ID] ,!rideIdStr.isEmpty, let rideType = params[Ride.FLD_RIDETYPE], !rideType.isEmpty, let rideId = Double(rideIdStr)  else {
                return handler(false)
            }
            if Ride.REGULAR_PASSENGER_RIDE == rideType{
                guard let _ = MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId: rideId) else{
                    return handler(true)
                }
                return handler(false)
            }else{
                guard let _ = MyRegularRidesCache.getInstance().getRegularRiderRide(riderRideId: rideId) else {
                    return handler(true)
                }
                return handler(false)
            }
        }
        
    }

    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handleTap()")
        self.userNotification = userNotification
        handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        let params = getActionParams(userNotification: userNotification)
        var ride : Ride?
        if Ride.REGULAR_PASSENGER_RIDE == params[Ride.FLD_RIDETYPE]{
            ride = MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId: Double(params[Ride.FLD_ID]!)!)
        }else{
            ride = MyRegularRidesCache.getInstance().getRegularRiderRide(riderRideId: Double(params[Ride.FLD_ID]!)!)
        }
        if ride == nil{
            UIApplication.shared.keyWindow?.makeToast( "Ride is closed")
            
        }else{
            let recurringRideViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.recurringRideViewController) as! RecurringRideViewController
            recurringRideViewController.initializeDataBeforePresentingView(ride: ride!, isFromRecurringRideCreation: false)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: recurringRideViewController, animated: false)
        }
    }
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
      AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.extend
    }
    override func getActionParams(userNotification: UserNotification) -> [String : String] {
      AppDelegate.getAppDelegate().log.debug("getActionParams() ")
        let dynamicData = Mapper<DymamicData>().map(JSONString: userNotification.msgObjectJson!)
        return dynamicData!.getParams()
    }
    class DymamicData : Mappable{
        var rideId : String?
        var rideType : String?
        
        required init?(map: Map) {
        }
        func mapping(map: Map) {
            self.rideId <- map[Ride.FLD_ID]
            self.rideType <- map[Ride.FLD_RIDETYPE]
        }
        func getParams() -> [String: String]{
            var params : [String : String] = [String : String]()
            params[Ride.FLD_ID] = rideId
            params[Ride.FLD_RIDETYPE] = rideType
            return params
        }
    }
}
