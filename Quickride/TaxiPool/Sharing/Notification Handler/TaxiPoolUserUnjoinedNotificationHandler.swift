//
//  TaxiPoolUserUnjoinedNotificationHandler.swift
//  Quickride
//
//  Created by HK on 09/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiPoolUserUnjoinedNotificationHandler: NotificationHandler {
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.ACCEPT
    }
    
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.VIEW
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        guard let passengerRideData = Mapper<PassengerRideData>().map(JSONString: userNotification.msgObjectJson ?? "") else { return }
        if let taxiRideId = Double(passengerRideData.taxiRidePassengerId ?? ""),let fixedFareId = passengerRideData.exclusiveFixedFareRefId{
            super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
            bookExclusiveTaxiIfTaxipoolNotConfirmed(taxiPassengerId: taxiRideId, fixedFareId: fixedFareId)
        }
    }
    
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        if let notification = Mapper<PassengerRideData>().map(JSONString: msgObjectJson){
            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
            let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
            taxiLiveRide.initializeDataBeforePresenting(rideId: Double(notification.taxiRidePassengerId ?? "") ?? 0)
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        }
    }
    
    private func bookExclusiveTaxiIfTaxipoolNotConfirmed(taxiPassengerId: Double,fixedFareId: String){
        QuickRideProgressSpinner.startSpinner()
        TaxiSharingRestClient.updateSharingToExclusive(taxiRidePassengerId: taxiPassengerId, allocateTaxiIfPoolNotConfirmed: true, fixedFareId: fixedFareId) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                if let taxiRideDetails = Mapper<TaxiRidePassengerDetails>().map(JSONObject: responseObject!["resultData"]){
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: taxiPassengerId, taxiRidePassengerDetails: taxiRideDetails)
                }
            }
        }
    }
}
