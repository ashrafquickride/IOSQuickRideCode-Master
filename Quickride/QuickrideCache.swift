//
//  QuickrideCache.swift
//  Quickride
//
//  Created by KNM Rao on 24/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public protocol QuickRideCache{
  
  // New user is created
  func newUserSession()
  
  // Existing user relogged in fresh
  func reInitializeUserSession()
  
  // Logout Session
  func clearUserSession()
  
  //Reopen app, resuse existing logged in user session
  func resumeUserSession()
}
