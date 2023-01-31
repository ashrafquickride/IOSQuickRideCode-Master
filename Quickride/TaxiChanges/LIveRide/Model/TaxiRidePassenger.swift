//
//  TaxiRidePassenger.swift
//  Quickride
//
//  Created by Ashutos on 23/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiRidePassenger: Mappable,NSCopying{

    var id: Double?
    var userId: Double?
    var userName: String?
    var contactNo: String?
    var email: String?
    var imageURI: String?
    var taxiGroupId: Double?
    var startTimeMs: Double?
    var expectedEndTimeMs: Double?
    var startAddress: String?
    var startLat: Double?
    var startLng:Double?
    var startArea: String?
    var endAddress:String?
    var endLat: Double?
    var endLng: Double?
    var endArea: String?
    var tripType: String?// Local / Outstation / Rental
    var journeyType: String?// OneWay / RoundTrip
    var taxiVehicleCategory: String?// Hatchback / Sedan / SUV / TT
    var taxiType: String?// Car / Bike / Auto
    var shareType: String?
    var status: String? //Requested / Confirmed / Started ...
    var noOfSeats = 1
    var distance: Double?
    var initialFare: Double?
    var advanceFare : Double?
    var finalFare: Double?
    var taxiRideJoinTimeMs: Double?
    var pickupTimeMs: Double?
    var pickupOrder: Int?
    var dropTimeMs: Double?
    var dropOrder: Int?
    var finalDistance: Double?
    var deviatedFromOriginalRoute: Bool?
    var actualStartTimeMs: Double?
    var actualEndTimeMs: Double?
    var taxiRideUnjoinTimeMs: Double?
    var taxiUnjoinReason: String?
    var cancellationAmount: Double?
    var routeId: Double?
    var wayPoints: String?
    var refRequestId: String?
    var singleSharingOn: Bool?
    var pickupOtp: String?
    var pickupReachedTimeMs: Double?
    var dropOtp: String?
    var creationTimeMs: Double?
    var modifiedTimeMs: Double?
    var routePolyline: String?
    var version: Int?
    var pickupRouteId : Double?
    var pickupRoutePolyline : String?
    var pendingAmount = 0.0
    var rideDate = "" // using in mytrips/closedride to sort in app side
    var paymentType: String?
    var paymentMode: String?
    var pickupNote: String?
    var couponCode: String?
    var allocateTaxiIfPoolNotConfirmed = false
    var exclusiveFixedFareRefId: String?
    var initialShareType: String?
    var gender: String?
    var rentalPkgId: Int?
    var startCity: String?
    var endCity: String?
    var forCommuteUser: Bool?

    static let LOCAL_TAXI = "Local Taxi"
    static let OUTSTATION = "Outstation"
    static let TRIP_TYPE_RENTAL = "Rental"

    static let FIELD_USER_ID = "userId"
    static let FIELD_TAXI_GROUP_ID = "taxiGroupId"
    static let FIELD_TAXI_RIDE_PASSENGER_ID = "taxiRidePassengerId"
    static let FIELD_START_TIME = "startTime"
    static let FIELD_EXPECTED_END_TIME = "expectedEndTime"
    static let FIELD_START_ADDRESS = "startAddress"
    static let FIELD_START_LAT = "startLat"
    static let FIELD_START_LNG = "startLng"
    static let FIELD_START_CITY = "startCity"
    static let FIELD_END_ADDRESS = "endAddress"
    static let FIELD_END_LAT = "endLat"
    static let FIELD_END_LNG = "endLng"
    static let FIELD_TRIP_TYPE = "tripType"
    static let FIELD_JOURNEY_TYPE = "journeyType"
    static let FIELD_TAXI_VEHICLE_CATEGORY = "taxiVehicleCategory"
    static let FIELD_TAXI_TYPE = "taxiType"
    static let FIELD_SHARE_TYPE = "shareType"
    static let FIELD_STATUS = "status"
    static let FIELD_NO_OF_SEATS = "noOfSeats"
    static let FIELD_DISTANCE = "distance"
    static let FIELD_ROUTE_ID = "routeId"
    static let FIELD_SELECTED_ROUTE_ID = "selectedRouteId"
    static let FIELD_WAY_POINTS = "wayPoints"
    static let FIELD_REF_REQUEST_ID = "refRequestId"
    static let FIELD_SINGLE_SHARING_ON = "singleSharingOn"
    static let FIELD_USER_NAME = "userName"
    static let FIELD_CONTACT_NO = "contactNo"
    static let FIELD_EMAIL = "email"
    static let FIELD_IMAGE_URI = "imageURI"
    static let FIELD_BOOKING_STATUS = "bookingStatus"
    static let FIELD_TAXI_UNJOIN_REASON = "taxiUnjoinReason"
    static let FIELD_FINAL_FARE = "finalFare"
    static let FIELD_PAYMENT_TYPE = "paymentType"
    static let FIELD_PAYMENT_MODE = "paymentMode"
    static let FIELD_ADVANCE_PAYMENT_PERCENTAGE = "advPaymentPercent"
    static let FIELD_MAX_FARE = "maxFare"
    static let FIELD_FIXED_FARE_ID = "fixedFareId"
    static let FIELD_REF_ID = "refId"
    static let FIELD_ENABLE_PAYLATER = "enablePayLater"
    static let FIELD_COUPON_CODE = "couponCode"
    static let FIELD_ID = "id"
    static let FIELD_PASSENGER_ID = "taxiPassengerId"
    static let FIELD_CUSTOMER_ID = "customerId"
    static let FIELD_CREATED_BY = "createdBy"
    static let FIELD_ORIGINATING_APP = "originatingApp"
    static let FIELD_RENTAL_PACKAGE_ID = "rentalPackageId"
    static let FIELD_RENTAL_TAXI_VEHICLE_CATEGORY = "taxiVehicleCategory"
    static let FIELD_STOP_POINT_ADDRESS = "stopPointAddress"
    static let FIELD_STOP_POINT_LAT = "stopPointLat"
    static let FIELD_STOP_POINT_LNG = "stopPointLng"
    static let FIELD_MAX_RESULT = "maxResults"
    static let FIELD_MAX_DISTANCE = "maxDistance"
    static let FIELD_LATITUDE = "latitude"
    static let FIELD_LONGITUDE = "longitude"
    static let FIELD_COMMUTE_CONTACT_NO = "commuteContactNo"
    static let FIELD_COMMUTE_PASSENGER_NAME = "commutePassengerName"

    static let STATUS_REQUESTED = "Requested"
    static let STATUS_CONFIRMED = "Confirmed"
    static let STATUS_NOT_BOARDED = "NotBoarded"
    static let STATUS_STARTED = "Started"
    static let STATUS_DRIVER_EN_ROUTE_PICKUP = "DriverEnRoutePickup"
    static let STATUS_DRIVER_REACHED_PICKUP = "DriverReachPickup"
    static let STATUS_COMPLETED = "Completed"
    static let STATUS_CANCELLED = "Cancelled"
    static let STATUS_PAYMENT_PENDING = "PaymentPending"
    static let ROUND_TRIP = "RoundTrip"
    static let FIELD_PICKUP_NOTE = "pickupNote"
    static let DRIVER_CHANGE_REASON = "driverChangeReason"

    static let START_CITY = "startCity"
    static let START_STATE = "startState"
    static let END_CITY = "endCity"
    static let END_STATE = "endState"

    static let TAXI_CANCELED_MESSAGE = "taxiCanceledMessage"
    static let TAXI_TRIP_UPDATED = "taxiTripUpdated"

    static let PAYMENT_MODE_CASH = "CASH"
    static let PAYMENT_MODE_ONLINE = "ONLINE"
    static let PAYMENT_MODE_PAYMENT_LINK = "PAYMENT_LINK"

    static let REF_INVITED_ID = "refInviteId"
    static let UNKNOWN_LAT: Double = -999
    static let UNKNOWN_LNG: Double = -999

    static let oneWay = "OneWay"
    static let roundTrip = "RoundTrip"

    required init?(map: Map) {

    }
    init() {}
    init(startLat: Double?,startLng:Double?,startAddress: String?,endLat: Double?,endLng: Double?,endAddress:String?,startTimeMs: Double?) {
        self.startLat = startLat
        self.startLng = startLng
        self.startAddress = startAddress
        self.endLat = endLat
        self.endLng = endLng
        self.endAddress = endAddress
        self.startTimeMs = startTimeMs
    }

    func mapping(map: Map) {
        self.id <- map["id"]
        self.userId <- map["userId"]
        self.userName <- map["userName"]
        self.contactNo <- map["contactNo"]
        self.email <- map["email"]
        self.imageURI <- map["imageURI"]
        self.taxiGroupId <- map["taxiGroupId"]
        self.startTimeMs <- map["startTimeMs"]
        self.expectedEndTimeMs <- map["expectedEndTimeMs"]
        self.startAddress <- map["startAddress"]
        self.startLat <- map["startLat"]
        self.startLng <- map["startLng"]
        self.startArea <- map["startArea"]
        self.endAddress <- map["endAddress"]
        self.endLat <- map["endLat"]
        self.endLng <- map["endLng"]
        self.endArea <- map["endArea"]
        self.tripType <- map["tripType"]
        self.journeyType <- map["journeyType"]
        self.taxiVehicleCategory <- map["taxiVehicleCategory"]
        self.taxiType <- map["taxiType"]
        self.shareType <- map["shareType"]
        self.status <- map["status"]
        self.noOfSeats <- map["noOfSeats"]
        self.distance <- map["distance"]
        self.initialFare <- map["initialFare"]
        self.finalFare <- map["finalFare"]
        self.taxiRideJoinTimeMs <- map["taxiRideJoinTimeMs"]
        self.pickupTimeMs <- map["pickupTimeMs"]
        self.pickupOrder <- map["pickupOrder"]
        self.dropTimeMs <- map["dropTimeMs"]
        self.dropOrder <- map["dropSequenceOrder"]
        self.finalDistance <- map["finalDistance"]
        self.deviatedFromOriginalRoute <- map["deviatedFromOriginalRoute"]
        self.actualStartTimeMs <- map["actualStartTimeMs"]
        self.actualEndTimeMs <- map["actualEndTimeMs"]
        self.taxiRideUnjoinTimeMs <- map["taxiRideUnjoinTimeMs"]
        self.taxiUnjoinReason <- map["taxiUnjoinReason"]
        self.cancellationAmount <- map["cancellationAmount"]
        self.routeId <- map["routeId"]
        self.wayPoints <- map["wayPoints"]
        self.refRequestId <- map["refRequestId"]
        self.singleSharingOn <- map["singleSharingOn"]
        self.pickupOtp <- map["pickupOtp"]
        self.pickupReachedTimeMs <- map["pickupReachedTimeMs"]
        self.dropOtp <- map["dropOtp"]
        self.creationTimeMs <- map["creationTimeMs"]
        self.modifiedTimeMs <- map["modifiedTimeMs"]
        self.routePolyline <- map["routePolyline"]
        self.version <- map["version"]
        self.advanceFare <- map["advanceFare"]
        self.pickupRouteId <- map["pickupRouteId"]
        self.pickupRoutePolyline <- map["pickupRoutePolyline"]
        self.pendingAmount <- map["pendingAmount"]
        self.paymentType <- map["paymentType"]
        self.paymentMode <- map["paymentMode"]
        self.pickupNote <- map["pickupNote"]
        self.couponCode <- map["couponCode"]
        self.allocateTaxiIfPoolNotConfirmed <- map["allocateTaxiIfPoolNotConfirmed"]
        self.exclusiveFixedFareRefId <- map["exclusiveFixedFareRefId"]
        self.initialShareType <- map["initialShareType"]
        self.gender <- map["gender"]
        self.rentalPkgId <- map["rentalPkgId"]
        self.startCity <- map["startCity"]
        self.endCity <- map["endCity"]
        self.forCommuteUser <- map["forCommuteUser"]
    }
    func getShareType() -> String?{
        if let _ = initialShareType,shareType == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING,allocateTaxiIfPoolNotConfirmed{
            return TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE
        }else{
           return shareType
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let taxiRide = TaxiRidePassenger()
        taxiRide.id = self.id
        taxiRide.userId = self.userId
        taxiRide.userName = self.userName
        taxiRide.contactNo = self.contactNo
        taxiRide.email = self.email
        taxiRide.imageURI = self.imageURI
        taxiRide.imageURI = self.imageURI
        taxiRide.startTimeMs = self.startTimeMs
        taxiRide.expectedEndTimeMs = self.expectedEndTimeMs
        taxiRide.startAddress = self.startAddress
        taxiRide.startLat = self.startLat
        taxiRide.startLng = self.startLng
        taxiRide.startArea = self.startArea
        taxiRide.endAddress = self.endAddress
        taxiRide.endLat = self.endLat
        taxiRide.endLng = self.endLng
        taxiRide.endArea = self.endArea
        taxiRide.tripType =   self.tripType
        taxiRide.journeyType =   self.journeyType
        taxiRide.taxiVehicleCategory =    self.taxiVehicleCategory
        taxiRide.taxiType =  self.taxiType
        taxiRide.shareType =  self.shareType
        taxiRide.status =   self.status
        taxiRide.noOfSeats =   self.noOfSeats
        taxiRide.distance =   self.distance
        taxiRide.initialFare =   self.initialFare
        taxiRide.finalFare =  self.finalFare
        taxiRide.taxiRideJoinTimeMs =  self.taxiRideJoinTimeMs
        taxiRide.pickupTimeMs = self.pickupTimeMs
        taxiRide.pickupOrder =   self.pickupOrder
        taxiRide.dropTimeMs =    self.dropTimeMs
        taxiRide.dropOrder =    self.dropOrder
        taxiRide.finalDistance =    self.finalDistance
        taxiRide.deviatedFromOriginalRoute =    self.deviatedFromOriginalRoute
        taxiRide.actualStartTimeMs =    self.actualStartTimeMs
        taxiRide.actualEndTimeMs =    self.actualEndTimeMs
        taxiRide.taxiRideUnjoinTimeMs =   self.taxiRideUnjoinTimeMs
        taxiRide.taxiUnjoinReason =   self.taxiUnjoinReason
        taxiRide.cancellationAmount =   self.cancellationAmount
        taxiRide.routeId =   self.routeId
        taxiRide.wayPoints =   self.wayPoints
        taxiRide.refRequestId =  self.refRequestId
        taxiRide.singleSharingOn =  self.singleSharingOn
        taxiRide.pickupOtp =  self.pickupOtp
        taxiRide.pickupReachedTimeMs =   self.pickupReachedTimeMs
        taxiRide.dropOtp =   self.dropOtp
        taxiRide.creationTimeMs =  self.creationTimeMs
        taxiRide.modifiedTimeMs =  self.modifiedTimeMs
        taxiRide.routePolyline =  self.routePolyline
        taxiRide.version =   self.version
        taxiRide.advanceFare =  self.advanceFare
        taxiRide.pendingAmount =  self.pendingAmount
        taxiRide.pickupNote = self.pickupNote
        taxiRide.couponCode =  self.couponCode
        taxiRide.allocateTaxiIfPoolNotConfirmed = self.allocateTaxiIfPoolNotConfirmed
        taxiRide.exclusiveFixedFareRefId = self.exclusiveFixedFareRefId
        taxiRide.initialShareType = self.initialShareType
        taxiRide.gender = self.gender
        return taxiRide
    }

    var description: String {
        return "id: \(String(describing: self.id)),"
        + "userId: \(String(describing: self.userId)),"
        + "userName: \(String(describing: self.userName)),"
        + "contactNo: \(String(describing: self.contactNo)),"
        + "email: \(String(describing: self.email)),"
        + "imageURI: \(String(describing: self.imageURI)),"
        + "taxiGroupId: \(String(describing: self.taxiGroupId)),"
        + "startTimeMs: \(String(describing: self.startTimeMs)),"
        + "expectedEndTimeMs: \(String(describing: self.expectedEndTimeMs)),"
        + "startAddress: \(String(describing: self.startAddress)),"
        + "startLat: \(String(describing: self.startLat)),"
        + "startLng: \(String(describing: self.startLng)),"
        + "startArea: \(String(describing: self.startArea)),"
        + "endAddress: \(String(describing: self.endAddress)),"
        + "endLat: \(String(describing: self.endLat)),"
        + "endLng: \(String(describing: self.endLng)),"
        + "endArea: \(String(describing: self.endArea)),"
        + "tripType: \(String(describing: self.tripType)),"
        + "journeyType: \(String(describing: self.journeyType)),"
        + "taxiVehicleCategory: \(String(describing: self.taxiVehicleCategory)),"
        + "taxiType: \(String(describing: self.taxiType)),"
        + "shareType: \(String(describing: self.shareType)),"
        + "status: \(String(describing: self.status)),"
        + "noOfSeats: \(String(describing: self.noOfSeats)),"
        + "distance: \(String(describing: self.distance)),"
        + "initialFare: \(String(describing: self.initialFare)),"
        + "finalFare: \(String(describing: self.finalFare)),"
        + "taxiRideJoinTimeMs: \(String(describing: self.taxiRideJoinTimeMs)),"
        + "pickupTimeMs: \(String(describing: self.pickupTimeMs)),"
        + "pickupOrder: \(String(describing: self.pickupOrder)),"
        + "dropTimeMs: \(String(describing: self.dropTimeMs)),"
        + "dropOrder: \(String(describing: self.dropOrder)),"
        + "finalDistance: \(String(describing: self.finalDistance)),"
        + "deviatedFromOriginalRoute: \(String(describing: self.deviatedFromOriginalRoute)),"
        + "actualStartTimeMs: \(String(describing: self.actualStartTimeMs)),"
        + "actualEndTimeMs: \(String(describing: self.actualEndTimeMs)),"
        + "taxiRideUnjoinTimeMs: \(String(describing: self.taxiRideUnjoinTimeMs)),"
        + "taxiUnjoinReason: \(String(describing: self.taxiUnjoinReason)),"
        + "cancellationAmount: \(String(describing: self.cancellationAmount)),"
        + "routeId: \(String(describing: self.routeId)),"
        + "wayPoints: \(String(describing: self.wayPoints)),"
        + "refRequestId: \(String(describing: self.refRequestId)),"
        + "singleSharingOn: \(String(describing: self.singleSharingOn)),"
        + "pickupOtp: \(String(describing: self.pickupOtp)),"
        + "pickupReachedTimeMs: \(String(describing: self.pickupReachedTimeMs)),"
        + "dropOtp: \(String(describing: self.dropOtp)),"
        + "creationTimeMs: \(String(describing: self.creationTimeMs)),"
        + "modifiedTimeMs: \(String(describing: self.modifiedTimeMs)),"
        + "routePolyline: \(String(describing: self.routePolyline)),"
        + "version: \(String(describing: self.version))"
        + "pendingAmount: \(String(describing: self.pendingAmount))"
        + "pickupNote: \(String(describing: self.pickupNote))"
        + "couponCode: \(String(describing: self.couponCode))"
        + "allocateTaxiIfPoolNotConfirmed: \(String(describing: self.allocateTaxiIfPoolNotConfirmed))"
        + "exclusiveFixedFareRefId: \(String(describing: self.exclusiveFixedFareRefId))"
        + "initialShareType: \(String(describing: self.initialShareType))"
        + "gender: \(String(describing: self.gender))"
        + "forCommuteUser: \(String(describing: self.forCommuteUser))"
    }
}
