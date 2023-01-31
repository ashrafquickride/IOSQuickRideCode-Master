//
//  RideCompletionClient.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/20/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class RideCompletionClient {
  
  public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  public typealias responseStringCompletionHandler = (_ responseObject: String?, _ error: NSError?) -> Void
 static let riderRideComplete = "QRRiderRide/complete"
 static let passengerRideComplete = "QRPassengerRide/complete"
  
  public static func putRiderCompleteTheRideWithBody(targetViewController: UIViewController?, body : Dictionary<String, String> , completionHandler: @escaping responseJSONCompletionHandler ){
    AppDelegate.getAppDelegate().log.debug("putRiderCompleteTheRideWithBody()")
    let putRiderCompleteTheRideWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + riderRideComplete
     HttpUtils.putRequestWithBody(url: putRiderCompleteTheRideWithBodyUrl, targetViewController: targetViewController, handler: completionHandler, body : body)
  }
  
  public static func putPassengerCompleteTheRideWithBody(targetViewController: UIViewController?, body : Dictionary<String, String> , completionHandler: @escaping responseJSONCompletionHandler ){
    AppDelegate.getAppDelegate().log.debug("putPassengerCompleteTheRideWithBody()")
    let putPassengerCompleteTheRideWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + passengerRideComplete
    HttpUtils.putRequestWithBody(url: putPassengerCompleteTheRideWithBodyUrl, targetViewController: targetViewController, handler: completionHandler, body : body)
  }
  
}
