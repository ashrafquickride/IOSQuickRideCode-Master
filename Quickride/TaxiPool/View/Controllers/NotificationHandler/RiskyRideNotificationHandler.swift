//
//  RiskyRideNotificationHandler.swift
//  Quickride
//
//  Created by Rajesab on 13/09/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RiskyRideNotificationHandler: NotificationHandler {
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        if let notification = Mapper<TaxiRiskyRideData>().map(JSONString: msgObjectJson){
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
}

struct TaxiRiskyRideData: Mappable{

    var taxiRidePassengerId: String?
    var taxiGroupId: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        taxiRidePassengerId <- map["taxiRidePassengerId"]
        taxiGroupId <- map["taxiGroupId"]
    }
    
    public var description: String {
        return "taxiRidePassengerId: \(String(describing: self.taxiRidePassengerId)),"
        + "taxiGroupId: \(String(describing: self.taxiGroupId))"
    }
}
