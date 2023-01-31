//
//  Ride.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class Ride : NSObject, Mappable,NSCopying{
  
    var rideId : Double = 0
    var userId : Double = 0
    var userName : String?
    var rideType : String?
    var startAddress : String = ""
    var startLatitude : Double = 0.0
    var startLongitude : Double = 0
    var endAddress : String = ""
    var endLatitude : Double? = 0
    var endLongitude : Double? = 0
    var distance : Double?
    var startTime : Double = 0
    var expectedEndTime : Double? = 0
    var status : String = ""
    var routePathPolyline : String = ""
    var actualStartTime : Double? = 0
    var actualEndtime : Double? = 0
    var waypoints : String?
    var routeId : Double?
    var promocode : String?
    var rideNotes : String?
    var allowRideMatchToJoinedGroups = Bool()
    var showMeToJoinedGroups = Bool()
    var regularRideId: Int?
    var rideDate = "" //using for rides sorting in My Rides

    
    public static let  FLD_ID : String = "id";
    public static let  FLD_RIDER_RIDE_ID : String = "riderRideId";
    public static let  FLD_USERID : String = "userId";
    public static let  FLD_RIDERID : String = "riderId";
    public static let  FLD_RIDEID : String = "rideId";
    public static let  FLD_RIDETYPE : String = "rideType";
    public static let  FLD_STARTADDRESS : String = "startAddress";
    public static let  FLD_STARTLATITUDE : String = "startLatitude";
    public static let  FLD_STARTLONGITUDE : String = "startLongitude";
    public static let  FLD_ENDADDRESS : String = "endAddress";
    public static let  FLD_ENDLATITUDE : String = "endLatitude";
    public static let  FLD_ENDLONGITUDE : String = "endLongitude";
    public static let  FLD_DISTANCE : String = "distance";
    public static let  FLD_POINTS : String = "points";
    public static let  FLD_NEW_FARE : String = "newFare";
    public static let  FLD_FARE_CHANGE : String = "fareChange";
    public static let  FLD_STARTTIME : String = "startTime";
    public static let  FLD_EXPECTEDENDTIME : String = "expectedEndTime";
    public static let  FLD_ACTUALENDTIME : String = "actualEndtime";
    public static let  FLD_STATUS : String = "status";
    public static let  FLD_ROUTEPATHPOLYLINE : String = "routePathPolyline";
    public static let  FLD_ACTUALSTARTTIME : String = "actualStartTime";
    public static let  FLD_PICKUP_ADDRESS : String = "pickupAddress";
    public static let  FLD_PICKUP_LATITUDE : String = "pickupLatitude";
    public static let  FLD_PICKUP_LONGITUDE : String = "pickupLongitude";
    public static let  FLD_PICKUP_TIME : String = "pickupTime";
    public static let  FLD_DROP_ADDRESS : String = "dropAddress";
    public static let  FLD_DROP_LATITUDE : String = "dropLatitude";
    public static let  FLD_DROP_LONGITUDE : String = "dropLongitude";
    public static let  FLD_DROP_TIME : String = "dropTime";
    public static let  FLD_PASSENGER_NAME : String = "passengerName";
    public static let  FLD_RIDER_NAME : String = "riderName";
    public static let  FLD_VEHICLE_NUMBER : String = "vehicleNumber";
    public static let  FLD_FARE_KM : String = "farePerKm";
    public static let  FLD_VEHICLE_MODEL : String = "vehicleModel";
    public static let  FLD_VEHICLE_TYPE : String = "vehicleType";
    public static let  FLD_AVAILABLE_SEATS : String = "availableSeats";
    public static let  FLD_NO_OF_PASSENGERS : String = "availableSeats";
    public static let  FLD_WAYPOINTS : String = "waypoints"
    public static let  FLD_CONFIRMED : String = "confirmed"
    public static let  FLD_NO_OF_SEATS : String = "noOfSeats"
    public static let  FLD_ROUTE : String = "route"
    public static let  FLD_CANCEL_REASON = "cancelReason"
    public static let  FLD_PROMOCODE = "promocode"
    public static let  FLD_ROUTE_ID = "routeId"
    public static let  FLD_RIDE_NOTES = "rideNotes"
    public static let FLD_VEHICLE_ID = "vehicleId"
    public static let FLD_VEHICLE_MAKE_AND_CATEGORY = "vehicleMakeAndCategory"
    public static let FLD_VEHICLE_ADDITIONAL_FACILITES = "additionalFacilities"
    public static let FLD_CAPACITY = "capacity"
    public static let FLD_WEIGHTED_ROUTES = "weightedRoutes"
    public static let  DRIVER_DEVICEID : String = "DRIVER_DEVICEID";
    public static let  PASSENGER_DEVICEID : String = "PASSENGER_DEVICEID";
    public static let  PASSENGER_ID : String = "passengerid";
    public static let  ROUTE_MATCHING_RESULTS : String = "ROUTE_MATCHING_RESULTS";
    public static let  RIDE_STATUS_REQUESTED : String = "Requested";
    public static let  RIDE_STATUS_SCHEDULED : String = "Scheduled";
    public static let  RIDE_STATUS_STARTED : String = "Started";
    public static let  RIDE_STATUS_COMPLETED : String = "Completed";
    public static let  RIDE_STATUS_DELAYED : String = "Delayed";
    public static let  RIDE_STATUS_CANCELLED : String = "Cancelled";
    public static let  RIDE_STATUS_BREAKDOWN : String = "Breakdown";
    public static let  RIDE_STATUS_UNREACHABLE : String = "Unreachable";
    public static let  RIDE_STATUS_RESCHEDULED = "Rescheduled"
    public static let  RIDE_STATUS_SUSPENDED = "Suspended"
    public static let  RIDE_STATUS_ARCHIVE_COMPLETED = "ArchCom"
    public static let  RIDE_STATUS_ARCHIVE_CANCELLED = "ArchCancel"
    public static let  FLD_DISTANCE_ON_PSGR_ROUTE = "distanceOnPsgrRoute";
    public static let  RIDE_STATUS_REQUEST_PENDING = "REQUEST PENDING"
    public static let  RIDE_STATUS_INVITATION_PENDING = "INVITATION PENDING"
    
    public static let  FLD_PASSENGERRIDEID : String = "passengerRideId";
    public static let  FLD_PASSENGERID : String = "passengerId";
    public static let  RIDER_RIDE : String = "Rider";
    public static let  PASSENGER_RIDE : String = "Passenger";
    public static let  FLD_RIDER_RIDE : String = "RiderRide";
    public static let  FLD_PASSENGER_RIDE : String = "PassengerRide";
    public static let  REGULAR_RIDER_RIDE : String = "RegularRider";
    public static let  REGULAR_PASSENGER_RIDE : String = "RegularPassenger";
    public static let  CHECK_IN_RIDE : String = "Check in";
    public static let  CHECK_OUT_RIDE : String = "Check Out";
    public static let  START_RIDE : String = "Start Ride";
    public static let  END_RIDE : String = "End Ride";
    public static let  RIDE_STATUS_ARCHIVED : String = "Archived"
    public static let  FLD_RIDE_GROUP_ID : String = "rideGroupId"
    
    public static let  FLD_FROM_DATE : String = "fromDate"
    public static let  FLD_TO_DATE : String = "toDate"
    public static let  FLD_SUNDAY : String = "sunday"
    public static let  FLD_MONDAY : String = "monday"
    public static let  FLD_TUESDAY : String = "tuesday"
    public static let  FLD_WEDNESDAY : String = "wednesday"
    public static let  FLD_THURSDAY : String = "thursday"
    public static let  FLD_FRIDAY : String = "friday"
    public static let  FLD_SATURDAY : String = "saturday"
    public static let  FLD_OVERLAPDISTANCE : String = "overLappingDistance"
    public static let FLD_JOINED_GROUP_RESTRICTION = "joinedGroupRestriction"
    public static let FLD_SHOW_ME_TO_JOINED_GRPS = "showMeToJoinedGroups"
    public static let FLD_RECALCULATE_PICKUP_DROP_TRAFFIC = "pickupDropRecalcualtionBasedOnTraffic"
    public static let FLD_DEVICE = "device"
    public static let FLD_PICKUP_NOTE = "pickupNote"
    public static let FLD_OVERVIEW_POLYLINE = "overviewPolyline"
    public static let FLD_TRAVEL_MODE = "travelMode"
    public static let DRIVING = "Driving"
    public static let matchPercentThreshold = "matchPercentThreshold"
    
    public static let ODD_DAYS = "ODD"
    public static let EVEN_DAYS = "EVEN"
    public static let ALL_DAYS = "ALL"
    public static let UPDATE_BY_RIDER = "updateByRider"
    public static let IS_FOR_ANALYTICS = "isForAnalytics"
    public static let IS_FROM_INVITE_BY_CONTACT = "isFromInviteByContact"
    public static let FLD_PAYMENT_TYPE = "paymentType"
    public static let FLD_WAVEOFF = "waveOff"
    public static let parentRideId = "parentRideId"
    public static let relayLegSeq = "relayLegSeq"
    public static let FLD_CALLERUSERID = "callerUserId"
    public static let FLD_CURRENT_USER_ID = "currentUserId"
    public static let FLD_INCLUDE_CAPTURE_RELEASE_TXN = "includeCaptureReleaseTxn"
    public static let FLD_SOURCE_APK = "sourceApplication"
    static let INITIAL_STATUS_FOR_TAXI = "initialStatus"
    static let FLD_PAY_AFTER_CONFIRM = "paymentAfterConfirmation"
    
    public override init(){
        
    }
  
    public init(userId : Double,  rideType : String,  startAddress : String,
        startLatitude : Double,  startLongitude : Double,  endAddress : String,
        endLatitude :Double ,  endLongitude : Double, startTime : Double)
    {
      super.init()
      self.userId = userId;
      self.rideType = rideType;
      self.startAddress = startAddress;
      self.startLatitude = startLatitude;
      self.startLongitude = startLongitude;
      self.endAddress = endAddress;
      self.endLatitude = endLatitude;
      self.endLongitude = endLongitude;
      self.startTime = startTime;
    }
    
    init(ride : Ride) {
        self.rideId  = ride.rideId
        self.userId  = ride.userId
        self.userName = ride.userName
        self.rideType = ride.rideType
        self.startAddress = ride.startAddress
        self.startLatitude =  ride.startLatitude
        self.startLongitude = ride.startLongitude
        self.endAddress = ride.endAddress
        self.endLatitude = ride.endLatitude
        self.endLongitude = ride.endLongitude
        self.distance = ride.distance
        self.startTime = ride.startTime
        self.expectedEndTime = ride.expectedEndTime
        self.status = ride.status
        self.routePathPolyline = ride.routePathPolyline
        self.actualStartTime = ride.actualStartTime
        self.actualEndtime = ride.actualEndtime
        self.waypoints = ride.waypoints
        self.routeId = ride.routeId
        self.promocode = ride.promocode
        self.rideNotes = ride.rideNotes
        self.allowRideMatchToJoinedGroups = ride.allowRideMatchToJoinedGroups
        self.showMeToJoinedGroups = ride.showMeToJoinedGroups
        self.regularRideId = ride.regularRideId
    }
    required public init?(map:Map){
        
    }
    func updateWithValuesFromNewRide( newRide : Ride) {
        self.startAddress = newRide.startAddress
        self.startLatitude = newRide.startLatitude
        self.startLongitude = newRide.startLongitude
        self.endAddress = newRide.endAddress
        self.endLatitude = newRide.endLatitude
        self.endLongitude = newRide.endLongitude
        self.distance = newRide.distance
        self.startTime = newRide.startTime
        self.expectedEndTime = newRide.expectedEndTime
        self.actualStartTime = newRide.actualStartTime
        self.actualEndtime = newRide.actualEndtime
        self.status = newRide.status
        self.routePathPolyline = newRide.routePathPolyline
        self.rideType = newRide.rideType
    }
    public func mapping(map: Map) {
        rideId <- map["id"]
        userId <- map["userId"]
        userName <- map["userName"]
        rideType <- map["rideType"]
        startAddress <- map["startAddress"]
        startLatitude <- map["startLatitude"]
        startLongitude <- map["startLongitude"]
        endAddress <- map["endAddress"]
        endLatitude <- map["endLatitude"]
        endLongitude <- map["endLongitude"]
        distance <- map["distance"]
        startTime <- map["startTime"]
        expectedEndTime <- map["expectedEndTime"]
        status <- map["status"]
        routePathPolyline <- map["routePathPolyline"]
        actualStartTime <- map["actualStartTime"]
        actualEndtime <- map["actualEndtime"]
        waypoints <- map["waypoints"]
        routeId <- map["routeId"]
        rideNotes <- map["rideNotes"]
        allowRideMatchToJoinedGroups <- map["allowRideMatchToJoinedGroups"]
        showMeToJoinedGroups <- map["showMeToJoinedGroups"]
        regularRideId <- map["regularRideId"]
    }
    
    func  prepareRideStatusObject() -> RideStatus{
        let statusObj:RideStatus  = RideStatus(rideId: rideId, userId: userId, status: status, rideType: rideType!)
        return statusObj
    }
     public func copy(with zone: NSZone? = nil) -> Any {
        return  Ride(ride: self)
    }
    func checkIfRideIsValid() ->Bool{
        if self.rideType != nil && self.startTime != 0 && self.expectedEndTime != 0 && self.startLatitude != 0 && self.startLongitude != 0 && self.endLatitude != 0 && self.endLongitude != 0 && self.distance != nil && self.startAddress.isEmpty == false && self.endAddress.isEmpty == false && self.routeId != nil{
            return true
        }
        return false
    }
    func isStartAndEndValid() ->Bool{
        if self.rideType != nil && self.startLatitude != 0 && self.startLongitude != 0 && self.endLatitude != 0 && self.endLongitude != 0 && self.startAddress.isEmpty == false && self.endAddress.isEmpty == false {
            return true
        }
        return false
    }
    
    init(taxiRide: TaxiRidePassenger) {
        self.userId = taxiRide.userId ?? 0
        self.rideId = taxiRide.id ?? 0
        self.startLatitude = taxiRide.startLat ?? 0
        self.startLongitude = taxiRide.startLng ?? 0
        self.endLatitude = taxiRide.endLat
        self.endLongitude = taxiRide.endLng
        self.startTime = taxiRide.startTimeMs ?? 0
        self.rideType = TaxiPoolConstants.Taxi
        self.startAddress = taxiRide.startAddress!
        self.endAddress = taxiRide.endAddress!
        self.startTime = taxiRide.pickupTimeMs!
        self.expectedEndTime = taxiRide.dropTimeMs!
        self.status = taxiRide.status!
               
    }
    
    public override var description: String {
        return "rideId: \(String(describing: self.rideId))," + "userId: \(String(describing: self.userId))," + " userName: \( String(describing: self.userName))," + " rideType: \(String(describing: self.rideType))," + " startAddress: \(String(describing: self.startAddress)),"
            + " startLatitude: \(String(describing: self.startLatitude))," + "startLongitude: \(String(describing: self.startLongitude))," + "endAddress:\(String(describing: self.endAddress))," + "endLatitude:\(String(describing: self.endLatitude))," + "endLongitude:\(String(describing: self.endLongitude))," + "distance:\(String(describing: self.distance))," + "startTime: \(String(describing: self.startTime))," + "expectedEndTime: \( String(describing: self.expectedEndTime))," + "status: \(String(describing: self.status))," + "routePathPolyline: \( String(describing: self.routePathPolyline))," + "actualStartTime: \(String(describing: self.actualStartTime))," + "actualEndtime: \( String(describing: self.actualEndtime))," + "waypoints:\(String(describing: self.waypoints))," + "routeId:\(String(describing: self.routeId))," + "promocode: \(String(describing: self.promocode))," + "rideNotes:\(String(describing: self.rideNotes))," + "allowRideMatchToJoinedGroups: \(String(describing: self.allowRideMatchToJoinedGroups))," + "showMeToJoinedGroups\(self.showMeToJoinedGroups)," + "regularRideId\(String(describing: self.regularRideId)),"
    }
}
