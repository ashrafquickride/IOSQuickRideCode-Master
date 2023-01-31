//
//  TaxiBookingDetailsUpdatedNotificationHandler.swift
//  Quickride
//
//  Created by Rajesab on 29/12/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiBookingDetailsUpdatedNotificationHandler: NotificationHandler{
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        if let notification = Mapper<PassengerRideData>().map(JSONString: msgObjectJson){
            ContainerTabBarViewController.indexToSelect = 0
            let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
            taxiLiveRide.initializeDataBeforePresenting(rideId: Double(notification.taxiRidePassengerId ?? "") ?? 0.0)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        }
    }
    
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "taxi_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "taxi_notification_icon")
        }
    }
    
    override func displayNotification(clientNotification: UserNotification) {
        var userInfo = [String : Any]()
        userInfo["result"] = TaxiRidePassenger.TAXI_TRIP_UPDATED
        guard let msgObjectJson = clientNotification.msgObjectJson else { return }
        if let notification = Mapper<PassengerRideData>().map(JSONString: msgObjectJson){
            if let taxiRidePassengerIdStr = notification.taxiRidePassengerId,let taxiRidePassengerId = Double(taxiRidePassengerIdStr), let taxiRideGroupIdStr = notification.taxiRideGroupId, let taxiRideGroupId = Double(taxiRideGroupIdStr) {
                let taxiRidePassengerUpdate = TaxiPassengerStatusUpdate(taxiRidePassengerId: taxiRidePassengerId, taxiRideGroupId: taxiRideGroupId)
                TaxiRideDetailsCache.getInstance().updateTaxiRidePassengerStatus(taxiRidePassengerUpdate: taxiRidePassengerUpdate)
            }
        }
        NotificationCenter.default.post(name: .showTaxiLiveRideNotification, object: nil, userInfo: userInfo)
    }
    
}
