//
//  CreateRegularRiderRideTask.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias regularRideCompletionHandler = (_ responseError : ResponseError?,_ error: NSError?,_ regularRiderRide : RegularRiderRide?,_ regularPassengerRide : RegularPassengerRide?) -> Void

class CreateRegularRiderRideTask  {
    var regularRiderRide : RegularRiderRide?
    var riderRideId : Double = 0
    var viewController :UIViewController?
    var rideRoute : RideRoute?
    var isFromSignUpFlow = false
    
    init(regularriderRide : RegularRiderRide,riderRideId : Double,viewController :UIViewController,rideRoute : RideRoute?, isFromSignUpFlow : Bool){
        self.regularRiderRide = regularriderRide
        self.riderRideId = riderRideId
        self.viewController = viewController
        self.rideRoute = rideRoute
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    func createRegularRiderRide(handler : @escaping regularRideCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("createRegularRiderRide()")
        RegularRiderRideServiceClient.createRegularRiderRide(ride: regularRiderRide!, riderRideId: riderRideId, rideRoute: self.rideRoute) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!.value(forKey: "result")! as! String == "SUCCESS"{
                    let regularRiderRide:RegularRiderRide? = Mapper<RegularRiderRide>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as RegularRiderRide
                    MyRegularRidesCache.getInstance().addNewRide(regularRide: regularRiderRide!)
                    UserDataCache.getInstance()?.setUserRecentRideType(rideType: Ride.RIDER_RIDE)
                    handler(nil, nil,regularRiderRide,nil)
            }
            else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                
                let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                 handler(responseError, nil,nil,nil)
            }else{
                  handler(nil, error,nil,nil)
            }
        }
    }
}
