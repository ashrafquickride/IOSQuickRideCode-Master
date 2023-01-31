//
//  RecurringRideCancellationHandler.swift
//  Quickride
//
//  Created by Halesh on 27/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RecurringRideCancellationHandler: NotificationHandler{
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.yes_caps
    }
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.no_caps
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        if let rideIdString = userNotification.groupValue{
            let rideType = userNotification.groupName
            if let rideId = Double(rideIdString)
            {
                var ride: Ride?
                if rideType == Ride.FLD_RIDER_RIDE{
                    ride =  MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId)
                }
                else if rideType == Ride.FLD_PASSENGER_RIDE{
                    ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideId)
                }
                if ride != nil{
                    QuickRideProgressSpinner.startSpinner()
                    RideCancelActionProxy.cancelRide(ride: ride!, cancelReason: nil, isWaveOff: false, viewController: ViewControllerUtils.getCenterViewController(), handler: {
                        QuickRideProgressSpinner.stopSpinner()
                        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
                    })
                }
            }
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        var centerViewController: UINavigationController?
        if (viewController == nil || viewController?.navigationController == nil) {
            let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            var containerTabBarViewController = appDelegate.window?.rootViewController as? ContainerTabBarViewController
            if containerTabBarViewController == nil{
                containerTabBarViewController = ContainerTabBarViewController()
                AppDelegate.getAppDelegate().window!.rootViewController = containerTabBarViewController
            }
            centerViewController = containerTabBarViewController!.centerNavigationController
        }else{
            centerViewController = viewController?.navigationController
        }
        centerViewController?.tabBarController?.selectedIndex = 1
        centerViewController?.popToRootViewController(animated: false)
        ContainerTabBarViewController.fromPopRooController = true
    }
}
