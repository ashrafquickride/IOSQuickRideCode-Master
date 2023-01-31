//
//  TaxiRideEditRouteViewModel.swift
//  Quickride
//
//  Created by Rajesab on 23/12/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
import ObjectMapper

class TaxiRideEditRouteViewModel {
    
    var startLocation: Location?
    var endLocation: Location?
    var selectedRouteId = -1.0
    var selectedViaPointIndex = -1
    var rideRoute: RideRoute?
    var newViaPoint : Location?
    var wayPoints = [Location]()
    var mainRoute : RideRoute?
    var routeSelectionDelegate : RouteSelectionDelegate?
    var userPreferredRoute : UserPreferredRoute?
    var isNewViaPointAdded = false

    let charArray : [Character] = ["A","B","C","D","E","F","G","I","J","K","L","M","N","0","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    init(startLocation: Location?,endLocation: Location?,rideRoute: RideRoute?,routeSelectionDelegate : RouteSelectionDelegate){
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.rideRoute = rideRoute
        self.mainRoute = rideRoute
        self.routeSelectionDelegate = routeSelectionDelegate
        if let viaPoints = getWayPointsOfRoute(), viaPoints.count <= 5 {
            self.wayPoints = viaPoints
        }
        if let rideRoute = rideRoute {
        self.userPreferredRoute = isUserPreferredRoute(route : rideRoute)
        }
    }
    
    init(){
    }
    
    func isUserRouteChanged() -> Bool{
        if (mainRoute?.routeId != rideRoute?.routeId) {
            return true
        }
        return false
    }
    
    func isStartAndEndAddressAreSame() -> Bool{
      AppDelegate.getAppDelegate().log.debug("isStartAndEndAddressAreSame()")

        let startPoint = CLLocation(latitude : startLocation?.latitude ?? 0, longitude: startLocation?.longitude ?? 0)
        let endPoint = CLLocation(latitude: endLocation?.latitude ?? 0, longitude: endLocation?.longitude ?? 0)
        return startPoint.distance(from: endPoint) <= MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES
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
    func getWayPointsOfRoute() -> [Location]? {
        if let waypoints = rideRoute?.waypoints, waypoints.isEmpty == false, waypoints != "null" {
            return Mapper<Location>().mapArray(JSONString: (waypoints))
        }
        return nil
    }
    func getSequenceAlphabetFor(index: Int) -> String{
        if index < 25 {
            return String(charArray[index])
        }else{
            return String(charArray[index%25])
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
    func handleViaPointSelection(viaPoint : Location){
        newViaPoint = viaPoint
        if selectedViaPointIndex != -1{
            NotificationCenter.default.post(name: .viaPointsChanged, object: self)
        }else{
            NotificationCenter.default.post(name: .newViaPointChanged, object: self)
        }
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
    func newViaPointRemoved(){
        newViaPoint = nil
        selectedViaPointIndex = -1
        self.foundLoopsInRoute = false
        NotificationCenter.default.post(name: .routeReceived, object: self)
    }
    var foundLoopsInRoute = false
    func saveViaPoint(){
        
        guard let viaPoint = newViaPoint, let start = startLocation, let end = endLocation else {
            return
        }
        var temp = [Location](wayPoints)
        if selectedViaPointIndex != -1{
            temp.remove(at: selectedViaPointIndex)
            temp.insert(viaPoint, at: selectedViaPointIndex)
        }else{
            temp.append(viaPoint)
        }
        MyRoutesCache.getInstance()?.getEditedRoute(useCase: "iOS.App.CustomRoute.TaxiRideEditRoute", rideId: 0, startLatitude: start.latitude, startLongitude: start.longitude, endLatitude: end.latitude, endLongitude: end.longitude, wayPoints: temp.toJSONString() ?? "", handler: { rideRoute, responseError, error in
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
            self.receiveRoute(rideRoute: [rideRoute], alternative: false)
            
        })
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
    
    func getRoutes(){
        
        let viaPoints = LocationClientUtils.simplifyWayPoints(wayPoints: wayPoints)
        let wayPointsString = viaPoints?.toJSONString()
        MyRoutesCache.getInstance()?.getUserRoute(useCase: "iOS.App.CustomRoute.RouteSelectionVIew", rideId: 0 ,startLatitude: startLocation?.latitude ?? 0, startLongitude: startLocation?.longitude ?? 0, endLatitude: endLocation?.latitude ?? 0, endLongitude: endLocation?.longitude ?? 0 ,wayPoints: wayPointsString, routeReceiver : self,saveCustomRoute: false)
    }
    func isRouteChanged() -> Bool{
        if let mainRoute = mainRoute {
            if mainRoute.routeId == 0 {
                return true
            }else if let rideRoute = rideRoute, rideRoute.routeId != mainRoute.routeId{
                return true
            }
        }
        return false
    }
 
    func isRouteDistanceIncreasedByThreshold() -> Bool{
        let distanceChange = calculateDistanceChangeInNewRoute()
        if let distance = mainRoute?.distance {
        return distanceChange > 1 && distanceChange > Int(0.15*distance)
        }
        return false
    }
    func calculateDistanceChangeInNewRoute() -> Int {
        if let newRouteDistance = rideRoute?.distance,let mainRouteDistance = mainRoute?.distance{
            return Int(newRouteDistance - mainRouteDistance)
        }
        return 0
    }
    func getSuggestingNameForRoute(startLocation: Location?,endLocation: Location?, wayPoints: [Location]?) -> String{
        var routeName =  startLocation?.address?.prefix(4)
        if let wayPoints = wayPoints {
            for waypoint in wayPoints {
                if let address = waypoint.address {
                    routeName = (routeName ?? "") + "-" + String(address.prefix(4))
                }
            }
        }
       let routeFinalName = (routeName ?? "") + "-" + (endLocation?.address?.prefix(4) ?? "")
        return String(routeFinalName)
    }
}
extension TaxiRideEditRouteViewModel : RouteReceiver{
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
