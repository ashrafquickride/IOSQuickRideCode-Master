//
//  FeedbackNotificationHandler.swift
//  Quickride
//
//  Created by Rajesab on 06/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class FeedbackNotificationHandler: NotificationHandler{
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: nil)
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        if let notification = Mapper<TaxiFeedBackNotification>().map(JSONString: msgObjectJson){
            let taxiTripFeedbackVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FeedbackReminderNotificationViewController") as! FeedbackReminderNotificationViewController
            taxiTripFeedbackVC.initialiseDriverData(taxiFeedBackNotification: notification)
            ViewControllerUtils.addSubView(viewControllerToDisplay: taxiTripFeedbackVC)
        }
    }
}
struct TaxiFeedBackNotification: Mappable{
    
    var driverImgUri: String?
    var phone: String?
    var taxiRidePassengerId: String?
    var taxiGroupId: String?
    var taxiBookingId: String?
    var driverName: String?
    var endTimeInMs: String?
    var endAddress: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        driverImgUri <- map["driverImgUri"]
        phone <- map["phone"]
        taxiRidePassengerId <- map["taxiRidePassengerId"]
        taxiGroupId <- map["taxiGroupId"]
        taxiBookingId <- map["taxiBookingId"]
        driverName <- map["driverName"]
        endTimeInMs <- map["endTimeInMs"]
        endAddress <- map["endAddress"]
    }
    
    public var description: String {
        return "driverImgUri: \(String(describing: self.driverImgUri))," + "phone: \(String(describing: self.phone))," + "taxiRidePassengerId: \(String(describing: self.taxiRidePassengerId))," + "taxiGroupId: \(String(describing: self.taxiGroupId))" + "taxiBookingId: \(String(describing: self.taxiBookingId))" + "driverName: \(String(describing: self.driverName))" + "endTimeInMs: \(String(describing: self.endTimeInMs))" + "endAddress: \(String(describing: self.endAddress))"
    }
}
