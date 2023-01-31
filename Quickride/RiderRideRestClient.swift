//
//  RiderRide.swift
//  Quickride
//
//  Created by KNM Rao on 24/10/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import  ObjectMapper

public class RiderRideRestClient{
    
    // MARK: Local Variable
    
    private static let riderRideServicePath = "/QRRiderRide"
    private static let riderRideStatusServicePath = "/QRRiderRide/status"
    private static let riderRideCompleteServicePath = "/QRRiderRide/complete"
    static let getRideParticipant = "QRRide/participant"
    static let RIDER_RIDE_RESCHEDULE_RESOURCE_PATH = "/QRRiderRide/reschedule/utc"
    static let baseServerUrl: String = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath
    static let getAllRidesForUser = AppConfiguration.apiServerPath + "QRRide/all"
    static let getAllRiderRidesForUser = "QRRide/activeride/rider"
    static let getAllPassengerRidesForUser = "QRRide/activeride/passenger"
    static let getAllRideParticipants = "QRRide/participant/all"
    static let UPDATE_RIDE_STATUS_MESSAGE_SERVICE_PATH = "/QRRiderRide/rideNotes"
    static let freezeRiderRidePath = "/QRRiderRide/freezeRide"
    static let UPADATE_RIDER_RIDE = "/QRRiderRide/update/utc"
    static let MULTI_USER_PATH = "/QRRideconn/addpassenger/multiple"
    public static let RIDER_RIDES_CANCEL_RESOURCE_PATH = "/QRRiderRide/cancelRidesInBulk"
    static let CANCEL_RIDER_RIDE = "/QRRiderRide/cancelRide"
    
    // MARK: Type Alias
    
    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    
    // MARK: Webservice Method
    
    public static func getRiderRide(rideId : Double, targetViewController : UIViewController?, complitionHandler: @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getRiderRide() \(rideId)")
        let getRiderUrl = baseServerUrl + riderRideServicePath
            
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)

              AppDelegate.getAppDelegate().log.debug("")
     HttpUtils.getJSONRequestWithBody(url: getRiderUrl, targetViewController: targetViewController, params: params, handler: complitionHandler)
    }
    
    public static func completeRide(rideId : Double, targetViewController : UIViewController?, complitionHandler: @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("completeRide() \(rideId)")
        let getRiderUrl = baseServerUrl + riderRideServicePath
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        
        HttpUtils.putJSONRequestWithBody(url: getRiderUrl, targetViewController: targetViewController, handler: complitionHandler, body: params)
    }
    public static func freezeRide(rideId : Double, freezeRide : Bool, targetViewController : UIViewController?, complitionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("\(rideId)")
        let freezeRideUrl = baseServerUrl + freezeRiderRidePath
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[RiderRide.FLD_FREEZE_Ride] = String(freezeRide)
        HttpUtils.putJSONRequestWithBody(url: freezeRideUrl, targetViewController: targetViewController, handler: complitionHandler, body: params)
    }

    public static func updateRideStatus(rideId : Double, status: String, targetViewController : UIViewController?, complitionHandler: @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("updateRideStatus() \(rideId) \(status)")
        let getRiderUrl = baseServerUrl + riderRideStatusServicePath
        var params =  [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_STATUS] = status
        
        HttpUtils.putJSONRequestWithBody(url: getRiderUrl, targetViewController: targetViewController, handler: complitionHandler, body: params)
    }
    
    public static func cancelRide(rideId : Double, userId: Double,cancelReason: String?, isWaveOff: Bool, targetViewController : UIViewController?, complitionHandler: @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("cancelRide() \(rideId) \(userId)")
        let getRiderUrl = baseServerUrl + CANCEL_RIDER_RIDE
        
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params[Ride.FLD_CANCEL_REASON] = cancelReason
        params[Ride.FLD_WAVEOFF] = String(isWaveOff)
        
        HttpUtils.putRequestWithBody(url: getRiderUrl, targetViewController: targetViewController, handler: complitionHandler, body: params)
    }
    
    public static func getAllPassengerRidesForUser(userId : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getAllPassengerRidesForUser() \(userId)")
        let getPassengerRidesForServerUrl = baseServerUrl + getAllPassengerRidesForUser
        var params = [String : String]()
        params[Ride.FLD_USERID] = userId.components(separatedBy: ".")[0]
        HttpUtils.getJSONRequestWithBody(url: getPassengerRidesForServerUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
    }
    
    public static func getAllRiderRidesForUser(userId : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getAllRiderRidesForUser() \(userId)")
        let getRiderRidesForServerUrl = baseServerUrl + getAllRiderRidesForUser
        
        var params = [String : String]()
        params[Ride.FLD_USERID] = userId.components(separatedBy: ".")[0]
        HttpUtils.getJSONRequestWithBody(url: getRiderRidesForServerUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
        
        
    }
    
    public static func getAllParticipantRides(rideId : Double, userId: String?, pickupLat: Double?, pickupLng: Double?, dropLat: Double?, dropLng: Double?, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getAllParticipantRides() \(rideId)")
        let getAllParticipantRidesUrl = baseServerUrl + getAllRideParticipants
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = UserDataCache.getInstance()?.userId ?? ""
        params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLat ?? 0)
        params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLng ?? 0)
        params[Ride.FLD_DROP_LATITUDE] = String(dropLat ?? 0)
        params[Ride.FLD_DROP_LONGITUDE] = String(dropLng ?? 0)
        HttpUtils.getJSONRequestWithBody(url: getAllParticipantRidesUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
    }
    
    public static func getRideParticipant(rideId : String, userId : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getRideParticipant() \(rideId) \(userId)")
        let getRideParticipantUrl = baseServerUrl + getRideParticipant
        var params = [String : String]()
        params[Ride.FLD_ID] = rideId.components(separatedBy: ".")[0]
        params[Ride.FLD_USERID] = userId.components(separatedBy: ".")[0]
        params[Ride.FLD_CALLERUSERID] = UserDataCache.getInstance()?.userId ?? ""
        
        HttpUtils.getJSONRequestWithBody(url: getRideParticipantUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
    }
    public static func rescheduleRiderRide( riderRideId : Double, startTime : Double,ViewController :UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("rescheduleRiderRide() \(riderRideId) \(startTime)" )
        var params : [String : String] = [String : String]()
        
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_STARTTIME] =  AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime))
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + RIDER_RIDE_RESCHEDULE_RESOURCE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: ViewController, handler: completionHandler, body: params)
    }
    public static func updateRideNotes(rideId : Double, rideNotes : String, ViewController :UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_RIDE_NOTES] = rideNotes
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATE_RIDE_STATUS_MESSAGE_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: ViewController, handler: completionHandler, body: params)
    }
    static func updateRiderRide(rideId: Double, startAddress: String, startLatitude: Double, startLongitude: Double, endAddress: String, endLatitude: Double, endLongitude: Double, startTime: Double, vehicleNumber: String,vehicleModel: String,fare: Double, vehicleMakeandCategory: String?,vehicleAdditionalFacilities: String?,riderHasHelmet : Bool, route: RideRoute?,capacity:Int,vehicleType: String,vehicleId: Double,allowRideMatchToJoinedGroups:Bool,showMeToJoinedGroups:Bool,vehicleImageURI: String?,ViewController :UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_STARTADDRESS] = startAddress
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        params[Ride.FLD_ENDADDRESS] = endAddress
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime))
        params[Ride.FLD_VEHICLE_NUMBER] = vehicleNumber
        params[Ride.FLD_VEHICLE_MODEL] = vehicleModel
        params[Ride.FLD_FARE_KM] = String(fare)
        params[Ride.FLD_VEHICLE_MAKE_AND_CATEGORY] = vehicleMakeandCategory
        params[Ride.FLD_VEHICLE_ADDITIONAL_FACILITES] = vehicleAdditionalFacilities
        if route != nil{
            params[Ride.FLD_ROUTE_ID] =  StringUtils.getStringFromDouble(decimalNumber: route!.routeId)
            params[Ride.FLD_ROUTE] =   Mapper().toJSONString(route!)
        }
        params[Ride.FLD_VEHICLE_TYPE] = vehicleType
        params[Ride.FLD_CAPACITY] = String(capacity)
        params[Ride.FLD_VEHICLE_ID] = StringUtils.getStringFromDouble(decimalNumber: vehicleId)
        params[Vehicle.IMAGE_URI] = vehicleImageURI
        params[Ride.FLD_JOINED_GROUP_RESTRICTION] = String(allowRideMatchToJoinedGroups)
        params[Ride.FLD_SHOW_ME_TO_JOINED_GRPS] = String(showMeToJoinedGroups)
        params["riderHasHelmet"] = String(riderHasHelmet)

        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPADATE_RIDER_RIDE
        HttpUtils.putRequestWithBody(url: url, targetViewController: ViewController, handler: completionHandler, body: params)
    }
    
    public static func addMultiplePassengersToRide(riderRideId : Double,rideInviteString : String,  moderatorId: String?, ViewController :UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        
        var params : [String : String] = [String : String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[RideInvitation.RIDE_INVITE_BULK] = rideInviteString
        params[RideInvitation.RIDE_MODERATOR_ID] = moderatorId
         let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath + MULTI_USER_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: ViewController, handler: completionHandler, body: params)
     }
    
    public static func cancelRiderRidesBulk(rideIds : String?, userId: String, targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("cancelRiderRidesBulk() \(String(describing: rideIds)) \(userId)")
        let getRiderUrl = baseServerUrl + RIDER_RIDES_CANCEL_RESOURCE_PATH
        var params = [String : String]()
        params[Ride.FLD_ID] = rideIds
        params[Ride.FLD_USERID] = userId
        
        HttpUtils.putJSONRequestWithBody(url: getRiderUrl, targetViewController: targetViewController, handler: completionHandler, body: params)
    }
    
}
