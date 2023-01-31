//
//  RescheduleRide.swift
//  Quickride
//
//  Created by QuickRideMac on 17/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RescheduleRide : SelectDateDelegate{
    
    var ride : Ride?
    var viewController : UIViewController?
    var moveToRideView : Bool = false
    init(ride :Ride,viewController :UIViewController?,moveToRideView : Bool){
        self.ride = ride
        self.viewController = viewController
        self.moveToRideView = moveToRideView
    }
    func rescheduleRide(){
      AppDelegate.getAppDelegate().log.debug("rescheduleRide()")
        if Ride.PASSENGER_RIDE == ride?.rideType && (ride as! PassengerRide).riderRideId != 0{
            UIApplication.shared.keyWindow?.makeToast( Strings.can_not_be_reschedule_now)
            return
        }
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        
        let selectDateTimeViewController :ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
             AppDelegate.getAppDelegate().log.debug("\(storyboard)")
             AppDelegate.getAppDelegate().log.debug("\(selectDateTimeViewController)")
        var datePickerMode : UIDatePicker.Mode?
        if Ride.RIDER_RIDE == ride?.rideType{
            if (ride as? RiderRide)?.noOfPassengers ?? 0 < 1{
                datePickerMode = UIDatePicker.Mode.dateAndTime
            }else{
                datePickerMode = UIDatePicker.Mode.time
            }
        }else{
            datePickerMode = UIDatePicker.Mode.dateAndTime
        }
      
        selectDateTimeViewController.initializeDataBeforePresentingView(minDate: NSDate().timeIntervalSince1970/1000,maxDate: nil, defaultDate: (ride?.startTime)!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: datePickerMode, datePickerTitle: nil, handler: nil)
        selectDateTimeViewController.modalPresentationStyle = .overFullScreen
        ViewControllerUtils.presentViewController(currentViewController: viewController, viewControllerToBeDisplayed: selectDateTimeViewController, animated: false, completion: nil)
    }
    
        
    func getTime(date: Double) {
      AppDelegate.getAppDelegate().log.debug("getTime()")
        let rideToReschedule = ride?.copy() as! Ride
        rideToReschedule.startTime = date*1000
        let redundantRide = MyActiveRidesCache.singleCacheInstance?.checkForRedundancyOfRide(ride: rideToReschedule)
        if  redundantRide != nil{
            RideValidationUtils.displayRedundentRideAlert(ride: redundantRide!, viewController: viewController!)
            
        }else{
            if rideToReschedule.rideType == Ride.RIDER_RIDE{
                RiderRideRestClient.rescheduleRiderRide(riderRideId: ride!.rideId, startTime: rideToReschedule.startTime, ViewController: viewController!, completionHandler: { (responseObject, error) -> Void in
                    if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                        ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: self.viewController, handler: nil)
                    }else if responseObject!["result"] as! String == "SUCCESS"{
                        let rideStatus : RideStatus = RideStatus(rideId :rideToReschedule.rideId, userId:rideToReschedule.userId,  status : Ride.RIDE_STATUS_RESCHEDULED, rideType : Ride.RIDER_RIDE, scheduleTime : self.ride!.startTime , rescheduledTime :rideToReschedule.startTime)
                        MyActiveRidesCache.getRidesCacheInstance()?.rescheduleRide(rideStatus: rideStatus)
                        self.ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: self.ride!.rideId)
                        UIApplication.shared.keyWindow?.makeToast( Strings.ride_rescheduled)
                        self.checkAndMoveToRideView()
                    }
                })
            }else if rideToReschedule.rideType == Ride.PASSENGER_RIDE{
                PassengerRideServiceClient.reschedulePassengerRide(passengerRideId: (ride?.rideId)!, startTime: rideToReschedule.startTime, viewController: viewController!, completionHandler: { (responseObject, error) -> Void in
                        if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                            ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: self.viewController, handler: nil)
                        }else{
                            let rideStatus : RideStatus = RideStatus(rideId :rideToReschedule.rideId, userId:rideToReschedule.userId,  status : Ride.RIDE_STATUS_RESCHEDULED, rideType : Ride.PASSENGER_RIDE, scheduleTime : self.ride!.startTime , rescheduledTime :rideToReschedule.startTime)
                            MyActiveRidesCache.getRidesCacheInstance()?.rescheduleRide(rideStatus: rideStatus)
                            self.ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: self.ride!.rideId)
                            UIApplication.shared.keyWindow?.makeToast( Strings.ride_rescheduled)
                            self.checkAndMoveToRideView()
                    }
                })
            }
        }
        
    }
    func checkAndMoveToRideView(){
        if moveToRideView{
            let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
            mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
        }
    }
}
