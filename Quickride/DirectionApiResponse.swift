//
//  DirectionApiResponse.swift
//  Quickride
//
//  Created by rakesh on 11/21/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class DirectionApiResponse: Mappable {
   
    var routes : [Route]?
    var status : String?
    var error_message : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.routes <- map["routes"]
        self.status <- map["status"]
        self.error_message <- map["error_message"]
    }

}


class Route : Mappable{
   
    var legs : [Leg]?
    var overviewPolyline : OverviewPolyline?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.legs <- map["legs"]
        self.overviewPolyline <- map["overview_polyline"]
    }
    
    
}


class OverviewPolyline : Mappable{
    
    var points : String?
    
    required init?(map: Map) {
        
    }
   func mapping(map: Map) {
        self.points <- map["points"]
    }
    
    
}


class Leg : Mappable{
    
    var startLocation : LocationMap?
    var distance : Distance?
    var startAddress : String?
    var endAddress : String?
    var duration : Distance?
    var endLocation : LocationMap?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.startLocation <- map["start_location"]
        self.distance <- map["distance"]
        self.startAddress <- map["start_address"]
        self.endAddress <- map["end_address"]
        self.duration <- map["duration"]
        self.endLocation <- map["end_location"]
    }
}

class LocationMap : Mappable{
    var lat : Double?
    var lng : Double?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.lat <- map["lat"]
        self.lng <- map["lng"]
    }
}





