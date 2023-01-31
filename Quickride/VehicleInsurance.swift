//
//  VehicleInsurance.swift
//  Quickride
//
//  Created by iDisha on 30/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class VehicleInsurance: NSObject, Mappable{
    
    var offerText: String?
    var link: String?
    var insuranceType: String?
    var insuranceImageUrl: String?
    
    required public init?(map: Map) {
        
    }
    
    override init() { }
    
    func mapping(map: Map) {
        self.offerText <- map["offerText"]
        self.link <- map["link"]
        self.insuranceType <- map["insuranceType"]
        self.insuranceImageUrl <- map["imageUri"]
    }
    public override var description: String {
           return "offerText: \(String(describing: self.offerText))," + "link: \(String(describing: self.link))," + " insuranceType: \( String(describing: self.insuranceType))," + "insuranceImageUrl: \(String(describing: self.insuranceImageUrl)),"
       }
}
