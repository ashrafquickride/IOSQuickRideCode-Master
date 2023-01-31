//
//  MatchedUser.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class MatchedUser : NSObject, Mappable {
    
    var userid:Double?
    var rideid:Double?
    var name:String?
    var imageURI:String?
    var userRole:String?
    var gender:String?
    var rating:Double?
    var startDate:Double?
    var fromLocationAddress:String?
    var fromLocationLatitude:Double?
    var fromLocationLongitude:Double?
    var toLocationAddress:String?
    var toLocationLatitude:Double?
    var toLocationLongitude:Double?
    var pickupLocationAddress:String?
    var pickupLocationLatitude:Double?
    var pickupLocationLongitude:Double?
    var pickupTime:Double?
    var passengerReachTimeTopickup:Double?
    var dropLocationAddress:String?
    var dropLocationLatitude:Double?
    var dropLocationLongitude:Double?
    var dropTime:Double?
    var distance:Double?
    var points:Double?
    var newFare:Double = -1
    var fareChange = false
    var matchPercentage:Int?
    var routePolyline:String?
    var verificationStatus : Bool = false
    var noOfReviews : Int = 0
    var companyName : String?
    var callSupport : String = UserProfile.SUPPORT_CALL_ALWAYS
    var uniqueID : String?
    var lastRideCreatedTime : Double?
    var rideDistance : Double = 0
    var passengerDistance : Double = 0
    var routeId : Double = 0
    var allowFareChange = true
    var rideNotes : String?
    var matchPercentageOnMatchingUserRoute : Int = 0
    var pickupTimeRecalculationRequired = true
    var totalNoOfRideShared : Int?
    var androidAppVersionName : Double?
    var iosAppVersionName : Double?
    var userOnTimeComplianceRating: String?
    var enableChatAndCall : Bool = true
    var lastResponseTime: Double = 0.0
    var ridePassId : Double = 0.0
    var profileVerificationData : ProfileVerificationData?
    var noOfRidesShared :Double = 0
    var matchingSortingStatus: String?
    var userPreferredPickupDrop: UserPreferredPickupDrop?
    var hasSafeKeeperBadge = false
    var walkingDistance : Double? //it will not map from server manually calculating
    var isReadyToGo = false //Used to diffenetiate normal and instant matches, not a mapping value
    var psgReachToPk: Double?
    var pkTime: Double?

    static var PASSENGER = "Passenger"
    static var RIDER = "Rider"
    static var REGULAR_PASSENGER = "RegularPassenger"
    static var REGULAR_RIDER = "RegularRider"
    static var USER_ID = "USER_ID"
    static var RIDE_ID = "RIDE_ID"
    static var USER_TYPE = "USER_TYPE"
    static var MATCHED_USER = "MatchedUser"
    static let SUPPORTED_ANDROID_APP_VERSION = 6.83
    static let SUPPORTED_IOS_APP_VERSION = 6.04
    static let FLD_PICK_UP_TIME_RECALCULATION_REQUIRED = "pickupTimeRecalculationRequired"
    static let ENABLE_CALL_OPTION_TO_INACTIVE_USER = "ENABLE_CALL_OPTION_TO_INACTIVE_USER"
    static let INVITEE_SORT_POSITION = "inviteeSortPosition"
    static let CURRENT_SORT_FILTER_STATUS="currentSortFilterStatus"
    static let PASSENGERREQUIRESHELMET = "passengerRequiresHelmet"
    override init(){
        
    }
  
    
    required  public init(map:Map){
        
    }
    init(ride : Ride,rideInvitation: RideInvitation,userProfile : UserBasicInfo) {
        self.userid  = userProfile.userId
        if ride.rideType == Ride.RIDER_RIDE{
            self.rideid  = rideInvitation.passenegerRideId
            self.userRole = MatchedUser.PASSENGER
            self.matchPercentage = 100
        }else{
            self.rideid  = rideInvitation.rideId
            self.userRole = MatchedUser.RIDER
            self.matchPercentage =  100
        }
        
        self.name = userProfile.name
        self.imageURI = userProfile.imageURI
        self.gender = userProfile.gender
        self.rating = Double(userProfile.rating)
        self.rating = self.rating!.roundToPlaces(places: 1)
        self.startDate = rideInvitation.startTime
        self.fromLocationAddress = rideInvitation.pickupAddress
        self.fromLocationLatitude = rideInvitation.pickupLatitude
        self.fromLocationLongitude = rideInvitation.pickupLongitude
        self.toLocationAddress = rideInvitation.dropAddress
        self.toLocationLatitude = rideInvitation.dropLatitude
        self.toLocationLongitude = rideInvitation.dropLongitude
        self.pickupLocationAddress = rideInvitation.pickupAddress
        self.pickupLocationLatitude = rideInvitation.pickupLatitude
        self.pickupLocationLongitude = rideInvitation.pickupLongitude
        self.pickupTime = rideInvitation.pickupTime
        self.dropLocationAddress = rideInvitation.dropAddress
        self.dropLocationLatitude = rideInvitation.dropLatitude
        self.dropLocationLongitude = rideInvitation.dropLongitude
        self.dropTime = rideInvitation.dropTime
        self.distance = rideInvitation.matchedDistance
        if rideInvitation.rideType == Ride.RIDER_RIDE || rideInvitation.rideType == Ride.REGULAR_RIDER_RIDE {
            self.points = rideInvitation.riderPoints
        } else {
            self.points = rideInvitation.points
        }
        self.fareChange = rideInvitation.fareChange
        
        self.routePolyline = ride.routePathPolyline
        self.verificationStatus = userProfile.verificationStatus
        self.noOfReviews = userProfile.noOfReviews
        self.companyName = userProfile.companyName
        self.callSupport = userProfile.callSupport
        
        self.rideDistance = ride.distance!
        self.passengerDistance = ride.distance!
        self.routeId = ride.routeId!
        self.passengerReachTimeTopickup = rideInvitation.pickupTime
        self.allowFareChange = rideInvitation.allowFareChange
//        self.rideNotes = userProfile.ride
        self.matchPercentageOnMatchingUserRoute  = 100
//        self.pickupTimeRecalculationRequired <- map["pickupTimeRecalculationRequired"]
//        self.totalNoOfRideShared <- map["totalNoOfRideShared"]
//        self.androidAppVersionName <- map["androidAppVersionName"]
//        self.iosAppVersionName <- map["iosAppVersionName"]
//        self.userOnTimeComplianceRating <- map["userOnTimeComplianceRating"]
//        self.enableChatAndCall <- map["enableChatAndCall"]
//        self.lastResponseTime <- map["lastResponseTime"]
//        self.ridePassId <- map["ridePassId"]
        self.profileVerificationData = userProfile.profileVerificationData
//        self.noOfRidesShared = userProfile.n
//        self.matchingSortingStatus <- map["matchingSortingStatus"]
//        self.hasSafeKeeperBadge <- map["hasCovid19Badge"]
    }
    
    public func mapping(map: Map) {
        userid <- map["userid"]
        rideid <-  map["rideid"]
        name <- map["name"]
        imageURI <- map["imageURI"]
        userRole <- map["userRole"]
        gender <- map["gender"]
        rating <- map["rating"]
        startDate <- map["startDate"]
        fromLocationAddress <- map["fromLocationAddress"]
        fromLocationLatitude <- map["fromLocationLatitude"]
        fromLocationLongitude <- map["fromLocationLongitude"]
        toLocationAddress <- map["toLocationAddress"]
        toLocationLatitude <- map["toLocationLatitude"]
        toLocationLongitude <- map["toLocationLongitude"]
        pickupLocationAddress <- map["pickupLocationAddress"]
        pickupLocationLatitude <- map["pickupLocationLatitude"]
        pickupLocationLongitude <- map["pickupLocationLongitude"]
        pickupTime <- map["pickupTime"]
        dropLocationAddress <- map["dropLocationAddress"]
        dropLocationLatitude <- map["dropLocationLatitude"]
        dropLocationLongitude <- map["dropLocationLongitude"]
        dropTime <- map["dropTime"]
        distance <- map["distance"]
        points <- map["points"]
        newFare <- map["newFare"]
        fareChange <- map["fareChange"]
        matchPercentage <- map["matchPercentage"]
        routePolyline <- map["routePolyline"]
        verificationStatus <- map["verificationStatus"]
        noOfReviews <- map["noOfReviews"]
        companyName <- map["companyName"]
        callSupport <- map["callSupport"]
        uniqueID <- map["uniqueID"]
        lastRideCreatedTime <- map["lastRideCreatedTime"]
        rideDistance <- map["rideDistance"]
        passengerDistance <- map["passengerDistance"]
        routeId <- map["routeId"]
        self.passengerReachTimeTopickup <- map["passengerReachTimeToPickup"]
        self.allowFareChange <- map["allowFareChange"]
        rideNotes <- map["rideNotes"]
        matchPercentageOnMatchingUserRoute <- map["matchPercentageOnMatchingUserRoute"]
        pickupTimeRecalculationRequired <- map["pickupTimeRecalculationRequired"]
        totalNoOfRideShared <- map["totalNoOfRideShared"]
        androidAppVersionName <- map["androidAppVersionName"]
        iosAppVersionName <- map["iosAppVersionName"]
        userOnTimeComplianceRating <- map["userOnTimeComplianceRating"]
        enableChatAndCall <- map["enableChatAndCall"]
        lastResponseTime <- map["lastResponseTime"]
        ridePassId <- map["ridePassId"]
        profileVerificationData <- map["profileVerificationData"]
        noOfRidesShared <- map["noOfRidesShared"]
        matchingSortingStatus <- map["matchingSortingStatus"]
        hasSafeKeeperBadge <- map["hasCovid19Badge"]
        psgReachToPk <- map["psgReachToPk"]
        pkTime <- map["pkTime"]
    }

    init(riderRide : RiderRide, rideParticipant: RideParticipant, currentRideParticipant: RideParticipant?) {
        self.userid = rideParticipant.userId
        self.rideid = rideParticipant.rideId
        self.name = rideParticipant.name
        self.imageURI = rideParticipant.imageURI
        self.userRole = rideParticipant.rider ? Ride.RIDER_RIDE : Ride.PASSENGER_RIDE
        self.gender = rideParticipant.gender
        self.startDate = riderRide.startTime
        self.fromLocationAddress = riderRide.startAddress
        self.fromLocationLatitude = riderRide.startLatitude
        self.fromLocationLongitude = riderRide.startLongitude
        self.toLocationAddress = riderRide.endAddress
        self.toLocationLatitude = riderRide.endLatitude
        self.toLocationLongitude = riderRide.endLongitude
        self.pickupLocationAddress = currentRideParticipant?.startAddress
        self.pickupLocationLatitude = currentRideParticipant?.startPoint?.latitude
        self.pickupLocationLongitude = currentRideParticipant?.startPoint?.longitude
        self.pickupTime = rideParticipant.pickUpTime
        self.dropLocationAddress = currentRideParticipant?.endAddress
        self.dropLocationLatitude = currentRideParticipant?.endPoint?.latitude
        self.dropLocationLongitude = currentRideParticipant?.endPoint?.longitude
        self.dropTime = rideParticipant.dropTime
        self.distance = riderRide.distance
        self.points = rideParticipant.points
        self.routePolyline = riderRide.routePathPolyline
        self.callSupport = rideParticipant.callSupport!
        self.rideDistance = riderRide.distance ?? 0
        self.routeId = riderRide.routeId ?? 0
        self.rideNotes = rideParticipant.rideNote
        self.enableChatAndCall = rideParticipant.enableChatAndCall
        self.noOfRidesShared = Double(rideParticipant.noOfRidesShared ?? 0)
    }
    func initialise(matchedUser : MatchedUser) {
        
        matchedUser.userid = self.userid
        matchedUser.rideid = self.rideid
        matchedUser.name = self.name
        matchedUser.imageURI = self.imageURI
        matchedUser.userRole = self.userRole
        matchedUser.gender = self.gender
        matchedUser.rating = self.rating
        matchedUser.startDate = self.startDate
        matchedUser.fromLocationAddress = self.fromLocationAddress
        matchedUser.fromLocationLatitude = self.fromLocationLatitude
        matchedUser.fromLocationLongitude = self.fromLocationLongitude
        matchedUser.toLocationAddress = self.toLocationAddress
        matchedUser.toLocationLatitude = self.toLocationLatitude
        matchedUser.toLocationLongitude = self.toLocationLongitude
        matchedUser.pickupLocationAddress = self.pickupLocationAddress
        matchedUser.pickupLocationLatitude = self.pickupLocationLatitude
        matchedUser.pickupLocationLongitude = self.pickupLocationLongitude
        matchedUser.pickupTime = self.pickupTime
        matchedUser.passengerReachTimeTopickup = self.passengerReachTimeTopickup
        matchedUser.dropLocationAddress = self.dropLocationAddress
        matchedUser.dropLocationLatitude = self.dropLocationLatitude
        matchedUser.dropLocationLongitude = self.dropLocationLongitude
        matchedUser.dropTime = self.dropTime
        matchedUser.distance = self.distance
        matchedUser.points = self.points
        matchedUser.newFare = self.newFare
        matchedUser.fareChange  = self.fareChange
        matchedUser.matchPercentage = self.matchPercentage
        matchedUser.routePolyline = self.routePolyline
        matchedUser.verificationStatus  = self.verificationStatus
        matchedUser.noOfReviews  = self.noOfReviews
        matchedUser.companyName  = self.companyName
        matchedUser.callSupport  = self.callSupport
        matchedUser.uniqueID  = self.uniqueID
        matchedUser.lastRideCreatedTime  = self.lastRideCreatedTime
        matchedUser.rideDistance  = self.rideDistance
        matchedUser.passengerDistance  = self.passengerDistance
        matchedUser.routeId  = self.routeId
        matchedUser.allowFareChange  = self.allowFareChange
        matchedUser.rideNotes  = self.rideNotes
        matchedUser.matchPercentageOnMatchingUserRoute  = self.matchPercentageOnMatchingUserRoute
        matchedUser.pickupTimeRecalculationRequired  = self.pickupTimeRecalculationRequired
        matchedUser.totalNoOfRideShared = self.totalNoOfRideShared
        matchedUser.androidAppVersionName = self.androidAppVersionName
        matchedUser.iosAppVersionName = self.iosAppVersionName
        matchedUser.userOnTimeComplianceRating = self.userOnTimeComplianceRating
        matchedUser.enableChatAndCall = self.enableChatAndCall
        matchedUser.lastResponseTime = self.lastResponseTime
        matchedUser.ridePassId = self.ridePassId
        matchedUser.profileVerificationData = self.profileVerificationData
        matchedUser.noOfRidesShared = self.noOfRidesShared
        matchedUser.matchingSortingStatus = self.matchingSortingStatus
        matchedUser.userPreferredPickupDrop = self.userPreferredPickupDrop
    }
    public override var description: String {
        return "userid: \(String(describing: self.userid))," + "rideid: \(String(describing: self.rideid))," + " name: \( String(describing: self.name))," + " imageURI: \(String(describing: self.imageURI))," + " userRole: \(String(describing: self.userRole)),"
            + " gender: \(String(describing: self.gender))," + "rating: \(String(describing: self.rating))," + "startDate:\(String(describing: self.startDate))," + "fromLocationAddress:\(String(describing: self.fromLocationAddress))," + "fromLocationLatitude:\(String(describing: self.fromLocationLatitude))," + "fromLocationLongitude:\(String(describing: self.fromLocationLongitude))," + "toLocationAddress: \(String(describing: self.toLocationAddress))," + "toLocationLatitude: \( String(describing: self.toLocationLatitude))," + "toLocationLongitude: \(String(describing: self.toLocationLongitude))," + "pickupLocationAddress: \( String(describing: self.pickupLocationAddress))," + "pickupLocationLatitude: \(String(describing: self.pickupLocationLatitude))," + "pickupLocationLongitude: \( String(describing: self.pickupLocationLongitude))," + "pickupTime:\(String(describing: self.pickupTime))," + "dropLocationAddress:\(String(describing: self.dropLocationAddress))," + "passengerReachTimeTopickup: \(String(describing: self.passengerReachTimeTopickup))," + "dropLocationLatitude:\(String(describing: self.dropLocationLatitude))," + "dropLocationLongitude: \(String(describing: self.dropLocationLongitude))," + "dropTime\(String(describing: self.dropTime))," + "distance: \(String(describing: self.distance))," + "points: \( String(describing: self.points))," + "newFare:\(String(describing: self.newFare))," + "fareChange:\(String(describing: self.fareChange))," + "matchPercentage: \(String(describing: self.matchPercentage))," + "routePolyline:\(String(describing: self.routePolyline))," + "verificationStatus: \(String(describing: self.verificationStatus))," + "noOfReviews\(self.noOfReviews)," + "companyName: \(String(describing: self.companyName))," + "callSupport: \( String(describing: self.callSupport))," + "uniqueID: \(String(describing: self.uniqueID))," + "lastRideCreatedTime: \( String(describing: self.lastRideCreatedTime))," + "rideDistance: \(String(describing: self.rideDistance))," + "passengerDistance: \( String(describing: self.passengerDistance))," + "routeId:\(String(describing: self.routeId))," + "allowFareChange:\(String(describing: self.allowFareChange))," + "rideNotes: \(String(describing: self.rideNotes))," + "matchPercentageOnMatchingUserRoute: \(String(describing: self.matchPercentageOnMatchingUserRoute))," + "pickupTimeRecalculationRequired\(self.pickupTimeRecalculationRequired)," + " totalNoOfRideShared: \(String(describing: self.totalNoOfRideShared)),"
            + " androidAppVersionName: \(String(describing: self.androidAppVersionName))," + "iosAppVersionName: \(String(describing: self.iosAppVersionName))," + "userOnTimeComplianceRating:\(String(describing: self.userOnTimeComplianceRating))," + "enableChatAndCall:\(String(describing: self.enableChatAndCall))," + "lastResponseTime:\(String(describing: self.lastResponseTime))," + "ridePassId:\(String(describing: self.ridePassId))," + "profileVerificationData: \(String(describing: self.profileVerificationData))," + "matchingSortingStatus:\(String(describing: self.matchingSortingStatus))," + "hasSafeKeeperBadge:\(String(describing: hasSafeKeeperBadge))" + "psgReachToPk:\(String(describing: psgReachToPk))" + "pkTime:\(String(describing: pkTime))"
    }
}
