
//
//  RepeatRideController.swift
//  Quickride
//
//  Created by QuickRideMac on 10/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class RepeatRideController : SelectDateDelegate{
  var rideToBeRepeated : Ride?
  var viewController : UIViewController?
  
  init(ride :Ride,viewController : UIViewController){
    self.rideToBeRepeated = ride
    self.viewController = viewController
  }
  
  func repeatRide(){
    AppDelegate.getAppDelegate().log.debug("repeatRide()")
    let dateTimePickerView = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
    var newDate = NSDate().addDays(daysToAdd: 1)
    let rideDate = NSDate(timeIntervalSince1970: rideToBeRepeated!.startTime/1000)
    let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
    var newDatecomponents = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: newDate as Date)
    let rideDatecomponents = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: rideDate as Date)
    
    // Change the time to 9:30:00 in your locale
    newDatecomponents.hour = rideDatecomponents.hour
    newDatecomponents.minute = rideDatecomponents.minute
    
    newDate = gregorian.date(from: newDatecomponents)! as NSDate
  
    dateTimePickerView.initializeDataBeforePresentingView(minDate: NSDate().timeIntervalSince1970,maxDate: nil, defaultDate: newDate.timeIntervalSince1970, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
    dateTimePickerView.modalPresentationStyle = .overFullScreen
    viewController!.present(dateTimePickerView, animated: false, completion: nil)
  }
  
  func getTime(date: Double) {
    AppDelegate.getAppDelegate().log.debug("getTime()")
    
    rideToBeRepeated?.rideId = 0
    let rideDuration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: rideToBeRepeated!.startTime, time2: rideToBeRepeated?.expectedEndTime)
    rideToBeRepeated?.startTime = date*1000
    let rideRoute :RideRoute = RideRoute(routeId: rideToBeRepeated!.routeId!,overviewPolyline : (rideToBeRepeated?.routePathPolyline)!,distance :(rideToBeRepeated?.distance)!,duration : Double(rideDuration), waypoints : rideToBeRepeated?.waypoints)
    let redundantRide = MyActiveRidesCache.singleCacheInstance?.checkForRedundancyOfRide(ride: rideToBeRepeated!)
    if redundantRide != nil{
        RideValidationUtils.displayRedundentRideAlert(ride: redundantRide!, viewController: viewController!)
      return
    }
    if rideToBeRepeated?.rideType == Ride.RIDER_RIDE{
        QuickRideProgressSpinner.startSpinner()
      (rideToBeRepeated as! RiderRide).availableSeats = (rideToBeRepeated as! RiderRide).capacity
      
      CreateRiderRideHandler(ride: rideToBeRepeated as! RiderRide, rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: viewController).createRiderRide(handler: { (riderRide, error) in
        QuickRideProgressSpinner.stopSpinner()
        if riderRide != nil{
          self.moveToRideView(ride: riderRide!)
        }
      })
    }else{
        QuickRideProgressSpinner.startSpinner()
        CreatePassengerRideHandler(ride: rideToBeRepeated as! PassengerRide, rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: viewController, parentRideId: nil,relayLegSeq: nil).createPassengerRide(handler: { (passengerRide, error) in
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
