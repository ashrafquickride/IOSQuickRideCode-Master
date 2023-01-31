//
//  RouteCache.swift
//  Quickride
//
//  Created by KNM Rao on 14/12/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
import Polyline
import GoogleMaps
class RouteCache {
  var routeCacheDictionary =  [String: [CLLocationCoordinate2D]]()
  
  static var routeCache : RouteCache? = nil
  static func getInstance() -> RouteCache{
		if routeCache == nil{
      routeCache = RouteCache()
		}
		return routeCache!
  }
  func getLatLngListForPolyline(polyline : String) -> [CLLocationCoordinate2D]{
		var latLngList = routeCacheDictionary[polyline]
		if nil == latLngList{
      latLngList = Polyline(encodedPolyline: polyline).coordinates
      routeCacheDictionary[polyline] = latLngList
		}
		return latLngList!
  }
}
