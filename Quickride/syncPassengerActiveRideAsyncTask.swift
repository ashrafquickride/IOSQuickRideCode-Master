//
//  syncPassengerActiveRideAsyncTask.swift
//  Quickride
//
//  Created by KNM Rao on 07/12/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias SyncPassengerActiveRideReceiver = (_ passengerRide : PassengerRide?)->Void

class SyncPassengerActiveRideTask {
  
  var userId : Double
  var rideId : Double
  var status : String
  var delegate:SyncPassengerActiveRideReceiver?
  
  init(userId : Double, rideId : Double, status : String, passengerActiveRideReceive : @escaping SyncPassengerActiveRideReceiver){
    self.userId = userId
    self.rideId = rideId
    self.status = status
    self.delegate = passengerActiveRideReceive
  }
  
  func getPassengerRide(){
    AppDelegate.getAppDelegate().log.debug("getRoutes()")
    
    RideServicesClient.syncActivePassengerRide(userId: userId, rideId: rideId, status: status) { (responseObject, error) in
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
        let passengerRide  = Mapper<PassengerRide>().map(JSONObject: responseObject!["resultData"])
        self.delegate!(passengerRide)
        
      }else{
        self.delegate!(nil)
        
      }
    }
  
  }
}
