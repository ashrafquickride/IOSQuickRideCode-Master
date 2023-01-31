//
//  EventServiceConnection.swift
//  Quickride
//
//  Created by KNM Rao on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Moscapsule

protocol MqttCallback {
  func onConnectionSuccessful(message: String)
  func onConnectionFailed(errorMsg : String)
  func onConnectionLost(errorMsg: String)
  func onNewMessageArrived(mqttMessage: MQTTMessage)
}

protocol EventServiceConnection {
    func connect()
    func disconnect()
    func publishMessage(topicName : String, mqttMessage : String)
    func subscribe(topicName : String)
    func unSubscribe(topicName : String)
    func isConnected() -> Bool
    func isConnecting() -> Bool
}
