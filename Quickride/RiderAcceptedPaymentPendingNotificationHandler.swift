//
//  RiderAcceptedPaymentPendingNotificationHandler.swift
//  Quickride
//
//  Created by Rajesab on 02/01/23.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RiderAcceptedPaymentPendingNotificationHandler: NotificationHandler{
    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handleTap()")
        super.handleTap(userNotification: userNotification, viewController: viewController)
        guard let msgObjectJson = userNotification.msgObjectJson, let paymentPendingRideInfo = Mapper<PaymentPendingRideInfo>().map(JSONString: msgObjectJson) else { return }
        moveToLiveRide(paymentPendingRideInfo: paymentPendingRideInfo)
    }
    
    override func displayNotification(clientNotification: UserNotification) {
        super.displayNotification(clientNotification: clientNotification)
        guard let msgObjectJson = clientNotification.msgObjectJson, let paymentPendingRideInfo = Mapper<PaymentPendingRideInfo>().map(JSONString: msgObjectJson) else { return }
        moveToLiveRide(paymentPendingRideInfo: paymentPendingRideInfo)
    }
    
    private func moveToLiveRide(paymentPendingRideInfo: PaymentPendingRideInfo){
        AppDelegate.getAppDelegate().log.debug("paymentPendingRideInfo: \(paymentPendingRideInfo)")
        guard let rideIdStr = paymentPendingRideInfo.passengerRideId, let rideId = Double(rideIdStr), let ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(rideId: rideId) else { return }
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: mainContentVC, animated: true)
        let allInvitesOfRide = RideInviteCache().getInvitationsForRide(rideId: ride.rideId, rideType: ride.rideType ?? "")
        guard let riderIdStr = paymentPendingRideInfo.userId, let riderId = Double(riderIdStr), let invite = allInvitesOfRide.first(where: {$0.riderId ==  riderId}) else { return }
        self.moveToPayToConfirmRideView(rideInvitation: invite)
    }
    
    private func moveToPayToConfirmRideView(rideInvitation: RideInvitation){
        let payToConfirmRideViewController = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "PayToConfirmRideViewController") as! PayToConfirmRideViewController
        payToConfirmRideViewController.initialiseData(rideInvitation: rideInvitation)
        payToConfirmRideViewController.modalPresentationStyle = .overFullScreen
        ViewControllerUtils.addSubView(viewControllerToDisplay: payToConfirmRideViewController)
    }
}
struct PaymentPendingRideInfo: Mappable {
    var passengerRideId: String?
    var userId: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.passengerRideId <- map["passengerRideId"]
        self.userId <- map["phone"]
    }
    
    public var description: String {
        return "passengerRideId: \(String(describing: self.passengerRideId)),"
        + "userId: \(String(describing: self.userId)),"
    }
}
