//
//  ResumeRecurringRidesViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 15/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ResumeRecurringRidesViewModel{
    
    var recurringRides = [RegularRide]()
    var selcetedRides = [RegularRide]()
    var weekdays :[Int : String?] = [Int : String?]()
    var chosedRides = 0
    
    func getSuspendedRecurringRides(){
        recurringRides.removeAll()
        let riderRides = MyRegularRidesCache.getInstance().getSuspendedRegularRiderRides()
        let passengerRides = MyRegularRidesCache.getInstance().getSuspendedRegularPassengerRides()
        recurringRides.append(contentsOf: riderRides)
        recurringRides.append(contentsOf: passengerRides)
        selcetedRides = recurringRides
    }
    
    func resumeSelectedRecurringRides(){
        AppDelegate.getAppDelegate().log.debug("updateRegularRiderRidStatus()")
        chosedRides = selcetedRides.count
        for ride in selcetedRides{
            if Ride.REGULAR_RIDER_RIDE == ride.rideType{
                RegularRiderRideServiceClient.updateRegularRiderRideStatus(id: ride.rideId, status: Ride.RIDE_STATUS_SCHEDULED, handler: { (responseObject, error) in
                    self.handleRegularRideUpdateResponse(responseObject: responseObject,error: error,ride: ride)
                })
            }else if Ride.REGULAR_PASSENGER_RIDE == ride.rideType{
                RegularPassengerRideServiceClient.updateRegularPassengerRideStatus(rideId: ride.rideId, status: Ride.RIDE_STATUS_REQUESTED, completionHander: { (responseObject, error) in
                    self.handleRegularRideUpdateResponse(responseObject: responseObject,error: error,ride: ride)
                })
            }
        }
    }
    private func handleRegularRideUpdateResponse(responseObject: NSDictionary?,error : NSError?,ride: Ride){
        AppDelegate.getAppDelegate().log.debug("handleRegularRideUpdateResponse()")
        chosedRides -= 1
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            let rideStatus = RideStatus(rideId: ride.rideId, userId: ride.userId, status: Ride.RIDE_STATUS_SCHEDULED, rideType: ride.rideType!)
            MyRegularRidesCache.getInstance().updateRideStatus(rideStatus: rideStatus)
        }
        if chosedRides == 0{
            NotificationCenter.default.post(name: .stopSpinner, object: nil)
        }
    }
    func fillTimeForDayInWeek(regularRide: RegularRide){
        for index in 0...6{
            getTimeForWeekDay(weekDayIndex: index, regularRide: regularRide)
        }
    }
    private func getTimeForWeekDay(weekDayIndex : Int,regularRide: RegularRide){
        AppDelegate.getAppDelegate().log.debug("getTimeForWeekDay() \(weekDayIndex)")
        var time : String?
        switch weekDayIndex{
        case 0:
            time = regularRide.monday
            break
        case 1:
            time = regularRide.tuesday
            break
        case 2:
            time = regularRide.wednesday
            break
        case 3:
            time = regularRide.thursday
            break
        case 4:
            time = regularRide.friday
            break
        case 5:
            time = regularRide.saturday
            break
        case 6:
            time = regularRide.sunday
            break
        default :
            break
        }
        if let time = time{
            weekdays[weekDayIndex] = time
        }else{
            weekdays[weekDayIndex] = nil
        }
    }
    
    func updateRide(regularRide: RegularRide){
        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: regularRide.expectedEndTime, time2: regularRide.startTime)
        let rideRoute = RideRoute(routeId: regularRide.routeId ?? 0,overviewPolyline : regularRide.routePathPolyline ,distance: regularRide.distance ?? 0,duration : Double(duration), waypoints : regularRide.waypoints)
        if Ride.REGULAR_RIDER_RIDE == regularRide.rideType{
            updateRegularRiderRide(regularRide: regularRide, rideRoute: rideRoute)
        }else if Ride.REGULAR_PASSENGER_RIDE == regularRide.rideType{
            updateRegularPassengerRide(regularRide: regularRide, rideRoute: rideRoute)
        }
    }
    
    func updateRegularPassengerRide(regularRide:RegularRide,rideRoute: RideRoute){
        AppDelegate.getAppDelegate().log.debug("updateRegularPassengerRide()")
        let updateRegularRideTask = UpdateRegularPassengerRideTask(regularRide: regularRide, rideRoute: rideRoute, delegate: nil, viewController: nil)
        updateRegularRideTask.updateRegularRide()
    }
    
    func updateRegularRiderRide(regularRide:RegularRide,rideRoute: RideRoute){
        AppDelegate.getAppDelegate().log.debug("updateRegularRiderRide()")
        let updateRegularRideTask = UpdateRegularRiderRideTask(regularRide: regularRide, rideRoute: rideRoute, delegate: nil, viewController: nil)
        updateRegularRideTask.updateRegularRide()
    }
}
