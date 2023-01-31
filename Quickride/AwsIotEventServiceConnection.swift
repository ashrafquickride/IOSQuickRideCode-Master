//
//  AwsIotEventServiceConnection.swift
//  Quickride
//
//  Created by Admin on 26/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import AWSIoT
import AWSMobileClient

protocol AwsIotEventServiceConnectionDelegate {
    func messageArrivedFromAWSIot(topic: String,messageData: Data)
}

class AwsIotEventServiceConnection : EventServiceConnection {
    
    //MARK: Properties
    private var cleanSession = false
    private var clientId: String?
    private var awsIotDataManager: AWSIoTDataManager?
    private var mqttCallback : MqttCallback?
    private var delegate: AwsIotEventServiceConnectionDelegate?
    
    static let AWS_IOT_DATA_MANAGER = "AWSIOTDataManager"
    static let AWS_IOT = "AWSIoT"
    
    //MARK: Initializer
    init(cleanSession: Bool,clientId: String?,awsIotDataManager: AWSIoTDataManager?,mqttCallback : MqttCallback?,delegate: AwsIotEventServiceConnectionDelegate?) {
        self.cleanSession = cleanSession
        self.clientId = clientId
        self.awsIotDataManager = awsIotDataManager
        self.mqttCallback = mqttCallback
        self.delegate = delegate
    }
    
    //MARK: Methods
    private func handleMqttCallback(_ status: AWSIoTMQTTStatus ) {
        switch status {
        case .connected: mqttCallback?.onConnectionSuccessful(message: "AWSIOT")
        case .connectionRefused: mqttCallback?.onConnectionFailed(errorMsg: "AWSIOTStatus :- connection failed")
        case .connectionError: mqttCallback?.onConnectionFailed(errorMsg: "AWSIOTStatus :- connection error")
        case .disconnected: mqttCallback?.onConnectionLost(errorMsg: "AWSIOTStatus:- connection lost")
        default: mqttCallback?.onConnectionFailed(errorMsg: "AWSIOTStatus :- connection failed")
        }
    }
    
    func connect() {
        let certificate = Bundle.main.paths(forResourcesOfType: "p12" as String, inDirectory:nil)
        
        if (certificate.count > 0) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: certificate[0])) {
                if AWSIoTManager.importIdentity(fromPKCS12Data: data, passPhrase:"quickride", certificateId:certificate[0]) {
                    self.awsIotDataManager?.connect(withClientId: self.clientId ?? "", cleanSession: cleanSession, certificateId:certificate[0], statusCallback: self.handleMqttCallback)
                }
            }
        }
     }
    
    func disconnect() {
        awsIotDataManager?.disconnect()
    }
    
    func publishMessage(topicName: String, mqttMessage: String) {
        awsIotDataManager?.publishString(mqttMessage, onTopic: topicName, qoS: .messageDeliveryAttemptedAtLeastOnce)
    }
    
    func subscribe(topicName: String) {
        awsIotDataManager?.subscribe(toTopic: topicName, qoS: .messageDeliveryAttemptedAtLeastOnce, messageCallback: { (data) in
            DispatchQueue.main.async(execute: {
                self.delegate?.messageArrivedFromAWSIot(topic: topicName, messageData: data)
            })
        })
    }
    
    func unSubscribe(topicName: String) {
        awsIotDataManager?.unsubscribeTopic(topicName)
    }
    
    func isConnected() -> Bool {
        if let connectionStatus = awsIotDataManager?.getConnectionStatus(),connectionStatus == .connected  {
            return true
        }
        return false
    }
    
    func isConnecting() -> Bool {
        if let connectionStatus = awsIotDataManager?.getConnectionStatus(),connectionStatus == .connecting  {
            return true
        }
        return false
    }
    
    func checkConnectionStatusAndReconnectIfRequired() -> Bool {
       
        if let connectionStatus = awsIotDataManager?.getConnectionStatus(),connectionStatus != .connected  {
            self.connect()
            return false
        } else {
            return true
        }
       
    }
    
    
}


