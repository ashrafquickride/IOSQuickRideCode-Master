//
//  MatchedShareTaxi.swift
//  Quickride
//
//  Created by Ashutos on 4/29/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class  MatchedShareTaxi : NSObject, Mappable {
    var userId: Double?
    var name: String?
    var imageURI: String?
    var gender: String?
    var rating: Double?
    var noOfReviews: Int?
    var verificationStatus: String?
    var taxiId: Double?
    var startAddress: String?
    var startLatitude: Double?
    var startLongitude: Double?
    var endAddress: String?
    var endLatitude: Double?
    var endLongitude: Double?
    var pickUpAddress: String?
    var pickUpLatitude: Double?
    var pickUpLongitude: Double?
    var pickUpTime: Double?
    var dropAddress: String?
    var dropLatitude: Double?
    var dropLongitude: Double?
    var distance: Double?
    var minPoints: Double?
    var maxPoints: Double?
    var routePolyline: String?
    var routeId: Double?
    var pkTime: Double?
    var dpTime: Double?
    var stTime: Double?
    var taxiProvider: String?
    var shareType: String?
    var capacity: Int?
    var availableSeats: Int?
    var noOfPassengers: Double?
    var bookingType: String?
    var bookingStatus: String?
    var bookingMessage: String?
    var vehicleModel: String?
    var vehicleRegistrationNumber: String?
    var additionalFacilities: String?
    var vehiclePhotoURI: String?
    var driverName: String?
    var driverContactNumber: String?
    var driverVerificationStatus: String?
    var driverAddress: String?
    var driverPhotoURI: String?
    var driverRating: Int?
    var taxiTrackingURI: String?
    var pickUpSequenceOrder: Int?
    var dropSequenceOrder: Int?
    var taxiShareRidePassengerInfos: [TaxiShareRidePassengerInfos]? = []
    
    static let MATCHED_SHARE_TAXI = "MatchedShareTaxi"
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        name <- map["name"]
        imageURI <- map["imageURI"]
        gender <- map["gender"]
        rating <- map["rating"]
        noOfReviews <- map["noOfReviews"]
        verificationStatus <- map["verificationStatus"]
        
        taxiId <- map["taxiId"]
        startAddress <- map["startAddress"]
        startLatitude <- map["startLatitude"]
        startLongitude <- map["startLongitude"]
        endAddress <- map["endAddress"]
        endLatitude <- map["endLatitude"]
        endLongitude <- map["endLongitude"]
        pickUpAddress <- map["pickUpAddress"]
        pickUpLatitude <- map["pickUpLatitude"]
        pickUpLongitude <- map["pickUpLongitude"]
        pickUpTime <- map["pickUpTime"]
        dropAddress <- map["dropAddress"]
        dropLatitude <- map["dropLatitude"]
        dropLongitude <- map["dropLongitude"]
        distance <- map["distance"]
        minPoints <- map["minPoints"]
        maxPoints <- map["maxPoints"]
        routePolyline <- map["routePolyline"]
        routeId <- map["routeId"]
        pkTime <- map["pkTime"]
        dpTime <- map["dpTime"]
        stTime <- map["stTime"]
        taxiProvider <- map["taxiProvider"]
        shareType <- map["shareType"]
        capacity <- map["capacity"]
        availableSeats <- map["availableSeats"]
        noOfPassengers <- map["noOfPassengers"]
        bookingType <- map["bookingType"]
        bookingStatus <- map["bookingStatus"]
        bookingMessage <- map["bookingMessage"]
        vehicleModel <- map["vehicleModel"]
        vehicleRegistrationNumber <- map["vehicleRegistrationNumber"]
        additionalFacilities <- map["additionalFacilities"]
        vehiclePhotoURI <- map["vehiclePhotoURI"]
        driverName <- map["driverName"]
        driverContactNumber <- map["driverContactNumber"]
        driverVerificationStatus <- map["driverVerificationStatus"]
        driverAddress <- map["driverAddress"]
        driverPhotoURI <- map["driverPhotoURI"]
        driverRating <- map["driverRating"]
        taxiTrackingURI <- map["taxiTrackingURI"]
        pickUpSequenceOrder <- map["pickUpSequenceOrder"]
        dropSequenceOrder <- map["dropSequenceOrder"]
        taxiShareRidePassengerInfos <- map["taxiShareRidePassengerInfos"]
    }
    
    public override var description: String {
        return "userId: \(String(describing: self.userId)),"
            + " name: \(String(describing: self.name)),"
            + " imageURI: \(String(describing: self.imageURI)),"
            + " gender: \(String(describing: self.gender)),"
            + " rating: \(String(describing: self.rating)),"
            + "noOfReviews: \(String(describing: self.noOfReviews)),"
            + "verificationStatus: \(String(describing: self.verificationStatus)),"
            + " taxiId: \(String(describing: self.taxiId)),"
            + "startAddress: \(String(describing: self.startAddress)),"
            + " startLatitude: \(String(describing: self.startLatitude)),"
            + "startLongitude: \(String(describing: self.startLongitude)),"
            + "endAddress: \(String(describing: self.endAddress)),"
            + " endLatitude: \(String(describing: self.endLatitude)),"
            + " endLongitude: \(String(describing: self.endLongitude)),"
            + " pickUpAddress: \(String(describing: self.pickUpAddress)),"
            + " pickUpLatitude: \(String(describing: self.pickUpLatitude)),"
            + "pickUpLongitude: \(String(describing: self.pickUpLongitude)),"
            + "pickUpTime: \(String(describing: self.pickUpTime)),"
            + " dropAddress: \(String(describing: self.dropAddress)),"
            + " dropLatitude: \(String(describing: self.dropLatitude)),"
            + "dropLongitude: \(String(describing: self.dropLongitude)),"
            + "distance: \(String(describing: self.distance)),"
            + "minPoints: \(String(describing: self.minPoints)),"
            + " maxPoints: \(String(describing: self.maxPoints)),"
            + "routePolyline: \(String(describing: self.routePolyline)),"
            + "routeId: \(String(describing: self.routeId)),"
            + " pkTime: \(String(describing: self.pkTime)),"
            + " dpTime: \(String(describing: self.dpTime)),"
            + " stTime: \(String(describing: self.stTime)),"
            + " taxiProvider: \(String(describing: self.taxiProvider)),"
            + "shareType: \(String(describing: self.shareType)),"
            + "capacity: \(String(describing: self.capacity)),"
            + " availableSeats: \(String(describing: self.availableSeats)),"
            + " noOfPassengers: \(String(describing: self.noOfPassengers)),"
            + "bookingType: \(String(describing: self.bookingType)),"
            + " bookingStatus: \(String(describing: self.bookingStatus)),"
            + "bookingMessage: \(String(describing: self.bookingMessage)),"
            + " vehicleModel: \(String(describing: self.vehicleModel)),"
            + " vehicleRegistrationNumber: \(String(describing: self.vehicleRegistrationNumber)),"
            + " additionalFacilities: \(String(describing: self.additionalFacilities)),"
            + " vehiclePhotoURI: \(String(describing: self.vehiclePhotoURI)),"
            + "driverName: \(String(describing: self.driverName)),"
            + "driverContactNumber: \(String(describing: self.driverContactNumber)),"
            + " driverVerificationStatus: \(String(describing: self.driverVerificationStatus)),"
            + " driverAddress: \(String(describing: self.driverAddress)),"
            + "driverPhotoURI: \(String(describing: self.driverPhotoURI)),"
            + " driverRating: \(String(describing: self.driverRating)),"
            + "taxiTrackingURI: \(String(describing: self.taxiTrackingURI)),"
            + "pickUpSequenceOrder: \(String(describing: self.pickUpSequenceOrder)),"
            + "dropSequenceOrder: \(String(describing: self.dropSequenceOrder)),"
            + "taxiShareRidePassengerInfos: \(String(describing: self.taxiShareRidePassengerInfos))"
    }
}
