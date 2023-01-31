//
//  ETAFinder.swift
//  Quickride
//
//  Created by Quick Ride on 2/23/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
class ETAFinder {
    
    private static let duration_for_mtr_in_sec = 0.25

    private static var instance : ETAFinder?
    
    var  etaResponseRepo = [LatLng : ETAResponse]()
    var inProgress = false
    
    static func getInstance() -> ETAFinder{
        if instance == nil{
            instance = ETAFinder()
        }
        return instance!
    }
    func getETA(userId : Double, rideId : Double,  useCase : String, source : LatLng,  destination : LatLng,  routeId : Double,  startTime : Double, vehicleType : String ,routeStartLatitude: Double, routeStartLongitude: Double, routeEndLatitude: Double, routeEndLongitude: Double, routeWaypoints: String?, routeOverviewPolyline: String?,  handler : @escaping (_ etaResponse : ETAResponse) -> Void) {
        let startCL = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let endCL = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
    
        if let etaResponse = getETAFromCache(dest: destination), let lastUpdatedTime = etaResponse.lastUpdateTime, NSDate().getTimeStamp() - lastUpdatedTime < 45 * 1000 {
            handler(etaResponse)
            return
        }
        if inProgress {
            return
        }
        inProgress = true
        AppDelegate.getAppDelegate().log.debug("ETA start : \(source), end :\(destination)")
        RoutePathServiceClient.getETABetweenTwoPoints(routeId: StringUtils.getStringFromDouble(decimalNumber: routeId), startTime: startTime, startLatitude: source.latitude, startLongitude: source.longitude, endLatitude: destination.latitude, endLangitude: destination.longitude, vehicleType: vehicleType,rideId: rideId,useCase: useCase,snapToRoute: true,routeStartLatitude: routeStartLatitude, routeStartLongitude: routeStartLongitude, routeEndLatitude: routeEndLatitude, routeEndLongitude: routeEndLongitude, routeWaypoints: routeWaypoints, routeOverviewPolyline: routeOverviewPolyline) { [weak self] (responseObject, error) in
            AppDelegate.getAppDelegate().log.debug("getETABetweenTwoPoints : \(responseObject), error :\(error)")
            guard let self = self else {
                return
            }
            self.inProgress = false
            let result = RestResponseParser<ETAResponse>().parse(responseObject: responseObject, error: error)
            if var etaResponse = result.0{
                let mps = (etaResponse.distanceInKM*1000.0)/Double(etaResponse.timeTakenInSec)
                etaResponse.speed = mps*3.6
                self.etaResponseRepo[destination] = etaResponse
                handler(etaResponse)
            }else{
                handler(self.handleFailure(source: source, destination: destination, routeId: routeId))
            }
        }
        
    }
    
    private func handleFailure(source : LatLng, destination : LatLng,routeId : Double) -> ETAResponse {
        let destCL = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let sourceCL = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let distanceInMtr = destCL.distance(from: sourceCL)
        let durationInSec = distanceInMtr*ETAFinder.duration_for_mtr_in_sec
        let etaResponse = ETAResponse( source : source, destination : destination, timeTakenInSec :Int(durationInSec), distanceInKM : distanceInMtr/1000,routeId : routeId, error : nil)
        return etaResponse
    }

    private func  getETAFromCache( dest : LatLng) -> ETAResponse?{
        for  key in etaResponseRepo.keys{
            let destCL = CLLocation(latitude: dest.latitude, longitude: dest.longitude)
            let keyCL = CLLocation(latitude: key.latitude, longitude: key.longitude)
            let distance = destCL.distance(from: keyCL)
            
            if distance <= 20{
                return etaResponseRepo[key]
            }
        }
        return nil
    }
}
