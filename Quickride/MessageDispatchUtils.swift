//
//  MessageDispatchUtils.swift
//  Quickride
//
//  Created by KNM Rao on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Moscapsule
import ObjectMapper

public class MessageDispatchUtils {
  
    public static func dispatchMessageToListeners(topicName : String, mqttMessage : String, topicListener : TopicListener){
        AppDelegate.getAppDelegate().log.debug("dispatchMessageToListeners() \(topicName) \(String(describing: mqttMessage))")
        DispatchQueue.main.async(execute: { () -> Void in
            topicListener.onMessageRecieved(message: topicName, messageObject: mqttMessage)
        })
    }
}
