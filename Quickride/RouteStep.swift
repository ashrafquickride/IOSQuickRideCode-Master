//
//  RouteStep.swift
//  Quickride
//
//  Created by KNM Rao on 28/10/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RouteStep: NSObject,Mappable {
  
  var id : Double = 0
  var routeId : Double = 0
  var polyline : String?
  var distance :Int = 0
  
  required init?(map: Map) {
    
  }
  func mapping(map: Map) {
    self.id <- map["id"]
    self.routeId <- map["routeId"]
    self.polyline <- map["polyline"]
    self.distance <- map["distance"]
    
  }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "routeId: \(String(describing: self.routeId))," + " polyline: \( String(describing: self.polyline))," + " distance: \(String(describing: self.distance)),"
    }
}
