//
//  ModuleSessionProtocol.swift
//  Quickride
//
//  Created by KNM Rao on 07/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public protocol ModuleSessionChangeActionStatusListener {
  
  func sessionChangeActionForModuleComplete(moduleName : String)
  func sessionChangeActionForModuleFailed(moduleName : String, exceptionCause : SessionManagerOperationFailedException?)
  
}

public protocol UserDataCacheInitializationStatusListener {
  
  func initializationSuccess()
  func initializationFailure(exceptionCause : SessionManagerOperationFailedException?)
  
}

public protocol SessionChangeCompletionListener {
  
  func sessionChangeOperationCompleted()
  func sessionChangeOperationFailed(exceptionCause : SessionManagerOperationFailedException?)
  
}

