//
//  EventServiceStatusListener.swift
//  Quickride
//
//  Created by KNM Rao on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public protocol EventServiceStatusListener {
  
  func eventServiceInitialized()
  func eventServiceFailed(causeException : EventServiceOperationFailedException?)
  
}
