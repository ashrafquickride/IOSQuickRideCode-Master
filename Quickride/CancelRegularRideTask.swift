//
//  CancelRegularRideAsyncTask.swift
//  Quickride
//
//  Created by QuickRideMac on 05/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CancelRegularRideTask{
    
    var ride : Ride?
    var rideType : String?
    var viewController : UIViewController?
    init(ride : Ride,rideType : String?,viewController : UIViewController?){
        self.rideType = rideType
        self.ride = ride
        self.viewController = viewController
    }
    func cancelRegularRide(){
       AppDelegate.getAppDelegate().log.debug("cancelRegularRide()")
        if rideType == Ride.REGULAR_RIDER_RIDE{
            QuickRideProgressSpinner.startSpinner()
            RegularRiderRideServiceClient.cancelRegularRiderRide(regularRiderRideId: ride!.rideId, handler: { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                self.handleResponse(responseObject: responseObject,error: error)
            })
        }else{
            QuickRideProgressSpinner.startSpinner()
            RegularPassengerRideServiceClient.cancelRegularPassengerRide(rideId: ride!.rideId, completionHander: { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                self.handleResponse(responseObject: responseObject,error: error)
                
            })
        }
    }
    func handleResponse(responseObject: NSDictionary?,error :NSError?){

        AppDelegate.getAppDelegate().log.debug("handleResponse() \(String(describing: error)) ")

        if responseObject != nil && responseObject!.value(forKey: "result")! as! String == "SUCCESS"{
            let userId = QRSessionManager.getInstance()?.getUserId()
            let rideStatus =  RideStatus(rideId: ride!.rideId,userId: Double(userId!)!,status: Ride.RIDE_STATUS_CANCELLED,rideType: rideType!)
            MyRegularRidesCache.getInstance().updateRideStatus(rideStatus: rideStatus)
        }
    }
}
