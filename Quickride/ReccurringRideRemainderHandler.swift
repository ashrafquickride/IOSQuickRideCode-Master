//
//  ReccurringRideRemainderHandler.swift
//  Quickride
//
//  Created by Halesh K on 17/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation


class ReccurringRideRemainderHandler: NotificationHandler{
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        var ride: Ride?
        if let rideIdString = userNotification.groupValue,let rideId = Double(rideIdString){
            ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideId)
        }
        guard let rideObj = ride else { return }
        let sendInviteBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
        
        sendInviteBaseViewController.initializeDataBeforePresenting(scheduleRide: rideObj, isFromCanceRide: false, isFromRideCreation: false)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: sendInviteBaseViewController, animated: false)
    }
}
