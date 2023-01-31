//
//  StartAndEndPointSearchOnRoute.swift
//  Quickride
//
//  Created by KNM Rao on 14/12/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation

class StartAndEndPointSearchOnRoute {
    
    var route :RoutePathData
    var startPoint: CLLocationCoordinate2D
    var endPoint :CLLocationCoordinate2D
    var startMatchedRouteStepIndex = -1
    var endMatchedRouteStepIndex = -1
    var startMatchedRouteStepLatLngIndex = -1
    var endMatchedRouteStepLatLngIndex = -1
    var lastMinStartDistance = -1.0
    var lastMinEndDistance = -1.0
    var matchedStartPointOnRoute :CLLocationCoordinate2D?
    var matchedEndPointOnRoute :CLLocationCoordinate2D?
    var thresholdDistance  : Double = -1
    
    init( riderRoute :RoutePathData,  startPoint : CLLocationCoordinate2D,  endPoint : CLLocationCoordinate2D,thresholdDistance : Double) {
        self.route = riderRoute
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.thresholdDistance = thresholdDistance
    }
    
    
    func performSearch() {
        var distance = 0.0
        var routeStepIndex = 0
        let routeSteps = self.route.routeSteps
        
        for  routePoint in routeSteps{
            let latlangListForStep = RouteCache.getInstance().getLatLngListForPolyline(polyline: routePoint.polyline!)
            var lalLngIndex = 0
            for  latLng in latlangListForStep
            {
                
                distance = LocationClientUtils.getDistance(fromLatitude: startPoint.latitude, fromLongitude: startPoint.longitude, toLatitude: latLng.latitude, toLongitude: latLng.longitude)
                
                if distance < thresholdDistance && (lastMinStartDistance == -1 || lastMinStartDistance > distance)  {
                    startMatchedRouteStepIndex = routeStepIndex
                    startMatchedRouteStepLatLngIndex = lalLngIndex
                    matchedStartPointOnRoute = latLng
                    lastMinStartDistance = distance
                }
                
                distance=LocationClientUtils.getDistance(fromLatitude: endPoint.latitude, fromLongitude: endPoint.longitude, toLatitude: latLng.latitude, toLongitude: latLng.longitude)
                
                if distance < thresholdDistance && (lastMinEndDistance == -1 || lastMinEndDistance > distance) {
                    endMatchedRouteStepIndex = routeStepIndex
                    endMatchedRouteStepLatLngIndex = lalLngIndex
                    matchedEndPointOnRoute = latLng
                    lastMinEndDistance = distance
                }
                lalLngIndex += 1
            }
            routeStepIndex += 1
        }
    }
    
    func doesRouteContainBothStartAndEndLocations() -> Bool {
        return matchedStartPointOnRoute != nil &&  matchedEndPointOnRoute != nil
    }
    
    func isStartLocationCrossedDestination() -> Bool{
        if endMatchedRouteStepIndex < startMatchedRouteStepIndex {
            return true
        }else if endMatchedRouteStepIndex == startMatchedRouteStepIndex &&
            endMatchedRouteStepLatLngIndex < startMatchedRouteStepLatLngIndex {
            return true
        }else {
            return false
        }
    }
    
    
    func getRouteDistanceBetweenMatchedPoints() -> Double {
        if let startPoint = matchedStartPointOnRoute, let endPoint = matchedEndPointOnRoute{
            return MatchedRouteDistanceCalculator.getDistanceBetweenMatchedPointsOnRoute(route: self.route, startMatchedRouteStepIndex: self.startMatchedRouteStepIndex, matchedStartPointOnRoute: startPoint, matchedEndPointOnRoute: endPoint, endMatchedRouteStepIndex: self.endMatchedRouteStepIndex)
        }
        return 0
    }
}
