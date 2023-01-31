//
//  EncashInformation.swift
//  Quickride
//
//  Created by KNM Rao on 14/08/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EncashInformation : NSObject, Mappable {
  var redeemablePoints : Int = 0
  var encashingFirstTime : Bool = false
  var preferredFuelCompany : String?
  var fuelCardRegistrations : [FuelCardRegistration]?
    
  override init(){
    
  }
  
  required init(map:Map){
    
  }

  func mapping(map: Map) {
    redeemablePoints <- map["redeemablePoints"]
    encashingFirstTime <- map["encashingFirstTime"]
    preferredFuelCompany <- map["preferredFuelCompany"]
    fuelCardRegistrations <- map["fuelCardRegistrations"]
  }
  func getParams() -> [String : String] {
    AppDelegate.getAppDelegate().log.debug("getParams()")
    var params : [String : String] = [String : String]()
    params["redeemablePoints"] = String(describing: self.redeemablePoints)
    params["encashingFirstTime"] = String(describing: self.encashingFirstTime)
    return params
  }
    public override var description: String {
        return "redeemablePoints: \(String(describing: self.redeemablePoints))," + "encashingFirstTime: \(String(describing: self.encashingFirstTime))," + " preferredFuelCompany: \(String(describing: self.preferredFuelCompany)),"
    }
}
