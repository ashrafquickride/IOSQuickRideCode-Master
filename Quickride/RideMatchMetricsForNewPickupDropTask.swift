//
//  RideMatchMetricsForNewPickupDropTask.swift
//  Quickride
//
//  Created by KNM Rao on 08/04/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias RideMatchMetricsForNewPickupDropReceiver = (_ rideMatchMetrics : RideMatchMetrics?,_ responseObject: NSDictionary?,_ error: NSError?)->Void
class RideMatchMetricsForNewPickupDropTask {

  var passengerRideId : Double = 0.0
  var riderRideId : Double = 0.0
  var riderId : Double = 0
  var passengerId : Double = 0
  var pickupLat : Double = 0.0
  var pickupLng : Double = 0.0
  var dropLat : Double = 0.0
  var dropLng : Double = 0.0
  var noOfSeats : Int = 1
  var rideMatchMetrics : RideMatchMetrics?
  var viewController : UIViewController?
  
  init(riderRideId : Double,passengerRideId : Double ,riderId : Double,passengerId : Double,pickupLat : Double,pickupLng : Double,dropLat : Double,dropLng : Double,noOfSeats : Int,viewController : UIViewController){
    self.passengerRideId = passengerRideId
    self.riderRideId = riderRideId
    self.riderId = riderId
    self.passengerId = passengerId
    self.pickupLat = pickupLat
    self.pickupLng = pickupLng
    self.dropLat = dropLat
    self.dropLng = dropLng
    self.noOfSeats = noOfSeats
    self.viewController = viewController
  }
  
  func getRideMatchMetricsForNewPickupDrop(handler :@escaping RideMatchMetricsForNewPickupDropReceiver){
    rideMatchMetrics = MatchedUsersCache.getInstance().getRideMatchMetrics(riderRideId: riderRideId, passengerRideId: passengerRideId, pickupLat: pickupLat, pickupLng: pickupLng, dropLat: dropLat, dropLng: dropLng, noOfSeats: noOfSeats)
    if rideMatchMetrics != nil{
        handler(rideMatchMetrics!, nil, nil)
      return
    }
    RideMatcherServiceClient.getRideMatchMetricsForNewPickupDrop(riderRideId: riderRideId, passengerRideId: passengerRideId,riderId: riderId,passengerId: passengerId, pickupLat: pickupLat, pickupLng: pickupLng, dropLat: dropLat, dropLng: dropLng, noOfSeats: noOfSeats, viewController: viewController) { (responseObject, error) in
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
        self.rideMatchMetrics = Mapper<RideMatchMetrics>().map(JSONObject: responseObject!["resultData"])
        handler(self.rideMatchMetrics, nil, nil)
      }else{
        handler(self.rideMatchMetrics, responseObject, error)
      }
    }
  }
}
