//
//  RelayMatch.swift
//  Quickride
//
//  Created by Vinutha on 18/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RelayMatch: Mappable{
    
    var firstLegMatch: MatchedRider?
    var secondLegMatches = [MatchedRider]()
    
    mutating func mapping(map: Map) {
        self.firstLegMatch <- map["firstLegMatch"]
        self.secondLegMatches <- map["secondLegMatches"]
    }
    
    init?(map: Map) {
        
    }
    
    public var description: String {
        return "firstLegMatch: \(String(describing: self.firstLegMatch))," + "secondLegMatches: \(String(describing: self.secondLegMatches)),"
    }
}
