//
//  TaxiRidePassengerBasicInfo.swift
//  Quickride
//
//  Created by Ashutos on 23/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiRidePassengerBasicInfo: Mappable {
    var userId: Double?
    var userName: String?
    var contactNo: String?
    var gender: String?
    var imageURI: String?
    var taxiGroupId: String?
    var startAddress: String?
    var startLat: Double?
    var startLng: Double?
    var endAddress: String?
    var endLat: Double?
    var endLng: Double?
    var noOfSeats: Int = 1
    var status: String?
    var pickupTimeMs: Double?
    var pickupSequenceOrder: Int?
    var dropTimeMs: Double?
    var dropSequenceOrder: Int?
    var pickupReachedTimeMs: Double?
    var creationTimeMs: Double?
    var modifiedTimeMs: Double?
    var extraKmFare: Double?
    var extraMinFare: Double?

    
    init(){
        
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.userId <- map["userId"]
        self.userName <- map["userName"]
        self.contactNo <- map["contactNo"]
        self.gender <- map["gender"]
        self.imageURI <- map["imageURI"]
        self.taxiGroupId <- map["taxiGroupId"]
        self.startAddress <- map["startAddress"]
        self.startLat <- map["startLat"]
        self.startLng <- map["startLng"]
        self.endAddress <- map["endAddress"]
        self.endLat <- map["endLat"]
        self.endLng <- map["endLng"]
        self.noOfSeats <- map["noOfSeats"]
        self.status <- map["status"]
        self.pickupTimeMs <- map["pickupTimeMs"]
        self.pickupSequenceOrder <- map["pickupSequenceOrder"]
        self.dropTimeMs <- map["dropTimeMs"]
        self.dropSequenceOrder <- map["dropSequenceOrder"]
        self.pickupReachedTimeMs <- map["pickupReachedTimeMs"]
        self.creationTimeMs <- map["creationTimeMs"]
        self.modifiedTimeMs <- map["modifiedTimeMs"]
        self.extraKmFare <- map["extraKmFare"]
        self.extraMinFare <- map["extraMinFare"]
    }
    
    var description: String {
        return "userId: \(String(describing: self.userId)),"
            + "userName: \(String(describing: self.userName)),"
            + "contactNo: \(String(describing: self.contactNo)),"
            + "gender: \(String(describing: self.gender)),"
            + "imageURI: \(String(describing: self.imageURI)),"
            + "taxiGroupId: \(String(describing: self.taxiGroupId)),"
            + "startAddress: \(String(describing: self.startAddress)),"
            + "startLat: \(String(describing: self.startLat)),"
            + "startLng: \(String(describing: self.startLng)),"
            + "endAddress: \(String(describing: self.endAddress)),"
            + "endLat: \(String(describing: self.endLat)),"
            + "endLng: \(String(describing: self.endLng)),"
            + "noOfSeats: \(String(describing: self.noOfSeats)),"
            + "status: \(String(describing: self.status)),"
            + "pickupTimeMs: \(String(describing: self.pickupTimeMs)),"
            + "pickupSequenceOrder: \(String(describing: self.pickupSequenceOrder)),"
            + "dropTimeMs: \(String(describing: self.dropTimeMs)),"
            + "dropSequenceOrder: \(String(describing: self.dropSequenceOrder)),"
            + "pickupReachedTimeMs: \(String(describing: self.pickupReachedTimeMs)),"
            + "creationTimeMs: \(String(describing: self.creationTimeMs)),"
            + "modifiedTimeMs: \(String(describing: self.modifiedTimeMs))"
    }
}
