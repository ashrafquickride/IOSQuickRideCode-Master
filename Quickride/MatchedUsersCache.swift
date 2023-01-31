//
//  MatchedUsersCache.swift
//  Quickride
//
//  Created by KNM Rao on 25/08/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MatchedUsersCache {
    
    static let MAX_CACHE_ENTRIES = 16
    static let DEFAULT_ROUND_PLACES = 4
    static let QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS = 45
    
    static let singleInstance = MatchedUsersCache()
    
    
    var matchedPassengersCache =
        [String: MatchedPassengersQueryResultHolder]()
    var matchedRidersCache = [String: MatchedRidersQueryResultHolder]()
    var rideMatchMetricsForPickupDrop = [String: RideMatchMetrics]()
    var gettingMatchesProgresRideIds = Set<Double>()
    var favouritePassengersCache =
        [String: FavouritePassengersQueryResultHolder]()
    var favouriteRidersCache = [String: FavouriteRidersQueryResultHolder]()
    var inActiveMatchedPassengers = [String: [MatchedPassenger]]()
    var inActiveMatchedRiders = [String: [MatchedRider]]()
    var taxiMatchedRidersCache = [Double : MatchedRidersQueryResultHolder]()
    
    init() {}
    
    static func getInstance() -> MatchedUsersCache {
        return singleInstance
    }
    func refreshMatchedUsersCache()
    {
        matchedRidersCache = [String: MatchedRidersQueryResultHolder]()
        matchedPassengersCache = [String: MatchedPassengersQueryResultHolder]()
        rideMatchMetricsForPickupDrop = [String: RideMatchMetrics]()
        inActiveMatchedPassengers.removeAll()
        inActiveMatchedRiders.removeAll()
        gettingMatchesProgresRideIds.removeAll()
    }
    
    
    func getAllMatchedRiders(ride : Ride,  rideRoute : RideRoute?,  overviewPolyline : String?,  noOfSeats : Int, requestSeqId : Int,displaySpinner : Bool,dataReceiver : MatchedUsersDataReceiver) {
        if ride.startLatitude == 0 || ride.startLongitude == 0 || ride.endLatitude == 0 || ride.endLongitude == 0{
            dataReceiver.receiveMatchedRidersList(requestSeqId: requestSeqId, matchedRiders: [MatchedRider](), currentMatchBucket: MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH)
            return
        }
        let rideStartTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
        if rideStartTime == nil{
            dataReceiver.receiveMatchedRidersList(requestSeqId: requestSeqId, matchedRiders: [MatchedRider](), currentMatchBucket: MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH)
            return
        }
        let cacheKey = getCacheKey(fromLatitude: ride.startLatitude, fromLongitude: ride.startLongitude, toLatitude: ride.endLatitude!, toLongitude: ride.endLongitude!, rideStartTime: rideStartTime!, noOfSeats: noOfSeats,fare: nil, overviewPolyline: overviewPolyline)
        let matchedRidersQueryResult = matchedRidersCache[cacheKey]
        if matchedRidersQueryResult != nil {
            let lastQueryTime = matchedRidersQueryResult!.queryTime
            if DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: lastQueryTime!) <=
                MatchedUsersCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS {
                AppDelegate.getAppDelegate().log.debug("Cache contains some query result that is still valid!!!")
                if ride.rideId == 0{
                    dataReceiver.receiveMatchedRidersList(requestSeqId: requestSeqId , matchedRiders: matchedRidersQueryResult!.queryResult!, currentMatchBucket: matchedRidersQueryResult!.currentMatchBucket!)
                    dataReceiver.receiveInactiveMatchedRidersList(requestSeqId: requestSeqId, matchedRiders: inActiveMatchedRiders[cacheKey] ?? [MatchedRider](), currentMatchBucket: matchedRidersQueryResult!.currentMatchBucket!)
                    return
                }
                else{
                    let matchedRiders = self.filterMatchedRider(matchedRiders: matchedRidersQueryResult!.queryResult!, ride: ride as! PassengerRide)
                    dataReceiver.receiveMatchedRidersList(requestSeqId: requestSeqId , matchedRiders: matchedRiders as! [MatchedRider], currentMatchBucket: matchedRidersQueryResult!.currentMatchBucket!)
                    dataReceiver.receiveInactiveMatchedRidersList(requestSeqId: requestSeqId, matchedRiders: inActiveMatchedRiders[cacheKey] ?? [MatchedRider](), currentMatchBucket: matchedRidersQueryResult!.currentMatchBucket!)
                    return
                }
            }
        }
        AppDelegate.getAppDelegate().log.debug("Query result has either expired or is not available in cache, will fetch from server!!!")

        getMatchedRidersFromServerAndRefreshInCache(ride: ride, rideRoute: rideRoute, noOfSeats: noOfSeats, dataReceiver: dataReceiver, cacheKey: cacheKey, requestSeqId: requestSeqId,displaySpinner: displaySpinner)
    }
    
    func getAllMatchedPassengers(ride : Ride,  rideRoute :RideRoute?,  overviewPolyline : String?, capacity : Int, fare : Double, requestSeqId : Int,displaySpinner : Bool, dataReceiver : MatchedUsersDataReceiver) {
        if ride.startLatitude == 0 || ride.startLongitude == 0 || ride.endLatitude == 0 || ride.endLongitude == 0{
            dataReceiver.receiveMatchedPassengersList(requestSeqId: requestSeqId, matchedPassengers: [MatchedPassenger](),currentMatchBucket: MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH)
            return
        }
        let rideStartTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
        if rideStartTime == nil{
            dataReceiver.receiveMatchedPassengersList(requestSeqId: requestSeqId, matchedPassengers: [MatchedPassenger](),currentMatchBucket: MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH)
            return
        }
        let cacheKey = getCacheKey(fromLatitude: ride.startLatitude,  fromLongitude: ride.startLongitude, toLatitude: ride.endLatitude!, toLongitude: ride.endLongitude!, rideStartTime: rideStartTime!, noOfSeats: capacity, fare : fare,overviewPolyline: overviewPolyline)
        
        
        let matchedPassengersQueryResult = matchedPassengersCache[cacheKey]
        if matchedPassengersQueryResult != nil{
            if DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: matchedPassengersQueryResult!.queryTime!) <= MatchedUsersCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS {
                AppDelegate.getAppDelegate().log.debug("\(cacheKey) : Cache contains some query result that is still valid!!!")
                let matchedPassengers = self.filterMatchedPassenger(matchedPassengers: matchedPassengersQueryResult!.queryResult!, rideId: ride.rideId)
                dataReceiver.receiveMatchedPassengersList(requestSeqId: requestSeqId, matchedPassengers: matchedPassengers as! [MatchedPassenger],currentMatchBucket : matchedPassengersQueryResult!.currentMatchBucket!)
                dataReceiver.receiveInactiveMatchedPassengers(requestSeqId: requestSeqId, matchedPassengers: inActiveMatchedPassengers[cacheKey] ?? [MatchedPassenger](), currentMatchBucket: matchedPassengersQueryResult!.currentMatchBucket!)
                return
            }
        }
        
        AppDelegate.getAppDelegate().log.debug("Query result has either expired or is not available in cache, will fetch from server!!!")
        getMatchedPassengersFromServerAndRefreshInCache(ride: ride, rideRoute: rideRoute, capacity: capacity, fare: fare, dataReceiver: dataReceiver, cacheKey: cacheKey, requestSeqId: requestSeqId,displaySpinner: displaySpinner)
    }
    
    func getInactivePassengersForRoute(ride : Ride,  rideRoute :RideRoute?,  overviewPolyline : String?, capacity : Int, fare : Double,requestSeqId : Int,cacheKey : String,dataReceiver : MatchedUsersDataReceiver){
        RouteMatcherServiceClient.getInactivePassengersForRoute(ride: ride, rideRoute: rideRoute, rideFare: String(fare), noOfSeats: String(capacity), viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let inactivePassengers = Mapper<MatchedPassenger>().mapArray(JSONObject: responseObject!["resultData"])!
                self.inActiveMatchedPassengers[cacheKey] = inactivePassengers
                let filteredMatchedPassengers = self.filterMatchedPassenger(matchedPassengers: inactivePassengers, rideId: ride.rideId)
                dataReceiver.receiveInactiveMatchedPassengers(requestSeqId: requestSeqId, matchedPassengers: filteredMatchedPassengers as! [MatchedPassenger], currentMatchBucket: self.matchedPassengersCache[cacheKey]?.currentMatchBucket ?? 0)
            }
        }
    }

    
    func getInactiveRidersForRoute( ride : Ride,  rideRoute :  RideRoute?,
                                    noOfSeats : Int,overviewPolyline : String?,cacheKey : String,
                                    dataReceiver : MatchedUsersDataReceiver){
        RouteMatcherServiceClient.getInactiveRidersForRoute(ride: ride, rideRoute: rideRoute, noOfSeats: noOfSeats, uiViewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let inactiveRiders = Mapper<MatchedRider>().mapArray(JSONObject: responseObject!["resultData"])!
                self.inActiveMatchedRiders[cacheKey] = inactiveRiders
                let matchedRiders = self.filterMatchedRider(matchedRiders: inactiveRiders, ride: ride as! PassengerRide)
                dataReceiver.receiveInactiveMatchedRidersList(requestSeqId: 1, matchedRiders: matchedRiders as! [MatchedRider], currentMatchBucket: self.matchedRidersCache[cacheKey]?.currentMatchBucket ?? 0)
            }
        }
    }
    
    func getAllFavouriteRiders(ride : Ride,  rideRoute : RideRoute?,  overviewPolyline : String?,  noOfSeats : Int, requestSeqId : Int,displaySpinner : Bool,dataReceiver : FavouriteUsersDataReceiver) {
        let rideStartTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
        if rideStartTime == nil{
            dataReceiver.receiveFavouriteRidersList(requestSeqId: requestSeqId, matchedRiders: [MatchedRider]())
            return
        }
        let cacheKey = getCacheKey(fromLatitude: ride.startLatitude, fromLongitude: ride.startLongitude, toLatitude: ride.endLatitude!, toLongitude: ride.endLongitude!, rideStartTime: rideStartTime!, noOfSeats: noOfSeats,fare: nil, overviewPolyline: overviewPolyline)
        let favouriteRidersQueryResult = favouriteRidersCache[cacheKey]
        if favouriteRidersQueryResult != nil {
            let lastQueryTime = favouriteRidersQueryResult!.queryTime
            if DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: lastQueryTime!) <=
                MatchedUsersCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS {
                AppDelegate.getAppDelegate().log.debug("Cache contains some query result that is still valid!!!")
                    dataReceiver.receiveFavouriteRidersList(requestSeqId: requestSeqId , matchedRiders: favouriteRidersQueryResult!.queryResult!)
                    return
            }
        }
        AppDelegate.getAppDelegate().log.debug("Query result has either expired or is not available in cache, will fetch from server!!!")
        
        getFavouriteRidersFromServerAndRefreshInCache(ride: ride, rideRoute: rideRoute, noOfSeats: noOfSeats, dataReceiver: dataReceiver, cacheKey: cacheKey, requestSeqId: requestSeqId,displaySpinner: displaySpinner)
    }
    
    func getFavouriteRidersFromServerAndRefreshInCache( ride : Ride,  rideRoute :  RideRoute?,
                                                      noOfSeats : Int,
                                                      dataReceiver : FavouriteUsersDataReceiver,
                                                      cacheKey : String, requestSeqId : Int,displaySpinner : Bool) {
        if displaySpinner{
            QuickRideProgressSpinner.startSpinner()
        }
        RouteMatcherServiceClient.getFavouriteUserRiderRides(ride: ride, noOfSeats: noOfSeats, uiViewController: nil){ (responseObject, error) in
            if displaySpinner{
                QuickRideProgressSpinner.stopSpinner()
            }

            if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{

                dataReceiver.matchingFavouriteRidersRetrievalFailed(requestSeqId: requestSeqId,responseObject:responseObject,error :error)
            }else if responseObject!["result"] as! String == "SUCCESS"{

                let favouriteRidersResultHolder = Mapper<MatchedRider>().mapArray(JSONObject: responseObject!["resultData"])!
                
                let matchingRiders = favouriteRidersResultHolder

                let favouriteRidersQueryResult = FavouriteRidersQueryResultHolder(queryTime: NSDate(), queryResult: matchingRiders)
                self.favouriteRidersCache[cacheKey] = favouriteRidersQueryResult
                dataReceiver.receiveFavouriteRidersList(requestSeqId: requestSeqId, matchedRiders: matchingRiders)
            }

        }
    }
    func getAllFavouritePassengers(ride : Ride,  rideRoute :RideRoute?,  overviewPolyline : String?, capacity : Int, fare : Double, requestSeqId : Int,displaySpinner : Bool, dataReceiver : FavouriteUsersDataReceiver) {
        let rideStartTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
        if rideStartTime == nil{
            dataReceiver.receiveFavouritePassengersList(requestSeqId: requestSeqId, matchedPassengers: [MatchedPassenger]())
            return
        }
        let cacheKey = getCacheKey(fromLatitude: ride.startLatitude,  fromLongitude: ride.startLongitude, toLatitude: ride.endLatitude!, toLongitude: ride.endLongitude!, rideStartTime: rideStartTime!, noOfSeats: capacity, fare : fare,overviewPolyline: overviewPolyline)


        let favouritePassengersQueryResult = favouritePassengersCache[cacheKey]
        if favouritePassengersQueryResult != nil{
            if DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: favouritePassengersQueryResult!.queryTime!) <= MatchedUsersCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS {
                AppDelegate.getAppDelegate().log.debug("\(cacheKey) : Cache contains some query result that is still valid!!!")
                dataReceiver.receiveFavouritePassengersList(requestSeqId: requestSeqId, matchedPassengers: favouritePassengersQueryResult!.queryResult!)
                return
            }
        }

        AppDelegate.getAppDelegate().log.debug("Query result has either expired or is not available in cache, will fetch from server!!!")
        getFavouritePassengersFromServerAndRefreshInCache(ride: ride, rideRoute: rideRoute, capacity: capacity, fare: fare, dataReceiver: dataReceiver, cacheKey: cacheKey, requestSeqId: requestSeqId,displaySpinner: displaySpinner)
    }
    
    func getFavouritePassengersFromServerAndRefreshInCache(ride : Ride, rideRoute : RideRoute?,
                                                         capacity : Int, fare : Double,
                                                         
                                                         dataReceiver : FavouriteUsersDataReceiver,
                                                         cacheKey : String, requestSeqId :Int,displaySpinner : Bool) {
        if displaySpinner{
            QuickRideProgressSpinner.startSpinner()
        }
        
        RouteMatcherServiceClient.getFavouriteUserPassengerRides(ride: ride, rideFare: String(fare), noOfSeats: String(capacity), viewController: nil){ (responseObject, error) in
            if displaySpinner{
                QuickRideProgressSpinner.stopSpinner()
            }
            if(responseObject == nil || responseObject!["result"] as! String == "FAILURE"){
                
                dataReceiver.matchingFavouritePassengersRetrievalFailed(requestSeqId: requestSeqId,responseObject: responseObject,error: error)
                
            }else if responseObject!["result"] as! String == "SUCCESS"{
                let matchedPassengersResultHolder = Mapper<MatchedPassenger>().mapArray(JSONObject: responseObject!["resultData"])!
                let matchingPassengers = matchedPassengersResultHolder
                let matchedPassengersQueryResult = FavouritePassengersQueryResultHolder(queryTime: NSDate(), queryResult: matchingPassengers)
                self.favouritePassengersCache[cacheKey] = matchedPassengersQueryResult
                dataReceiver.receiveFavouritePassengersList(requestSeqId: requestSeqId, matchedPassengers: matchingPassengers)
            }
        }
    }
    func getRideMatchMetrics(riderRideId : Double,  passengerRideId  : Double,
                             pickupLat : Double,pickupLng : Double,dropLat : Double,dropLng : Double, noOfSeats : Int) -> RideMatchMetrics? {
        let key = getCacheKeyForRideMatchMetrics( riderRideId: riderRideId,  passengerRideId: passengerRideId,
                                                  pickupLatitude: pickupLat, pickupLongitude: pickupLng, dropLatitude: dropLat, dropLongitude: dropLng, noOfSeats: noOfSeats)
        return rideMatchMetricsForPickupDrop[key]
    }
    func putRideMatchMetrics(riderRideId : Double,  passengerRideId  : Double,
                             pickupLat : Double,pickupLng : Double,dropLat : Double,dropLng : Double, noOfSeats : Int, rideMatchMetrics : RideMatchMetrics) {
        let key = getCacheKeyForRideMatchMetrics( riderRideId: riderRideId,  passengerRideId: passengerRideId,
                                                  pickupLatitude: pickupLat, pickupLongitude: pickupLng, dropLatitude: dropLat, dropLongitude: dropLng, noOfSeats: noOfSeats)
        rideMatchMetricsForPickupDrop[key] = rideMatchMetrics
    }
    
    func  getCacheKeyForRideMatchMetrics(riderRideId :Double,passengerRideId : Double, pickupLatitude : Double,  pickupLongitude: Double,  dropLatitude: Double,
                                         dropLongitude: Double,noOfSeats : Int) -> String
    {
        var cacheKey  = String()
        
        cacheKey = cacheKey+(StringUtils.getStringFromDouble(decimalNumber: riderRideId))
        cacheKey = cacheKey+", "
        cacheKey = cacheKey+(StringUtils.getStringFromDouble(decimalNumber: passengerRideId))
        cacheKey = cacheKey+" : "
        cacheKey = cacheKey+(String(pickupLatitude))
        cacheKey = cacheKey+", "
        cacheKey = cacheKey+(String(pickupLongitude))
        cacheKey = cacheKey+" : "
        cacheKey = cacheKey+(String(dropLatitude))
        cacheKey = cacheKey+", "
        cacheKey = cacheKey+(String(dropLongitude))
        cacheKey = cacheKey+":"
        cacheKey = cacheKey+String(noOfSeats)
        
        return cacheKey
    }
    
    func getMatchedRidersFromServerAndRefreshInCache( ride : Ride,  rideRoute :  RideRoute?,
                                                      noOfSeats : Int,
                                                      dataReceiver : MatchedUsersDataReceiver,
                                                      cacheKey : String, requestSeqId : Int,displaySpinner : Bool) {
        if gettingMatchesProgresRideIds.contains(ride.rideId){
            return
        }
        if displaySpinner{
            QuickRideProgressSpinner.startSpinner()
        }
        gettingMatchesProgresRideIds.insert(ride.rideId)
        RouteMatcherServiceClient.getMatchingRidersForRoute(ride: ride, rideRoute: rideRoute,noOfSeats: noOfSeats, uiViewController: nil,minMatchingPercent: nil) { (responseObject, error) in
            if displaySpinner{
                QuickRideProgressSpinner.stopSpinner()
            }
            self.gettingMatchesProgresRideIds.remove(ride.rideId)
            if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                
                dataReceiver.matchingRidersRetrievalFailed(requestSeqId: requestSeqId,responseObject:responseObject,error :error)
            }else if responseObject!["result"] as! String == "SUCCESS"{
                
                let matchedRidersResultHolder = Mapper<MatchedRidersResultHolder>().map(JSONObject: responseObject!["resultData"])
                let matchingRiders = matchedRidersResultHolder!.matchedRiders
                
                for matchedRider in matchingRiders{
                   
                    if let rideInvite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId : ride.rideId, rideType: ride.rideType!, matchedUserRideId: matchedRider.rideid!, matchedUserTaxiRideId: nil)
                    {
                        
                        matchedRider.newFare = rideInvite.newFare
                        if  matchedRider.pickupTime == nil || rideInvite.pickupTime > matchedRider.pickupTime! {
                            matchedRider.pickupTime = rideInvite.pickupTime
                            matchedRider.dropTime = rideInvite.dropTime
                        }
                    }
                }
                SharedPreferenceHelper.storeMatchedUserCountForRoute(rideType: Ride.PASSENGER_RIDE, fromlat: ride.startLatitude, fromlong: ride.startLongitude, tolat: ride.endLatitude!, tolong: ride.endLongitude!, noOfMatches: matchingRiders.count)
                
                let matchedRidersQueryResult = MatchedRidersQueryResultHolder(queryTime: NSDate(), queryResult: matchingRiders, currentMatchBucket: matchedRidersResultHolder!.currentMatchBucket!)
                self.matchedRidersCache[cacheKey] = matchedRidersQueryResult
                if ride.rideId == 0{
                    dataReceiver.receiveMatchedRidersList(requestSeqId: requestSeqId, matchedRiders: matchingRiders, currentMatchBucket: matchedRidersQueryResult.currentMatchBucket!)
                }
                else{
                    let matchedRiders = self.filterMatchedRider(matchedRiders: matchingRiders, ride: ride as! PassengerRide)
                    dataReceiver.receiveMatchedRidersList(requestSeqId: requestSeqId, matchedRiders: matchedRiders as! [MatchedRider], currentMatchBucket: matchedRidersResultHolder!.currentMatchBucket!)
                }
                var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
                if clientConfiguration == nil
                {
                    clientConfiguration = ClientConfigurtion()
                }
                
                if clientConfiguration!.enableToGetInactiveMatches && matchingRiders.count <= clientConfiguration!.thresoldMatchesToGetInactiveMatches{
                    self.getInactiveRidersForRoute(ride: ride, rideRoute: rideRoute, noOfSeats: noOfSeats, overviewPolyline: nil, cacheKey: cacheKey , dataReceiver: dataReceiver)
                }
            }
            
        }
    }
    
    
    
    func filterMatchedRider(matchedRiders: [MatchedRider], ride: PassengerRide) -> [MatchedUser]{
        var riders = self.filterRejectedAndPaymentPendingInvitationsAndConnectedMatchedRiders(matchedRiders: matchedRiders,ride : ride)
        riders = filterDeletedUsersFromMatchingList(matchedUsers: riders, rideId: ride.rideId)
        return riders
    }
    func filterMatchedPassenger(matchedPassengers: [MatchedPassenger], rideId: Double) -> [MatchedUser]{
        var passengers = self.filterRejectedInvitationsMatchedPassengers(matchedPassengers: matchedPassengers)
        passengers = self.filterDeletedUsersFromMatchingList(matchedUsers: passengers, rideId: rideId)
        return passengers
    }
    func filterRejectedInvitationsMatchedPassengers(matchedPassengers : [MatchedPassenger]) -> [MatchedUser]{
        
        var filteredMatchedPassengers = [MatchedPassenger]()
        for matchedPassenger in matchedPassengers{
            if (matchedPassenger.name != nil && !matchedPassenger.name!.isEmpty && RideInviteCache.getInstance().isRejectedInvitationPresentBetweenRide(rideId: matchedPassenger.rideid!, userId: matchedPassenger.userid!, rideType: Ride.PASSENGER_RIDE) == false), !RideInviteCache.getInstance().isPaymentPendingRide(rideId: matchedPassenger.rideid!) {
                    filteredMatchedPassengers.append(matchedPassenger)
            }
        }
        
        return filteredMatchedPassengers
    }
    func filterRejectedAndPaymentPendingInvitationsAndConnectedMatchedRiders(matchedRiders : [MatchedRider],ride :PassengerRide )-> [MatchedUser]{
        
        var filteredMatchedRiders = [MatchedRider]()
            for matchedRider in matchedRiders {
                if matchedRider.name != nil && !matchedRider.name!.isEmpty && RideInviteCache.getInstance().isRejectedInvitationPresentBetweenRide(rideId: matchedRider.rideid!, userId: matchedRider.userid!, rideType: Ride.RIDER_RIDE) || RideInviteCache.getInstance().isPaymentPendingRide(rideId: matchedRider.rideid ?? 0) {
                    continue
                }
                if ride.riderRideId != 0 && ride.riderRideId == matchedRider.rideid{
                    continue
                }
                filteredMatchedRiders.append(matchedRider)
            }
        
        return filteredMatchedRiders
    }
    
    
    func getMatchedPassengersFromServerAndRefreshInCache(ride : Ride, rideRoute : RideRoute?,
                                                         capacity : Int, fare : Double,
                                                         dataReceiver : MatchedUsersDataReceiver,
                                                         cacheKey : String, requestSeqId :Int,displaySpinner : Bool) {
        if gettingMatchesProgresRideIds.contains(ride.rideId){
            return
        }
        if displaySpinner{
            QuickRideProgressSpinner.startSpinner()
        }
        gettingMatchesProgresRideIds.insert(ride.rideId)
        RouteMatcherServiceClient.getMatchingPassengersForRoute(ride: ride, rideRoute: rideRoute, rideFare: String(fare), noOfSeats: String(capacity), viewController: nil) { (responseObject, error) in
            if displaySpinner{
                QuickRideProgressSpinner.stopSpinner()
            }
            self.gettingMatchesProgresRideIds.remove(ride.rideId)
            if(responseObject == nil || responseObject!["result"] as! String == "FAILURE"){
                
                dataReceiver.matchingPassengersRetrievalFailed(requestSeqId: requestSeqId,responseObject: responseObject,error: error)
                
            }else if responseObject!["result"] as! String == "SUCCESS"{
                let matchedPassengersResultHolder = Mapper<MatchedPassengersResultHolder>().map(JSONObject: responseObject!["resultData"])!
                let matchingPassengers = matchedPassengersResultHolder.matchedPassengers
                
                for matchedPassenger in matchingPassengers{
                    if let rideInvite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId : ride.rideId, rideType: ride.rideType!, matchedUserRideId: matchedPassenger.rideid!, matchedUserTaxiRideId: nil){
                        matchedPassenger.newFare = rideInvite.newRiderFare

                        if  matchedPassenger.pickupTime == nil || rideInvite.pickupTime > matchedPassenger.pickupTime! {
                            matchedPassenger.pickupTime = rideInvite.pickupTime
                            matchedPassenger.dropTime = rideInvite.dropTime
                        }
                    }
                }
                SharedPreferenceHelper.storeMatchedUserCountForRoute(rideType: Ride.RIDER_RIDE, fromlat: ride.startLatitude, fromlong: ride.startLongitude, tolat: ride.endLatitude!, tolong: ride.endLongitude!, noOfMatches: matchingPassengers.count)
                let matchedPassengersQueryResult = MatchedPassengersQueryResultHolder(queryTime: NSDate(), queryResult: matchingPassengers, currentMatchBucket: matchedPassengersResultHolder.currentMatchBucket!)
                self.matchedPassengersCache[cacheKey] = matchedPassengersQueryResult
                let matchedPassengers = self.filterMatchedPassenger(matchedPassengers: matchingPassengers, rideId: ride.rideId)
                dataReceiver.receiveMatchedPassengersList(requestSeqId: requestSeqId, matchedPassengers: matchedPassengers as! [MatchedPassenger], currentMatchBucket: matchedPassengersResultHolder.currentMatchBucket!)
                var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
                if clientConfiguration == nil
                {
                    clientConfiguration = ClientConfigurtion()
                }
                
                if clientConfiguration!.enableToGetInactiveMatches && matchingPassengers.count <= clientConfiguration!.thresoldMatchesToGetInactiveMatches{
                    self.getInactivePassengersForRoute(ride: ride, rideRoute: rideRoute, overviewPolyline: ride.routePathPolyline, capacity: capacity, fare: fare, requestSeqId: 1, cacheKey: cacheKey, dataReceiver: dataReceiver)
                }
            }
        }
    }
    
    func getMatchedRidersFromServerForNextBucketAndRefreshInCache(ride : Ride,rideRoute : RideRoute?,noOfSeats : Int,overviewPolyline : String?,currentMatchBucket : Int?,dataReceiver : MatchedUsersDataReceiver){
        
        let rideStartTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
        let cacheKey = getCacheKey(fromLatitude: ride.startLatitude, fromLongitude: ride.startLongitude, toLatitude: ride.endLatitude!, toLongitude: ride.endLongitude!, rideStartTime: rideStartTime!, noOfSeats: noOfSeats,fare: nil, overviewPolyline: overviewPolyline)
        
        RouteMatcherServiceClient.getMatchingRidersForRouteForNextBucket(ride: ride, rideRoute: rideRoute, noOfSeats: noOfSeats,currentMatchBucket : currentMatchBucket!,uiViewController: nil) { (responseObject, error) in
            
            if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                
                dataReceiver.matchingRidersRetrievalFailed(requestSeqId: 1,responseObject:responseObject,error :error)
            }else if responseObject!["result"] as! String == "SUCCESS"{
                let matchingOptionsData = Mapper<MatchedRidersResultHolder>().map(JSONObject: responseObject!["resultData"])
                let matchingRiders = matchingOptionsData!.matchedRiders
                for matchedRider in matchingRiders{
                    if let rideInvite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId : ride.rideId, rideType: ride.rideType!, matchedUserRideId: matchedRider.rideid!, matchedUserTaxiRideId: nil){
                        matchedRider.newFare = rideInvite.newFare
                        if rideInvite.pickupTime != 0 && matchedRider.pickupTime != nil && rideInvite.pickupTime > matchedRider.pickupTime! {
                            matchedRider.pickupTime = rideInvite.pickupTime
                            matchedRider.dropTime = rideInvite.dropTime
                        }
                    }
                }
                SharedPreferenceHelper.storeMatchedUserCountForRoute(rideType: Ride.PASSENGER_RIDE, fromlat: ride.startLatitude, fromlong: ride.startLongitude, tolat: ride.endLatitude!, tolong: ride.endLongitude!, noOfMatches: matchingRiders.count)
                
                let matchedRidersQueryResult = MatchedRidersQueryResultHolder(queryTime: NSDate(), queryResult: matchingRiders, currentMatchBucket: matchingOptionsData!.currentMatchBucket!)
                self.matchedRidersCache[cacheKey] = matchedRidersQueryResult
                if ride.rideId == 0{
                    dataReceiver.receiveMatchedRidersList(requestSeqId: 1, matchedRiders: matchingRiders, currentMatchBucket: matchedRidersQueryResult.currentMatchBucket!)
                }
                else{
                    let matchedRiders = self.filterMatchedRider(matchedRiders: matchingRiders, ride: ride as! PassengerRide)
                    dataReceiver.receiveMatchedRidersList(requestSeqId: 1, matchedRiders: matchedRiders as! [MatchedRider], currentMatchBucket: matchedRidersQueryResult.currentMatchBucket!)
                }
                
            }
        }
        
        
    }
    func getMatchedPassengersFromServerForNextBucketAndRefreshInCache(ride : Ride,rideRoute : RideRoute?,noOfSeats : Int,fare : Double,overviewPolyline : String?,currentMatchBucket : Int?,dataReceiver : MatchedUsersDataReceiver){
        
        let rideStartTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
        let cacheKey = getCacheKey(fromLatitude: ride.startLatitude, fromLongitude: ride.startLongitude, toLatitude: ride.endLatitude!, toLongitude: ride.endLongitude!, rideStartTime: rideStartTime!, noOfSeats: noOfSeats,fare: nil, overviewPolyline: overviewPolyline)
        
        RouteMatcherServiceClient.getMatchingPassengersForRouteForNextBucket(ride: ride, rideRoute: rideRoute, rideFare: String(fare), noOfSeats: String(noOfSeats), currentMatchBucket: currentMatchBucket!, uiViewController: nil) { (responseObject, error) in
            if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                
                dataReceiver.matchingPassengersRetrievalFailed(requestSeqId: 1,responseObject:responseObject,error :error)
            }else if responseObject!["result"] as! String == "SUCCESS"{
                let matchedPassengersResultHolder = Mapper<MatchedPassengersResultHolder>().map(JSONObject: responseObject!["resultData"])
                let matchingPassengers = matchedPassengersResultHolder!.matchedPassengers
                
                for matchedPassenger in matchingPassengers{
                    if let rideInvite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId : ride.rideId, rideType: ride.rideType!, matchedUserRideId: matchedPassenger.rideid!, matchedUserTaxiRideId: nil){
                        matchedPassenger.newFare = rideInvite.newRiderFare
                        if rideInvite.pickupTime != 0 && matchedPassenger.pickupTime != nil && rideInvite.pickupTime > matchedPassenger.pickupTime! {
                            matchedPassenger.pickupTime = rideInvite.pickupTime
                            matchedPassenger.dropTime = rideInvite.dropTime
                        }
                    }
                    
                }
                SharedPreferenceHelper.storeMatchedUserCountForRoute(rideType: Ride.RIDER_RIDE, fromlat: ride.startLatitude, fromlong: ride.startLongitude, tolat: ride.endLatitude!, tolong: ride.endLongitude!, noOfMatches: matchingPassengers.count)
                let matchedPassengersQueryResult = MatchedPassengersQueryResultHolder(queryTime: NSDate(), queryResult: matchingPassengers, currentMatchBucket: matchedPassengersResultHolder!.currentMatchBucket!)
                self.matchedPassengersCache[cacheKey] = matchedPassengersQueryResult
                let matchedPassengers = self.filterMatchedPassenger(matchedPassengers: matchingPassengers, rideId: ride.rideId)
                dataReceiver.receiveMatchedPassengersList(requestSeqId: 1, matchedPassengers: matchedPassengers as! [MatchedPassenger], currentMatchBucket: matchedPassengersResultHolder!.currentMatchBucket!)
            }
        }
    }
    
    func  getCacheKey( fromLatitude : Double,  fromLongitude: Double,  toLatitude: Double,toLongitude: Double,  rideStartTime : String, noOfSeats : Int,fare:Double?, overviewPolyline : String? ) -> String
    {
        var cacheKey  = String()
        
        cacheKey = cacheKey+(String(Double(round(10000*fromLatitude)/10000)))
        cacheKey = cacheKey+", "
        cacheKey = cacheKey+(String(Double(round(10000*fromLongitude)/10000)))
        cacheKey = cacheKey+" : "
        cacheKey = cacheKey+(String(Double(round(10000*toLatitude)/10000)))
        cacheKey = cacheKey+", "
        cacheKey = cacheKey+(String(Double(round(10000*toLongitude)/10000)))
        if overviewPolyline != nil && overviewPolyline!.isEmpty == false {
            cacheKey = cacheKey+":"
            cacheKey = cacheKey+overviewPolyline!
        }
        cacheKey = cacheKey+"@"
        cacheKey = cacheKey + rideStartTime
        cacheKey = cacheKey+":"
        cacheKey = cacheKey+String(noOfSeats)
        if fare != nil{
            cacheKey = cacheKey+String(fare!)
        }
        
        return cacheKey
    }
    
    func filterDeletedUsersFromMatchingList(matchedUsers : [MatchedUser],rideId : Double) -> [MatchedUser]{
        var filteredMatchedUsers = [MatchedUser]()
        let ignoredUsersRideId = SharedPreferenceHelper.getIgnoredRideIds(rideId: StringUtils.getStringFromDouble(decimalNumber: rideId))
        if ignoredUsersRideId.isEmpty{
            return matchedUsers
        }
        for matchedUser in matchedUsers
        {
            if ignoredUsersRideId.contains(matchedUser.rideid!)
            {
                continue
            }else{
                filteredMatchedUsers.append(matchedUser)
            }
        }
        return filteredMatchedUsers
    }
    
    func addUsersToDeletedMatchedUsersList(ignoredRideId : Double, rideId: Double){
        SharedPreferenceHelper.storeIgnoredRideId(ignoredRideId: ignoredRideId, rideId: StringUtils.getStringFromDouble(decimalNumber: rideId))
    }
    
    func getAllMatchedRidersForTaxi(taxiRide: TaxiRidePassenger,dataReceiver: TaxiMatchedRidersDataReceiver) {
        if let taxiMatchedRidersQueryResult = taxiMatchedRidersCache[taxiRide.id ?? 0] {
            if DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: taxiMatchedRidersQueryResult.queryTime ?? NSDate()) <=
                MatchedUsersCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS {
                AppDelegate.getAppDelegate().log.debug("Cache contains some valid riders")
                let matchedRiders = taxiMatchedRidersQueryResult.queryResult ?? [MatchedRider]()
                dataReceiver.receiveMatchedRidersList(matchedRiders: matchedRiders)
                return
            }
        }
        AppDelegate.getAppDelegate().log.debug("result is expired or is not available in cache")
        getMatchedRidersFromServer(ride: Ride(taxiRide: taxiRide),dataReceiver: dataReceiver)
    }
    
    func getMatchedRidersFromServer(ride: Ride,dataReceiver: TaxiMatchedRidersDataReceiver) {
        let minMatchingPercent = ConfigurationCache.getObjectClientConfiguration().minMatchingPercentForTaxiRidesToRetrieveCarpoolRiders
        RouteMatcherServiceClient.getMatchingRidersForRoute(ride: ride, rideRoute: nil,noOfSeats: 1, uiViewController: nil, minMatchingPercent: minMatchingPercent) { (responseObject, error) in
            if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                dataReceiver.matchingRidersRetrievalFailed(responseObject: responseObject, error: error)
            }else if responseObject!["result"] as! String == "SUCCESS"{
                let matchedRidersResultHolder = Mapper<MatchedRidersResultHolder>().map(JSONObject: responseObject!["resultData"])
                let matchingRiders = matchedRidersResultHolder!.matchedRiders
                let matchedRidersQueryResult = MatchedRidersQueryResultHolder(queryTime: NSDate(), queryResult: matchingRiders, currentMatchBucket: matchedRidersResultHolder!.currentMatchBucket!)
                self.taxiMatchedRidersCache[ride.rideId] = matchedRidersQueryResult
                dataReceiver.receiveMatchedRidersList(matchedRiders: matchingRiders)
            }
        }
    }
    
    class MatchedRidersQueryResultHolder {
        var queryTime : NSDate?
        var queryResult : [MatchedRider]?
        var currentMatchBucket : Int?
        
        init(queryTime : NSDate, queryResult : [MatchedRider],currentMatchBucket : Int) {
            self.queryTime = queryTime
            self.queryResult = queryResult
            self.currentMatchBucket = currentMatchBucket
        }
    }
    
    class MatchedPassengersQueryResultHolder {
        var queryTime : NSDate?
        var queryResult : [MatchedPassenger]?
        var currentMatchBucket : Int?
        
        init(queryTime : NSDate, queryResult : [MatchedPassenger] ,currentMatchBucket : Int) {
            self.queryTime = queryTime
            self.queryResult = queryResult
            self.currentMatchBucket = currentMatchBucket
        }
    }
    
    class FavouriteRidersQueryResultHolder {
        var queryTime : NSDate?
        var queryResult : [MatchedRider]?
        
        init(queryTime : NSDate, queryResult : [MatchedRider]) {
            self.queryTime = queryTime
            self.queryResult = queryResult
        }
    }
    
    class FavouritePassengersQueryResultHolder {
        var queryTime : NSDate?
        var queryResult : [MatchedPassenger]?
        
        init(queryTime : NSDate, queryResult : [MatchedPassenger]) {
            self.queryTime = queryTime
            self.queryResult = queryResult
        }
    }
}
