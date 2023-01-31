//
//  DriverRejectedAdditionalCashPaymentsByPassenger.swift
//  Quickride
//
//  Created by HK on 18/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class DriverRejectedAdditionalCashPaymentsByPassenger: NotificationHandler {
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        if let notification = Mapper<PassengerRideData>().map(JSONString: msgObjectJson){
            ContainerTabBarViewController.indexToSelect = 0
            let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
            taxiLiveRide.initializeDataBeforePresenting(rideId: Double(notification.taxiRidePassengerId ?? "") ?? 0.0, isRequiredToInitiatePayment: false)
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
        super.displayNotification(clientNotification: clientNotification)
        NotificationCenter.default.post(name: .refreshOutStationFareSummary, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: .cashHandleRejectedByDriver, object: nil, userInfo: nil)
    }
}
