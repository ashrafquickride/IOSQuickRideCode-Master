//
//  TaxiPoolBillNotificationHandler.swift
//  Quickride
//
//  Created by Ashutos on 7/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiPoolBillNotificationHandler : NotificationHandler {
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        let notData = userNotification.msgObjectJson!.data(using: .utf8)!
        if let notDict = try? JSONSerialization.jsonObject(with: notData, options: .mutableLeaves) as? [String : String],let taxiID =  notDict["taxiRideId"],let passengerRideId = notDict["passengerRideId"]{
            QuickRideProgressSpinner.startSpinner()
            
            BillRestClient.getPassengerRideBillingDetails(id: taxiID, userId: QRSessionManager.getInstance()!.getUserId(), completionHandler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                    ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: viewController, handler: nil)
                }else {
                    let rideBillingDetails = Mapper<RideBillingDetails>().map(JSONObject: responseObject!["resultData"])!
                    var rideBillingDetailslist = [RideBillingDetails]()
                    rideBillingDetailslist.append(rideBillingDetails)
                    let billPassengerViewController  = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
                    billPassengerViewController.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetailslist, isFromClosedRidesOrTransaction: false,rideType: Ride.PASSENGER_RIDE,currentUserRideId: Double(passengerRideId)!)
                    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: billPassengerViewController, animated: false)
                }
            })
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
