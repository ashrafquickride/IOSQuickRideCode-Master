//
//  LatLng.swift
//  Quickride
//
//  Created by KNM Rao on 11/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class LatLng : NSObject,Mappable {
    
    var latitude:Double = 0
    var longitude:Double = 0
    
    override init() {
        
    }
    init(lat : Double ,long : Double) {
        self.latitude = lat
        self.longitude = long
    }
    
    required public init(map:Map){
        
    }
    
    public func mapping(map:Map){
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
    public override var description: String {
        return "latitude: \(String(describing: self.latitude))," + "longitude: \(String(describing: self.longitude)),"
    }
}
