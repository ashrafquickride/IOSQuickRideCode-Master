//
//  RentalTaxiEndOdometerDetailsHandler.swift
//  Quickride
//
//  Created by Rajesab on 30/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RentalTaxiEndOdometerDetailsHandler: NotificationHandler{
    
    var taxiRidePassengerDetails: TaxiRidePassengerDetails?
    var outstationTaxiFareDetails: PassengerFareBreakUp?
    
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
        guard let taxiRidePassengerId = rentalTaxiOdometerDetails.taxiRidePassengerId, let taxiRideID = Double(taxiRidePassengerId) else {
            return
        }
        displayRentalTaxiEndOdometerDetailsView(taxiRideID: taxiRideID,rentalTaxiOdometerDetails: rentalTaxiOdometerDetails) { completed in
            NotificationCenter.default.post(name: .refreshOutStationFareSummary, object: nil)
        }
    }
    
    private func displayRentalTaxiEndOdometerDetailsView(taxiRideID: Double,rentalTaxiOdometerDetails: RentalTaxiOdometerDetails, actionComplitionHandler: actionComplitionHandler?){
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        group.enter()
        queue.async(group: group) {
            self.gettaxiRidePassengerDetails(taxiRideID: taxiRideID) { responseError,error in
                group.leave()
            }
        }
        group.enter()
        queue.async(group: group) {
            self.getOutstationFareSummaryDetails(taxiRideId: taxiRideID) { responseError,error in
                group.leave()
            }
        }
        group.notify(queue: queue) {
            if let actionComplitionHandler = actionComplitionHandler {
                actionComplitionHandler(true)
            }
            guard let taxiRidePassengerDetails = self.taxiRidePassengerDetails, let outstationTaxiFareDetails = self.outstationTaxiFareDetails else {
                return
            }
            let rentalTaxiEndOdometerDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_rental_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RentalTaxiEndOdometerDetailsViewController") as! RentalTaxiEndOdometerDetailsViewController
            rentalTaxiEndOdometerDetailsViewController.initialiseData(taxiRidePassengerDetails: taxiRidePassengerDetails, outstationTaxiFareDetails: outstationTaxiFareDetails, rentalTaxiOdometerDetails: rentalTaxiOdometerDetails)
            rentalTaxiEndOdometerDetailsViewController.modalPresentationStyle = .overFullScreen
            ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: rentalTaxiEndOdometerDetailsViewController, animated: false, completion: nil)
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handleTap(userNotification: userNotification, viewController: viewController)
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        guard let rentalTaxiOdometerDetails = Mapper<RentalTaxiOdometerDetails>().map(JSONString: msgObjectJson) else {
            return
        }
        guard let taxiRidePassengerId = rentalTaxiOdometerDetails.taxiRidePassengerId, let taxiRideID = Double(taxiRidePassengerId) else {
            return
        }
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
        taxiLiveRide.initializeDataBeforePresenting(rideId: taxiRideID)
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        QuickRideProgressSpinner.startSpinner()
        displayRentalTaxiEndOdometerDetailsView(taxiRideID: taxiRideID, rentalTaxiOdometerDetails: rentalTaxiOdometerDetails) { completed in
            QuickRideProgressSpinner.stopSpinner()
        }
    }
    
    func gettaxiRidePassengerDetails(taxiRideID: Double, handler : @escaping (_ responseError: ResponseError?, _ error: NSError?) -> Void) {
        TaxiRideDetailsCache.getInstance().getTaxiRideDetailsFromCache(rideId: taxiRideID ) { (restResponse) in
            handler(nil,nil)
            if restResponse.result != nil {
                self.taxiRidePassengerDetails = restResponse.result
            }
        }
    }
    
    func getOutstationFareSummaryDetails(taxiRideId: Double, handler : @escaping (_ responseError: ResponseError?, _ error: NSError?) -> Void){
        TaxiPoolRestClient.getFareBreakUpDuringTrip(taxiRideId: taxiRideId,userId: UserDataCache.getInstance()?.userId ?? "") { [weak self] (responseObject, error) in
            handler(nil,nil)
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self?.outstationTaxiFareDetails = Mapper<PassengerFareBreakUp>().map(JSONObject: responseObject!["resultData"])
            }
        }
    }
}
struct RentalTaxiOdometerDetails: Mappable{
    
    var startOdometerReading: String?
    var endOdometerReading: String?
    var kmsTravelled: String?
    var taxiGroupId: String?
    var taxiRidePassengerId: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        startOdometerReading <- map["startOdometerReading"]
        endOdometerReading <- map["endOdometerReading"]
        kmsTravelled <- map["kmsTravelled"]
        taxiGroupId <- map["taxiRideId"]
        taxiRidePassengerId <- map["taxiRidePassengerId"]
    }
    
    public var description: String {
        return "startOdometerReading: \(String(describing: self.startOdometerReading))," + "endOdometerReading: \(String(describing: self.endOdometerReading))," + "kmsTravelled: \(String(describing: self.kmsTravelled))," + "taxiRideId: \(String(describing: self.taxiGroupId))"
    }
}
