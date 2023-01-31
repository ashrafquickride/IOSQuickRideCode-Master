//
//  RefundRequestHandler.swift
//  Quickride
//
//  Created by KNM Rao on 12/08/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias RefundRequestCompletionHandler = ()->Void

class RefundRequestHandler {
  
  var viewController : UIViewController?
  var userId : Double = 0
  var riderId : Double = 0
  var passengerRideId : Double = 0
  var completionHandler : RefundRequestCompletionHandler?
  
  
  init (viewController : UIViewController, userId : Double , passengerRideId : Double,riderId : Double,completionHandler : @escaping RefundRequestCompletionHandler){
    self.viewController = viewController
    self.userId=userId
    self.riderId=riderId
    self.passengerRideId=passengerRideId
    self.completionHandler = completionHandler
  }
  
  func requestRefund(){
    
  }
}
