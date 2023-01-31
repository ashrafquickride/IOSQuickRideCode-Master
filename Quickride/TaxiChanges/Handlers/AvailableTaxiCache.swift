//
//  AvailableTaxiCache.swift
//  Quickride
//
//  Created by Quick Ride on 2/5/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AvailableTaxiCache {
    
    static let QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS = 45
    static let singleInstance = AvailableTaxiCache()
    
    var availableTaxiCache = [Double: DetailedEstimateFare]()
    var matchingTaxipool = [Double: MatchedTaxiRideGroup]()
    
    init() {}
    
    static func getInstance() -> AvailableTaxiCache {
        return singleInstance
    }
    
    func getAvailableTaxis(passengerRide: PassengerRide, handler : @escaping (_ detailEstimatedFare : RestResponse<DetailedEstimateFare>) -> Void) {
        if let matchedTaxiRideQueryResult = availableTaxiCache[passengerRide.rideId], NSDate().getTimeStamp() - matchedTaxiRideQueryResult.lastUpdateTime <=  Double(AvailableTaxiCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS)*1000.0 {
            handler(RestResponse<DetailedEstimateFare>(result: matchedTaxiRideQueryResult))
        }else{
            getAvailableTaxisFromServer(passengerRide: passengerRide, handler: handler)
        }
    }
    
    private func getAvailableTaxisFromServer(passengerRide: PassengerRide,  handler : @escaping (_ detailEstimatedFare : RestResponse<DetailedEstimateFare>) -> Void) {
        var tripTye = TaxiPoolConstants.TRIP_TYPE_LOCAL
        var journeyType: String?
        var endTime: Double?
        var startTime = passengerRide.startTime
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if (passengerRide.distance ?? 0) > clientConfiguration.minDistanceForInterCityRide{
            tripTye = TaxiPoolConstants.TRIP_TYPE_OUTSTATION
            journeyType = TaxiPoolConstants.JOURNEY_TYPE_ROUND_TRIP
            endTime = passengerRide.expectedEndTime
            startTime = DateUtils.addMinutesToTimeStamp(time: passengerRide.startTime, minutesToAdd: clientConfiguration.outStationInstantBookingThresholdTimeInMins)
        }
        
        TaxiPoolRestClient.getAvailableTaxiDetails(startTime: startTime, expectedEndTime: endTime, startAddress: passengerRide.startAddress, startLatitude: passengerRide.startLatitude , startLongitude: passengerRide.startLongitude , endLatitude: passengerRide.endLatitude! , endLongitude: passengerRide.endLongitude!, endAddress: passengerRide.endAddress,journeyType: journeyType,routeId: passengerRide.routeId) { [weak self] (responseObject, error) in
            let restResponse = RestResponse<DetailedEstimateFare>(responseObject: responseObject, error: error)
            if let detailedEstimatedFare =  restResponse.result {
                detailedEstimatedFare.lastUpdateTime = NSDate().getTimeStamp()
                self?.availableTaxiCache[passengerRide.rideId] = detailedEstimatedFare
            }
            handler(restResponse)
        }
    }
    
    //Get taxipool
    func getMatchingTaxipool(scheduleRide: Ride,handler : @escaping (_ matchedTaxiRideGroup: MatchedTaxiRideGroup?) -> Void){
        if let matchingTaxipool = matchingTaxipool[scheduleRide.rideId]{
            let timeDiff = DateUtils.getTimeDifferenceInSeconds(date1: NSDate() , date2: matchingTaxipool.lastUpdatedTime ?? NSDate())
            if timeDiff < AvailableTaxiCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS{
                handler(matchingTaxipool)
                return
            }
        }
        getMatchingTaxipoolFromServer(scheduleRide: scheduleRide, handler: handler)
    }
    
    private func getMatchingTaxipoolFromServer(scheduleRide: Ride,handler : @escaping (_ matchedTaxiRideGroup: MatchedTaxiRideGroup?) -> Void){
        TaxiSharingRestClient.getMatchingTaxipool(startTime: scheduleRide.startTime, startLat: scheduleRide.startLatitude, startLng: scheduleRide.startLongitude, endLat: scheduleRide.endLatitude ?? 0, endLng: scheduleRide.endLongitude ?? 0, noOfSeats: 1, routeId: scheduleRide.routeId ?? 0, expectedEndTime: scheduleRide.expectedEndTime ?? 0, distance: scheduleRide.distance ?? 0, requiresFare: true) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if var matchedTaxiRideGroup = Mapper<MatchedTaxiRideGroup>().map(JSONObject: responseObject!["resultData"]) {
                    matchedTaxiRideGroup.startAddress = scheduleRide.startAddress
                    matchedTaxiRideGroup.endAddress = scheduleRide.endAddress
                    self.matchingTaxipool[scheduleRide.rideId] = matchedTaxiRideGroup
                    handler(matchedTaxiRideGroup)
                }else{
                    handler(nil)
                }
            }else{
                handler(nil)
            }
        }
    }
}
