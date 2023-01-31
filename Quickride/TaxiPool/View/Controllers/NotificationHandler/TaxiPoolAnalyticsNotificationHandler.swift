//
//  TaxiPoolAnalyticsNotificationHandler.swift
//  Quickride
//
//  Created by Ashutos on 7/22/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiPoolAnalyticsNotificationHandler : NotificationHandler {
    
    private var dataObj:AnalyticNotificationHandlerModel?
    
    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        let passengerRideId = self.getPassengerRideId(userNotification: userNotification) ?? 0
        let passengerRide =  MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId: passengerRideId)
        
        let taxiPoolMapDetailViewViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolMapDetailViewViewController") as! TaxiPoolMapDetailViewViewController
             taxiPoolMapDetailViewViewController.getDataForTheSharedTaxi(selectedIndex: nil, matchedShareTaxis: nil,ride: passengerRide, analyticNotificationHandlerModel: dataObj, taxiInviteData: nil)
             ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: taxiPoolMapDetailViewViewController, animated: false)
        
    }
    
    
    func getPassengerRideId (userNotification : UserNotification) -> Double? {
        AppDelegate.getAppDelegate().log.debug("getRiderRideId()")
        var passengerRideId: Double?
        let notificationDynamicParams : String? = userNotification.msgObjectJson
        if (notificationDynamicParams != nil) {
            dataObj = Mapper<AnalyticNotificationHandlerModel>().map(JSONString: notificationDynamicParams!)! as AnalyticNotificationHandlerModel
            if let passengerId = dataObj?.passengerRideId {
                passengerRideId = Double(passengerId)
            }
        }
        return passengerRideId
    }
    
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "taxi_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "taxi_notification_icon")
        }
    }
}
