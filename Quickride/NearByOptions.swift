//
//  NearByOptions.swift
//  Quickride
//
//  Created by QuickRideMac on 14/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol AvailableRideMatchOptionsAroundLocation {
    func receiveNearestOptionLocations( rideType : String,latitude : Double, longitude: Double,queryTime :NSDate, matchLocations : [NearByRideOption])
}
class NearByOptions : MatchingRideOptionsDelegate{
    var nearByQueryResults = [MatchOptionQueryResult]()
    
    var  listener : AvailableRideMatchOptionsAroundLocation?
    
    func getNearestRideMatchOptions(userId : Double,rideType : String,latitude : Double, longitude: Double,queryTime :NSDate, viewController : UIViewController, listener : AvailableRideMatchOptionsAroundLocation)
    {
        let options = getNearByOptionsFromCache(latitude: latitude, longitude: longitude, rideType: rideType, startTime: queryTime)
        if options != nil{
            sendResultBack(rideType: rideType, latitude: latitude, longitude: longitude, queryTime: queryTime, options: options!)
            return
        }
        self.listener = listener
        if rideType == Ride.RIDER_RIDE{
            var noOfSeats = Vehicle.VEHICLE_MAX_CAPACITY
            let userDataCache = UserDataCache.getInstance()
            if userDataCache != nil && userDataCache?.getCurrentUserVehicle().capacity != nil{
                noOfSeats = (userDataCache?.getCurrentUserVehicle().capacity)!
            }
            RouteMatcherServiceClient.getMatchingPassengerRidesAroundLocation(latitude: latitude, longitude: longitude, startTime: queryTime.timeIntervalSince1970*1000,noOfSeats: noOfSeats, delegate: self)
        }else{
            RouteMatcherServiceClient.getMatchingRiderRidesAroundLocation(latitude: latitude, longitude: longitude, startTime: queryTime.timeIntervalSince1970*1000, delegate: self)
        }
    }
    
    func getNearByOptionsFromCache(latitude: Double, longitude: Double, rideType: String, startTime :NSDate) -> [NearByRideOption]?
    {
        for  queryResult in nearByQueryResults{
            if queryResult.doesQueryMatches(latitude: latitude, longitude: longitude, rideType: rideType, startTime: startTime){
                return queryResult.nearestOptions
            }
        }
        return nil
    }
    
    func sendResultBack( rideType : String,  latitude : Double,  longitude : Double, queryTime : NSDate, options : [NearByRideOption]){
        if listener != nil {
            listener!.receiveNearestOptionLocations(rideType: rideType,latitude: latitude,longitude: longitude,queryTime: queryTime,matchLocations: options)
        }
    }
    @objc func receiveMatchingRidersAroundLocation(rideType: String, latitude: Double, longitude: Double, queryTime: NSDate, riders: [NearByRideOption]) {
        receiveNearestOptionLocations(rideType: rideType, latitude: latitude, longitude: longitude, queryTime: queryTime, matchLocations: riders)
    }
    @objc func receiveMatchingPassengersAroundLocation(rideType: String, latitude: Double, longitude: Double, queryTime: NSDate, passengers: [NearByRideOption]) {
        receiveNearestOptionLocations(rideType: rideType, latitude: latitude, longitude: longitude, queryTime: queryTime, matchLocations: passengers)
    }
    func receiveNearestOptionLocations(rideType : String,latitude : Double, longitude: Double,queryTime :NSDate, matchLocations : [NearByRideOption])
    {
        if UserSessionStatus.User == QRSessionManager.getInstance()?.getCurrentSessionStatus(){
            nearByQueryResults.append( MatchOptionQueryResult(latitude: latitude,longitude: longitude,rideType: rideType,queryTime: queryTime,nearestOptions: matchLocations))
        }
        sendResultBack(rideType: rideType, latitude: latitude, longitude: longitude, queryTime: queryTime, options: matchLocations)
    }
}
