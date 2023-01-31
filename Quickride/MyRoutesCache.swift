//
//  MyRoutesCache.swift
//  Quickride
//
//  Created by KNM Rao on 21/11/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
import ObjectMapper

class MyRoutesCache {
    
    static var myroutescache : MyRoutesCache?
    
    var userRoutes = [String:[RideRoute]]()
    var  pendingAllRouteRequests = [String: [RouteReceiver]]()
    var  pendingDefaultRouteRequests = [String: [RouteReceiver]]()
    
    var walkRoutes = [String:RideRoute]()
    var pendingWalkRouteRequests = [String: [routeHandler]]()
    
    static let minimumDisplacementBetweenStartAndEnd : CLLocationDistance = 500
    
    init(){
        
    }
    
    static func getInstance() -> MyRoutesCache? {
        
        if myroutescache == nil {
            myroutescache = MyRoutesCache()
        }
        return myroutescache
    }
    
    
    func getUserRoutes(useCase : String,rideId : Double,startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, weightedRoutes: Bool, routeReceiver : RouteReceiver){
            
        if(!validateRoutePreConditions(startLatitude: startLatitude,startLongitude : startLongitude,endLatitude : endLatitude,endLongitude : endLongitude)){
            //Error error = new Error(RideManagementException.ROUTES_NOT_FOUND, "Distance is very less to find routes", "Please check with valid details");
            
            //routeReceiver.receiveRouteFailed(new RideManagementException(error));
            return
        }
        
        let key = MyRoutesCache.getCacheKey(fromlatitude: startLatitude, fromlongitude: startLongitude, tolatitude: endLatitude, tolongitude: endLongitude,places: 4)
        var availableRoutes = userRoutes[key]
        
        if(availableRoutes == nil || availableRoutes!.isEmpty == true){
            availableRoutes = MyRoutesCachePersistenceHelper.getAvailableRoutes(startLatitude: startLatitude,startLongitude: startLongitude,endLatitude: endLatitude,endLongitude: endLongitude)
        }
        
        if checkAlternatesAvailable(routes: availableRoutes){
            userRoutes[key] = availableRoutes
            return routeReceiver.receiveRoute(rideRoute : availableRoutes!, alternative: true)
        }
        if pendingAllRouteRequests[key] != nil{
            addRouteRequestToPendingList(key: key, availableRoutes: true, routeReceiver: routeReceiver)
        }else{
            addRouteRequestToPendingList(key: key,availableRoutes: true,routeReceiver: routeReceiver)
            let routeAsyncTask = RouteAsyncTask(rideId: rideId, useCase: useCase, startLat: startLatitude, startLng: startLongitude, endLat: endLatitude, endLng: endLongitude, wayPoints: nil, alternatives: true,weightedRoutes: weightedRoutes, viewController: nil, routeReceive: { (routes, responseObject, error) in
                if routes != nil{
                    self.saveUserRoutes(routes: routes)
                }
                self.processPendingAllRoutesRequest(key: key, routeList: routes, responseObject: responseObject, error: error)
            })
            routeAsyncTask.getRoutes()
        }
    }

    func getUserRoute(useCase : String ,rideId : Double, startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, wayPoints: String?,routeReceiver : RouteReceiver,saveCustomRoute: Bool){
        if(!validateRoutePreConditions(startLatitude: startLatitude,startLongitude : startLongitude,endLatitude : endLatitude,endLongitude : endLongitude)){
            //Error error = new Error(RideManagementException.ROUTES_NOT_FOUND, "Distance is very less to find routes", "Please check with valid details");
            
            //routeReceiver.receiveRouteFailed(new RideManagementException(error));
            return
        }
        let key  = MyRoutesCache.getCacheKey(fromlatitude: startLatitude, fromlongitude: startLongitude, tolatitude: endLatitude, tolongitude: endLongitude,places: 4)
        var availableRoutes = userRoutes[key]
        
        if availableRoutes == nil || availableRoutes!.isEmpty == true{
            availableRoutes = MyRoutesCachePersistenceHelper.getAvailableRoutes(startLatitude: startLatitude,startLongitude: startLongitude,endLatitude: endLatitude,endLongitude: endLongitude)!
            
        }
        if availableRoutes != nil && availableRoutes!.isEmpty == false {
            
            userRoutes[key] = availableRoutes
            let route = getSpecificRoute(availableRoutes: availableRoutes,wayPoints: wayPoints)
            if route != nil{
                var routes = [RideRoute]()
                routes.append(route!)
                return routeReceiver.receiveRoute(rideRoute: routes, alternative: false)
            }
            
        }
        if pendingDefaultRouteRequests[key] != nil{
            addRouteRequestToPendingList(key: key, availableRoutes: false, routeReceiver: routeReceiver)
        }else{
            addRouteRequestToPendingList(key: key,availableRoutes: false,routeReceiver: routeReceiver)
            let routeAsyncTask = RouteAsyncTask(rideId: rideId, useCase : useCase, startLat: startLatitude, startLng: startLongitude, endLat: endLatitude, endLng: endLongitude, wayPoints: wayPoints, alternatives: false,weightedRoutes: false, viewController: nil, routeReceive: { (routes, responseObject, error) in
                if routes != nil && routes?.isEmpty == false && (routes![0].waypoints == nil || routes![0].waypoints!.isEmpty || saveCustomRoute){
                    self.saveUserRoute(route: routes![0],key: key)
                }
                self.processPendingDefaultRoutesRequest(key: key, routeList: routes, responseObject: responseObject, error: error)
            })
            routeAsyncTask.getRoutes()
        }
    }
    func getEditedRoute(useCase : String ,rideId : Double, startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, wayPoints: String, handler : @escaping(_ rideRoute: RideRoute?, _ responseError: ResponseError?, _ error: NSError?) -> Void){
        if(!validateRoutePreConditions(startLatitude: startLatitude,startLongitude : startLongitude,endLatitude : endLatitude,endLongitude : endLongitude)){
            let responseError = ResponseError(errorCode: 2044, userMessage: "Distance is very less to find routes, Please check with valid details")
            return handler(nil,responseError,nil)
        }
        let key  = MyRoutesCache.getCacheKey(fromlatitude: startLatitude, fromlongitude: startLongitude, tolatitude: endLatitude, tolongitude: endLongitude,places: 4)
        if let availableRoutes = userRoutes[key], !availableRoutes.isEmpty, let route = getSpecificRoute(availableRoutes: availableRoutes,wayPoints: wayPoints){
            return handler(route,nil,nil)
        }
        
        if let availableRoutes = MyRoutesCachePersistenceHelper.getAvailableRoutes(startLatitude: startLatitude,startLongitude: startLongitude,endLatitude: endLatitude,endLongitude: endLongitude), !availableRoutes.isEmpty {
            userRoutes[key] = availableRoutes
            if let route = getSpecificRoute(availableRoutes: availableRoutes,wayPoints: wayPoints){
                return handler(route,nil,nil)
            }
            
        }
        
        let routeAsyncTask = RouteAsyncTask(rideId: rideId, useCase : useCase, startLat: startLatitude, startLng: startLongitude, endLat: endLatitude, endLng: endLongitude, wayPoints: wayPoints, alternatives: false,weightedRoutes: false, viewController: nil, routeReceive: { (routes, responseObject, error) in
            if let routes = routes, !routes.isEmpty {
                self.saveUserRoute(route: routes[0],key: key)
                return handler(routes[0],nil,nil)
            }else{
                let responseParser = RestResponseParser<RideRoute>().parseArray(responseObject: responseObject, error: error)
                return handler(nil,responseParser.1,error)
            }
            
        })
        routeAsyncTask.getRoutes()
        
    }
    
    func validateRoutePreConditions( startLatitude : Double, startLongitude : Double,  endLatitude : Double, endLongitude : Double) -> Bool{
        let startLocation = CLLocation(latitude: startLatitude, longitude: startLongitude)
        let endLocation = CLLocation(latitude: endLatitude, longitude: endLongitude)
        
        return endLocation.distance(from: startLocation) >= MyRoutesCache.minimumDisplacementBetweenStartAndEnd
    }
    func addRouteRequestToPendingList( key : String,  availableRoutes : Bool,  routeReceiver : RouteReceiver){
        
        if availableRoutes{
            var requests = pendingAllRouteRequests[key]
            if requests == nil{
                requests = [RouteReceiver]()
            }
            requests!.append(routeReceiver)
            pendingAllRouteRequests[key] = requests
            
        }else {
            var requests = pendingDefaultRouteRequests[key]
            if requests == nil{
                requests = [RouteReceiver]()
            }
            requests?.append(routeReceiver)
            pendingDefaultRouteRequests[key] = requests!
        }
    }
    
    func processPendingAllRoutesRequest(key: String, routeList:[RideRoute]?, responseObject : NSDictionary?, error : NSError?){
        let requests = pendingAllRouteRequests[key]
        if requests == nil || requests!.isEmpty{
            return
        }
        for routReceiver in requests! {
            if routeList != nil
            {
                routReceiver.receiveRoute(rideRoute: routeList!,alternative: true)
            }else{
                routReceiver.receiveRouteFailed(responseObject: responseObject, error: error)
            }
        }
        pendingAllRouteRequests.removeValue(forKey: key)
    }
    
    func processPendingDefaultRoutesRequest(key: String, routeList:[RideRoute]?, responseObject : NSDictionary?, error : NSError?){
        let requests = pendingDefaultRouteRequests[key]
        if requests == nil || requests!.isEmpty{
            return
        }
        for routReceiver in requests! {
            if routeList != nil
            {
                routReceiver.receiveRoute(rideRoute: routeList!,alternative: false)
            }else{
                routReceiver.receiveRouteFailed(responseObject: responseObject, error: error)
            }
        }
        pendingDefaultRouteRequests.removeValue(forKey: key)
    }
    
    
    func saveUserRoutes(routes:[RideRoute]?)
    {
        if(routes == nil || routes!.isEmpty == true){
            return
        }
        let route = routes![0]
        let key = MyRoutesCache.getCacheKey(fromlatitude: route.fromLatitude!,fromlongitude: route.fromLongitude!, tolatitude:route.toLatitude!, tolongitude:route.toLongitude!,places: 4)
        
        var availableRoutes = userRoutes[key]
        
        if availableRoutes == nil || availableRoutes!.isEmpty{
            availableRoutes = [RideRoute]()
            
        }
        availableRoutes!.append(contentsOf: routes!)
        userRoutes[key] = availableRoutes
        MyRoutesCachePersistenceHelper.saveRoutesInBulk(routeList: routes!)
        
    }
    
    
    func saveUserRoute(route:RideRoute,key: String?)
    {
        var routeKey = ""
        if let cacheKey = key{
            routeKey = cacheKey
        }else{
            routeKey = MyRoutesCache.getCacheKey(fromlatitude: route.fromLatitude!,fromlongitude: route.fromLongitude!, tolatitude:route.toLatitude!, tolongitude:route.toLongitude!,places :4)
        }
        var availableRoutes = userRoutes[routeKey]
        
        if availableRoutes == nil || availableRoutes!.isEmpty{
            availableRoutes = [RideRoute]()
        }
        availableRoutes!.append(route)
        userRoutes[routeKey] = availableRoutes
        MyRoutesCachePersistenceHelper.saveRoute(riderroute: route)
        
    }
    func getUserRoute(routeId : Double, startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, waypoints: String?, overviewPolyline: String?, travelMode: String, useCase: String,handler : @escaping (_ route : RideRoute) -> Void){
        for userRoute in userRoutes {
            let routes = userRoute.1
            for route in routes{
                if route.routeId == routeId{
                    return handler(route)
                }
            }
        }
        RoutePathServiceClient.getRideRoute(routeId: routeId,startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, waypoints: waypoints, overviewPolyline: overviewPolyline, travelMode: travelMode, useCase: useCase, viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let route = Mapper<RideRoute>().map(JSONObject: responseObject!["resultData"]), let _ = route.overviewPolyline {
                    MyRoutesCache.getInstance()?.saveUserRoute(route: route, key: nil)
                    handler(route)
                }
            }
        }
    }
    
    
    
    
    func getSpecificRoute(availableRoutes:[RideRoute]?,wayPoints:String?)-> RideRoute?{
        
        if availableRoutes == nil || availableRoutes!.isEmpty{
            return nil
        }
        
        for route in availableRoutes!{
            if wayPoints != nil && !wayPoints!.isEmpty && wayPoints != "null" && wayPoints != "nil"{
                let routeWayPointsString = getWayPointsToCompare(waypoints: route.waypoints ?? "")
                let wayPointsString = getWayPointsToCompare(waypoints: wayPoints!)
                if wayPointsString == routeWayPointsString{
                    return route
                }
                continue
            }
            if RoutePathData.ROUTE_TYPE_DEFAULT == route.routeType || RoutePathData.ROUTE_TYPE_MAIN == route.routeType{
                return route
                
            }
            
        }
        return nil
    }
    
    private func getWayPointsToCompare(waypoints: String) -> String{
        guard let wayPointsLocations = Mapper<Location>().mapArray(JSONString: waypoints) else { return "" }
        var wayPointString = ""
        for location in wayPointsLocations{
            wayPointString += String(location.latitude) + String(location.longitude) + ","
        }
        return wayPointString
    }
    
    static func clearCache(){
        MyRoutesCachePersistenceHelper.clearRouteTable()
        myroutescache = nil
    }
    
    private func checkAlternatesAvailable(routes : [RideRoute]?) -> Bool{
        
        if routes == nil || routes?.isEmpty == true{
            return false
        }
        for route in routes! {
            
            if route.routeType == RoutePathData.ROUTE_TYPE_ALTERNATE || route.routeType == RoutePathData.ROUTE_TYPE_MAIN{
                return true
            }
        }
        return false
    }
    
    static func getCacheKey(fromlatitude: Double,fromlongitude: Double,tolatitude: Double,tolongitude: Double,places :Int) -> String{
        
        let formatter = NumberFormatter()
        formatter.roundingMode = .down
        formatter.maximumFractionDigits = places
        
        var cacheKey = formatter.string(from: NSNumber(value: fromlatitude))
        cacheKey = cacheKey!+", "
        cacheKey = cacheKey!+formatter.string(from: NSNumber(value: fromlongitude))!
        cacheKey = cacheKey!+" : "
        cacheKey = cacheKey!+formatter.string(from: NSNumber(value: tolatitude))!
        cacheKey = cacheKey!+", "
        cacheKey = cacheKey!+formatter.string(from: NSNumber(value: tolongitude))!
        return cacheKey!
    }
    
    func getWalkRoute(rideId : Double,useCase : String,startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double,routeReceiver : @escaping routeHandler){
        
        let key  = MyRoutesCache.getCacheKey(fromlatitude: startLatitude, fromlongitude: startLongitude, tolatitude: endLatitude, tolongitude: endLongitude,places: 5)
        var walkRoute = walkRoutes[key]
        if walkRoute != nil {
            routeReceiver(walkRoute,nil)
            MyRoutesCachePersistenceHelper.updateWalkRoute(rideRoute: walkRoute!)
            return
        }
        walkRoute = MyRoutesCachePersistenceHelper.getWalkRoute(startLatitude: startLatitude,startLongitude: startLongitude,endLatitude: endLatitude,endLongitude: endLongitude)
        if walkRoute != nil{
            walkRoutes[key] = walkRoute
            routeReceiver(walkRoute, nil)
            MyRoutesCachePersistenceHelper.updateWalkRoute(rideRoute: walkRoute!)
            return
        }
        if pendingWalkRouteRequests[key] != nil{
            addWalkRouteRequestToPendingList(key: key, routeReceiver: routeReceiver)
        }else{
            addWalkRouteRequestToPendingList(key: key,routeReceiver: routeReceiver)
            
            RoutePathServiceClient.getWalkRoute(rideId: rideId, useCase: useCase, startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, viewController: nil, completionHandler: { (responseObject,error) in
                if let rideRoute = Mapper<RideRoute>().map(JSONObject: responseObject?["resultData"]){
                    self.saveWalkRoute(route: rideRoute,key: key)
                    self.processPendingWalkRoutesRequest(key: key, route: rideRoute, error: nil)
                }else{
                    self.processPendingWalkRoutesRequest(key: key, route: nil, error: error)
                }
            })
        }
    }
    
    func getDistance(directionRoute : Route) -> Double{
        var distance = 0.0
        for leg in directionRoute.legs!{
            distance = distance + Double(leg.distance!.value!)
        }
        return distance/1000
    }
    
    func getDuration(directionRoute : Route) -> Double{
        var duration = 0.0
        for leg in directionRoute.legs!{
            duration = duration + Double(leg.duration!.value!)
        }
        return duration/60
    }
    
    func addWalkRouteRequestToPendingList( key : String,  routeReceiver : @escaping routeHandler){
        var requests = pendingWalkRouteRequests[key]
        if requests == nil{
            requests = [routeHandler]()
        }
        requests!.append(routeReceiver)
        pendingWalkRouteRequests[key] = requests
    }
    func processPendingWalkRoutesRequest(key: String, route:RideRoute?,error : NSError?){
        let requests = pendingWalkRouteRequests[key]
        if requests == nil || requests!.isEmpty{
            return
        }
        for routReceiver in requests! {
            if route != nil
            {
                routReceiver(route, nil)
            }else{
                routReceiver(nil, error)
            }
        }
        pendingWalkRouteRequests.removeValue(forKey: key)
    }
    func saveWalkRoute(route:RideRoute,key : String)
    {
        route.routeId = NSDate().getTimeStamp()
        walkRoutes[key] = route
        MyRoutesCachePersistenceHelper.saveWalkRoute(riderroute: route)
    }
    static func cleanupRoutes( routes : [RideRoute]) -> [RideRoute]{
        
        var dictionary = [String : RideRoute]()
        for route in routes {
            guard let polyline = route.overviewPolyline else {
                continue
            }
            dictionary[polyline] = route
        }
        
        if dictionary.count < 3{
            return Array(dictionary.values)
        }
        var filteredRoutes = [RideRoute]()
        let valuesFromDic = dictionary.values
        for  route in valuesFromDic {
            if route.routeType !=  RoutePathData.ROUTE_TYPE_CUSTOM{
                filteredRoutes.append(route)
            }
        }
        return filteredRoutes
        
    }
}
protocol  RouteReceiver :class {
    func receiveRoute(rideRoute:[RideRoute], alternative: Bool)
    func receiveRouteFailed(responseObject :NSDictionary?,error: NSError?)
}
typealias routeHandler = (_ rideRoute: RideRoute?,_ error : NSError?) -> Void
