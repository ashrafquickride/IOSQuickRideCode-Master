//
//  RelayParentRideCancellationHandler.swift
//  Quickride
//
//  Created by Vinutha on 20/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RelayParentRideCancellationHandler: NotificationHandler{
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.cancel_ride
    }
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.view_my_rides
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        if let msgObjectJson = userNotification.msgObjectJson, !msgObjectJson.isEmpty{
            let relayRideCancellationNotification = Mapper<RelayRideCancellationNotification>().map(JSONString: msgObjectJson)
            if let rideIdStr = relayRideCancellationNotification?.parentId, let rideId = Double(rideIdStr){
                let ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideId)
                guard let rideObj = ride else { return }
                QuickRideProgressSpinner.startSpinner()
                RideCancelActionProxy.cancelRide(ride: rideObj, cancelReason: nil, isWaveOff: false, viewController: ViewControllerUtils.getCenterViewController(), handler: {
                    QuickRideProgressSpinner.stopSpinner()
                    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
                })
            }
        }else{
          super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
            return
        }
    }
    
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        let myRidesVC = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myRidesController)
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: myRidesVC, animated: false)
    }
}

struct RelayRideCancellationNotification: Mappable{
    
    var parentId: String?
    var relayLeg1: String?
    var relayLeg2: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        parentId <- map["parentId"]
        relayLeg1 <- map["relayLeg1"]
        relayLeg2 <- map["relayLeg2"]
    }
}
