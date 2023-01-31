//
//  ReturnRideCreation.swift
//  Quickride
//
//  Created by QuickRideMac on 10/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ReturnRideCreation :SelectDateDelegate {
    
    var viewController : UIViewController?
    var ride : Ride?
    
    init(viewController : UIViewController, ride : Ride){
        self.ride = ride
        self.viewController = viewController
    }
    func createReturnRide(){
       AppDelegate.getAppDelegate().log.debug("createReturnRide()")
        let dateTimePickerView = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
             AppDelegate.getAppDelegate().log.debug("\(dateTimePickerView)")
        dateTimePickerView.initializeDataBeforePresentingView(minDate: NSDate().timeIntervalSince1970,maxDate: nil, defaultDate: (ride?.expectedEndTime)!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
        dateTimePickerView.modalPresentationStyle = .overFullScreen
        viewController!.present(dateTimePickerView, animated: false, completion: nil)
    }
    func getTime(date: Double) {
         AppDelegate.getAppDelegate().log.debug("getTime()")
        var tempDouble :Double = (self.ride?.startLatitude)!
        ride?.startLatitude = (ride?.endLatitude)!
        ride?.endLatitude = tempDouble
        
        tempDouble = (ride?.startLongitude)!
        ride?.startLongitude = (ride?.endLongitude)!
        ride?.endLongitude = tempDouble
        
        let tempAddress = ride?.endAddress
        ride?.endAddress = (ride?.startAddress)!
        ride?.startAddress = tempAddress!
        ride?.rideId = 0
        ride?.waypoints = nil
        ride?.routePathPolyline = ""
        ride?.startTime = date*1000
        ride?.routeId = 0
      
      if ride?.rideType == Ride.RIDER_RIDE{
        QuickRideProgressSpinner.startSpinner()
        (ride as! RiderRide).availableSeats = (ride as! RiderRide).capacity
        CreateRiderRideHandler(ride: ride as! RiderRide, rideRoute: nil, isFromInviteByContact: false, targetViewController: viewController).createRiderRide(handler: { (riderRide, error) in
            QuickRideProgressSpinner.stopSpinner()
          if riderRide != nil{
            self.moveToRideView(ride: riderRide!)
          }
        })
      }else{
        QuickRideProgressSpinner.startSpinner()
        CreatePassengerRideHandler(ride: ride as! PassengerRide, rideRoute: nil, isFromInviteByContact: false, targetViewController: viewController, parentRideId: nil,relayLegSeq: nil).createPassengerRide(handler: { (passengerRide, error) in
            QuickRideProgressSpinner.stopSpinner()
          if passengerRide != nil{
            self.moveToRideView(ride: passengerRide!)
          }
        })
      }
    }
  func moveToRideView(ride :Ride){
    AppDelegate.getAppDelegate().log.debug("moveToRideView()")
    QuickRideProgressSpinner.stopSpinner()
    
    let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
    mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
  }
}
