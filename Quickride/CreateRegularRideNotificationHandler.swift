//
//  CreateRegularRideNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 25/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class CreateRegularRideNotificationHandler: NotificationHandler {
    
    var userNotification : UserNotification?
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            let params = self.getActionParams(userNotification: clientNotification)
            guard let rideIdStr = params[Ride.FLD_ID], !rideIdStr.isEmpty, let rideId = Double(rideIdStr), let rideType = params[Ride.FLD_RIDETYPE], !rideType.isEmpty else {
                return handler(false)
            }
            if Ride.PASSENGER_RIDE == rideType{
                if let _ = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: ){
                    return handler(true)
                }else if let ride = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: rideId), ride.status != Ride.RIDE_STATUS_CANCELLED{
                    return handler(true)
                }
                return handler(false)
            }else if Ride.RIDER_RIDE == rideType{
                if let _ = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId) {
                    return handler(true)
                }else if let ride = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: Double(rideId)), ride.status != Ride.RIDE_STATUS_CANCELLED{
                    return handler(true)
                }
                return handler(true)
            }
            return handler(false)
        }
        
    }

    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
      handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {

        AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")

        self.userNotification = userNotification
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        let params = getActionParams(userNotification: userNotification)
        var ride : Ride?
        if Ride.PASSENGER_RIDE == params[Ride.FLD_RIDETYPE]{
            ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: Double(params[Ride.FLD_ID]!)!)
            if ride == nil{
                ride = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: Double(params[Ride.FLD_ID]!)!)
            }
        }else{
            ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: Double(params[Ride.FLD_ID]!)!)
            if ride == nil{
                ride = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: Double(params[Ride.FLD_ID]!)!)
            }
        }
        if ride == nil{
            UIApplication.shared.keyWindow?.makeToast( "Ride is closed")
            
        }else{
           let regularRideCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.regularRideCreationViewController) as! RegularRideCreationViewController
            regularRideCreationViewController.initializeView(createRideAsRecuringRide: true, ride: ride!)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: regularRideCreationViewController, animated: false)
        }
    }
    
    override func getActionParams(userNotification: UserNotification) -> [String : String] {
       AppDelegate.getAppDelegate().log.debug("getActionParams()")
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
