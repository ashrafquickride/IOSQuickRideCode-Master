//
//  RMQBrokerEventServiceConnection.swift
//  Quickride
//
//  Created by Admin on 26/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Moscapsule

class RMQBrokerEventServiceConnection : EventServiceConnection {
    
    //MARK: Properties
    private var mqttClient : MQTTClient?
    private var mqttConfig : MQTTConfig?
    private var clientId : String?
    private var mqttBrokerUrl : String?
    private var mqttBrokerPort : Int32?
    private var stickySession = false
    private var isConnectionProgress = false
    private let keepAliveConstant : Int32 = 60
    private var mqttCallback : MqttCallback?
    
    //MARK: Initializer
    init(mqttCallback : MqttCallback, clientId : String,mqttBrokerUrl : String,mqttBrokerPort : Int32,stickySession :Bool) {
        self.mqttCallback = mqttCallback
        self.clientId = clientId
        self.mqttBrokerUrl = mqttBrokerUrl
        self.mqttBrokerPort = mqttBrokerPort
        self.stickySession = stickySession
        createMqttConfig()
    }
    
    //MARK: Methods
    func connect () {
        AppDelegate.getAppDelegate().log.debug("connect()")
        if (self.mqttClient != nil && self.mqttClient!.isConnected) || isConnectionProgress {
            return
        }
        isConnectionProgress = true
        self.mqttClient = MQTT.newConnection(self.mqttConfig!, connectImmediately: true)
        
    }
    
    func publishMessage(topicName : String, mqttMessage : String){
        AppDelegate.getAppDelegate().log.debug("publishMessage() \(topicName) \(mqttMessage)")
        
        self.mqttClient?.publish(string: mqttMessage, topic: topicName, qos: 1, retain: false)
    }
    
    func subscribe(topicName : String) {
        AppDelegate.getAppDelegate().log.debug("subscribe() \(topicName)")
        
        self.mqttClient?.subscribe(topicName, qos: 2)
    }
    
    func unSubscribe(topicName : String) {
        AppDelegate.getAppDelegate().log.debug("unSubscribe()  \(topicName)")
        
        self.mqttClient?.unsubscribe(topicName)
    }
    
    private func createMqttConfig(){
        AppDelegate.getAppDelegate().log.debug("createMqttConfig()")
        
        self.mqttConfig = MQTTConfig(clientId: clientId!, host: mqttBrokerUrl! , port: mqttBrokerPort!, keepAlive: keepAliveConstant)
        self.mqttConfig!.cleanSession = stickySession
        self.mqttConfig?.onConnectCallback = {[weak self]
            returnCode in
            self?.isConnectionProgress = false
            if returnCode == ReturnCode.success {
                self?.mqttCallback?.onConnectionSuccessful(message: "RMQ broker")
            }else {
                self?.mqttCallback?.onConnectionFailed(errorMsg: returnCode.description)
            }
        }
        self.mqttConfig!.onPublishCallback = { messageId in
            AppDelegate.getAppDelegate().log.debug("\(messageId)")
        }
        
        self.mqttConfig?.onDisconnectCallback = {[weak self]
            reasonCode in
            if reasonCode == ReasonCode.unknown || reasonCode == ReasonCode.keepAlive_timeout {
                self?.isConnectionProgress = false
                self?.mqttCallback?.onConnectionLost(errorMsg: "RMQBrokerStatus: connection lost")
            }
        }
        
        self.mqttConfig?.onMessageCallback = {[weak self]
            mqttMessage in
            DispatchQueue.main.async(execute: {
                self?.mqttCallback?.onNewMessageArrived(mqttMessage: mqttMessage)
            })
        }
    }
    
    func disconnect(){
        AppDelegate.getAppDelegate().log.debug("disconnect()")
        if self.mqttClient != nil && self.mqttClient?.isConnected == true{
            self.mqttClient?.disconnect()
        }
        self.mqttClient = nil
        isConnectionProgress = false
    }
    
    func isConnected() -> Bool{
        AppDelegate.getAppDelegate().log.debug("isConnected()")
        var isConnected : Bool = false
        if self.mqttClient != nil && self.mqttClient?.isConnected == true{
            isConnected = true
        }
        return isConnected
    }
    func checkConnectionStatusAndReconnectIfRequired() -> Bool {
        AppDelegate.getAppDelegate().log.debug("checkConnectionStatusAndReconnectIfRequired()")
        if self.mqttClient == nil || self.mqttClient?.isConnected == false{
            return false
        }else{
            return true
        }
    }
    
    func checkConnectionStatus() -> Bool {
        AppDelegate.getAppDelegate().log.debug("checkConnectionStatus()")
        if self.mqttClient == nil || self.mqttClient?.isConnected == false{
            return false
        }else{
            return true
        }
    }
    
    func isConnecting() -> Bool {
        return isConnectionProgress
    }
    
    
    
}
