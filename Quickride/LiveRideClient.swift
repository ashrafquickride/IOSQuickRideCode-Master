//
//  LiveRideClient.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/17/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import Foundation

public class LiveRideClient {
  
  public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  public typealias responseStringCompletionHandler = (_ responseObject: String?, _ error: NSError?) -> Void
  static let riderRide = "QRRiderRide"
  static let passengerRide = "QRPassengerRide"
  static let rideParticipantLocations = "QRRideLocation/location"
  public static func getRiderRide(id : String, targetViewController: UIViewController, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getRiderRide()  \(id)")
    let getRiderRideUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + riderRide
    var params : [String : String] = [String : String]()
    params[Ride.FLD_ID] = id
    HttpUtils.getJSONRequestWithBody(url: getRiderRideUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
    
  }
  
  public static func getPassengerRide(id : String, targetViewController: UIViewController, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getPassengerRide() \(id)")
    let getPassengerRideUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + passengerRide
    var params : [String : String] = [String : String]()
    params[Ride.FLD_ID] = id
      HttpUtils.getJSONRequestWithBody(url: getPassengerRideUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  
  public static func getRideParticipantLocations(riderRideId : String, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getRideParticipantLocations() \(riderRideId)")
    let getRideParticipantLocationsUrl = AppConfiguration.rideLocationServerUrlIP + AppConfiguration.RL_serverPort + AppConfiguration.rideLocationServerPath + rideParticipantLocations
    var params : [String : String] = [String : String]()
    params[Ride.FLD_RIDER_RIDE_ID] = riderRideId
    HttpUtils.getJSONRequestWithBodyUnSecure(url: getRideParticipantLocationsUrl, targetViewController: targetViewController,params : params, completionHandler: completionHandler)
  }
  
    
    
    
}
