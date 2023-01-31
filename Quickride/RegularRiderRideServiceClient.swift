//
//  RegularRiderRideServiceClient.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RegularRiderRideServiceClient{
    
    static let REGULAR_RIDER_RIDE_SERVICE_PATH = "QRRegularRiderRide"
    static let REGULAR_RIDER_RIDE_UTC_SERVICE_PATH = "QRRegularRiderRide/utc"
    static let REGULAR_RIDER_RIDE_INFO_SERVICE_PATH = REGULAR_RIDER_RIDE_SERVICE_PATH+"/riderinfo"
    static let REGULAR_RIDER_RIDE_UPDATE_SERVICE_PATH = REGULAR_RIDER_RIDE_SERVICE_PATH+"/update/utc"
    static let REGULAR_RIDER_RIDE_STATUS_SERVICE_PATH = REGULAR_RIDER_RIDE_SERVICE_PATH+"/status"
    
    
    static func createRegularRiderRide(ride : RegularRiderRide, riderRideId : Double, rideRoute : RideRoute?,handler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("createRegularRiderRide() \(riderRideId)")
        var params = ride.getParams()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        if rideRoute != nil{
            params[Ride.FLD_ROUTE] =   Mapper().toJSONString(rideRoute!)!
        }
        let createRideUrl = (AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_RIDER_RIDE_UTC_SERVICE_PATH)

        HttpUtils.postJSONRequestWithBody(url: createRideUrl, targetViewController: nil, handler:handler,body: params)
    }
    static func updateRegularRiderRide(ride : RegularRiderRide,rideRoute : RideRoute?,handler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("updateRegularRiderRide()")
        let updateRideUrl = (AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_RIDER_RIDE_UPDATE_SERVICE_PATH)
        var params = ride.getParams()
        if rideRoute != nil
        {
            params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute!)!
        }
        HttpUtils.putJSONRequestWithBody(url: updateRideUrl, targetViewController: nil, handler: handler, body: params)
    }
    static func cancelRegularRiderRide(regularRiderRideId : Double,handler :@escaping RiderRideRestClient.responseJSONCompletionHandler ){
        AppDelegate.getAppDelegate().log.debug("cancelRegularRiderRide() \(regularRiderRideId)")
        let cancelUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_RIDER_RIDE_SERVICE_PATH
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: regularRiderRideId)
        
        
      
        HttpUtils.deleteJSONRequest(url: cancelUrl,params:  params, targetViewController: nil, handler: handler)
    }
    static func getRiderInfoOfRegularRiderRide(regularRiderRideId : Double,regularPassengerRideId : Double,handler :@escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getRiderInfoOfRegularRiderRide() \(regularRiderRideId) \(regularPassengerRideId)")

        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_RIDER_RIDE_INFO_SERVICE_PATH
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: regularRiderRideId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: regularPassengerRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    static func updateRegularRiderRideStatus( id : Double, status :  String,handler :@escaping RiderRideRestClient.responseJSONCompletionHandler){
       AppDelegate.getAppDelegate().log.debug("updateRegularRiderRideStatus() \(id) \(status) ")
        var params = [String: String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: id)
    params[Ride.FLD_STATUS] = status
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGULAR_RIDER_RIDE_STATUS_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    
}
