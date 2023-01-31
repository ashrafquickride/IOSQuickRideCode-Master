//
//  SaveRouteViewUtils.swift
//  Quickride
//
//  Created by Vinutha on 29/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SaveRouteViewUtils {
    func saveEditedRoute(useCase: String, ride: Ride, preferredRoute: UserPreferredRoute?, viaPointString: String?, routeName : String?, handler : @escaping(_ route : RideRoute?, _ userPreferredRoute: UserPreferredRoute?, _ responseError : ResponseError?,_ error: NSError?) -> Void){
        RoutePathServiceClient.confirmCustomizedRouteAndSave(rideId: 0, useCase: useCase, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endLatitude: ride.endLatitude!, endLongitude: ride.endLongitude!, wayPoints: viaPointString, confirmed : true,viewController: nil, completionHandler: {(responseObject, error) in
            let result = RestResponseParser<RideRoute>().parse(responseObject: responseObject, error: error)
            if let route = result.0{
                route.waypoints = viaPointString
                MyRoutesCache.getInstance()!.saveUserRoute(route: route,key: nil)
                if preferredRoute != nil {
                    self.updateUserPreferredRoute(userPreferredRoute: preferredRoute!, rideRoute: route)
                    handler(result.0,nil,result.1,result.2)
                } else {
                    self.saveUserPreferredRoute(routeName: routeName, rideRoute: route, ride: ride) { (userPreferredRoute, responseError, error) in
                        handler(result.0,userPreferredRoute,result.1,result.2)
                    }
                }
            } else {
                ErrorProcessUtils.handleResponseError(responseError: result.1, error: result.2, viewController: nil)
            }
        })
    }
    func saveTaxiEditedRoute(useCase: String, startLocation: Location?, endLocation: Location?, preferredRoute: UserPreferredRoute?, viaPointString: String?, routeName : String?, handler : @escaping(_ route : RideRoute?, _ userPreferredRoute: UserPreferredRoute?, _ responseError : ResponseError?,_ error: NSError?) -> Void){
        RoutePathServiceClient.confirmCustomizedRouteAndSave(rideId: 0, useCase: useCase, startLatitude: startLocation?.latitude ?? 0, startLongitude: startLocation?.longitude ?? 0, endLatitude: endLocation?.latitude ?? 0, endLongitude: endLocation?.longitude ?? 0, wayPoints: viaPointString, confirmed : true,viewController: nil, completionHandler: {(responseObject, error) in
            let result = RestResponseParser<RideRoute>().parse(responseObject: responseObject, error: error)
            if let route = result.0{
                route.waypoints = viaPointString
                MyRoutesCache.getInstance()!.saveUserRoute(route: route,key: nil)
                if preferredRoute != nil {
                    self.updateUserPreferredRoute(userPreferredRoute: preferredRoute!, rideRoute: route)
                    handler(result.0,preferredRoute,result.1,result.2)
                } else {
                    self.saveTaxiUserPreferredRoute(routeName : routeName, rideRoute: route,startLocation: startLocation, endLocation: endLocation) { (userPreferredRoute, responseError, error) in
                        handler(result.0,userPreferredRoute,result.1,result.2)
                    }
                }
            } else {
                ErrorProcessUtils.handleResponseError(responseError: result.1, error: result.2, viewController: nil)
            }
        })
    }
    private func saveTaxiUserPreferredRoute(routeName : String?, rideRoute: RideRoute,startLocation: Location?, endLocation: Location?, handler : @escaping (_ route : UserPreferredRoute?,_  responseError : ResponseError?,_ error : NSError?) -> Void){
        
        var userId = Double(QRSessionManager.getInstance()!.getUserId())
        if userId == nil || userId == 0{
            userId = SharedPreferenceHelper.getUserObject()?.phoneNumber
        }
        
        let userPreferredRoute = UserPreferredRoute(id: 0, userId: userId, routeId: rideRoute.routeId, fromLatitude: startLocation?.latitude ?? 0, fromLongitude: startLocation?.longitude ?? 0, toLatitude: endLocation?.latitude ?? 0, toLongitude: endLocation?.longitude ?? 0, rideRoute: rideRoute, fromLocation: startLocation?.address, toLocation: endLocation?.address, routeName: routeName)
        
        RoutePathServiceClient.saveUserPreferredRoute(userPreferredRoute: userPreferredRoute) { (responseObject, error) in
            let result = RestResponseParser<UserPreferredRoute>().parse(responseObject: responseObject, error: error)
            if let route = result.0{
                route.rideRoute = rideRoute
                UserDataCache.getInstance()?.saveUserPreferredRoute(userPreferredRoute: route)
            }
            handler(result.0,result.1,result.2)
        }
        
    }
    
    private func saveUserPreferredRoute(routeName : String?, rideRoute: RideRoute, ride: Ride, handler : @escaping (_ route : UserPreferredRoute?,_  responseError : ResponseError?,_ error : NSError?) -> Void){
        
        var userId = Double(QRSessionManager.getInstance()!.getUserId())
        if userId == nil || userId == 0{
            userId = SharedPreferenceHelper.getUserObject()?.phoneNumber
        }
        
        let userPreferredRoute = UserPreferredRoute(id: 0, userId: userId, routeId: rideRoute.routeId, fromLatitude: ride.startLatitude, fromLongitude: ride.startLongitude, toLatitude: ride.endLatitude!, toLongitude: ride.endLongitude, rideRoute: rideRoute, fromLocation: ride.startAddress, toLocation: ride.endAddress, routeName: routeName)
        
        RoutePathServiceClient.saveUserPreferredRoute(userPreferredRoute: userPreferredRoute) { (responseObject, error) in
            let result = RestResponseParser<UserPreferredRoute>().parse(responseObject: responseObject, error: error)
            if let route = result.0{
                route.rideRoute = rideRoute
                UserDataCache.getInstance()?.saveUserPreferredRoute(userPreferredRoute: route)
            }
            handler(result.0,result.1,result.2)
        }
        
    }
    private func updateUserPreferredRoute(userPreferredRoute : UserPreferredRoute, rideRoute: RideRoute){
        
        userPreferredRoute.routeId = rideRoute.routeId
        userPreferredRoute.rideRoute = rideRoute
        RoutePathServiceClient.updateUserPreferredRoute(userPreferredRoute : userPreferredRoute) { (responseObject, error) in
                UserDataCache.getInstance()?.updateUserPreferredRoute(userPreferredRoute: userPreferredRoute)
            
        }
    }
    
    func getSuggestingNameForRoute(ride: Ride, wayPoints: [Location]?) -> String{
        var routeName =  String(ride.startAddress.prefix(4))
        if let wayPoints = wayPoints {
            for waypoint in wayPoints {
                if let address = waypoint.address {
                    routeName = routeName + "-" + String(address.prefix(4))
                }
            }
        }
        routeName = routeName + "-" + String(ride.endAddress.prefix(4))
        return routeName
    }
}
