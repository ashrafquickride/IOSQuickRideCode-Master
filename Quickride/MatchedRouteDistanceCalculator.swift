//
//  MatchedRouteDistanceCalculator.swift
//  Quickride
//
//  Created by KNM Rao on 14/12/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
class MatchedRouteDistanceCalculator {
  
  static func getDistanceBetweenMatchedPointsOnRouteStep( routeStep: String, startMatchedRouteStepIndex :Int,  endMatchedRouteStepIndex : Int) -> Double{
    var routeStepLatlngs = RouteCache.getInstance().getLatLngListForPolyline(polyline: routeStep)
    var distanceInMtrs = 0.0
    
    for i in startMatchedRouteStepIndex..<endMatchedRouteStepIndex{
      
      distanceInMtrs = distanceInMtrs + LocationClientUtils.getDistance(fromLatitude: routeStepLatlngs[i].latitude, fromLongitude: routeStepLatlngs[i].longitude, toLatitude: routeStepLatlngs[i+1].latitude, toLongitude: routeStepLatlngs[i+1].longitude)
      
    }
    return distanceInMtrs
  }
  static func getDistanceBetweenMatchedPointsOnRoute( route : RoutePathData, startMatchedRouteStepIndex :Int, matchedStartPointOnRoute :CLLocationCoordinate2D,  matchedEndPointOnRoute : CLLocationCoordinate2D,  endMatchedRouteStepIndex :Int) -> Double{
    var totalMatchedDistance = 0.0
    var endMatchedLatLngIndex = -1
    var startMatchedLatLngIndex = -1
    
    
    if startMatchedRouteStepIndex == -1 || endMatchedRouteStepIndex == -1{
      return totalMatchedDistance
    }
    
    var routeSteps = route.routeSteps
    for j in startMatchedRouteStepIndex...endMatchedRouteStepIndex{
      var matchedStepDistance = Double(routeSteps[j].distance)
      
      if j == startMatchedRouteStepIndex{
        var routeStepLatlngs = RouteCache.getInstance().getLatLngListForPolyline(polyline: routeSteps[j].polyline!)
        var previousLatLng = routeStepLatlngs[0]
        var distanceFromFirstIndexToFirstPartialMatchedIndex = 0.0
        var index = 0
        for latLng in routeStepLatlngs {
          
          distanceFromFirstIndexToFirstPartialMatchedIndex = distanceFromFirstIndexToFirstPartialMatchedIndex + LocationClientUtils.getDistance(fromLatitude: previousLatLng.latitude, fromLongitude: previousLatLng.longitude, toLatitude: latLng.latitude, toLongitude: latLng.longitude)
          previousLatLng = latLng
          if latLng.latitude == matchedStartPointOnRoute.latitude && latLng.longitude == matchedStartPointOnRoute.longitude{
            startMatchedLatLngIndex = index
            break
          }
          index += 1
        }
        
        matchedStepDistance =  matchedStepDistance - distanceFromFirstIndexToFirstPartialMatchedIndex;
      }
      if j == endMatchedRouteStepIndex{
        var routeStepLatlngs = RouteCache.getInstance().getLatLngListForPolyline(polyline: routeSteps[j].polyline!)
        
        var distanceFromlastMatchedIndexToLastIndex = 0.0
        

        var previousLatLng = routeStepLatlngs[0]
        var index = 0
        for latLng in routeStepLatlngs {
          
          
         
          if latLng.latitude == matchedEndPointOnRoute.latitude && latLng.longitude == matchedEndPointOnRoute.longitude{
             previousLatLng = routeStepLatlngs[index]
            endMatchedLatLngIndex = index
            
          }
          if endMatchedLatLngIndex != -1{
            distanceFromlastMatchedIndexToLastIndex = distanceFromlastMatchedIndexToLastIndex + LocationClientUtils.getDistance(fromLatitude: previousLatLng.latitude, fromLongitude: previousLatLng.longitude, toLatitude: latLng.latitude, toLongitude: latLng.longitude)
             previousLatLng = latLng
          }
          index += 1
        }
        
        matchedStepDistance = matchedStepDistance - distanceFromlastMatchedIndexToLastIndex;
      }
      totalMatchedDistance = totalMatchedDistance+matchedStepDistance
    }
    if startMatchedRouteStepIndex == endMatchedRouteStepIndex && startMatchedLatLngIndex > endMatchedLatLngIndex{
        return -1
    }
    return totalMatchedDistance
  }
  static func geExactDistanceBetweenStartAndPickup( pickupLat : Double,  pickupLng: Double, startLat: Double, startLng : Double, riderRoute :[RouteStep]) -> Double
    {
  
  		var lastMinStartDistance = 0.0
  		var routeStepIndex = 0
      var matchedStartPointOnRoute : CLLocationCoordinate2D? = nil
  		var startMatchedRouteStepIndex = 0
  		var isStartPointMatched = false
  		for routePoint in riderRoute{
    let latlangListForStep = RouteCache.getInstance().getLatLngListForPolyline(polyline: routePoint.polyline!)
    for latLng in latlangListForStep{
    let distance = LocationClientUtils.getDistance(fromLatitude: pickupLat, fromLongitude: pickupLng, toLatitude: latLng.latitude, toLongitude: latLng.longitude)
    if distance <= 100{
    if !isStartPointMatched || distance < lastMinStartDistance{
      startMatchedRouteStepIndex = routeStepIndex
      matchedStartPointOnRoute = latLng
      lastMinStartDistance = distance
      isStartPointMatched = true
    }
  
    }
    }
    routeStepIndex += 1
  		}
  		var distanceFromStartToPickup = 0.0
  		for i in 0...startMatchedRouteStepIndex{
    let stepDistance = Double(riderRoute[i].distance)
    if i == startMatchedRouteStepIndex{
    var routeStepLatlngs = RouteCache.getInstance().getLatLngListForPolyline(polyline: riderRoute[i].polyline!)
    var previousLatLng = routeStepLatlngs[0]
    var distanceFromFirstIndexToFirstPartialMatchedIndex = 0.0
    for latLng in routeStepLatlngs{
      
    distanceFromFirstIndexToFirstPartialMatchedIndex = distanceFromFirstIndexToFirstPartialMatchedIndex + LocationClientUtils.getDistance(fromLatitude: previousLatLng.latitude, fromLongitude: previousLatLng.longitude, toLatitude: latLng.latitude, toLongitude: latLng.longitude)
    previousLatLng = latLng;
    if latLng.latitude == matchedStartPointOnRoute!.latitude && latLng.longitude == matchedStartPointOnRoute!.longitude {
    break
    }
    }
    
    distanceFromStartToPickup = distanceFromStartToPickup + distanceFromFirstIndexToFirstPartialMatchedIndex
    
    }else{
    distanceFromStartToPickup = distanceFromStartToPickup + stepDistance;
    }
  		}
  		return distanceFromStartToPickup
    }
}
