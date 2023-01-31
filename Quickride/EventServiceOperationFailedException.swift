//
//  EventServiceOperationFailedException.swift
//  Quickride
//
//  Created by KNM Rao on 29/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public enum EventServiceOperationFailedException : Error {
  
  case EventServiceConnectionFailed
  case ClientIdGenerationFailed
  case NetworkConnectionNotAvailable
}
