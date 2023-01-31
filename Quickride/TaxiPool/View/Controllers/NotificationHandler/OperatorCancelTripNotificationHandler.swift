//
//  OperatorCancelTripNotificationHandler.swift
//  Quickride
//
//  Created by HK on 14/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class OperatorCancelTripNotificationHandler: NotificationHandler {
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        if let notification = Mapper<PassengerRideData>().map(JSONString: msgObjectJson){
            ContainerTabBarViewController.indexToSelect = 0
            guard let taxiRide = MyActiveTaxiRideCache.getInstance().getClosedTaxiRidePassenger(taxiRideId: Double(notification.taxiRidePassengerId ?? "") ?? 0.0) else { return }
            getCanceTaxiTripInvoice(taxiPassengerRide: taxiRide) { (cancelTaxiRideInvoices) in
                if let cancelTaxiInvoices = cancelTaxiRideInvoices{
                    var feeAppliedTaxiRides = [CancelTaxiRideInvoice]()
                    for cancelRideInvoice in cancelTaxiInvoices{
                        if cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_CUSTOMER || cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_PARTNER{
                            feeAppliedTaxiRides.append(cancelRideInvoice)
                        }
                    }
                    let taxiBillVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripReportViewController") as! TaxiTripReportViewController
                    taxiBillVC.initialiseData(taxiRideInvoice: nil,taxiRide: taxiRide, cancelTaxiRideInvoice: feeAppliedTaxiRides)
                    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: taxiBillVC, animated: false)
                }
            }
        }
    }
    
    private func getCanceTaxiTripInvoice(taxiPassengerRide: TaxiRidePassenger?,completionHandler: @escaping(_ cancelTaxiRideInvoice: [CancelTaxiRideInvoice]?)->()) {
        if let id = taxiPassengerRide?.id, id != 0 {
            QuickRideProgressSpinner.startSpinner()
            TaxiPoolRestClient.getCancelTripInvoice(taxiRideId: id , userId: UserDataCache.getInstance()?.userId ?? "") {  (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let cancelTaxiRideInvoice = Mapper<CancelTaxiRideInvoice>().mapArray(JSONObject: responseObject!["resultData"])
                    completionHandler(cancelTaxiRideInvoice)
                }else{
                    completionHandler(nil)
                }
            }
        }else{
            completionHandler(nil)
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
