//
//  SessionManagerOperationFailedException.swift
//  Quickride
//
//  Created by KNM Rao on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public enum SessionManagerOperationFailedException : Error {
  case UserSessionNotFound
  case SessionChangeOperationFailed
  case NetworkConnectionNotAvailable
  case InvalidUserSession
  case CouldNotValidateUserSession
  case SessionChangeOperationTimedOut
}
