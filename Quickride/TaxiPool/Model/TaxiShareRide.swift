//
//  TaxiShareRide.swift
//  Quickride
//
//  Created by Ashutos on 4/29/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class TaxiShareRide: NSObject, Mappable {
    
    var id: Double?
    var refUserId: Double?
    var refRideId: Double?
    var taxiProvider: String?
    var shareType: String?
    var routeCategory: String?
    var capacity: Double?
    var availableSeats: Double?
    var noOfPassengers: Int?
    var status: String?
    var plannedStartTime: Double?
    var actualStartTime: Double?
    var expectedEndTime: Double?
    var actualEndTime: Double?
    var startAddress: String?
    var startLatitude: Double?
    var startLongitude: Double?
    var startCellId: Double?
    var endAddress: String?
    var endLatitude: Double?
    var endLongitude: Double?
    var endCellId: Double?
    var distance: Double?
    var routePathPolyline: String?
    var wayPoints: String?
    var taxiPathTravelled: String?
    var durationInTraffic: Int?
    var cancelledBy: String?
    var cancelledTime: Double?
    var cancellationRemark: String?
    var taxiBookingId: String?
    var taxiBookingTime: Double?
    var bookingType: String?
    var bookingStatus: String?
    var bookingMessage: String?
    var vehicleModel: String?
    var vehicleNumber: String?
    var additionalFacilities: String?
    var vehicleImageURI: String?
    var driverName: String?
    var driverContactNumber: String?
    var driverVerificationStatus: String?
    var driverAddress: String?
    var driverImageURI: String?
    var driverRating: String?
    var taxiTrackingURI: String?
    var tripType: String?
    var journeyType: String?
    var toTime: Double?
    var vehicleClass: String?
    
    var createdOn: Double?
    var createdBy: String?
    var lastUpdatedOn: Double?
    var lastUpdatedBy: String?
    
    //MARK: OTP
    var dynamicAllotment: Bool = false
    var pickupLandMark: String?
    
    var taxiShareRidePassengerInfos: [TaxiShareRidePassengerInfos]? = []
    
    static let FLD_TAXI_RIDE_ID = "id"
    static let FLD_TAXI_START_LATITUDE = "startLatitude"
    static let FLD_TAXI_START_LONGITUDE = "startLongitude"
    static let FLD_TAXI_END_LATITUDE = "endLatitude"
    static let FLD_TAXI_END_LONGITUDE = "endLongitude"
    static let FLD_TAXI_DISTANCE = "distance"
    static let FLD_PASSENGER_RIDE_ID = "passengerRideId"
    static let FLD_TAXI_PROVIDER = "taxiProvider"
    static let FLD_USER_ID = "userId"
    static let FLD_SHARE_TYPE = "shareType"
    static let FLD_AVAILABLE_SEATS = "availableSeats"
    static let FLD_NO_OF_PASSENGERS = "noOfPassengers"
    static let FLD_TAXI_PATH_TRAVELLED = "taxiPathTravelled"
    static let FLD_TAXI_EXPECTED_START_TIME = "expectedStartTime"
    static let FLD_TAXI_POOL_CREATION_INITIATION_TIME = "taxiPoolCreationInitiatedTime"
    static let FLD_TAXI_POOL_CREATION_COMPLETION_TIME = "taxiPoolCreationCompletionTime"
    static let FLD_TAXI_BOOKING_TYPE = "taxiBookingType"
    static let FLD_TAXI_BOOKING_ID = "taxiBookingId"
    static let FLD_TAXI_BOOKING_TIME = "taxiBookingTime"
    static let FLD_TAXI_BOOKING_STATUS = "bookingStatus"
    static let FLD_TAXI_BOOKING_MESSAGE = "bookingMessage"
    static let FLD_VEHICLE_PHOTO_URI = "vehiclePhotoURI"
    static let FLD_DRIVER_NAME = "driverName"
    static let FLD_DRIVER_CONTACT_NUMBER = "driverContactNumber"
    static let FLD_DRIVER_VERIFICATION_STATUS = "driverVerificationStatus"
    static let FLD_DRIVER_ADDRESS = "driverAddress"
    static let FLD_DRIVER_PHOTO_URI = "driverPhotoURI"
    static let FLD_DRIVER_RATING = "driverRating"
    static let FLD_TAXI_TRACKING_URI = "taxiTrackingURI"
    static let FLD_PAYMENT_TYPE = "paymentType"
    static let FLD_NUMBER_SEATS = "noOfTaxiSeats"
    static let FLD_TAXI_RIDE_ID_ANALYTICS = "taxiRideId"
    static let FLD_TAXI_NO_OF_RATING = "noOfRating"
    static let FLD_TAXI_FEEDBACK = "feedback"
    static let FLD_TAXI_RIDE_PASS_USER_ID = "passengerUserId"
    static let FLD_TAXI_START_LAT = "taxiStartLat"
    static let FLD_TAXI_START_LNG = "taxiStartLng"
    static let FLD_TAXI_END_LAT = "taxiEndLat"
    static let FLD_TAXI_END_LNG = "taxiEndLng"
    static let FLD_DURATION_IN_MIN = "durationInMins"
    static let FLD_TAXI_START_TIME = "taxiStartTime"
    static let FLD_TAXIINVITE = "taxiInvite"
    static let FLD_INVITEID = "inviteId"
    static let FLD_REJACTION_REASON = "rejectionReason"
    static let FLD_FILTER_PASSENGER_ID = "filterPassengerRideId"
    static let FLD_TAXI_INVITE_ID = "inviteId"
    static let FLD_CANCELLATION_REMARK = "cancellationRemark"
    static let FLD_CANCEL_PASSENGER_RIDE = "cancelPassengerRide"
    static let UPI_CANCEL_REASON = "Customer Returned back from UPI"
    
    //MARK: OUTSTATION
    static let FLD_TAXI_START_ADDRESS = "taxiStartAddress"
    static let FLD_TAXI_END_ADDRESS = "taxiEndAddress"
    static let FLD_TRIP_TYPE = "tripType"
    static let FLD_JOURNEY_TYPE = "journeyType"
    static let FLD_TAXI_SHARE_TYPE = "taxiShareType"
    static let FLD_TO_TIME = "toTime"
    static let FLD_TAXI_END_TIME = "taxiEndTime"
    static let FLD_SOURCE_CITY = "sourceCity"
    static let FLD_DESTINATION_CITY = "destinationCity"
    static let FLD_CAR_TYPE = "carType"
    static let FLD_PERCENTAGE = "advPaymentPercent"
    static let ONE_WAY = "oneWay"
    static let ROUND_TRIP = "roundTrip"
    
    static let RIDE_STATUS_PENDING_TAXI_JOIN = "PendingTaxiJoin"
    
    static let TAXI_SHARE_RIDE_POOL_IN_PROGRESS = "taxi_pool_in_progress"
    static let TAXI_SHARE_RIDE_POOL_CONFIRMED = "taxi_pool_confirmed"
    static let TAXI_SHARE_RIDE_POOL_FROZEN = "taxi_pool_frozen"
    static let TAXI_SHARE_RIDE_POOL_INVALID = "taxi_pool_invalid"
    static let TAXI_SHARE_RIDE_BOOKING_IN_PROGRESS = "taxi_booking_in_progress"
    static let TAXI_SHARE_RIDE_SUCCESSFUL_BOOKING = "taxi_booking_success"
    static let TAXI_SHARE_RIDE_FAILED_BOOKING = "taxi_booking_failed"
    static let TAXI_SHARE_RIDE_ALLOTTED = "taxi_allotted"
    static let TAXI_SHARE_RIDE_RE_ALLOTTED = "taxi_re_allotted"
    static let TAXI_SHARE_RIDE_SCHEDULED = "taxi_scheduled"
    static let TAXI_SHARE_RIDE_ARRIVED = "taxi_arrived"
    static let TAXI_SHARE_RIDE_STARTED = "taxi_started"
    static let TAXI_SHARE_RIDE_DELAYED = "taxi_delayed"
    static let TAXI_SHARE_RIDE_COMPLETED = "taxi_completed"
    static let TAXI_SHARE_RIDE_CANCELLED = "taxi_cancelled"
    
   
    
    static let BOOKING_TYPE_MANUAL = "MANUAL"
    static let BOOKING_TYPE_AUTO = "AUTO"
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        refUserId <- map["refUserId"]
        refRideId <- map["refRideId"]
        taxiProvider <- map["taxiProvider"]
        shareType <- map["shareType"]
        routeCategory <- map["routeCategory"]
        capacity <- map["capacity"]
        availableSeats <- map["availableSeats"]
        noOfPassengers <- map["noOfPassengers"]
        status <- map["status"]
        plannedStartTime <- map["plannedStartTime"]
        actualStartTime <- map["actualStartTime"]
        expectedEndTime <- map["expectedEndTime"]
        actualEndTime <- map["actualEndTime"]
        startAddress <- map["startAddress"]
        startLatitude <- map["startLatitude"]
        startLongitude <- map["startLongitude"]
        startCellId <- map["startCellId"]
        endAddress <- map["endAddress"]
        endLatitude <- map["endLatitude"]
        endLongitude <- map["endLongitude"]
        endCellId <- map["endCellId"]
        distance <- map["distance"]
        routePathPolyline <- map["routePathPolyline"]
        wayPoints <- map["wayPoints"]
        taxiPathTravelled <- map["taxiPathTravelled"]
        durationInTraffic <- map["durationInTraffic"]
        cancelledBy <- map["cancelledBy"]
        cancelledTime <- map["cancelledTime"]
        cancellationRemark <- map["cancellationRemark"]
        taxiBookingId <- map["taxiBookingId"]
        taxiBookingTime <- map["taxiBookingTime"]
        bookingType <- map["bookingType"]
        bookingStatus <- map["bookingStatus"]
        bookingMessage <- map["bookingMessage"]
        vehicleModel <- map["vehicleModel"]
        vehicleNumber <- map["vehicleNumber"]
        additionalFacilities <- map["additionalFacilities"]
        vehicleImageURI <- map["vehicleImageURI"]
        driverName <- map["driverName"]
        driverContactNumber <- map["driverContactNumber"]
        driverVerificationStatus <- map["driverVerificationStatus"]
        driverAddress <- map["driverAddress"]
        driverImageURI <- map["driverImageURI"]
        driverRating <- map["driverRating"]
        taxiTrackingURI <- map["taxiTrackingURI"]
        createdOn <- map["createdOn"]
        createdBy <- map["createdBy"]
        lastUpdatedOn <- map["lastUpdatedOn"]
        lastUpdatedBy <- map["lastUpdatedBy"]
        taxiShareRidePassengerInfos <- map["taxiShareRidePassengerInfos"]
        tripType <- map["tripType"]
        journeyType <- map["journeyType"]
        toTime <- map["toTime"]
        vehicleClass <- map["vehicleClass"]
        dynamicAllotment <- map["dynamicAllotment"]
        pickupLandMark <- map["pickupLandMark"]
        
    }
    
    public override var description: String {
        return "id: \(String(describing: self.id)),"
            + "refUserId: \(String(describing: self.refUserId)),"
            + "refRideId: \(String(describing: self.refRideId)),"
            + "taxiProvider: \(String(describing: self.taxiProvider)),"
            + "shareType: \(String(describing: self.shareType)),"
            + "routeCategory: \(String(describing: self.routeCategory)),"
            + " capacity: \( String(describing: self.capacity)),"
            + " availableSeats: \(String(describing: self.availableSeats)),"
            + " noOfPassengers: \(String(describing: self.noOfPassengers)),"
            + " status: \(String(describing: self.status)),"
            + " plannedStartTime: \(String(describing: self.plannedStartTime)),"
            + " actualStartTime: \(String(describing: self.actualStartTime)),"
            + " expectedEndTime: \(String(describing: self.expectedEndTime)),"
            + " actualEndTime: \(String(describing: self.actualEndTime)),"
            + " startAddress: \(String(describing: self.startAddress)),"
            + " startLatitude: \(String(describing: self.startLatitude)),"
            + " startLongitude: \(String(describing: self.startLongitude)),"
            + " startCellId: \(String(describing: self.startCellId)),"
            + " endAddress: \(String(describing: self.endAddress)),"
            + " endLatitude: \(String(describing: self.endLatitude)),"
            + " endLongitude: \(String(describing: self.endLongitude)),"
            + " endCellId: \(String(describing: self.endCellId)),"
            + " distance: \(String(describing: self.distance)),"
            + " routePathPolyline: \(String(describing: self.routePathPolyline)),"
            + " wayPoints: \(String(describing: self.wayPoints)),"
            + " taxiPathTravelled: \(String(describing: self.taxiPathTravelled)),"
            + " durationInTraffic: \(String(describing: self.durationInTraffic)),"
            + "cancelledBy: \(String(describing: self.cancelledBy)),"
            + "cancelledTime: \(String(describing: self.cancelledTime)),"
            + "cancellationRemark: \(String(describing: self.cancellationRemark)),"
            + "taxiBookingId: \(String(describing: self.taxiBookingId)),"
            + "taxiBookingTime: \(String(describing: self.taxiBookingTime)),"
            + "bookingType: \(String(describing: self.bookingType)),"
            + "bookingStatus: \( String(describing: self.bookingStatus)),"
            + " bookingMessage: \(String(describing: self.bookingMessage)),"
            + " vehicleModel: \(String(describing: self.vehicleModel)),"
            + " vehicleNumber: \(String(describing: self.vehicleNumber)),"
            + "additionalFacilities: \(String(describing: self.additionalFacilities)),"
            + " vehicleImageURI: \(String(describing: self.vehicleImageURI)),"
            + " driverName: \(String(describing: self.driverName)),"
            + " driverContactNumber: \(String(describing: self.driverContactNumber)),"
            + "driverVerificationStatus: \(String(describing: self.driverVerificationStatus)),"
            + " driverAddress: \(String(describing: self.driverAddress)),"
            + " driverImageURI: \(String(describing: self.driverImageURI)),"
            + "driverRating: \(String(describing: self.driverRating)),"
            + "taxiTrackingURI: \(String(describing: self.taxiTrackingURI)),"
            + " createdOn: \(String(describing: self.createdOn)),"
            + " createdBy: \(String(describing: self.createdBy)),"
            + "lastUpdatedOn: \(String(describing: self.lastUpdatedOn)),"
            + "lastUpdatedBy: \(String(describing: self.lastUpdatedBy)),"
            + "taxiShareRidePassengerInfos: \(String(describing: self.taxiShareRidePassengerInfos))"
            + "tripType: \(String(describing: self.tripType)),"
            + "journeyType: \(String(describing: self.journeyType)),"
            + "toTime: \(String(describing: self.toTime)),"
            + "vehicleClass: \(String(describing: self.vehicleClass)),"
            + "dynamicAllotment: \(String(describing: self.dynamicAllotment)),"
            + "pickupLandMark: \(String(describing: self.pickupLandMark))"
    }
}
