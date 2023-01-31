//
//  RentalTaxiStartOdometerDetailsHandler.swift
//  Quickride
//
//  Created by Rajesab on 30/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RentalTaxiStartOdometerDetailsHandler: NotificationHandler{
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "taxi_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "taxi_notification_icon")
        }
    }
    
    override func displayNotification(clientNotification: UserNotification) {
        guard let msgObjectJson = clientNotification.msgObjectJson else { return }
        guard let rentalTaxiOdometerDetails = Mapper<RentalTaxiOdometerDetails>().map(JSONString: msgObjectJson) else {
            return
        }
        guard let startOdometerReading = rentalTaxiOdometerDetails.startOdometerReading else {
            return
        }
        NotificationCenter.default.post(name: .refreshOutStationFareSummary, object: nil)
        let rentalTaxiStartOdometerDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_rental_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RentalTaxiStartOdometerDetailsViewController") as! RentalTaxiStartOdometerDetailsViewController
        rentalTaxiStartOdometerDetailsViewController.initialiseData(odometerReading: startOdometerReading)
        ViewControllerUtils.addSubView(viewControllerToDisplay: rentalTaxiStartOdometerDetailsViewController)
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handleTap(userNotification: userNotification, viewController: viewController)
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        guard let rentalTaxiOdometerDetails = Mapper<RentalTaxiOdometerDetails>().map(JSONString: msgObjectJson) else {
            return
        }
        guard let startOdometerReading = rentalTaxiOdometerDetails.startOdometerReading, let taxiRideIDStr = rentalTaxiOdometerDetails.taxiRidePassengerId, let taxiRideID = Double(taxiRideIDStr)  else {
            return
        }        
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
        taxiLiveRide.initializeDataBeforePresenting(rideId: taxiRideID)
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        
        let rentalTaxiStartOdometerDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_rental_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RentalTaxiStartOdometerDetailsViewController") as! RentalTaxiStartOdometerDetailsViewController
        rentalTaxiStartOdometerDetailsViewController.initialiseData(odometerReading: startOdometerReading)
        ViewControllerUtils.addSubView(viewControllerToDisplay: rentalTaxiStartOdometerDetailsViewController)
    }
}
