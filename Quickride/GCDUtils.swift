//
//  GCDUtils.swift
//  Quickride
//
//  Created by KNM Rao on 24/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class GCDUtils{
  
  static var GlobalMainQueue: DispatchQueue {
    return DispatchQueue.main
  }
  
  static var GlobalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInteractive)
  }
  
  static var GlobalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInitiated)
  }
  
  static var GlobalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: .utility)
  }
  
  static var GlobalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: .background)
    
  }
}
