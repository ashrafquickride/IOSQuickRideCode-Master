//
//  QuickRideErrors.swift
//  Quickride
//
//  Created by KNM Rao on 01/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickRideErrors {
  private static let quickRideDomain = "com.disha.quickride.ios"
  
  // Error codes
  static let RequestTimedOut : Int = -1001 // This error code is from Alamofire when server is not reachable either due to scenarios like low balance in the data pack or server is down or network is slow and request times out
  static let NetworkConnectionNotAvailable : Int = 1001
    static let InternetConnectionNotAvailable : Int = -1004
  static let LocationNotAvailable : Int = -1005
    static let NetworkConnectionSlow = 9209
  // Error messages
  
  
  // NSErrors
  static let RequestTimedOutError  = NSError(domain: quickRideDomain, code: RequestTimedOut, userInfo: nil)
  static let NetworkConnectionNotAvailableError  = NSError(domain: quickRideDomain, code: NetworkConnectionNotAvailable, userInfo: nil)
  static let LocationNotAvailableError = NSError(domain: quickRideDomain, code: LocationNotAvailable, userInfo: nil)
  static let NetworkConnectionSlowError = NSError(domain: quickRideDomain, code: NetworkConnectionSlow, userInfo: nil)
  
  // ResponseErrors
  static let NetworkConnectionNotAvailableResponseError : ResponseError = ResponseError(errorCode: NetworkConnectionNotAvailable, userMessage: Strings.NetworkConnectionNotAvailable_Msg)
  static let RequestTimedOutResponseError : ResponseError = ResponseError(errorCode: RequestTimedOut, userMessage: Strings.RequestTimedOut_Msg)
  static let helmetNotAvailableResponseError = ResponseError(userMessage: Strings.helmet_not_available_msg)
}
