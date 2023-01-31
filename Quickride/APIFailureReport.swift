//
//  APIFailureReport.swift
//  Quickride
//
//  Created by apple on 4/3/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class APIFailureReport : NSObject, Mappable {
    
    var userId : String?
    var failedAPI : String?
    var referenceData : String?
    var apiKey : String?
    var errorMessage : String?
    var errorCode : String?
    var timeOfOccuranceInMillis : Double = 0.0
    
    
    static let STATUS_OK = "OK"
    static let STATUS_ZERO_RESULTS = "ZERO_RESULTS"
    
    static let AUTO_COMPLETE_PLACES_API = "Google Auto Complete Places API"
    static let AUTO_COMPLETE_PLACE_DETAILS_API = "Google Auto Complete place Details API"
    static let GEOCODE_API = "Google Geocoding API"
    static let DIRECTION_API = "Google Directions API"
    static let DISTANCE_MATRIX_API = "Google Distance Matrix API"
    static let DYNAMIC_LINKS_API = "Firebase Dynamic Links API"
    
    required init?(map: Map) {
        
    }
    
    public init(userId : String ,  failedAPI : String , apiKey : String, errorMessage : String?, errorCode : String?, timeOfOccuranceInMillis : Double) {
        self.userId = userId
        self.failedAPI = failedAPI
        self.apiKey = apiKey
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.timeOfOccuranceInMillis = timeOfOccuranceInMillis
    }
    func prepareAndSetReferenceData(params : [String : String]){
        referenceData = ""
        for tuple in params{
            referenceData  = referenceData! + tuple.key + "=" + tuple.value + "&"
        }
    }
    
    func mapping(map: Map) {
        self.userId <- map["userId"]
        self.failedAPI <- map["failedAPI"]
        self.referenceData <- map["referenceData"]
        self.apiKey <- map["apiKey"]
        self.errorMessage <- map["errorMessage"]
        self.errorCode <- map["errorCode"]
        self.timeOfOccuranceInMillis <- map["timeOfOccuranceInMillis"]
    }
    public override var description: String { 
        return "userId: \(String(describing: self.userId))," + "failedAPI: \(String(describing: self.failedAPI))," + " referenceData: \( String(describing: self.referenceData))," + " apiKey: \(String(describing: self.apiKey))," + " errorMessage: \(String(describing: self.errorMessage)),"
            + " errorCode: \(String(describing: self.errorCode))," + "timeOfOccuranceInMillis: \(String(describing: self.timeOfOccuranceInMillis)),"
    }
}
