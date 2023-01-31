//
//  UpdateRegularRideTask.swift
//  Quickride
//
//  Created by QuickRideMac on 26/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol UpdateRegularRideDelegate{
    func updateRegularRiderRide(ride: RegularRiderRide)
    func updateRegularPassengerRide(ride: RegularPassengerRide)
}
class UpdateRegularRideTask {
    
    var regularRide : RegularRide?
    var delegate : UpdateRegularRideDelegate?
    var viewController :UIViewController?
    var rideRoute : RideRoute?
    
    init(regularRide : RegularRide?, rideRoute : RideRoute?,delegate : UpdateRegularRideDelegate?, viewController :UIViewController?){
        self.regularRide = regularRide
        self.rideRoute = rideRoute
        self.delegate = delegate
        self.viewController = viewController
    }
    func updateRegularRide(){
        
    }
    func handleResponse(responseObject: NSDictionary?,error : NSError?){
      AppDelegate.getAppDelegate().log.error("handleResponse() \(String(describing: error))")
        QuickRideProgressSpinner.stopSpinner()
        if(responseObject == nil || responseObject!["result"] as! String == "FAILURE"){
            ErrorProcessUtils.handleError(responseObject: responseObject,error :error, viewController :viewController, handler: nil)
            return
        }
        if responseObject!["result"] as! String == "SUCCESS"{
            if let route = rideRoute{
                regularRide?.routeId = route.routeId
                regularRide?.routePathPolyline = route.overviewPolyline!
                regularRide?.waypoints = route.waypoints

            }
             MyRegularRidesCache.getInstance().updateRegularRide(regularRide: regularRide!)
            processSuccessResponse(updatedRide: regularRide!)
        }
    }
    func processSuccessResponse(updatedRide : RegularRide){}
}
