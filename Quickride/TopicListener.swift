//
//  TopicListener.swift
//  Quickride
//
//  Created by KNM Rao on 16/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
public class TopicListener : NSObject {
  
  public func getMessageClassName() -> AnyClass{
    return type(of: self)
  }
  
  public func onMessageRecieved(message : String?, messageObject : Any?){
          AppDelegate.getAppDelegate().log.debug("message : \(String(describing: message))")
  }
}
