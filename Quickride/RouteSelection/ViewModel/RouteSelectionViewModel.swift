//
//  RouteSelectionViewModel.swift
//  Quickride
//
//  Created by Quick Ride on 6/16/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

class RouteSelectionViewModel {
    
    var ride:Ride
    var rideRoute:RideRoute
    var mainRoute : RideRoute
    var routeSelectionDelegate : RouteSelectionDelegate?
    var userPreferredRoute : UserPreferredRoute?
    var selectedViaPointIndex = -1
    var isNotFromRecurringRide = true
    var newViaPoint : Location?
    var wayPoints = [Location]()
    let charArray : [Character] = ["A","B","C","D","E","F","G","I","J","K","L","M","N","0","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    init(ride : Ride, rideRoute:RideRoute, routeSelectionDelegate : RouteSelectionDelegate) {
        self.ride = ride
        self.rideRoute = rideRoute
        self.mainRoute = rideRoute
        self.routeSelectionDelegate = routeSelectionDelegate
        if let viaPoints = getWayPointsOfRoute(), viaPoints.count <= 5 {
            self.wayPoints = viaPoints
        }
        self.userPreferredRoute = isUserPreferredRoute(route : rideRoute)
    }
    //MARK : Temp
    init() {
        self.ride = Ride()
        self.rideRoute = RideRoute()
        self.mainRoute  = rideRoute
    }
    
    func isInPutValid() -> Bool {
        if !RideValidationUtils.isStartAndEndAddressAreSame(ride: ride){
            return true
        }
        return false
    }
    
    func getWayPointsOfRoute() -> [Location]?{
        if rideRoute.waypoints != nil && rideRoute.waypoints?.isEmpty == false && rideRoute.waypoints != "null" {
            return Mapper<Location>().mapArray(JSONString: rideRoute.waypoints!)!
        }
        return nil
    }
    
    func getTitleForRoute() -> String{
        if let routeName = userPreferredRoute?.routeName{
            return "Route - " + routeName
        }else{
            return Strings.edit_route
        }
    }
    func isUserPreferredRoute(route : RideRoute) -> UserPreferredRoute?{
        let prefRoutes = UserDataCache.getInstance()!.getUserPreferredRoutes()
        for preferredRoute in prefRoutes{
            if preferredRoute.routeId! == route.routeId{
                return preferredRoute
            }
        }
        return nil
    }
    func isRouteChanged() -> Bool{
        if mainRoute.routeId == 0 {
            return true
        }
        if rideRoute.routeId != mainRoute.routeId{
            return true
        }else{
            return false
        }
    }
    
    func isViaPointEditSession() -> Bool{
        return newViaPoint != nil
    }
    func isEditAllowedFor(row : Int) -> Bool{
        if isViaPointEditSession() && row != selectedViaPointIndex{
            return false
        }
        return true
    }
    
 
    
    func isRouteDistanceIncreasedByThreshold() -> Bool{
        let distanceChange = calculateDistanceChangeInNewRoute()
        return distanceChange > 1 && distanceChange > Int(0.15*mainRoute.distance!)
    }
    func calculateDistanceChangeInNewRoute() -> Int {
        if let newRouteDistance = rideRoute.distance,let mainRouteDistance = mainRoute.distance{
            return Int(newRouteDistance - mainRouteDistance)
        }
        return 0
    }
    
    func getSequenceAlphabetFor(index: Int) -> String{
        if index < 25 {
            return String(charArray[index])
        }else{
            return String(charArray[index%25])
        }
    }
    
    func handleViaPointSelection(viaPoint : Location){
        newViaPoint = viaPoint
        if selectedViaPointIndex != -1{
            NotificationCenter.default.post(name: .viaPointsChanged, object: self)
        }else{
            NotificationCenter.default.post(name: .newViaPointChanged, object: self)
        }
    }
    var foundLoopsInRoute = false
    func saveViaPoint(){
        guard let viaPoint = newViaPoint else {
            return
        }
        var temp = [Location](wayPoints)
        if selectedViaPointIndex != -1{
            temp.remove(at: selectedViaPointIndex)
            temp.insert(viaPoint, at: selectedViaPointIndex)
        }else{
            temp.append(viaPoint)
        }
        MyRoutesCache.getInstance()?.getEditedRoute(useCase: "iOS.App.CustomRoute.RouteSelectionVIew", rideId: ride.rideId, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endLatitude: ride.endLatitude!, endLongitude: self.ride.endLongitude!, wayPoints: temp.toJSONString() ?? "", handler: { rideRoute, responseError, error in
            guard let rideRoute = rideRoute else {
                var userInfo = [String : Any]()
                userInfo["responseError"] = responseError
                userInfo["nsError"] = error
                NotificationCenter.default.post(name: .routeFailed, object: self, userInfo: userInfo)
                return
            }
            
            if !self.foundLoopsInRoute && LocationClientUtils.isRouteContainLoops(polyline: rideRoute.overviewPolyline!){
                self.foundLoopsInRoute = true
                var userInfo = [String : Any]()
                userInfo["route"] = rideRoute
                NotificationCenter.default.post(name: .routeContainLoops, object: self, userInfo: userInfo)
                return
            }
            self.selectedViaPointIndex = -1
            self.newViaPoint = nil
            self.wayPoints = temp
            self.foundLoopsInRoute = false
            let rideRoutes = [rideRoute]
            self.receiveRoute(rideRoute: rideRoutes, alternative: false)
        })
    }
    
    func handleViaPointSelection(viaPoint : CLLocationCoordinate2D){
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.RouteSelectionView", coordinate: viaPoint, handler: { (location, error) in
            if location != nil{
                location?.latitude = viaPoint.latitude
                location?.longitude = viaPoint.longitude
                self.handleViaPointSelection(viaPoint: location!)
            }else{
                self.handleViaPointSelection(viaPoint: Location(latitude: viaPoint.latitude, longitude: viaPoint.longitude, shortAddress: nil))
            }
        })
    }
    
    func getRoutes(){
        
        let viaPoints = LocationClientUtils.simplifyWayPoints(wayPoints: wayPoints)
        let wayPointsString = viaPoints?.toJSONString()
        MyRoutesCache.getInstance()?.getUserRoute(useCase: "iOS.App.CustomRoute.RouteSelectionVIew", rideId: ride.rideId,startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endLatitude: ride.endLatitude!, endLongitude: self.ride.endLongitude!,wayPoints: wayPointsString, routeReceiver : self,saveCustomRoute: false)
    }
    
    func newViaPointRemoved(){
        newViaPoint = nil
        selectedViaPointIndex = -1
        self.foundLoopsInRoute = false
        NotificationCenter.default.post(name: .routeReceived, object: self)
    }
    
    func viaPointRemoved(index : Int){
        self.foundLoopsInRoute = false
        if selectedViaPointIndex != -1{
            newViaPoint = nil
            selectedViaPointIndex = -1
            NotificationCenter.default.post(name: .viaPointEditUndone, object: self)
        }else{
            wayPoints.remove(at: index)
            getRoutes()
        }
    }
}
//MARK: RouteReceiver
extension RouteSelectionViewModel : RouteReceiver{
    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
        self.rideRoute =  rideRoute[0]
        
        NotificationCenter.default.post(name: .routeReceived, object: self)
    }
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {
        AppDelegate.getAppDelegate().log.error("response : \(String(describing: responseObject)), nsError : \(String(describing: error))")
        let result = RestResponseParser<RideRoute>().parse(responseObject: responseObject, error: error)
        var userInfo = [String : Any]()
        userInfo["responseError"] = result.1
        userInfo["nsError"] = result.2
        NotificationCenter.default.post(name: .routeFailed, object: self, userInfo: userInfo)
    }
}


