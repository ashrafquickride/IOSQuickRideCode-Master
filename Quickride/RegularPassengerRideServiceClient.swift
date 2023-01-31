//
//  RegularPassengerRideServiceClient.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RegularPassengerRideServiceClient {
    
    static let REGULAR_PASSENGER_RIDE_RESOURCE_PATH = "QRRegularPassengerRide"
    static let REGULAR_PASSENGER_RIDE_UTC_RESOURCE_PATH = "QRRegularPassengerRide/utc"
    static let REGULAR_PASSENGER_RIDE_UPDATE_SERVICE_PATH = REGULAR_PASSENGER_RIDE_RESOURCE_PATH+"/update/utc"
    static let REGULAR_PASSENGER_RIDE_STATUS_UPDATE_SERVICE_PATH = REGULAR_PASSENGER_RIDE_RESOURCE_PATH+"/status"
    static let REGULAR_PASSENGERS_INFO_SERVICE_PATH = REGULAR_PASSENGER_RIDE_RESOURCE_PATH+"/passengers"
    static let REGULAR_PASSENGER_INFO_SERVICE_PATH = REGULAR_PASSENGER_RIDE_RESOURCE_PATH+"/passenger"
    
    static func createRegularPassengerRide(ride : RegularPassengerRide,passengerRideId :Double, rideRoute : RideRoute?, completionHander : @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("createRegularPassengerRide() \(passengerRideId)")
        var params = ride.getParams()
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber : passengerRideId)
        if rideRoute != nil{
            params[Ride.FLD_ROUTE] =   Mapper().toJSONString(rideRoute!)!
        }
        let createRideUrl = (AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_PASSENGER_RIDE_UTC_RESOURCE_PATH)
        HttpUtils.postJSONRequestWithBody(url: createRideUrl, targetViewController: nil, handler:completionHander,body: params)
    }
    static func getRegularPassengerRide(rideId : Double,completionHander : @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getRegularPassengerRide() \(rideId)")
        let url  = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_PASSENGER_RIDE_RESOURCE_PATH
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : rideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHander)
    }
    static func updateRegularPassengerRide(regularPassengerRide : RegularPassengerRide,rideRoute : RideRoute?,completionHander : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("updateRegularPassengerRide()")
        let url  = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_PASSENGER_RIDE_UPDATE_SERVICE_PATH
        var params = regularPassengerRide.getParams()
        if rideRoute != nil
        {
            params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute!)!
        }
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHander, body: params)
    }
    static func cancelRegularPassengerRide(rideId : Double,completionHander : @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("cancelRegularPassengerRide() \(rideId)")
        let cancelUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_PASSENGER_RIDE_RESOURCE_PATH
        
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : rideId)
        
        
        HttpUtils.deleteJSONRequest(url: cancelUrl,params : params, targetViewController: nil, handler: completionHander)

    }
    static func getPassengersInfoOfRegularRiderRide(regularRiderRideId : Double,completionHander : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getPassengersInfoOfRegularRiderRide() \(regularRiderRideId)")
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_PASSENGERS_INFO_SERVICE_PATH
        var params = [String : String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble (decimalNumber : regularRiderRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHander)
    }
    static func getPassengerInfoOfRegularRiderRide(regularRiderRideId : Double ,userId : Double,completionHander : @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getPassengersInfoOfRegularRiderRide() \(regularRiderRideId)")
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_PASSENGER_INFO_SERVICE_PATH
        var params = [String : String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber : regularRiderRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber : userId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHander)

    }
    static func updateRegularPassengerRideStatus(rideId : Double, status: String, completionHander : @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("updateRegularPassengerRideStatus() \(rideId) \(status)")
        var params = [String: String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : rideId)
    params[Ride.FLD_STATUS] = status
        
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_PASSENGER_RIDE_STATUS_UPDATE_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHander, body: params)
    }
    
}
