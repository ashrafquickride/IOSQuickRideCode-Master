//
//  MatchedPassengerTaxiCache.swift
//  Quickride
//
//  Created by Ashutos on 8/7/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias matchedTaxiPassengerDetailsCompletionHandler = (_ matchedPassenger: [MatchedPassenger]?, _ responseError: NSError?) -> Void

class MatchedPassengerTaxiCache {
    static let MAX_CACHE_ENTRIES = 16
    static let DEFAULT_ROUND_PLACES = 4
    static let QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS = 45
    
    static let singleInstance = MatchedPassengerTaxiCache()
    var matchedPassengersCache =
        [String: MatchedPassengersQueryResultHolder]()
    
    init() {}
    
    static func getInstance() -> MatchedPassengerTaxiCache {
        return singleInstance
    }
    
    func refreshMatchedUsersCache() {
        matchedPassengersCache = [String: MatchedPassengersQueryResultHolder]()
    }
    
    class MatchedPassengersQueryResultHolder {
        var queryTime : NSDate?
        var queryResult : [MatchedPassenger]?
        
        init(queryTime : NSDate, queryResult : [MatchedPassenger]) {
            self.queryTime = queryTime
            self.queryResult = queryResult
        }
    }
    
    func getAllMatchedPassengers(ride : Ride, completionHandler:  @escaping matchedTaxiPassengerDetailsCompletionHandler){
        if ride.startLatitude == 0 || ride.startLongitude == 0 || ride.endLatitude == 0 || ride.endLongitude == 0{
            completionHandler([MatchedPassenger](),nil)
            return
        }
        let currntRide = ride as! PassengerRide
        let cacheKey = String(currntRide.taxiRideId!)
        let matchedPassengersQueryResult = matchedPassengersCache[cacheKey]
        if let matchedPassengersQueryResult = matchedPassengersQueryResult {
            if DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: matchedPassengersQueryResult.queryTime!) <= MatchedPassengerTaxiCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS {
                AppDelegate.getAppDelegate().log.debug("\(cacheKey) : Cache contains some query result that is still valid!!!")
                completionHandler(matchedPassengersQueryResult.queryResult,nil)
                return
            }else{
                AppDelegate.getAppDelegate().log.debug("Query result has either expired or is not available in cache, will fetch from server!!!")
               getMatchedPassengersFromServerAndRefreshInCache(ride: ride, cacheKey: cacheKey,  completionHandler: completionHandler)
            }
        } else {
        getMatchedPassengersFromServerAndRefreshInCache(ride: ride, cacheKey: cacheKey,  completionHandler: completionHandler)
        }
    }
    
    private func getMatchedPassengersFromServerAndRefreshInCache(ride: Ride,cacheKey: String, completionHandler: @escaping matchedTaxiPassengerDetailsCompletionHandler) {
        let passengerRide = ride as! PassengerRide
        TaxiPoolRestClient.getPotentialCoRiders(passengerRideId: passengerRide.rideId, taxiRideId: passengerRide.taxiRideId, filterPassengerRideId: 0) { (responseObject, error) in
            if(responseObject == nil || responseObject!["result"] as! String == "FAILURE"){
                completionHandler(nil,error)
            }else if responseObject!["result"] as! String == "SUCCESS"{
                let matchedPassenger = Mapper<MatchedPassenger>().mapArray(JSONObject: responseObject!["resultData"])!
                let matchedPassengersQueryResult = MatchedPassengersQueryResultHolder(queryTime: NSDate(), queryResult: matchedPassenger)
                self.matchedPassengersCache[cacheKey] = matchedPassengersQueryResult
                completionHandler(matchedPassenger,error)
            }
        }
    }
    
}
