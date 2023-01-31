//
//  ProfileRestClient.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/14/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class ProfileRestClient {
    
    static let GET_USER_ATTRIBUTE_LIST = "/QRUserAttributePopularity/userAttributeList"
    static let GET_RIDE_ETIQUETTE_CERTIFICATE = "/QRRideEtiquette/get/rideEtiquetteCertification"
    
    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    public typealias responseStringCompletionHandler = (_ responseObject: String?, _ error: NSError?) -> Void
    
    public static func putProfileWithBody(targetViewController: UIViewController?, body : Dictionary<String, String> , completionHandler: @escaping responseJSONCompletionHandler ){
        AppDelegate.getAppDelegate().log.debug("putProfileWithBody(),\(body)")
        let putProfileUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AppConfiguration.userProfile
        HttpUtils.putRequestWithBody(url: putProfileUrl, targetViewController: targetViewController, handler: completionHandler, body : body)
    }
    
    public static func getProfileDetails(userId : String, targetViewController: UIViewController, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getProfileDetails() \(userId)")
        let getTransactionDetailsUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AppConfiguration.userParticipantCompleteProfile
        var params = [String : String]()
        params[Ride.FLD_USERID] = userId
        HttpUtils.getJSONRequestWithBody(url: getTransactionDetailsUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
    }
    
    public static func updateVehicle(params : [String : String], targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("updateVehicle()")
        let updateVehicleUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.updateVehicle
        HttpUtils.putRequestWithBody(url: updateVehicleUrl, targetViewController: targetViewController , handler: completionHandler, body: params)
    }
    
    public static func createVehicle(params : [String : String], targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("createVehicle()")
        let createVehicleUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.vehicle
        HttpUtils.postRequestWithBody(url: createVehicleUrl, targetViewController: targetViewController, handler: completionHandler, body: params)
    }
    
    public static func updateVehicleInsuranceStatus(userId: String?, regNo: String?, status: String?, insuranceType: String, source: String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("updateVehicleInsuranceStatus()")
        let vehicleInsuranceUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.vehicle_insurance_status_update_server_path
        var params = [String : String]()
        params[Ride.FLD_USERID] = userId
        params[Vehicle.FLD_REG_NO] = regNo
        params[Vehicle.FLD_STATUS] = status
        params[Vehicle.FLD_TYPE] = insuranceType
        params[Vehicle.FLD_SOURCE] = source
        HttpUtils.postRequestWithBody(url: vehicleInsuranceUrl, targetViewController: targetViewController, handler: completionHandler, body: params)
    }
    
    static func getUserAttributList(userId: String?, completionController: @escaping responseJSONCompletionHandler){
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_USER_ATTRIBUTE_LIST
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func getRideEtiquetteCertificate(userId : String?, completionHandler: @escaping responseJSONCompletionHandler){
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_RIDE_ETIQUETTE_CERTIFICATE
        var params = [String : String]()
        params[Ride.FLD_USERID] = userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
}
