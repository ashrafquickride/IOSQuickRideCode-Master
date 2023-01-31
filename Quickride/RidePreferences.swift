//
//  RidePreferences.swift
//  Quickride
//
//  Created by KNM Rao on 07/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RidePreferences: NSObject, Mappable, NSCopying{
    var userId : Double?
    var preferredVehicle : String = RidePreferences.PREFERRED_VEHICLE_BOTH
    var rideMatchPercentageAsRider = 15
    var rideMatchPercentageAsPassenger = 50
    var locationUpdateAccuracy = 1
    var dontShowWhenInActive = false
    var dontShowTaxiOptions = false
    var alertOnOverSpeed = false
    var rideMatchTimeThreshold = 45
    var allowRideMatchToJoinedGroups = false
    var showMeToJoinedGroups = false
    var allowFareChange = true
    var restrictPickupNearStartPoint = false
    var minFare = 20
    var rideNote : String?
    var autoconfirm = RidePreferences.AUTO_CONFIRM_VERIFIED
    var autoConfirmRideMatchTimeThreshold = 15
    var autoConfirmRideMatchPercentageAsRider = 50
    var autoConfirmRideMatchPercentageAsPassenger = 90
    var autoConfirmRidesType = RidePreferences.AUTO_CONFIRM_FOR_RIDES_TYPE_BOTH
    var rideInsuranceEnabled = true
    var autoConfirmEnabled = false
    var autoConfirmPartnerEnabled = false
    var rideModerationEnabled = true
   
    static let PREFERRED_VEHICLE_BOTH = "Both"
    static let PREFERRED_VEHICLE_CAR = "Car"
    static let PREFERRED_VEHICLE_BIKE = "Bike"
    static let USER_ID = "userId"
    static let PREFERRED_ROLE = "preferredRole"
    static let RIDE_MATCH_PERCENTAGE_AS_RIDER = "rideMatchPercentageAsRider"
    static let RIDE_MATCH_PERCENTAGE_AS_PASSENGER = "rideMatchPercentageAsPassenger"
    static let PREFERRED_VEHICLE = "preferredVehicle"
    static let DONT_SHOW_WHEN_IN_ACTIVE = "dontShowWhenInActive"
    static let DONT_SHOW_TAXI_OPTIONS = "dontShowTaxiOptions"
    static let MIN_FARE = "minFare"
    static let RIDE_NOTE = "rideNote"
    static let AUTO_CONFIRM_ALL = "ALL"
    static let AUTO_CONFIRM_VERIFIED = "VERIFIED"
    static let AUTO_CONFIRM_FAVORITE_PARTNERS = "FAVPARTNERS"
    static let AUTO_CONFIRM_NEVER = "NEVER"
    static let AUTO_CONFIRM_FOR_RIDES_TYPE_AUTO_ACCEPT = "AUTOACCEPT"
    static let AUTO_CONFIRM_FOR_RIDES_TYPE_AUTO_INVITE = "AUTOINVITE"
    static let AUTO_CONFIRM_FOR_RIDES_TYPE_BOTH = "BOTH"

    
    static let LOCATION_ACCURACY_OFF = 0
    static let LOCATION_ACCURACY_BALANCE = 1
    static let LOCATION_ACCURACY_HIGH = 2
    
    override init() {
        if QRSessionManager.getInstance()?.getUserId() != nil && QRSessionManager.getInstance()?.getUserId() == "0"{
            userId = Double(QRSessionManager.getInstance()!.getUserId())
        }
        else{
            userId = Double(SharedPreferenceHelper.getLoggedInUserId() ?? "0")
        }
        
        preferredVehicle = RidePreferences.PREFERRED_VEHICLE_BOTH
        rideMatchPercentageAsRider = 15
        rideMatchPercentageAsPassenger = 50
        locationUpdateAccuracy = 1
        dontShowWhenInActive = false
        dontShowTaxiOptions = false
        alertOnOverSpeed = false
        rideMatchTimeThreshold = 45
        allowRideMatchToJoinedGroups = false
        showMeToJoinedGroups = false
        allowFareChange = true
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil
        {
            clientConfiguration = ClientConfigurtion()
        }
        autoconfirm = clientConfiguration!.autoConfirmDefaultValue
        autoConfirmRideMatchTimeThreshold = clientConfiguration!.autoConfirmDefaultRideMatchTimeThreshold
        autoConfirmRideMatchPercentageAsRider = clientConfiguration!.autoConfirmDefaultRideMatchPercentageAsRider
        autoConfirmRideMatchPercentageAsPassenger = clientConfiguration!.autoConfirmDefaultRideMatchPercentageAsPassenger
        autoConfirmRidesType = clientConfiguration!.autoConfirmTypeDefaultValue
        minFare = clientConfiguration!.defaultMinFareForRide
        restrictPickupNearStartPoint = false
    }
    func mapping(map: Map) {
        self.userId <- map["userId"]
        self.preferredVehicle <- map["preferredVehicle"]
        self.rideMatchPercentageAsRider <- map["rideMatchPercentageAsRider"]
        self.rideMatchPercentageAsPassenger <- map["rideMatchPercentageAsPassenger"]
        self.locationUpdateAccuracy <- map["locationUpdateAccuracy"]
        self.dontShowWhenInActive <- map["dontShowWhenInActive"]
        self.dontShowTaxiOptions <- map["dontShowTaxiOptions"]
        self.alertOnOverSpeed <- map["alertOnOverSpeed"]
        self.rideMatchTimeThreshold <- map["rideMatchTimeThreshold"]
        self.allowFareChange <- map["allowFareChange"]
        self.allowRideMatchToJoinedGroups <- map["allowRideMatchToJoinedGroups"]
        self.showMeToJoinedGroups <- map["showMeToJoinedGroups"]
        self.minFare <- map["minFare"]
        self.rideNote <- map["rideNote"]
        self.restrictPickupNearStartPoint <- map["restrictPickupNearStartPoint"]
        self.autoconfirm <- map["autoConfirmRides"]
        self.autoConfirmRideMatchTimeThreshold <- map["autoConfirmRidesTimeThreshold"]
        self.autoConfirmRideMatchPercentageAsRider <- map["autoConfirmRideMatchPercentageAsRider"]
        self.autoConfirmRideMatchPercentageAsPassenger <- map["autoConfirmRideMatchPercentageAsPassenger"]
        self.autoConfirmRidesType <- map["autoConfirmRidesType"]
        self.rideInsuranceEnabled <- map["rideInsuranceEnabled"]
        self.autoConfirmEnabled <- map["autoConfirmEnabled"]
        self.autoConfirmPartnerEnabled <- map["autoConfirmPartnerEnabled"]
        rideModerationEnabled <- map["rideModerationEnabled"]
    }
    required init?(map: Map) {
        
    }
    
    func  getParamsMap() -> [String : String] {
        var params : [String : String] = [String : String]()
        params["userId"] =  StringUtils.getStringFromDouble(decimalNumber: userId)
        params["rideMatchPercentageAsRider"] = String(rideMatchPercentageAsRider)
        params["rideMatchPercentageAsPassenger"] = String(rideMatchPercentageAsPassenger)
        params["preferredVehicle"] = preferredVehicle
        params["dontShowWhenInActive"] = String(dontShowWhenInActive)
        params["dontShowTaxiOptions"] = String(dontShowTaxiOptions)
        params["locationUpdateAccuracy"] = String(self.locationUpdateAccuracy)
        params["alertOnOverSpeed"] = String(alertOnOverSpeed)
        params["rideMatchTimeThreshold"] = String(rideMatchTimeThreshold)
        params["allowFareChange"] = String(allowFareChange)
        params[Ride.FLD_JOINED_GROUP_RESTRICTION] = String(allowRideMatchToJoinedGroups)
        params[Ride.FLD_SHOW_ME_TO_JOINED_GRPS] = String(showMeToJoinedGroups)
        params["minFare"] = String(minFare)
        params["autoConfirmRides"] = String(autoconfirm)
        params["autoConfirmRidesTimeThreshold"] = String(autoConfirmRideMatchTimeThreshold)
        params["autoConfirmRideMatchPercentageAsRider"] = String(autoConfirmRideMatchPercentageAsRider)
        params["autoConfirmRideMatchPercentageAsPassenger"] = String(autoConfirmRideMatchPercentageAsPassenger)
        params["autoConfirmRidesType"] = String(autoConfirmRidesType)
        params["rideInsuranceEnabled"] = String(rideInsuranceEnabled)
        params["autoConfirmEnabled"] = String(autoConfirmEnabled)
        params["autoConfirmPartnerEnabled"] = String(autoConfirmPartnerEnabled)
        
        if rideNote != nil
        {
            params["rideNote"] = rideNote!
        }
        params["restrictPickupNearStartPoint"] = String(restrictPickupNearStartPoint)
        params["rideModerationEnabled"] = String(rideModerationEnabled)
        return params
    }
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let ridePreferences = RidePreferences()
        ridePreferences.userId = self.userId
        ridePreferences.rideMatchPercentageAsRider = self.rideMatchPercentageAsRider
        ridePreferences.rideMatchPercentageAsPassenger = self.rideMatchPercentageAsPassenger
        ridePreferences.preferredVehicle = self.preferredVehicle
        ridePreferences.dontShowWhenInActive = self.dontShowWhenInActive
        ridePreferences.dontShowTaxiOptions = self.dontShowTaxiOptions
        ridePreferences.alertOnOverSpeed = self.alertOnOverSpeed
        ridePreferences.locationUpdateAccuracy = self.locationUpdateAccuracy
        ridePreferences.rideMatchTimeThreshold = self.rideMatchTimeThreshold
        ridePreferences.allowFareChange = self.allowFareChange
        ridePreferences.allowRideMatchToJoinedGroups = self.allowRideMatchToJoinedGroups
        ridePreferences.showMeToJoinedGroups = self.showMeToJoinedGroups
        ridePreferences.minFare = self.minFare
        ridePreferences.rideNote = self.rideNote
        ridePreferences.restrictPickupNearStartPoint = self.restrictPickupNearStartPoint
        ridePreferences.autoconfirm = self.autoconfirm
        ridePreferences.autoConfirmRideMatchTimeThreshold = self.autoConfirmRideMatchTimeThreshold
        ridePreferences.autoConfirmRideMatchPercentageAsRider = self.autoConfirmRideMatchPercentageAsRider
        ridePreferences.autoConfirmRideMatchPercentageAsPassenger = self.autoConfirmRideMatchPercentageAsPassenger
        ridePreferences.autoConfirmRidesType = self.autoConfirmRidesType
        ridePreferences.rideInsuranceEnabled = self.rideInsuranceEnabled
        ridePreferences.autoConfirmEnabled = self.autoConfirmEnabled
        ridePreferences.autoConfirmPartnerEnabled = self.autoConfirmPartnerEnabled
        ridePreferences.rideModerationEnabled = self.rideModerationEnabled
        return ridePreferences
    }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "preferredVehicle: \(String(describing: self.preferredVehicle))," + " rideMatchPercentageAsRider: \(String(describing: self.rideMatchPercentageAsRider))," + " rideMatchPercentageAsPassenger: \(String(describing: self.rideMatchPercentageAsPassenger))," + " locationUpdateAccuracy: \(String(describing: self.locationUpdateAccuracy)),"
            + " dontShowWhenInActive: \(self.dontShowWhenInActive)," + "dontShowTaxiOptions: \(String(describing: self.dontShowTaxiOptions))," + "alertOnOverSpeed:\(self.alertOnOverSpeed)," + "rideMatchTimeThreshold:\(self.rideMatchTimeThreshold)," + "allowRideMatchToJoinedGroups:\(self.allowRideMatchToJoinedGroups)," + "showMeToJoinedGroups:\(String(describing: self.showMeToJoinedGroups))," + "allowFareChange: \(String(describing: self.allowFareChange))," + "restrictPickupNearStartPoint: \(String(describing: self.restrictPickupNearStartPoint))," + "minFare: \(String(describing: self.minFare))," + "rideNote: \(String(describing: self.rideNote))," + "autoconfirm: \(String(describing: self.autoconfirm))," + "autoConfirmRideMatchTimeThreshold: \(String(describing: self.autoConfirmRideMatchTimeThreshold))," + "autoConfirmRideMatchPercentageAsRider: \(String(describing: self.autoConfirmRideMatchPercentageAsRider))," + "autoConfirmRideMatchPercentageAsPassenger: \(String(describing: self.autoConfirmRideMatchPercentageAsPassenger))," + "autoConfirmRidesType: \(String(describing: self.autoConfirmRidesType))," + "rideModerationEnabled: \(rideModerationEnabled)"
    }

}
