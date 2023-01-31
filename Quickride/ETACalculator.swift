//
//  ETACalculator.swift
//  Quickride
//
//  Created by KNM Rao on 09/12/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
import ObjectMapper


class ETACalculator {

    static let ETA_RIDER_CROSSED_PICKUP_ERROR = 7008
    static let ETA_RIDER_RIDER_LOCATION_NOT_AVAILABLE_ERROR = 1203
    
    static let MAX_TIME_EXPIRY_FOR_DURATION_MINS = 9
    static let THRESHOLD_DISTANCE : Double = 100*1000 // 100 KM
    
    var etaCache = [String:RouteMetrics]()
    var etaInProgress = false
    static var etaCalculator : ETACalculator?

    static func getInstance() -> ETACalculator{
        if etaCalculator == nil{
            etaCalculator = ETACalculator()
        }
        return etaCalculator!
    }

    func calculateETAForRider(rideDetailInfo : RideDetailInfo,routeId : Double, riderCurrentLocation :CLLocationCoordinate2D,riderPreviousLocation : CLLocationCoordinate2D?,destinations : [CLLocationCoordinate2D],eTAReceiver: @escaping (_ routeMetrics : [RouteMetrics]) -> Void) {
        getRoutePathData(rideDetailInfo: rideDetailInfo, routeId :routeId, riderCurrentLocation: riderCurrentLocation) { (routePathData,riderLatestCurrentLocation) in

            self.calculateETA(riderRide: rideDetailInfo.riderRide!, routePathData: routePathData, riderCurrentLocation: riderLatestCurrentLocation, destinations: destinations,handler: { (routeMetricsList) in
                eTAReceiver(routeMetricsList)
            })
        }

    }
    var routesRetrievalInProgress = Set<Double>()
    func getRoutePathData(rideDetailInfo : RideDetailInfo,routeId : Double,riderCurrentLocation : CLLocationCoordinate2D, handler : @escaping (_ routePathData : RoutePathData?,_ riderCurrentLocation : CLLocationCoordinate2D)->Void){


        if let routePathData = rideDetailInfo.riderRideRoutePathData{
            return handler(routePathData,riderCurrentLocation)
        }else{
            if (routesRetrievalInProgress.contains(routeId)) {
                return
            }
            routesRetrievalInProgress.insert(routeId);
            RoutePathServiceClient.getRideRouteWithCurrentTrafficInfo(routeId: routeId,departureTime: rideDetailInfo.riderRide!.startTime, viewController: nil, completionHandler: { (responseObject, error) in
                self.routesRetrievalInProgress.remove(routeId)
                if responseObject != nil && responseObject![HttpUtils.RESULT] as! String == HttpUtils.RESPONSE_SUCCESS{
                    let riderRoutePathData = Mapper<RoutePathData>().map(JSONObject: responseObject![HttpUtils.RESULT_DATA])
                    if riderRoutePathData != nil &&
                        riderRoutePathData!.routeSteps.isEmpty == false{
                        if let rideId = rideDetailInfo.riderRide?.rideId{
                            MyActiveRidesCache.getRidesCacheInstance()?.addRoutepathDataToRideDetailInfo(routePathData: riderRoutePathData!, riderRideId: rideId)
                        }
                        return handler(riderRoutePathData,riderCurrentLocation)
                    }
                }
                return handler(nil,riderCurrentLocation)
            })
        }
    }

    func clearRouteMetricsForRoute(riderRideId : Double) {
        SharedPreferenceHelper.clearRouteMetricsForRideId(riderRideId: riderRideId)
    }

    private func calculateETA(riderRide : RiderRide,routePathData : RoutePathData?, riderCurrentLocation : CLLocationCoordinate2D,destinations : [CLLocationCoordinate2D],handler : @escaping (_ routeMetrics: [RouteMetrics]) -> Void){
        
        var routeMetricsList = [LatLng: RouteMetrics]()
        var routeMetricsExpiredDestinations = [LatLng]()
        var notAvaiableRouteMetrics = [CLLocationCoordinate2D]()
        var updatedRiderCurrentLocation = riderCurrentLocation
        
        for destination in destinations {
            let latLng = LatLng(lat: destination.latitude, long: destination.longitude)
            if routePathData != nil {
                let searcher =  StartAndEndPointSearchOnRoute(riderRoute: routePathData!, startPoint: updatedRiderCurrentLocation, endPoint: destination,thresholdDistance: ETACalculator.THRESHOLD_DISTANCE)
                searcher.performSearch()
                if searcher.lastMinStartDistance != -1 && searcher.lastMinStartDistance < 60 && searcher.matchedStartPointOnRoute
                    != nil{
                    updatedRiderCurrentLocation = searcher.matchedStartPointOnRoute!
                }
                if searcher.isStartLocationCrossedDestination(){
                    let routeMetrics = RouteMetrics()
                    routeMetrics.fromLat = updatedRiderCurrentLocation.latitude
                    routeMetrics.fromLng = updatedRiderCurrentLocation.longitude
                    routeMetrics.toLat = destination.latitude
                    routeMetrics.toLng = destination.longitude
                    routeMetrics.routeDistance = 0.0
                    routeMetrics.departureTime = 0.0
                    routeMetrics.arrivalTime = 0.0
                    routeMetrics.journeyDurationInTraffic = 0
                    routeMetrics.journeyDuration = 0
                    routeMetrics.creationTime = NSDate().getTimeStamp()
                    routeMetrics.error = ResponseError(errorCode: ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR,userMessage: Strings.eta_not_available_rider_crossed_pickup)
                    routeMetricsList[latLng] = routeMetrics
                    continue
                    
                }
                
                
                if destinations.count == 1 && riderRide.endLatitude == destination.latitude && riderRide.endLongitude == destination.longitude {
                    if let routeMetrics = getRouteMetrics(rideId: riderRide.rideId, destination: destination) {
                        if let newRouteMetrics = calculateRouteMetricsForCurrentLocation(riderCurrentLocation: updatedRiderCurrentLocation, destination: destination, departureTime: riderRide.startTime, searcher: searcher, routeMetrics: routeMetrics) {
                            routeMetricsList[latLng] = newRouteMetrics
                        } else {
                            routeMetricsList[latLng] = routeMetrics
                        }
                        return handler(Array(routeMetricsList.values))
                    }
                    
                }
                
                if isETAValid(riderRide: riderRide, destination: destination) {
                    if let routeMetrics = getRouteMetrics(rideId: riderRide.rideId, destination: destination),let newRouteMetrics = calculateRouteMetricsForCurrentLocation(riderCurrentLocation: updatedRiderCurrentLocation, destination: destination, departureTime: riderRide.startTime, searcher: searcher, routeMetrics: routeMetrics) {
                        routeMetricsList[latLng] = newRouteMetrics
                        continue
                    }
               }
            
               if let routeMetrics = getRouteMetrics(rideId: riderRide.rideId, destination: destination),let newRouteMetrics = calculateRouteMetricsForCurrentLocation(riderCurrentLocation: updatedRiderCurrentLocation, destination: destination, departureTime: riderRide.startTime, searcher: searcher, routeMetrics: routeMetrics) {
                   routeMetricsList[latLng] = newRouteMetrics
                   routeMetricsExpiredDestinations.append(latLng)
                   continue
                }
                
                notAvaiableRouteMetrics.append(destination)
                
            }
            if let nextPickUp = getNextPickUp(routeMetricsList: routeMetricsList) {
                let locationCoordinate = CLLocationCoordinate2D(latitude: nextPickUp.latitude, longitude: nextPickUp.longitude)
                if routeMetricsExpiredDestinations.contains(nextPickUp) {
                    notAvaiableRouteMetrics.append(locationCoordinate)
                } else {
                    if let nextRouteMetrics = getRouteMetrics(rideId: riderRide.rideId, destination: destination) {
                        for expiredDest in routeMetricsExpiredDestinations {
                            if let existing = routeMetricsList[expiredDest] {
                                let duration = calculateRouteMetrics(distance: nextRouteMetrics.routeDistance, duration: nextRouteMetrics.journeyDurationInTraffic, matchingDistance: existing.routeDistance/1000)
                                existing.journeyDurationInTraffic = duration
                                existing.journeyDuration = duration
                                routeMetricsList[expiredDest] = existing
                            }
                        }
                    }
                }
            }
        }
        
        if notAvaiableRouteMetrics.isEmpty {
            return handler(Array(routeMetricsList.values))
        }
        
        if etaInProgress {
            return
        }
        
        etaInProgress = true
        
        guard let user = UserDataCache.getInstance()?.getUser() else { return }
        var useCase : String
        
        if user.phoneNumber == 0 {
            useCase = "iOS.App.User.Eta.ETACalculator"
        } else if user.phoneNumber == riderRide.userId {
            useCase = "iOS.App.Rider.Eta.ETACalculator"
        }else{
            useCase = "iOS.App.Passenger.Eta.ETACalculator"
        }
        var origins = [CLLocationCoordinate2D]()
        origins.append(updatedRiderCurrentLocation)
        
//        RoutePathServiceClient.getRouteDurationAndDistanceInTraffic(rideId: riderRide.rideId , useCase: useCase, origins: origins , destinations: notAvaiableRouteMetrics, startTime: riderRide.startTime) { (responseObject, error) in
//            self.etaInProgress = false
//            if responseObject != nil && responseObject!["result"] as? String == "SUCCESS"{
//                if let routeMetricsListFresh = Mapper<RouteMetrics>().mapArray(JSONObject: responseObject!["resultData"]){
//                    for routeMetrics in routeMetricsListFresh {
//                        let destination = LatLng(lat: routeMetrics.toLat, long: routeMetrics.toLng)
//                        routeMetricsList[destination] = routeMetrics
//
//                        for (index,expiredDestination) in routeMetricsExpiredDestinations.enumerated() {
//                            if expiredDestination == destination {
//                                routeMetricsExpiredDestinations.remove(at: index)
//                                break
//                            }
//                        }
//                        let locationCoordinate = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
//                        self.saveRouteMetrics(riderRideId: riderRide.rideId, destination: locationCoordinate, routeMetrics: routeMetrics)
//                    }
//                    if let nextPickUp = self.getNextPickUp(routeMetricsList: routeMetricsList),let nextRouteMetrics = routeMetricsList[nextPickUp] {
//                        for expiredDestination in routeMetricsExpiredDestinations {
//                            if  let existing = routeMetricsList[expiredDestination] {
//                                let duration = self.calculateRouteMetrics(distance: nextRouteMetrics.routeDistance, duration: nextRouteMetrics.journeyDurationInTraffic, matchingDistance: existing.routeDistance)
//                                existing.journeyDurationInTraffic = duration
//                                existing.journeyDuration = duration
//                                routeMetricsList[expiredDestination] = existing
//                            }
//                        }
//
//                    }
//                    handler(Array(routeMetricsList.values))
//                }
//            } else {
//                let temp = self.handleETACalculationFailure(departureTime: riderRide.startTime, destinations: notAvaiableRouteMetrics, riderCurrentLocation: riderCurrentLocation, routePathData: routePathData!)
//                for tempElement in temp {
//                    routeMetricsList[tempElement.0] = tempElement.1
//                }
//                handler(Array(routeMetricsList.values))
//            }
//        }
    }
    
    private func calculateRouteMetricsForCurrentLocation(riderCurrentLocation:CLLocationCoordinate2D,destination:CLLocationCoordinate2D,departureTime: Double,searcher: StartAndEndPointSearchOnRoute,routeMetrics:RouteMetrics) -> RouteMetrics? {
        if !searcher.isStartLocationCrossedDestination() {
            var matchedDistance = searcher.getRouteDistanceBetweenMatchedPoints()
            if matchedDistance == 0 && searcher.matchedStartPointOnRoute == nil {
                return routeMetrics
            }
            if matchedDistance < 0 {
                matchedDistance = 1
            }
            guard let routeMetricsNew = routeMetrics.copy() as? RouteMetrics else { return nil }
            let deltaDistance = LocationClientUtils.getDistance(fromLatitude: riderCurrentLocation.latitude, fromLongitude: riderCurrentLocation.longitude, toLatitude: searcher.matchedStartPointOnRoute?.latitude ?? 0.0, toLongitude: searcher.matchedStartPointOnRoute?.longitude ?? 0.0)
            matchedDistance += deltaDistance
            let duration = calculateRouteMetrics(distance: routeMetrics.routeDistance, duration: routeMetrics.journeyDurationInTraffic, matchingDistance: matchedDistance)
            let currentTime = NSDate().getTimeStamp()
            var depTime = departureTime
            if depTime < currentTime {
                depTime = currentTime
            }
            routeMetricsNew.fromLat = riderCurrentLocation.latitude
            routeMetricsNew.fromLng = riderCurrentLocation.longitude
            routeMetricsNew.toLat = destination.latitude
            routeMetricsNew.toLng = destination.longitude
            routeMetricsNew.routeDistance = matchedDistance
            routeMetricsNew.departureTime = depTime
            routeMetricsNew.arrivalTime = depTime+Double(duration*60000)
            routeMetricsNew.creationTime = currentTime
            routeMetricsNew.journeyDurationInTraffic = duration
            routeMetricsNew.journeyDuration = duration
            routeMetricsNew.error = nil
            return routeMetricsNew
        }
        return nil
    }
    
    
    private func isETAValid(riderRide: RiderRide, destination: CLLocationCoordinate2D) -> Bool {
        let routeMetrics = getRouteMetrics(rideId: riderRide.rideId, destination: destination)
        if routeMetrics == nil || routeMetrics!.creationTime == 0 || DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: NSDate().getTimeStamp(), time2: routeMetrics!.creationTime) <= ETACalculator.MAX_TIME_EXPIRY_FOR_DURATION_MINS {
            return false
        }
        return true
    }
    
    private func getNextPickUp(routeMetricsList: [LatLng: RouteMetrics]) -> LatLng? {
        var nextRouteMetrics: RouteMetrics?
        var nextPickUp: LatLng?
        for latlng in Array(routeMetricsList.keys) {
            if let value = routeMetricsList[latlng],value.error == nil,value.routeDistance > 500 {
                if nextRouteMetrics == nil {
                    nextRouteMetrics = value
                    nextPickUp = latlng
                } else if value.routeDistance < nextRouteMetrics!.routeDistance {
                    nextRouteMetrics = value
                    nextPickUp = latlng
                }
            }
        }
        return nextPickUp
    }
    
    private func handleETACalculationFailure(departureTime: Double,destinations: [CLLocationCoordinate2D],riderCurrentLocation: CLLocationCoordinate2D,routePathData: RoutePathData) -> [LatLng:RouteMetrics]{
        var routeMetricsList = [LatLng:RouteMetrics]()
        for destination in destinations {
            let latLng = LatLng(lat: destination.latitude, long: destination.longitude)
            let searcher = StartAndEndPointSearchOnRoute(riderRoute: routePathData, startPoint: riderCurrentLocation, endPoint: destination, thresholdDistance: ETACalculator.THRESHOLD_DISTANCE)
            searcher.performSearch()
            if searcher.isStartLocationCrossedDestination() {
                var matchedDistance = searcher.getRouteDistanceBetweenMatchedPoints()
                let deltaDistance = LocationClientUtils.getDistance(fromLatitude: riderCurrentLocation.latitude, fromLongitude: riderCurrentLocation.longitude, toLatitude: searcher.startPoint.latitude, toLongitude: searcher.startPoint.longitude)
                matchedDistance += deltaDistance
                let routeMetricsNew = RouteMetrics()
                routeMetricsNew.fromLat = riderCurrentLocation.latitude
                routeMetricsNew.fromLng = riderCurrentLocation.longitude
                routeMetricsNew.toLat = destination.latitude
                routeMetricsNew.toLng = destination.longitude
                var depTime = departureTime
                let currentTime = NSDate().timeIntervalSince1970
                if depTime < currentTime {
                    depTime = currentTime
                }
                routeMetricsNew.departureTime = depTime
                let duration = calculateRouteMetrics(distance: routePathData.distance, duration: routePathData.durationInTraffic, matchingDistance: matchedDistance)
                routeMetricsNew.journeyDurationInTraffic = duration
                routeMetricsNew.journeyDuration = duration
                routeMetricsNew.arrivalTime = departureTime+Double((duration*60000))
                routeMetricsNew.creationTime = currentTime
                routeMetricsNew.routeDistance = matchedDistance
                routeMetricsList[latLng] = routeMetricsNew
               
            }
        }
        return routeMetricsList
    }
    
    func getKey(riderRideId : Double, dest : CLLocationCoordinate2D) -> String{
        return StringUtils.getStringFromDouble(decimalNumber: riderRideId)+":\(dest.latitude),\(dest.longitude)"
    }

    private func calculateRouteMetrics(distance : Double,duration : Int, matchingDistance : Double) -> Int {
        var durationInTraffic = 0
        var distanceToCalculate = distance
        var durationToCalculate = duration
        if distance != 0 || duration != 0{
            if durationToCalculate < 1{
                durationToCalculate = 1
            }
            if distanceToCalculate < 500{
                distanceToCalculate = 500
            }
            let speedInTraffic = distanceToCalculate/Double(durationToCalculate*60) // mps
            durationInTraffic = Int((matchingDistance/speedInTraffic)/60)
        }
        if durationInTraffic <= 0{
            durationInTraffic = 1
        }
        return durationInTraffic
    }

    private func getRouteMetrics(rideId : Double, destination : CLLocationCoordinate2D) -> RouteMetrics? {
        let key = getKey(riderRideId: rideId, dest: destination)
        var routeMetrics = etaCache[key]
        if  routeMetrics != nil {
            return routeMetrics
        }
        routeMetrics = SharedPreferenceHelper.getRouteMetrics(key: key)
        if routeMetrics != nil {
            etaCache[key] = routeMetrics
        }
        return routeMetrics
    }
    private func saveRouteMetrics(riderRideId : Double, destination : CLLocationCoordinate2D, routeMetrics : RouteMetrics) {
        let key = getKey(riderRideId: riderRideId, dest: destination)
        etaCache[key] = routeMetrics
        SharedPreferenceHelper.saveRouteMetrics(key: key, routeMetrics: routeMetrics)
    }
    
    func getRouteMetricsForMatchedRider(riderRideId: Double,matchedUser: MatchedUser,rideId: Double,origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D,useCase: String,routeMetricsReceiver: @escaping (_ routeMetrics : RouteMetrics) -> Void) {
        RoutePathServiceClient.getETABetweenTwoPoints(routeId: StringUtils.getStringFromDouble(decimalNumber: matchedUser.routeId), startTime: matchedUser.startDate ?? 0, startLatitude: origin.latitude, startLongitude: origin.longitude, endLatitude: destination.latitude, endLangitude: destination.longitude, vehicleType: (matchedUser as? MatchedRider)?.vehicleType ?? "Car",rideId: rideId, useCase: useCase, snapToRoute: true,routeStartLatitude: matchedUser.fromLocationLatitude ?? 0, routeStartLongitude: matchedUser.fromLocationLongitude ?? 0, routeEndLatitude: matchedUser.toLocationLatitude ?? 0, routeEndLongitude: matchedUser.toLocationLongitude ?? 0, routeWaypoints: nil, routeOverviewPolyline: matchedUser.routePolyline){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let etaResponse = Mapper<ETAResponse>().map(JSONObject: responseObject!["resultData"]){
                    let routeMetrics = RouteMetrics(originAddress: matchedUser.fromLocationAddress, destinationAddress: matchedUser.pickupLocationAddress ?? "", fromLat: origin.latitude, fromLng: origin.longitude, toLat: destination.latitude, toLng: destination.longitude, routeDistance: etaResponse.distanceInKM/1000, journeyDuration: etaResponse.timeTakenInSec/60, journeyDurationInTraffic: etaResponse.timeTakenInSec/60, departureTime: matchedUser.startDate ?? 0, arrivalTime: (matchedUser as? MatchedRider)?.pickupTime ?? 0, creationTime: DateUtils.getCurrentTimeInMillis(), error: etaResponse.error)
                    self.saveRouteMetrics(riderRideId: riderRideId, destination: destination, routeMetrics: routeMetrics)
                    routeMetricsReceiver(routeMetrics)
                }
            }
        }
    }
}
