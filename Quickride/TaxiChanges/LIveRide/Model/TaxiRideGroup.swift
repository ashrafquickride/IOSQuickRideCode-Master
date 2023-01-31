//
//  TaxiRideGroup.swift
//  Quickride
//
//  Created by Ashutos on 23/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiRideGroup: Mappable {
    var id: Double?
    var refUserId: Double?
    var refRideId: Double?
    var tripType: String?// Local / Outstation
    var journeyType: String?//OneWay / RoundTrip
    var taxiVehicleCategory: String?//Hatchback / Sedan / SUV / TT / ANY
    var taxiType: String?//Car / Bike / Auto
    var shareType: String?
    var routeCategory: String?
    var capacity: Int?
    var availableSeats :Int?
    var noOfPassengers :Int?
    var status: String?
    var startTimeMs: Double?
    var expectedEndTimeMs: Double?
    var startAddress: String?
    var startLat: Double?
    var startLng: Double?
    var startCellId: Double?
    var endAddress: String?
    var endLat: Double?
    var endLng: Double?
    var endCellId: Double?
    var distance: Double?
    var routeId: Double?
    var routePolyline: String?
    var wayPoints: String?
    var taxiPartnerCode: String?
    var taxiBookingId: String?
    var bookingStatus: String?
    var taxiOrderRefNo: String?
    var fixedFareRefId: String?
    var vehicleModel: String?
    var vehicleNumber: String?
    var vehicleImageURI: String?
    var driverName: String?
    var driverContactNo: String?
    var driverImageURI: String?
    var driverRating: Double?
    var creationTimeMs: Double?
    var modifiedTimeMs: Double?
    var version: Int?
    var dynamicAllotment = false
    var pickupLandMark: String?
    var vendorCode: String?
    var pickupRouteId = 0
    var partnerId : Int64 = 0
    var vehicleFuelType: String?
    
    static let FIELD_TAXI_BOOKING_ID = "taxiBookingId"
    static let FIELD_STATUS = "status"
    static let FIELD_VEHICLE_MODEL = "vehicleModel"
    static let FIELD_VEHICLE_NUMBER = "vehicleNumber";
    static let FIELD_VEHICLE_IMAGE_URI = "vehicleImageURI"
    static let FIELD_DRIVER_NAME = "driverName"
    static let FIELD_DRIVER_CONTACT_NO = "driverContactNo"
    static let FIELD_DRIVER_IMAGE_URI = "driverImageURI"
    static let FIELD_DRIVER_RATING = "driverRating"
    
    static let STATUS_OPEN = "Open"
    static let STATUS_CONFIRMED = "Confirmed"
    static let STATUS_FROZEN = "Frozen"
    static let STATUS_ALLOTTED = "Allotted"
    static let STATUS_RE_ALLOTTED = "ReAllotted"
    static let STATUS_STARTED = "Started"
    static let STATUS_DELAYED = "Delayed"
    static let STATUS_COMPLETED = "Completed"
    static let STATUS_CANCELLED = "Cancelled"
    
    static let BOOKING_STATUS_OPEN = "Open"
    static let BOOKING_STATUS_IN_PROGRESS = "InProgress"
    static let BOOKING_STATUS_SUCCESS = "Success"
    static let BOOKING_STATUS_FAILED = "Failed"
    
    static let ZYPY = "ZYPY"
    static let SAVAARI = "SAVAARI"
    
    //vehicleFuelType
    static let FIELD_VEHICLE_FUEL_ELECTRIC = "Electric"
    static let FIELD_VEHICLE_FUEL_GAS  = "Gas"
    static let FIELD_VEHICLE_FUEL_PETROL = "Petrol"
    static let FIELD_VEHICLE_FUEL_DIESEL = "Diesel"
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.refUserId <- map["refUserId"]
        self.refRideId <- map["refRideId"]
        self.tripType <- map["tripType"]
        self.journeyType <- map["journeyType"]
        self.taxiVehicleCategory <- map["taxiVehicleCategory"]
        self.taxiType <- map["taxiType"]
        self.shareType <- map["shareType"]
        self.routeCategory <- map["routeCategory"]
        self.capacity <- map["capacity"]
        self.availableSeats <- map["availableSeats"]
        self.noOfPassengers <- map["noOfPassengers"]
        self.status <- map["status"]
        self.startTimeMs <- map["startTimeMs"]
        self.expectedEndTimeMs <- map["expectedEndTimeMs"]
        self.startAddress <- map["startAddress"]
        self.startLat <- map["startLat"]
        self.startLng <- map["startLng"]
        self.startCellId <- map["startCellId"]
        self.endAddress <- map["endAddress"]
        self.endLat <- map["endLat"]
        self.endLng <- map["endLng"]
        self.endCellId <- map["endCellId"]
        self.distance <- map["distance"]
        self.routeId <- map["routeId"]
        self.routePolyline <- map["routePolyline"]
        self.wayPoints <- map["wayPoints"]
        self.taxiPartnerCode <- map["taxiPartnerCode"]
        self.taxiBookingId <- map["taxiBookingId"]
        self.bookingStatus <- map["bookingStatus"]
        self.taxiOrderRefNo <- map["taxiOrderRefNo"]
        self.fixedFareRefId <- map["fixedFareRefId"]
        self.vehicleModel <- map["vehicleModel"]
        self.vehicleNumber <- map["vehicleNumber"]
        self.vehicleImageURI <- map["vehicleImageURI"]
        self.driverName <- map["driverName"]
        self.driverContactNo <- map["driverContactNo"]
        self.driverImageURI <- map["driverImageURI"]
        self.driverRating <- map["driverRating"]
        self.creationTimeMs <- map["creationTimeMs"]
        self.modifiedTimeMs <- map["modifiedTimeMs"]
        self.version <- map["version"]
        self.dynamicAllotment <- map["dynamicAllotment"]
        self.pickupLandMark <- map["pickupLandMark"]
        self.vendorCode <- map["vendorCode"]
        self.pickupRouteId <- map["pickupRouteId"]
        self.partnerId <- map["partnerId"]
        self.vehicleFuelType <- map["vehicleFuelType"]
    }
    
    var description: String {
        return "id: \(String(describing: self.id)),"
            + "refUserId: \(String(describing: self.refUserId)),"
            + "refRideId: \(String(describing: self.refRideId)),"
            + "tripType: \(String(describing: self.tripType)),"
            + "journeyType: \(String(describing: self.journeyType)),"
            + "taxiVehicleCategory: \(String(describing: self.taxiVehicleCategory)),"
            + "taxiType: \(String(describing: self.taxiType)),"
            + "shareType: \(String(describing: self.shareType)),"
            + "routeCategory: \(String(describing: self.routeCategory)),"
            + "capacity: \(String(describing: self.capacity)),"
            + "availableSeats: \(String(describing: self.availableSeats)),"
            + "noOfPassengers: \(String(describing: self.noOfPassengers)),"
            + "status: \(String(describing: self.status)),"
            + "startTimeMs: \(String(describing: self.startTimeMs)),"
            + "expectedEndTimeMs: \(String(describing: self.expectedEndTimeMs)),"
            + "startAddress: \(String(describing: self.startAddress)),"
            + "startLat: \(String(describing: self.startLat)),"
            + "startLng: \(String(describing: self.startLng)),"
            + "startCellId: \(String(describing: self.startCellId)),"
            + "endAddress: \(String(describing: self.endAddress)),"
            + "endLat: \(String(describing: self.endLat)),"
            + "endLng: \(String(describing: self.endLng)),"
            + "endCellId: \(String(describing: self.endCellId)),"
            + "distance: \(String(describing: self.distance)),"
            + "routeId: \(String(describing: self.routeId)),"
            + "routePolyline: \(String(describing: self.routePolyline)),"
            + "wayPoints: \(String(describing: self.wayPoints)),"
            + "taxiPartnerCode: \(String(describing: self.taxiPartnerCode)),"
            + "taxiBookingId: \(String(describing: self.taxiBookingId)),"
            + "bookingStatus: \(String(describing: self.bookingStatus)),"
            + "taxiOrderRefNo: \(String(describing: self.taxiOrderRefNo)),"
            + "fixedFareRefId: \(String(describing: self.fixedFareRefId)),"
            + "vehicleModel: \(String(describing: self.vehicleModel)),"
            + "vehicleNumber: \(String(describing: self.vehicleNumber)),"
            + "vehicleImageURI: \(String(describing: self.vehicleImageURI)),"
            + "driverName: \(String(describing: self.driverName)),"
            + "driverContactNo: \(String(describing: self.driverContactNo)),"
            + "driverImageURI: \(String(describing: self.driverImageURI)),"
            + "driverRating: \(String(describing: self.driverRating)),"
            + "creationTimeMs: \(String(describing: self.creationTimeMs)),"
            + "modifiedTimeMs: \(String(describing: self.modifiedTimeMs)),"
            + "version: \(String(describing: self.version)),"
            + "dynamicAllotment: \(String(describing: self.dynamicAllotment)),"
            + "pickupLandMark: \(String(describing: self.pickupLandMark))"
            + "vendorCode: \(String(describing: self.vendorCode))"
            + "pickupRouteId: \(String(describing: self.pickupRouteId))"
    }
}


