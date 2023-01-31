//
//  RelayRideChildRidesCancellationHandler.swift
//  Quickride
//
//  Created by Vinutha on 20/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RelayRideChildRidesCancellationHandler: NotificationHandler{
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.cancel_relay_rides
    }
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.view_my_rides
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        if userNotification.msgObjectJson == nil || userNotification.msgObjectJson!.isEmpty{
            super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
            return
        }
        let relayRideCancellationNotification = Mapper<RelayRideCancellationNotification>().map(JSONString: userNotification.msgObjectJson!)
        
        if let firstRelayRideId = relayRideCancellationNotification?.relayLeg1, let firstRideId = Double(firstRelayRideId){
            let firtRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: firstRideId)
            if firtRide != nil{
                cancelRide(ride: firtRide!, viewController: viewController ?? ViewControllerUtils.getCenterViewController(), userNotification: nil)
            }
        }
        if let secondRelayRideId = relayRideCancellationNotification?.relayLeg2,let secondRideId = Double(secondRelayRideId){
            let secondRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: secondRideId)
            if secondRide != nil{
                cancelRide(ride: secondRide!, viewController: viewController ?? ViewControllerUtils.getCenterViewController(), userNotification: userNotification)
            }
        }
    }
    
    private func cancelRide(ride: Ride,viewController: UIViewController,userNotification: UserNotification?){
        QuickRideProgressSpinner.startSpinner()
        RideCancelActionProxy.cancelRide(ride: ride, cancelReason: nil, isWaveOff: false, viewController: viewController, handler: {
            QuickRideProgressSpinner.stopSpinner()
            if userNotification != nil{
                super.handlePositiveAction(userNotification: userNotification!, viewController: viewController)
            }
        })
    }
    
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        let myRidesVC = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myRidesController)
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: myRidesVC, animated: false)
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
}
