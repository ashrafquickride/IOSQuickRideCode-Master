//
//  RecurringRideUtils.swift
//  Quickride
//
//  Created by Halesh on 15/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RecurringRideUtils{
    
    func continueCreatingRegularRiderRide(regularRiderRide: RegularRiderRide,viewController: UIViewController,rideRoute:RideRoute?,recurringRideCreatedComplitionHandler: CompletionHandlers.recurringRideCreatedComplitionHandler?){
           MyActiveRidesCache.RECURRING_RIDES_CREATED = true
           let createRegularRiderRideTask : CreateRegularRiderRideTask = CreateRegularRiderRideTask(regularriderRide: regularRiderRide, riderRideId: regularRiderRide.rideId, viewController: viewController,rideRoute: rideRoute, isFromSignUpFlow: false)
           QuickRideProgressSpinner.startSpinner()
           createRegularRiderRideTask.createRegularRiderRide(handler: { (responseError,error,newRegularRiderRide,newRegularPassengerRide)  in
               QuickRideProgressSpinner.stopSpinner()
               if responseError == nil && error == nil{
                   recurringRideCreatedComplitionHandler?(newRegularRiderRide,nil,nil)
               }else{
                   recurringRideCreatedComplitionHandler?(nil,responseError,error)
               }
           })
       }
    
    func continueCreatingRegularPassengerRide(regularPassengerRide: RegularPassengerRide,viewController: UIViewController,rideRoute:RideRoute?,recurringRideCreatedComplitionHandler:  CompletionHandlers.recurringRideCreatedComplitionHandler?){
        MyActiveRidesCache.RECURRING_RIDES_CREATED = true
        let createRegularPassengerRideTask : CreateRegularPassengerRideTask = CreateRegularPassengerRideTask(regularPassengerRide: regularPassengerRide, passengerRideId: regularPassengerRide.rideId, viewController: viewController,rideRoute: rideRoute, isFromSignUpFlow: false)
        QuickRideProgressSpinner.startSpinner()
        createRegularPassengerRideTask.createRegularPassengerRide(handler: { (responseError,error,newRegularRiderRide,newRegularPassengerRide)  in
            QuickRideProgressSpinner.stopSpinner()
            if responseError == nil && error == nil{
                recurringRideCreatedComplitionHandler?(newRegularPassengerRide,nil,nil)
            }else{
                recurringRideCreatedComplitionHandler?(nil,responseError,error)
            }
        })
    }
    
    func fillTimeForEachDayInWeek(regularRide : RegularRide,weekdays: [Int : String?]) -> RegularRide{
           AppDelegate.getAppDelegate().log.debug("fillTimeForEachDayInWeek()")
        regularRide.monday = getTimeForWeekDayFromDaysTableView(weekDayPosition: 0, weekdays: weekdays)
        regularRide.tuesday = getTimeForWeekDayFromDaysTableView(weekDayPosition: 1, weekdays: weekdays)
        regularRide.wednesday = getTimeForWeekDayFromDaysTableView(weekDayPosition: 2, weekdays: weekdays)
        regularRide.thursday = getTimeForWeekDayFromDaysTableView(weekDayPosition: 3, weekdays: weekdays)
        regularRide.friday = getTimeForWeekDayFromDaysTableView(weekDayPosition: 4, weekdays: weekdays)
        regularRide.saturday = getTimeForWeekDayFromDaysTableView(weekDayPosition: 5, weekdays: weekdays)
        regularRide.sunday = getTimeForWeekDayFromDaysTableView(weekDayPosition: 6, weekdays: weekdays)
        return regularRide
       }
    func getTimeForWeekDayFromDaysTableView(weekDayPosition : Int, weekdays: [Int : String?]) -> String?{
        AppDelegate.getAppDelegate().log.debug("getTimeForWeekDayFromDaysTableView() \(weekDayPosition)")
        if weekdays[weekDayPosition] == nil{
            return nil
        }else{
            return weekdays[weekDayPosition]!
        }
    }
    
    func isValidDistance(ride: Ride) -> Bool{
        if let distance = ride.distance{
            if distance > MyRegularRidesCache.MAXIMUM_DISTANCE_ALLOWED_TO_CREATE_RIDE{
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    func isRegularRide(rideType : String?) -> Bool{
        AppDelegate.getAppDelegate().log.debug("isRiderRide() \(String(describing: rideType))")
        if Ride.REGULAR_PASSENGER_RIDE == rideType || Ride.REGULAR_RIDER_RIDE == rideType{
            return true
        }else{
            return false
        }
    }
    
}
