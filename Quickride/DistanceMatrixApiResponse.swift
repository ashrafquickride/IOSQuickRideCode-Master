//
//  DistanceMatrixApiResponse.swift
//  Quickride
//
//  Created by rakesh on 11/20/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class DistanceMatrixApiResponse :NSObject, Mappable{
   
    var destinationAddresses : [String]!
    var originAddresses : [String]!
    var rows : [Row]!
    var status : String?
    var error_message : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.destinationAddresses <- map["destination_addresses"]
        self.originAddresses <- map["origin_addresses"]
        self.status <- map["status"]
        self.rows <- map["rows"]
        self.error_message <- map["error_message"]
    }
    public override var description: String {
        return "destinationAddresses: \(String(describing: self.destinationAddresses))," + "originAddresses: \(String(describing: self.originAddresses))," + " rows: \( String(describing: self.rows))," + " status: \(String(describing: self.status))," + " error_message: \(String(describing: self.error_message)),"
    }
    
}

class Row :NSObject, Mappable{
    
    var elements : [Element]!
   
    required init?(map: Map) {
        
    }
    
     func mapping(map: Map) {
      self.elements <- map["elements"]
    }
    public override var description: String {
        return "elements: \(String(describing: self.elements)),"
    }
    
}

class Element :NSObject, Mappable{
   
    var distance : Distance?
    var duration : Distance?
    var status : String?
    var durationInTraffic : Distance?

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.distance <- map["distance"]
        self.duration <- map["duration"]
        self.status <- map["status"]
        self.durationInTraffic <- map["duration_in_traffic"]
    }
    public override var description: String {
        return "distance: \(String(describing: self.distance))," + "duration: \(String(describing: self.duration))," + " status: \( String(describing: self.status))," + " durationInTraffic: \(String(describing: self.durationInTraffic)),"
    }
    
}

class Distance :NSObject, Mappable{
    
    var text : String?
    var value : Int?
    
    required init?(map: Map) {
        
    }
    
     func mapping(map: Map) {
        self.text <- map["text"]
        self.value <- map["value"]
     }
    public override var description: String {
        return "text: \(String(describing: self.text))," + "value: \(String(describing: self.value)),"
    }
}
