//
//  RideBeginClient.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/20/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class RideBeginClient {
  
  public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  public typealias responseStringCompletionHandler = (_ responseObject: String?, _ error: NSError?) -> Void
  static let riderRideStart = "QRRiderRide/status"
  static let passengerRideCheckIn = "QRPassengerRide/status"
  public static func putRiderStartTheRideWithBody(targetViewController: UIViewController?, body : Dictionary<String, String> , completionHandler: @escaping responseJSONCompletionHandler ){
    AppDelegate.getAppDelegate().log.debug("putRiderStartTheRideWithBody()")
    let putRiderStartTheRideWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + riderRideStart
    HttpUtils.putRequestWithBody(url: putRiderStartTheRideWithBodyUrl, targetViewController: targetViewController, handler: completionHandler, body : body)
  }
  
  public static func putPassengerCheckInTheRideWithBody(targetViewController: UIViewController?, body : Dictionary<String, String> , completionHandler: @escaping responseJSONCompletionHandler ){
    AppDelegate.getAppDelegate().log.debug("putPassengerCheckInTheRideWithBody()")
    let putPassengerCheckInTheRideWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + passengerRideCheckIn
    HttpUtils.putRequestWithBody(url: putPassengerCheckInTheRideWithBodyUrl, targetViewController: targetViewController, handler: completionHandler, body : body)
  }
  
}
