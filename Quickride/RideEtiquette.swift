//
//  RideEtiquette.swift
//  Quickride
//
//  Created by iDisha on 03/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideEtiquette : NSObject,Mappable{
   
    var id: Double?
    var guideline: String?
    var severity: Int?
    var imageUri: String?
    var role: String?
    var tolerentCount: Int?
    var feedbackMsg: String?
    var ratings: String?
    var category: String?
    
    static let FLD_ROLE = "role"
    static let FLD_ETIQUETTE_ID = "etiquetteIds"
    static let SEVERITY_LOW = 0
    static let SEVERITY_MEDIUM = 1
    static let SEVERITY_HIGH = 2
    static let ROLE_BOTH = "Both"
    
    init(feedbackMsg: String) {
        self.feedbackMsg = feedbackMsg
    }
    
    required public init(map:Map){
        
    }
    
    public func mapping(map:Map){
        id <- map["id"]
        guideline <- map["guideline"]
        severity <- map["severity"]
        imageUri <- map["imageUri"]
        role <- map["role"]
        tolerentCount <- map["tolerentCount"]
        feedbackMsg <- map["feedbackMsg"]
        ratings <- map["ratings"]
        category <- map["category"]
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "guideline: \(String(describing: self.guideline))," + " severity: \( String(describing: self.severity))," + " imageUri: \(String(describing: self.imageUri))," + " role: \(String(describing: self.role)),"
            + " tolerentCount: \(String(describing: self.tolerentCount))," + "feedbackMsg: \(String(describing: self.feedbackMsg))," + "ratings:\(String(describing: self.ratings)),"
    }
}
