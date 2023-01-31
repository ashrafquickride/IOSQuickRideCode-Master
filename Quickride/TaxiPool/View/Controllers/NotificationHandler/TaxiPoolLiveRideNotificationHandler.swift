//
//  TaxiPoolLiveRideNotificationHandler.swift
//  Quickride
//
//  Created by Ashutos on 7/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiPoolLiveRideNotificationHandler : NotificationHandler {
    var userNotification : UserNotification?
    var viewController :UIViewController?
    var passengerRideData: PassengerRideData?
    
   
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "taxi_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "taxi_notification_icon")
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handleTap()")
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        super.handleTap(userNotification: userNotification, viewController: viewController)
        
        mapNotificationData(userNotification: userNotification)
        
        if let taxiRideId = passengerRideData?.taxiRidePassengerId {
            ContainerTabBarViewController.indexToSelect = 0
            let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
            taxiLiveRide.initializeDataBeforePresenting(rideId: Double(taxiRideId) ?? 0.0)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        }else{
            let passengerRideId = self.getPassengerRideId() ?? 0
            let passengerRide =  MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId: passengerRideId)
            if passengerRide == nil {
                return
            }else{
                ContainerTabBarViewController.indexToSelect = 1
                let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
                mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: passengerRide, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
                ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: mainContentVC, animated: true)
                
            }
        }
    }
    
    override func displayNotification(clientNotification: UserNotification) {
        super.displayNotification(clientNotification: clientNotification)
        SharedPreferenceHelper.storeNewDriverAllotedNotification(isRequiredToShowNewDriverAllotedPopup: true)
        NotificationCenter.default.post(name: .newDriverAlloted, object: nil, userInfo: nil)
        mapNotificationData(userNotification: clientNotification)
        if let taxiRideRideStr = passengerRideData?.taxiRidePassengerId, let taxiRideId = Double(taxiRideRideStr), let taxiRidePassenger = MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: taxiRideId), let taxiGroupId = taxiRidePassenger.taxiGroupId {
            var taxiRidePassengerStatus = TaxiPassengerStatusUpdate()
            taxiRidePassengerStatus.taxiRidePassengerId = taxiRideId
            taxiRidePassengerStatus.taxiRideGroupId = taxiGroupId
            TaxiRideDetailsCache.getInstance().updateTaxiRidePassengerStatus(taxiRidePassengerUpdate: taxiRidePassengerStatus)
        }
    }
    
    
    func mapNotificationData(userNotification : UserNotification) {
        let notificationDynamicParams : String? = userNotification.msgObjectJson
        if (notificationDynamicParams != nil) {
            passengerRideData = Mapper<PassengerRideData>().map(JSONString: notificationDynamicParams!)! as PassengerRideData
        }
    }
    
    func getPassengerRideId () -> Double? {
        AppDelegate.getAppDelegate().log.debug("getRiderRideId()")
        var passengerRideId: Double?
        if let passengerRideData = passengerRideData {
            passengerRideId = Double(passengerRideData.passengerRideId!)
        }
        return passengerRideId
    }
    
}

class PassengerRideData : NSObject, Mappable {
    var passengerRideId : String?
    var taxiRideId : String?
    var taxiRidePassengerId : String?
    var taxiRideGroupId: String?
    var exclusiveFixedFareRefId: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        passengerRideId <- map["id"]
        taxiRideId <- map["taxiRideId"]
        taxiRidePassengerId <- map["taxiRidePassengerId"]
        taxiRideGroupId <- map["taxiRideGroupId"]
        exclusiveFixedFareRefId <- map["exclusiveFixedFareRefId"]
    }
    
    public override var description: String {
        return "passengerRideId: \(String(describing: self.passengerRideId))," + "taxiRideId: \(String(describing: self.taxiRideId))," + "taxiRidePassengerId: \(String(describing: self.taxiRidePassengerId))," + "taxiRideGroupId: \(String(describing: self.taxiRideGroupId))" + "exclusiveFixedFareRefId: \(String(describing: self.exclusiveFixedFareRefId))"
    }
}
