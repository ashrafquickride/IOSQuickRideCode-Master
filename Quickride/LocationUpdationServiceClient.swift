//
//  LocationUpdationServiceClient.swift
//  Quickride
//
//  Created by KNM Rao on 17/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class LocationUpdationServiceClient{
    
    private static let rideParticipantLocationPath = "QRRideLocation/location"
    private static let rideRiderTraelledPath = "QRRideLocation/ridePath"
    private static let rideLocationPath = "QRRideLocation/rideLocation"
    private static let riderLocationPath = "QRRideLocation/riderLocation"
    private static let disableLocationUpdateReminder = "QRRideengine/disableReminder"
    private static let passengerLocationUpdateRequired = "QRRideLocation/psgrLocUpdateRequired"
    
    
    private static let baseServerUrl: String = AppConfiguration.rideLocationServerUrlIP + AppConfiguration.RL_serverPort + AppConfiguration.rideLocationServerPath
    
    // A generic defination for completion handler closure
    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    
    public static func getRiderCurrentLocation(riderRideId : String, targetViewController : UIViewController? , completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getRideCurrentLocation() \(riderRideId)")
        let getRideCurrentLocationUrl = baseServerUrl + rideLocationPath
        var params : [String : String] = [String : String]()
        params[Ride.FLD_RIDER_RIDE_ID] = riderRideId
        HttpUtils.getJSONRequestWithBodyUnSecure(url: getRideCurrentLocationUrl, targetViewController: targetViewController, params: params, completionHandler: completionHandler)
    }
    public static func getRideTravelledPath(riderRideId : Double,targetViewController : UIViewController?,completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getRideTravelledPath() \(riderRideId)")
        let getRidePathUrl = baseServerUrl + rideRiderTraelledPath
        var params : [String : String] = [String : String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        
        HttpUtils.getJSONRequestWithBodyUnSecure(url: getRidePathUrl, targetViewController: targetViewController,params: params, completionHandler: completionHandler)
    }
    static func updateRideParticipantLocation( rideParticipantLocation : RideParticipantLocation,targetViewController : UIViewController?,completionHandler:  @escaping responseJSONCompletionHandler){
        var params : [String : String] = [String : String]()
        params[RideParticipantLocation.RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: rideParticipantLocation.rideId)
        
        params[RideParticipantLocation.USER_ID] = StringUtils.getStringFromDouble(decimalNumber: rideParticipantLocation.userId)
        params[RideParticipantLocation.LATITUDE] = String(rideParticipantLocation.latitude!)
        params[RideParticipantLocation.LONGITUDE] = String(rideParticipantLocation.longitude!)
        params[RideParticipantLocation.BEARING] = StringUtils.getStringFromDouble(decimalNumber: rideParticipantLocation.bearing)
        params[RideParticipantLocation.SEQUENCE_NO] = String(rideParticipantLocation.sequenceNo)
        if let jsonString = rideParticipantLocation.participantETAInfos?.toJSONString(){
            params[RideParticipantLocation.FLD_PARTICIPANT_ETA_INFO] = jsonString

        }

        let postRideLocationPath = baseServerUrl + rideParticipantLocationPath
        
        HttpUtils.postRequestWithBody(url: postRideLocationPath, targetViewController: targetViewController, handler: completionHandler, body: params)
    }
    static func getRiderParticipantLocation(rideId : Double,targetViewController : UIViewController?,completionHandler: @escaping responseJSONCompletionHandler)
    {
        var params = [String : String]()
        params[RideParticipantLocation.RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        let getRiderCurrentLocationUrl = baseServerUrl + riderLocationPath
        HttpUtils.getJSONRequestWithBodyUnSecure(url: getRiderCurrentLocationUrl, targetViewController: nil, params: params, completionHandler: completionHandler)
    }
    static func getRideParticipantLocations(rideId : Double,targetViewController : UIViewController?,completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[RideParticipantLocation.RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        let getRideParticipantLocationsUrl = baseServerUrl + rideParticipantLocationPath
        
        HttpUtils.getJSONRequestWithBodyUnSecure(url: getRideParticipantLocationsUrl, targetViewController: nil, params: params, completionHandler: completionHandler)
    }
    static func disableLocationUpdateReminderForUser(userId : String,targetViewController : UIViewController?,completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        let disableLocationUpdateReminderURL = AppConfiguration.rideEngineServerUrlIP + AppConfiguration.RE_serverPort + AppConfiguration.rideengineServerPath + disableLocationUpdateReminder
        
        HttpUtils.putJSONRequestWithBody(url: disableLocationUpdateReminderURL, targetViewController: targetViewController, handler: completionHandler, body: params)
    }
    static func getPassegnerLocationUpdateIfRequired(riderRideId : Double,passengerId : Double,completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
        let passengerLocationUpdateRequiredURL = baseServerUrl + passengerLocationUpdateRequired
        HttpUtils.getJSONRequestWithBody(url: passengerLocationUpdateRequiredURL, targetViewController: nil, params: params, handler: completionHandler)
    }
}
