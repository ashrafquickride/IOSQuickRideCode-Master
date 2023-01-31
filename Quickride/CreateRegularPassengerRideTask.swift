//
//  CreateRegularPassengerRideTask.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class CreateRegularPassengerRideTask {
    
    var regularPassengerRide : RegularPassengerRide?
    var passengerRideId : Double = 0
    var viewController :UIViewController?
    var rideRoute : RideRoute?
    var isFromSignUpFlow = false
    
    init(regularPassengerRide : RegularPassengerRide,passengerRideId : Double,viewController :UIViewController,rideRoute : RideRoute?,isFromSignUpFlow : Bool){
        self.regularPassengerRide = regularPassengerRide
        self.passengerRideId = passengerRideId
        self.viewController = viewController
        self.rideRoute = rideRoute
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    func createRegularPassengerRide(handler : @escaping regularRideCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("createRegularPassengerRide()")
        RegularPassengerRideServiceClient.createRegularPassengerRide(ride: regularPassengerRide!, passengerRideId: passengerRideId, rideRoute: self.rideRoute) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!.value(forKey: "result")! as! String == "SUCCESS"{
                    
                    let regularPassengerRide:RegularPassengerRide? = Mapper<RegularPassengerRide>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as RegularPassengerRide
                    MyRegularRidesCache.getInstance().addNewRide(regularRide: regularPassengerRide!)
                    
                    UserDataCache.getInstance()?.setUserRecentRideType(rideType: Ride.PASSENGER_RIDE)
                handler(nil,nil,nil,regularPassengerRide)
            }
            else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                
                let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                handler(responseError,nil,nil,nil)
            }else{
               handler(nil,error,nil,nil)
            }
        }
    }
   
}
