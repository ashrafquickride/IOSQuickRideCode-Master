//
//  DriverAddedPaymentsOnTheWayNotificationHandler.swift
//  Quickride
//
//  Created by HK on 18/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class DriverAddedPaymentsOnTheWayNotificationHandler: NotificationHandler {
    
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "taxi_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "taxi_notification_icon")
        }
    }

    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        NotificationCenter.default.post(name: .refreshOutStationFareSummary, object: nil)
        return Strings.Dispute.uppercased()
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        let passengerRideData = Mapper<DriverAddedPaymentNotification>().map(JSONString: msgObjectJson)
        if let notification = passengerRideData{
            QuickRideProgressSpinner.startSpinner()
            TaxiPoolRestClient.updateAddedPaymentStatus(id: notification.id ?? "", customerId: UserDataCache.getInstance()?.userId ?? "", status: TaxiUserAdditionalPaymentDetails.STATUS_REJECTED) {(responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
                }
            }
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        if let notification = Mapper<PassengerRideData>().map(JSONString: msgObjectJson){
            ContainerTabBarViewController.indexToSelect = 0
            let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
            taxiLiveRide.initializeDataBeforePresenting(rideId: Double(notification.taxiRidePassengerId ?? "") ?? 0.0)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        }
    }
    
}

struct DriverAddedPaymentNotification: Mappable{
    
    var id : String?
    var customerId : String?
    var taxiRidePassengerId : String?
    var taxiGroupId: String?
    var fareDetails: String?
    var taxiTripExtraFareDetails: TaxiTripExtraFareDetails?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        customerId <- map["customerId"]
        taxiGroupId <- map["taxiGroupId"]
        taxiRidePassengerId <- map["taxiRidePassengerId"]
        fareDetails <- map["fareDetails"]
    }
    public var description: String {
        return "id: \(String(describing: self.id))," + "customerId: \(String(describing: self.customerId))," + "taxiRidePassengerId: \(String(describing: self.taxiRidePassengerId))," + "taxiGroupId: \(String(describing: self.taxiGroupId))" + "fareDetails: \(String(describing: self.fareDetails))" + "taxiTripExtraFareDetails: \(String(describing: self.taxiTripExtraFareDetails))"
    }
}
