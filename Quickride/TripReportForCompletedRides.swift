//
//  TripReportForCompletedRides.swift
//  Quickride
//
//  Created by QuickRideMac on 15/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
protocol TripReportReceiver{
    func riderTripReportReceived(rideBillingDetails: [RideBillingDetails]?)
  func passengerTripReportReceived(rideBillingDetails: RideBillingDetails,passengerRideId : Double)
    func receiveTripReportFailed()
}
class TripReportForCompletedRides {
    var viewController : UIViewController
    var ride : Ride
    var receiver : TripReportReceiver
    init(ride : Ride,viewController :UIViewController,receiver : TripReportReceiver){
        self.ride = ride
        self.viewController = viewController
        self.receiver = receiver
    }
    
    func getTripReport(){
      AppDelegate.getAppDelegate().log.debug("getTripReport()")
        QuickRideProgressSpinner.startSpinner()
        if Ride.RIDER_RIDE == ride.rideType{
            getTripReportForRiderRide()
        }else{
            getTripReportForPassengerRide()
        }
    }
    func getTripReportForRiderRide(){
      AppDelegate.getAppDelegate().log.debug("getTripReportForRiderRide()")
        BillRestClient.getRiderRideBillingDetails(id: StringUtils.getStringFromDouble(decimalNumber: ride.rideId), userId: StringUtils.getStringFromDouble(decimalNumber: ride.userId))  { (responseObject, error) -> Void in
            self.handleResponseAndProcess(responseObject: responseObject,error: error)
        }
    }
    func getTripReportForPassengerRide(){
      AppDelegate.getAppDelegate().log.debug("getTripReportForPassengerRide()")
        let passengerRide = ride as! PassengerRide
        var id = 0.0
        if passengerRide.taxiRideId == nil || passengerRide.taxiRideId == 0.0 {
            id = passengerRide.rideId
        } else {
            id = passengerRide.taxiRideId ?? 0
        }
        BillRestClient.getPassengerRideBillingDetails(id: StringUtils.getStringFromDouble(decimalNumber: id), userId: StringUtils.getStringFromDouble(decimalNumber: ride.userId), completionHandler: { (responseObject, error) in
            self.handleResponseAndProcess(responseObject: responseObject,error: error)
        })
        
    }
    
    func handleResponseAndProcess(responseObject: NSDictionary?,error: NSError?){
        AppDelegate.getAppDelegate().log.debug("handleResponseAndProcess()")
        QuickRideProgressSpinner.stopSpinner()
        
        if ride.rideType == Ride.RIDER_RIDE{
            let result = RestResponseParser<RideBillingDetails>().parseArray(responseObject: responseObject, error: error)
            if result.1 != nil || result.2 != nil {
                ErrorProcessUtils.handleResponseError(responseError: result.1, error: result.2, viewController: viewController, handler: nil)
                return
            }
            if let rideBillingDetailslist = result.0 {
                receiver.riderTripReportReceived(rideBillingDetails: rideBillingDetailslist)
            } else {
                receiver.receiveTripReportFailed()
            }
        }else{
            let result = RestResponseParser<RideBillingDetails>().parse(responseObject: responseObject, error: error)
            if result.1 != nil || result.2 != nil {
                ErrorProcessUtils.handleResponseError(responseError: result.1, error: result.2, viewController: viewController, handler: nil)
                return
            }
            if let rideBillingDetails = result.0 {
                var rideBillingDetailslist = [RideBillingDetails]()
                rideBillingDetailslist.append(rideBillingDetails)
                receiver.passengerTripReportReceived(rideBillingDetails: rideBillingDetails,passengerRideId :ride.rideId)
            } else {
                receiver.receiveTripReportFailed()
            }
        }
    }
}
