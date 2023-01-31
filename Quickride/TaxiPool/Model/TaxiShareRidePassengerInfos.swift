//
//  TaxiShareRidePassengerInfos.swift
//  Quickride
//
//  Created by Ashutos on 4/29/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class TaxiShareRidePassengerInfos: NSObject, Mappable {
    
    var id: Double?
    var taxiRideId: Double?
    var passengerRideId: Double?
    var passengerUserId: Double?
    var passengerName: String?
    var passengerContactNo: String?
    var passengerEmail: String?
    var passengerImageURI: String?
    var taxiUnjoinReason: String?
    var initialFare: Double?
    var finalFare: Double?
    var cancellationAmount: Double?
    var pickUpAddress: String?
    var pickUpLatitude: Double?
    var pickUpLongitude: Double?
    var pickUpTime: Double?
    var pickUpSequenceOrder: Int?
    var dropSequenceOrder: Int?
    var dropAddress: String?
    var dropLatitude: Double?
    var dropLongitude: Double?
    var actualDistance: Double?
    var finalDistance: Double?
    var pkTime: Double?
    var dpTime: Double?
    var plndStTime: Double?
    var plndEndTime: Double?
    var joinStatus: String?
    var advanceAmount: Double?
    var pickupOtp: String?
    
    static let FLD_TAXI_SHARE_UNJOIN_REASON = "taxiUnjoinReason"
    static let PAYMENT_PENDING = "Payment_Pending"
    
    required init?(map: Map) {
        
    }
    
    override init() {
        
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        taxiRideId <- map["taxiRideId"]
        passengerRideId <- map["passengerRideId"]
        passengerUserId <- map["passengerUserId"]
        passengerName <- map["passengerName"]
        passengerContactNo <- map["passengerContactNo"]
        passengerEmail <- map["passengerEmail"]
        passengerImageURI <- map["passengerImageURI"]
        taxiUnjoinReason <- map["taxiUnjoinReason"]
        initialFare <- map["initialFare"]
        finalFare <- map["finalFare"]
        cancellationAmount <- map["cancellationAmount"]
        pickUpAddress <- map["pickUpAddress"]
        pickUpLatitude <- map["pickUpLatitude"]
        pickUpLongitude <- map["pickUpLongitude"]
        pickUpTime <- map["pickUpTime"]
        pickUpSequenceOrder <- map["pickUpSequenceOrder"]
        dropSequenceOrder <- map["dropSequenceOrder"]
        dropAddress <- map["dropAddress"]
        dropLatitude <- map["dropLatitude"]
        dropLongitude <- map["dropLongitude"]
        actualDistance <- map["actualDistance"]
        finalDistance <- map["finalDistance"]
        pkTime <- map["pkTime"]
        dpTime <- map["dpTime"]
        plndStTime <- map["plndStTime"]
        plndEndTime <- map["plndEndTime"]
        joinStatus <- map["joinStatus"]
        advanceAmount <- map["advanceAmount"]
        pickupOtp <- map["pickupOtp"]
    }
    
    public override var description: String {
        return "id: \(String(describing: self.id)),"
            + "taxiRideId: \(String(describing: self.taxiRideId)),"
            + " passengerRideId: \( String(describing: self.passengerRideId)),"
            + " passengerUserId: \(String(describing: self.passengerUserId)),"
            + " passengerName: \(String(describing: self.passengerName)),"
            + " passengerContactNo: \(String(describing: self.passengerContactNo)),"
            + " passengerEmail: \(String(describing: self.passengerEmail)),"
            + " passengerImageURI: \(String(describing: self.passengerImageURI)),"
            + "taxiUnjoinReason: \(String(describing: self.taxiUnjoinReason)),"
            + "initialFare: \(String(describing: self.initialFare)),"
            + "finalFare: \(String(describing: self.finalFare)),"
            + "cancellationAmount: \(String(describing: self.cancellationAmount)),"
            + " pickUpAddress: \(String(describing: self.pickUpAddress)),"
            + " pickUpLatitude: \(String(describing: self.pickUpLatitude)),"
            + " pickUpLongitude: \(String(describing: self.pickUpLongitude)),"
            + "pickUpTime: \(String(describing: self.pickUpTime)),"
            + " pickUpSequenceOrder: \(String(describing: self.pickUpSequenceOrder)),"
            + " dropSequenceOrder: \(String(describing: self.dropSequenceOrder)),"
            + " dropAddress: \(String(describing: self.dropAddress)),"
            + "dropLatitude: \(String(describing: self.dropLatitude)),"
            + " dropLongitude: \(String(describing: self.dropLongitude)),"
            + "actualDistance: \(String(describing: self.actualDistance)),"
            + "finalDistance: \(String(describing: self.finalDistance)),"
            + "pkTime: \(String(describing: self.pkTime)),"
            + "dpTime: \(String(describing: self.dpTime)),"
            + "plndStTime: \(String(describing: self.plndStTime)),"
            + "plndEndTime: \(String(describing: self.plndEndTime)),"
            + "joinStatus: \(String(describing: self.joinStatus))"
            + "advanceAmount: \(String(describing: self.advanceAmount)),"
            + "pickupOtp: \(String(describing: self.pickupOtp))"
    }
    
}
