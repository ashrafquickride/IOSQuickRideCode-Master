//
//  RecurringRideViewModel.swift
//  Quickride
//
//  Created by Vinutha on 29/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class RecurringRideViewModel{
    
    //MARK: Varialbles
    var ride: Ride?
    var isFromRecurringRideCreation = false
    var rideRoute : RideRoute?
    var weekdays :[Int : String?] = [Int : String?]()
    var dayType = Ride.ALL_DAYS
    var recommendedMatches = [MatchedRegularUser]()
    var connectedMatches = [MatchedRegularUser]()
    var selectedRecommendMatchesIndex = -1
    
    init(ride : Ride, isFromRecurringRideCreation: Bool) {
        self.ride = ride
        self.isFromRecurringRideCreation = isFromRecurringRideCreation
    }
    
    init() {
        
    }
    
    func prapareRideRoute(){
        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride?.expectedEndTime, time2: ride?.startTime)
        rideRoute = RideRoute(routeId: ride?.routeId ?? 0,overviewPolyline : ride?.routePathPolyline ?? "",distance :ride?.distance ?? 0,duration : Double(duration), waypoints : ride?.waypoints)
    }
    
    func fillTimeForDayInWeek(){
        for index in 0...6{
            getTimeForWeekDay(weekDayIndex: index)
        }
    }
    private func getTimeForWeekDay(weekDayIndex : Int){
        AppDelegate.getAppDelegate().log.debug("getTimeForWeekDay() \(weekDayIndex)")
        var time : String?
        let regularRide = ride as? RegularRide
        switch weekDayIndex{
        case 0:
            time = regularRide?.monday
            break
        case 1:
            time = regularRide?.tuesday
            break
        case 2:
            time = regularRide?.wednesday
            break
        case 3:
            time = regularRide?.thursday
            break
        case 4:
            time = regularRide?.friday
            break
        case 5:
            time = regularRide?.saturday
            break
        case 6:
            time = regularRide?.sunday
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
    
    func getRecommendedMatches(viewController: UIViewController, matchingRegularRideOptionsDelegate: MatchingRegularRideOptionsDelegate){
        AppDelegate.getAppDelegate().log.debug("getRecommendedMatches()")
        if Ride.REGULAR_PASSENGER_RIDE == ride?.rideType && Ride.RIDE_STATUS_REQUESTED == ride?.status{
            let findMatchingRegularRiders : FindMatchingRegularRiders = FindMatchingRegularRiders(rideId: ride!.rideId, viewController: viewController, delegate: matchingRegularRideOptionsDelegate)
            findMatchingRegularRiders.getMatchingRegularRiders()
        }else if Ride.REGULAR_RIDER_RIDE == ride?.rideType{
            let findMatchingRegularPassengers : FindMatchingRegularPassengers = FindMatchingRegularPassengers(rideId: (ride?.rideId)!, viewController: viewController, delegate: matchingRegularRideOptionsDelegate)
            findMatchingRegularPassengers.getMatchingRegularPassengers()
        }
    }
    
    func getConnectedMatches(viewController: UIViewController,myRegularRidesCacheListener : MyRegularRidesCacheListener){
        AppDelegate.getAppDelegate().log.debug("getConnectedMatches()")
        if Ride.REGULAR_RIDER_RIDE == ride?.rideType && (ride as! RegularRiderRide).noOfPassengers > 0 {
            MyRegularRidesCache.getInstance().getConnectedPassengersOfRegularRiderRide(rideId: (ride?.rideId)!, viewController: viewController, listener: myRegularRidesCacheListener)
        }else if Ride.REGULAR_PASSENGER_RIDE == ride?.rideType && ride?.status != Ride.RIDE_STATUS_REQUESTED {
            MyRegularRidesCache.getInstance().getConnectedRiderOfRegularPassengerRide(regularPassengerRideId: (ride?.rideId)!, regularRiderRideId: (ride as! RegularPassengerRide).regularRiderRideId, viewController: viewController, listener: myRegularRidesCacheListener)
        }
    }
    func updateRide(viewContoller: UIViewController,updateRegularRideDelegate: UpdateRegularRideDelegate){
        if Ride.REGULAR_RIDER_RIDE == ride?.rideType{
            updateRegularRiderRide(viewContoller: viewContoller, updateRegularRideDelegate: updateRegularRideDelegate)
        }else if Ride.REGULAR_PASSENGER_RIDE == ride?.rideType{
            updateRegularPassengerRide(viewContoller: viewContoller, updateRegularRideDelegate: updateRegularRideDelegate)
        }
    }
    
    func updateRegularPassengerRide(viewContoller: UIViewController,updateRegularRideDelegate: UpdateRegularRideDelegate){
        AppDelegate.getAppDelegate().log.debug("updateRegularPassengerRide()")
        let regularPassengerRide = (ride as! RegularPassengerRide).copy()
        var regularRide = regularPassengerRide as! RegularRide
        regularRide.fromDate = (ride as! RegularRide).fromDate
        regularRide.dayType = self.dayType
        regularRide = RecurringRideUtils().fillTimeForEachDayInWeek(regularRide: regularPassengerRide as! RegularRide, weekdays: weekdays)
        let updateRegularRideTask = UpdateRegularPassengerRideTask(regularRide: regularPassengerRide as? RegularRide, rideRoute: self.rideRoute, delegate: updateRegularRideDelegate, viewController: viewContoller)
        updateRegularRideTask.updateRegularRide()
    }
    
    func updateRegularRiderRide(viewContoller: UIViewController,updateRegularRideDelegate: UpdateRegularRideDelegate){
        AppDelegate.getAppDelegate().log.debug("updateRegularRiderRide()")
        let regularRiderRide = (ride as! RegularRiderRide).copy()
        var regularRide = regularRiderRide as! RegularRide
        regularRide.fromDate = (ride as! RegularRide).fromDate
        regularRide.dayType = self.dayType
        regularRide = RecurringRideUtils().fillTimeForEachDayInWeek(regularRide: regularRiderRide as! RegularRide, weekdays: weekdays)
        let updateRegularRideTask = UpdateRegularRiderRideTask(regularRide: regularRiderRide as? RegularRide, rideRoute: self.rideRoute, delegate: updateRegularRideDelegate, viewController: viewContoller)
        updateRegularRideTask.updateRegularRide()
    }
    
    func updateRegularRideStatus(status : String){
        AppDelegate.getAppDelegate().log.debug("updateRegularRiderRidStatus() \(status)")
        if Ride.REGULAR_RIDER_RIDE == ride?.rideType{
            RegularRiderRideServiceClient.updateRegularRiderRideStatus(id: ride!.rideId, status: status, handler: { (responseObject, error) in
                self.handleRegularRideUpdateResponse(responseObject: responseObject,error: error,status : status)
            })
        }else if Ride.REGULAR_PASSENGER_RIDE == ride?.rideType{
            RegularPassengerRideServiceClient.updateRegularPassengerRideStatus(rideId: ride!.rideId, status: status, completionHander: { (responseObject, error) in
                self.handleRegularRideUpdateResponse(responseObject: responseObject,error: error,status : status)
            })
        }
    }
    private func handleRegularRideUpdateResponse(responseObject: NSDictionary?,error : NSError?,status :String){
        AppDelegate.getAppDelegate().log.debug("handleRegularRideUpdateResponse() \(status)")
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            let rideStatus = RideStatus(rideId: self.ride!.rideId, userId: self.ride!.userId, status: status, rideType: self.ride!.rideType!)
            MyRegularRidesCache.getInstance().updateRideStatus(rideStatus: rideStatus)
            NotificationCenter.default.post(name: .recurringRideStatusUpdated, object: self)
        }else {
            var userInfo = [String : Any]()
            userInfo["responseObject"] = responseObject
            userInfo["nsError"] = error
            NotificationCenter.default.post(name: .recurringRideStatusUpdateFailed, object: self, userInfo: userInfo)
        }
    }
    func putFavouritePartnersOnTop(recommendedMatches: [MatchedRegularUser]) -> [MatchedRegularUser]{
        var favouriteMatches = [MatchedRegularUser]()
        var unFavouriteMatches = [MatchedRegularUser]()
        for matchedUser in recommendedMatches{
            if UserDataCache.getInstance()!.isFavouritePartner(userId: matchedUser.userid!){
                favouriteMatches.append(matchedUser)
            }else{
                unFavouriteMatches.append(matchedUser)
            }
        }
        favouriteMatches.append(contentsOf: unFavouriteMatches)
        return favouriteMatches
    }
}


