//
//  LocationClientUtils.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 24/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Polyline
import CoreLocation
import GoogleMaps


public class LocationClientUtils:NSObject,CLLocationManagerDelegate{
    
    
    public static let kDegreesToRadians: Double = Double.pi / 180.0
    public static let kRadiansToDegrees: Double = 180.0 / Double.pi
    
    public static func  getNearestLatLongPositionForPath(checkLatLng:CLLocationCoordinate2D,route:[CLLocationCoordinate2D]) -> Int{
        AppDelegate.getAppDelegate().log.debug("getNearestLatLongPositionForPath()")
        let start:CLLocation = CLLocation(latitude: route[0].latitude, longitude:  route[0].longitude)
        var smallestDistance:Double = start.distance(from: CLLocation(latitude: checkLatLng.latitude, longitude: checkLatLng.longitude))
        var indexSmallest = 0
        for i in 1 ..< route.count {
            let start:CLLocation = CLLocation(latitude: route[i].latitude, longitude:  route[i].longitude)
            let distance:Double = start.distance(from: CLLocation(latitude: checkLatLng.latitude, longitude: checkLatLng.longitude))
            if(distance <= smallestDistance){
                smallestDistance = distance;
                indexSmallest = i;
            }
        }
        return indexSmallest
    }
    
    public static func getMatchedRouteLatLng(pickupLatLng:CLLocationCoordinate2D, dropLatLng:CLLocationCoordinate2D, polyline:String) -> [CLLocationCoordinate2D]{
        AppDelegate.getAppDelegate().log.debug("getMatchedRouteLatLng()")
        let polyLine = Polyline(encodedPolyline: polyline)
        let routeLatLng:[CLLocationCoordinate2D] = polyLine.coordinates!
         var route:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        if routeLatLng.count <= 2{
            route.insert(pickupLatLng, at: 0)
            route.append(dropLatLng)
            return route
        }
        let start:Int = LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: pickupLatLng, route: routeLatLng)
        let end:Int =  LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: dropLatLng, route: routeLatLng)
       
        if(start>end){
            for i in end ..< start{
                route.append(routeLatLng[i])
            }
            route.insert(pickupLatLng, at: 0)
            route.append(dropLatLng)
            return route
        }
        for i in start ..< end {
            route.append(routeLatLng[i])
        }
        route.insert(pickupLatLng, at: 0)
        route.append(dropLatLng)
        return route
    }
    
    public static func getNearestDistanceLocationFromThispath( latLng : CLLocationCoordinate2D, polyline : GMSPolyline) -> Double{
        AppDelegate.getAppDelegate().log.debug("getNearestDistanceLocationFromThispath()")
        let route : Polyline = Polyline(encodedPolyline: polyline.path!.encodedPath())
        return getNearestDistanceFromPath(latLng: latLng, routeLatLng: route.coordinates!)
    }
    
    public static func getNearestDistanceFromPath(latLng : CLLocationCoordinate2D, routeLatLng : [CLLocationCoordinate2D]) -> Double{
        AppDelegate.getAppDelegate().log.debug("getNearestDistanceFromPath()")
        let start:CLLocation = CLLocation(latitude: latLng.latitude, longitude:  latLng.longitude)
        var nearestDistance:Double = start.distance(from: CLLocation(latitude: routeLatLng[0].latitude, longitude: routeLatLng[0].longitude))
        
        for i in 1 ..< routeLatLng.count{
            let start:CLLocation = CLLocation(latitude: routeLatLng[i].latitude, longitude:  routeLatLng[i].longitude)
            let distance:Double = start.distance(from: CLLocation(latitude: latLng.latitude, longitude: latLng.longitude))
            if(distance<nearestDistance){
                nearestDistance = distance
            }
        }
        return nearestDistance
    }
    
    public static func getMatchedRoute( startLatLngIndex : Int, endLatLngIndex : Int, route : [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]{
        AppDelegate.getAppDelegate().log.debug("getMatchedRoute()")
        var matchedRoute : [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        if startLatLngIndex > endLatLngIndex{
            for index in endLatLngIndex...startLatLngIndex{
                matchedRoute.append(route[index])
            }
        }else{
            for index in startLatLngIndex...endLatLngIndex{
                matchedRoute.append(route[index])
            }
        }
        return matchedRoute
    }
    
    static func getDistance(fromLatitude : Double,fromLongitude: Double,toLatitude: Double,toLongitude : Double) -> Double{
        let fromlocation = CLLocation(latitude: fromLatitude, longitude: fromLongitude)
        let toLocation = CLLocation(latitude: toLatitude, longitude: toLongitude)
        return fromlocation.distance(from: toLocation)
    }
    static func simplifyWayPoints(wayPoints : [Location]?)->[Location]?{
        if wayPoints == nil{
            return nil
        }
        var simplifiedWayPoints = [Location]()
        for wayPoint in wayPoints!{
            simplifiedWayPoints.append(Location(latitude: wayPoint.latitude, longitude: wayPoint.longitude,shortAddress: wayPoint.shortAddress))
        }
        return simplifiedWayPoints
    }
    static func getWayPoints(routePathPolyline:String) -> [Location]{
        AppDelegate.getAppDelegate().log.debug("getWayPoints()")
        let route = Polyline(encodedPolyline: routePathPolyline)
        var coordinates = route.coordinates
        var wayPoints:[Location] = [Location]()
        let interval:Int = coordinates!.count/4
        for i in 1...3{
            let coOrdinate = coordinates![i*interval]
            wayPoints.append(Location(latitude:coOrdinate.latitude,longitude: coOrdinate.longitude,shortAddress: nil))
        }
        return wayPoints
    }
    
    
    public static func getLocationNameKey(lat : Double,lng : Double)-> String{
        return String(lat)+","+String(lng)
    }
    
    static func checkHomeAndOfficeLocationsSameAndConvey(officeLocation : Location?,homeLocation : Location?){
        if officeLocation == nil || homeLocation == nil{
            return
        }
        let office = CLLocation(latitude: officeLocation!.latitude, longitude: officeLocation!.longitude)
        let home = CLLocation(latitude: homeLocation!.latitude, longitude: homeLocation!.longitude)
        
        if officeLocation!.shortAddress == homeLocation!.shortAddress || office.distance(from: home) < 30
        {
            UIApplication.shared.keyWindow?.makeToast( Strings.home_office_same)
        }
    }
    static func getDistance(path : [CLLocationCoordinate2D]) -> Double{
        var distanceInMtrs = 0.0
        if path.count == 0 || path.count == 1{
            return distanceInMtrs
        }else if path.count == 2{
            return LocationClientUtils.getDistance(fromLatitude: path[0].latitude, fromLongitude: path[0].longitude, toLatitude: path[1].latitude, toLongitude: path[1].longitude)
        }
        for i in 0..<path.count-1{
            let startCoordinate = path[i]
            let endCoordinate = path[i+1]
            distanceInMtrs = distanceInMtrs + LocationClientUtils.getDistance(fromLatitude: startCoordinate.latitude, fromLongitude: startCoordinate.longitude, toLatitude: endCoordinate.latitude, toLongitude: endCoordinate.longitude)
            
        }
        return distanceInMtrs
        
    }
    
    static func getNearestLatLongFromThePath(checkLatLng : CLLocationCoordinate2D, routePath : String) -> (Double, CLLocationCoordinate2D) {
        let polyLine = Polyline(encodedPolyline: routePath)
        guard let routeLatLng = polyLine.coordinates else {
            return (0, checkLatLng)
        }
        let latLngToFind = CLLocation(latitude: checkLatLng.latitude, longitude: checkLatLng.longitude)
        if routeLatLng.isEmpty{
            return (0, checkLatLng)
        }
        let start = CLLocation(latitude: routeLatLng[0].latitude, longitude:  routeLatLng[0].longitude)
        var smallestDistance = start.distance(from: latLngToFind)
        var indexSmallest = 0
        for i in 1 ..< routeLatLng.count {
            let start:CLLocation = CLLocation(latitude: routeLatLng[i].latitude, longitude:  routeLatLng[i].longitude)
            let distance:Double = start.distance(from: CLLocation(latitude: checkLatLng.latitude, longitude: checkLatLng.longitude))
            if(distance <= smallestDistance){
                smallestDistance = distance
                indexSmallest = i
            }
        }
        if routeLatLng.count > 1 {
            return (smallestDistance, routeLatLng[indexSmallest])
        }
        return (smallestDistance, checkLatLng)
    }
    
    static func getDistanceBetweenTwoPointOnRoute(startLat: Double, startLng: Double, endLat: Double, endLng: Double, routePolyLine: String) -> Double {
        var distance = 0.0
        let matchedUserRoute = getMatchedRouteLatLng(pickupLatLng: CLLocationCoordinate2D(latitude: startLat, longitude: startLng), dropLatLng: CLLocationCoordinate2D(latitude: endLat, longitude: endLng), polyline: routePolyLine)
        if matchedUserRoute.count > 1 {
            for i in 0..<matchedUserRoute.count - 1 {
                let prev = matchedUserRoute[i]
                let next = matchedUserRoute[i+1]
                distance += getDistance(fromLatitude: prev.latitude, fromLongitude: prev.longitude, toLatitude: next.latitude, toLongitude: next.longitude)
            }
        }
        return distance
    }

    static func decodePolylineAndReturnLatlng(_ polyline: String) -> [CLLocationCoordinate2D]? {
        return decodePolyline(polyline)
    }
    static func checkLocationAutorizationStatus(status: CLAuthorizationStatus,completionHandler: @escaping (_ accessGranted: Bool) -> Void){
        AppDelegate.getAppDelegate().log.debug("Location permission status: \(status.rawValue)")
        switch status {
        case .notDetermined:
            showLoactionPermissionScreen(isRequiredToGoSettings: false, completionHandler: completionHandler)
        case .denied,.restricted:
            showLoactionPermissionScreen(isRequiredToGoSettings: true, completionHandler: completionHandler)
        case .authorizedAlways,.authorizedWhenInUse:
            completionHandler(true)
        default:
            break
        }
    }
    static func showLoactionPermissionScreen(isRequiredToGoSettings: Bool,completionHandler: @escaping (_ accessGranted: Bool) -> Void){
        let permissionVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AppPermissionsConfirmationViewController") as! AppPermissionsConfirmationViewController
        permissionVC.showConfirmationView(permissionType: .Location,isRequiredToGoSettings: isRequiredToGoSettings) { (isConfirmed) in
            if isConfirmed{
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: permissionVC)
    }
    
    static func getMinPickupTimeAcceptedForTaxi(tripType: String,fromLatitude : Double,fromLongitude: Double) -> Double {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        let instantTaxiLocations = clientConfiguration.instantTaxiEnabledLocations
        if !instantTaxiLocations.isEmpty{
            for enableLocation in clientConfiguration.instantTaxiEnabledLocations{
                if let location = enableLocation.location , enableLocation.tripType == tripType, getDistance(fromLatitude: fromLatitude, fromLongitude: fromLongitude, toLatitude: location.lat, toLongitude: location.lng)/1000 < location.radius{
                    return DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: enableLocation.advanceTimeInMinsForBookingToBeAllowed)
                }
            }
        }
        return DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: clientConfiguration.taxiPoolInstantBookingThresholdTimeInMins)
    }
    static func isRouteContainLoops(polyline: String) -> Bool{
        
        var dict = [String: CLLocationCoordinate2D]()
        let routeList = RouteCache.getInstance().getLatLngListForPolyline(polyline: polyline)
        for(index,latlng) in routeList.enumerated() {
            let key = "\(latlng.latitude),\(latlng.longitude)"
            if let _ = dict[key], routeList[index-1].latitude != latlng.latitude,routeList[index-1].longitude != latlng.longitude{
                return true
            }
            dict[key] = latlng
        }
        return false
        
    }
    static func humanizeDistance(meters: Int) -> String? {
        
        if meters > 1000 {
            if meters % 1000 == 0 {
                let km = Double(meters/1000)
                return km.printValue(places: 1) + " km"
            }else{
                let km = meters/1000
                return "\(km) km"
            }
        } else if meters > 900 {
            return "1 km"
        } else if meters > 50 {
             return "\(meters) m away"
        }
        return nil
    }
}
extension CLLocation{
    func getDirection(prevLat :Double?,prevLng : Double?) -> Double {
        if self.course >= 0{
            return self.course
        }else if prevLat == nil || prevLng == nil{
            return  0.0
        }
        
        let fromLat = prevLat! * LocationClientUtils.kDegreesToRadians
        let fromLong = prevLng! * LocationClientUtils.kDegreesToRadians
        
        let toLat = self.coordinate.latitude * LocationClientUtils.kDegreesToRadians
        let toLong = self.coordinate.longitude * LocationClientUtils.kDegreesToRadians
        
        let dlon = toLong - fromLong
        let y = sin(dlon)*cos(toLat)
        
        let x = cos(fromLat)*sin(toLat)-sin(fromLat)*cos(toLat)*cos(dlon)
        
        var direction = atan2(y,x)
        // convert to degrees
        direction = direction * LocationClientUtils.kRadiansToDegrees
        // normalize
        let fraction = modf(direction + 360.0)
        return fraction.0
        
    }
   
    
}
