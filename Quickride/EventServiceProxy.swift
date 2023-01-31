 //
 //  EventServiceProxy.swift
 //  Quickride
 //
 //  Created by KNM Rao on 14/11/15.
 //  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
 //
 
 import Foundation
 import Moscapsule
 import ObjectMapper
 import AWSIoT
 import AWSMobileClient
 
 public class EventServiceProxy : NSObject, MqttCallback,AwsIotEventServiceConnectionDelegate{
    
    
    var eventServiceStatusListener : EventServiceStatusListener?
    var mqttConnection : RMQBrokerEventServiceConnection?
    var iotConnection : AwsIotEventServiceConnection?
    var topicToListenerMap : [String : TopicListener]?
    var pendingTopicToListenerMap : [String : TopicListener]?
    var pendingMessageToPublish = [MQTTMessageAndTopic]()
    var topicToInitialMessagesMap : [String : [String]]? = [String : [String]]()
    var topicToInitialQuickRideMessagesMap : [String : [QuickRideMessageEntity]]? = [String : [QuickRideMessageEntity]]()
    var delayMsgDispatchUntilAllModulesAreInitialized : Bool?
    var holdMsgInInitialMsgCache : Bool = false
    private var awsIotDataManager: AWSIoTDataManager?
    private var rmqBrokerConnectInfo: RmqBrokerConnectInfo?
    let clientIdPrefix : String = "iOS"
    let clientIdSufix : String = AppConfiguration.APP_NAME
    
    let EVENT_BROKER_TYPE_RMQ = "RMQ"
    let EVENT_BROKER_TYPE_IOT = "IOT"
    
    typealias EventCallBackCompletionHandler = (_ mqttMessage: MQTTMessage) -> ()
    
    func createConnection() {
        AppDelegate.getAppDelegate().log.debug("")
        if (QRSessionManager.getInstance() == nil || QRSessionManager.getInstance()?.getUserId() == nil) {
            eventServiceStatusListener?.eventServiceFailed(causeException: EventServiceOperationFailedException.ClientIdGenerationFailed)
            return
        }
        
        var eventBrokerType = getEventBrokerType()
        if eventBrokerType == nil || eventBrokerType!.isEmpty {
            eventBrokerType = EVENT_BROKER_TYPE_RMQ
        }
        
        if eventBrokerType!.caseInsensitiveCompare(EVENT_BROKER_TYPE_IOT) == .orderedSame {
            if let publishMainEventsOnRMQBroker = ConfigurationCache.getInstance()?.mqttDataForApp?.publishMainEventsOnRMQBroker, publishMainEventsOnRMQBroker {
                initializeConnectionToRMQBroker()
            }
            initializeConnectionAwsIotCore()
        } else {
            initializeConnectionToRMQBroker()
        }
    }
    
    private func initializeConnectionToRMQBroker() {
        guard let rmqBrokerConnectInfo = getRmqBrokerConnectInfo(),let brokerURL = rmqBrokerConnectInfo.brokerIp,let brokerPort = rmqBrokerConnectInfo.brokerPort else {
            return
        }
        mqttConnection = RMQBrokerEventServiceConnection(mqttCallback: self, clientId: getClientId(), mqttBrokerUrl: brokerURL, mqttBrokerPort: Int32(brokerPort), stickySession: getCleanSession())
        mqttConnection?.connect()
    }
    
    private func initializeConnectionAwsIotCore() {
        
        guard let awsIotConnectCredentials = getAwsIotConnectCredentials(),let iotCoreEndPoint = awsIotConnectCredentials.iotCoreEndPoint else { return }
        AWSMobileClient.default().initialize { (userState, error) in
            if error != nil {
                AppDelegate.getAppDelegate().log.debug("Failed to Initialize AWSMobileClient. Error : \(error!.localizedDescription)")
                return
            }
        }
        
        let iotEndPointUrlString = "https://"+iotCoreEndPoint
        let iotEndPoint = AWSEndpoint(urlString: iotEndPointUrlString)
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .APSouth1, identityPoolId: AppConfiguration.AWS_IDENTITY_POOL_ID)
        
        let iotConfiguration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialProvider)
        
        // Configuration for AWSIoT data plane APIs
        let iotDataConfiguration = AWSServiceConfiguration(region: .APSouth1,
                                                           endpoint: iotEndPoint,
                                                           credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = iotConfiguration
        
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: AwsIotEventServiceConnection.AWS_IOT_DATA_MANAGER)
        awsIotDataManager = AWSIoTDataManager(forKey: AwsIotEventServiceConnection.AWS_IOT_DATA_MANAGER)
        
        iotConnection = AwsIotEventServiceConnection(cleanSession: getCleanSession(), clientId: getClientId(), awsIotDataManager: awsIotDataManager, mqttCallback: self, delegate: self)
        iotConnection?.connect()
    }
    
    init(eventServiceStatusListener : EventServiceStatusListener?){
        self.eventServiceStatusListener = eventServiceStatusListener
        
        topicToListenerMap = [String : TopicListener]()
        delayMsgDispatchUntilAllModulesAreInitialized = true
        holdMsgInInitialMsgCache = true
    }
    
    func clearInstance(){
        AppDelegate.getAppDelegate().log.debug("")
        if mqttConnection != nil{
            DispatchQueue.main.async(execute: {
                self.mqttConnection?.disconnect()
            })
            
        }
        if iotConnection != nil{
            DispatchQueue.main.async(execute: {
                self.iotConnection?.disconnect()
            })
            
        }
        
        if topicToListenerMap != nil{
            topicToListenerMap?.removeAll()
            topicToListenerMap = nil
        }
        
        if topicToInitialMessagesMap != nil{
            topicToInitialMessagesMap?.removeAll()
        }
        if topicToInitialQuickRideMessagesMap != nil{
            topicToInitialQuickRideMessagesMap?.removeAll()
        }
        if pendingTopicToListenerMap != nil{
            pendingTopicToListenerMap?.removeAll()
            pendingTopicToListenerMap = nil
        }
    }
    
    func onConnectionSuccessful(message: String) {
        AppDelegate.getAppDelegate().log.debug("Connection to \(message) was successful \(NSDate())")
        resubscribeToAlreadySubscribedTopics()
        subscribeToPendingTopics()
        publishPendingMessages()
        eventServiceStatusListener?.eventServiceInitialized()
        eventServiceStatusListener = nil
    }
    func publishPendingMessages(){
        if pendingMessageToPublish.isEmpty{
            return
        }
        let tempArray = [MQTTMessageAndTopic](pendingMessageToPublish)
        pendingMessageToPublish.removeAll()
        for pendingMessage in tempArray {
            publishMessage(topicName: pendingMessage.topic, mqttMessage: pendingMessage.message)
        }
    }
    func resubscribeToAlreadySubscribedTopics(){
        if topicToListenerMap == nil{
            return
        }
        for topic in topicToListenerMap!{
            mqttConnection?.subscribe(topicName: topic.0)
            iotConnection?.subscribe(topicName: topic.0)
        }
    }
    func subscribeToPendingTopics(){
        if pendingTopicToListenerMap != nil && pendingTopicToListenerMap?.isEmpty == false{
            for topic in pendingTopicToListenerMap!{
                subscribe(topicName: topic.0, topicListener: topic.1)
            }
            pendingTopicToListenerMap?.removeAll()
        }
    }
    func onConnectionFailed(errorMsg : String) {
        AppDelegate.getAppDelegate().log.debug("Connection failed due to : \(errorMsg) \(NSDate())")
        eventServiceStatusListener?.eventServiceFailed(causeException: EventServiceOperationFailedException.EventServiceConnectionFailed)
        eventServiceStatusListener = nil
        if let rmqMqttConnection = mqttConnection  {
            rmqMqttConnection.checkConnectionStatusAndReconnectIfRequired()
        }
        if let awsIotConnection = iotConnection {
            awsIotConnection.checkConnectionStatusAndReconnectIfRequired()
        }
    }
    
    func onConnectionLost(errorMsg : String) {
        AppDelegate.getAppDelegate().log.debug("\(errorMsg) \(NSDate())")
        if (eventServiceStatusListener != nil) {
            eventServiceStatusListener?.eventServiceFailed(causeException: EventServiceOperationFailedException.EventServiceConnectionFailed)
            eventServiceStatusListener = nil
        }
        if let rmqMqttConnection = mqttConnection {
            rmqMqttConnection.checkConnectionStatusAndReconnectIfRequired()
        }
        if let awsIotConnection = iotConnection {
            awsIotConnection.checkConnectionStatusAndReconnectIfRequired()
        }
    }
    
    
    func onNewMessageArrived(mqttMessage: MQTTMessage) {
        AppDelegate.getAppDelegate().log.debug("Message arrived from RMQ Broker- Topic : \(mqttMessage.topic), Message : \(String(describing: mqttMessage.payloadString))")
        checkDuplicatesAndDispatchMessage(topic: mqttMessage.topic, message: mqttMessage.payloadString)
    }
    
    func checkDuplicatesAndDispatchMessage(topic: String, message: String?) {
        if topicToListenerMap != nil && !topicToListenerMap!.isEmpty && !isThisTopicSubscribed(topicName: topic) {
            return
        }
        
        if checkForDuplicateAndAddNewMessageToPersistence(payloadString: message) {
            AppDelegate.getAppDelegate().log.debug("duplicate message()")
            return
        }
        if let jsonMsg = message {
            if delayMsgDispatchUntilAllModulesAreInitialized == false {
                dispatchMessageImmediately(topicName: topic, mqttMessage: jsonMsg)
                if holdMsgInInitialMsgCache {
                    addMessageToDelayedDispatchingList(topicName: topic, mqttMessage: jsonMsg)
                }
            }
            else {
                addMessageToDelayedDispatchingList(topicName: topic, mqttMessage: jsonMsg)
            }
        }
    }
    
    func messageArrivedFromAWSIot(topic: String, messageData: Data) {
        guard let message = String(data: messageData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else { return }
        AppDelegate.getAppDelegate().log.debug("Message arrived from IOT Core- Topic : \(topic),Message : \(String(describing: message))")
        checkDuplicatesAndDispatchMessage(topic: topic, message: message)
    }
    
    func jsonDataToDict(jsonData: Data?) -> Dictionary <String, Any> {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData!, options: [])
            let convertedDict = jsonDict as! [String: Any]
            return convertedDict
        } catch {
            return [:]
        }
    }
    
    func isThisTopicSubscribed(topicName : String) -> Bool{
        let listener = topicToListenerMap?[topicName]
        
        if listener != nil {
            return true
        }else{
            return false
        }
    }
    func onNewMessageArrivedFromRemoteNotification(topicName: String,message : Any?) {
        AppDelegate.getAppDelegate().log.debug("Message arrived from APNS- Topic : \(topicName), Message: \(String(describing: message))")
        
        let quickRideEntity = Mapper<QuickRideMessageEntity>().map(JSONString: message as? String ?? "")

        if quickRideEntity != nil && checkForDuplicateAndAddNewMessageToPersistence(message: quickRideEntity!) {
            AppDelegate.getAppDelegate().log.debug("APNS: duplicate message()")
            return
        }
        let listener = topicToListenerMap?[topicName]
        if listener != nil{
            dispatchMessageImmediately(topicName: topicName, message: message)
        }else{
            UserMessageTopicListener().onMessageRecieved(message: topicName, messageObject: message)
        }
    }
    
    func onNewMessageArrivedFromServer(topicName: String,message : QuickRideMessageEntity) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: message.uniqueID))")
        if checkForDuplicateAndAddNewMessageToPersistence(message: message) == true{
            AppDelegate.getAppDelegate().log.debug("duplicate message() \(String(describing: message.uniqueID)))")
            return
        }
        UserMessageTopicListener().onMessageRecieved(message: topicName, messageObject: message.toJSONString() as AnyObject)
    }
    func checkForDuplicateAndAddNewMessageToPersistence(payloadString: String?) -> Bool{
        AppDelegate.getAppDelegate().log.debug("")
        var isDuplicateMsg = false
        if let jsonMsg = payloadString {
            let newMessage = Mapper<QuickRideMessageEntity>().map(JSONString: jsonMsg)
            
            if newMessage != nil && newMessage?.uniqueID != nil {
                isDuplicateMsg = checkWhetherDuplicateId(uniqueID: newMessage!.uniqueID!)
            }
        }
        return isDuplicateMsg
        
    }
    
    func checkWhetherDuplicateId(uniqueID : String) -> Bool {
        let isDuplicateMsg = EventServiceStore.getInstance().isDuplicateMessage(newMessageId: uniqueID)
        if (isDuplicateMsg == false) {
            EventServiceStore.getInstance().addNewMessageID(uniqueID: uniqueID)
        }
        return isDuplicateMsg
    }
    func checkForDuplicateAndAddNewMessageToPersistence( message : QuickRideMessageEntity) -> Bool{
        AppDelegate.getAppDelegate().log.debug("\(String(describing: message.uniqueID))")
        var isDuplicateMsg = false
        if message.uniqueID != nil && message.payloadType == QuickRideMessageEntity.PAYLOAD_FULL{
            isDuplicateMsg = checkWhetherDuplicateId(uniqueID: message.uniqueID!)
        }
        return isDuplicateMsg
    }
    private func dispatchMessageImmediately(topicName : String, mqttMessage : String){
        AppDelegate.getAppDelegate().log.debug("Message: \(String(describing: mqttMessage))")
        let listener = topicToListenerMap?[topicName]
        
        if listener != nil {
            DispatchQueue.main.async(execute: { () -> Void in
                MessageDispatchUtils.dispatchMessageToListeners(topicName: topicName, mqttMessage: mqttMessage, topicListener: listener!)
            })
        }
    }
    private func dispatchMessageImmediately(topicName : String, message : Any?){
        var listener = topicToListenerMap?[topicName]
        if listener == nil{
            listener = pendingTopicToListenerMap?[topicName]
        }
        if listener != nil{
            DispatchQueue.main.async {
                listener!.onMessageRecieved(message: topicName, messageObject: message)
            }
        }
    }
    
    private func addMessageToDelayedDispatchingList(topicName : String, mqttMessage : String){
        AppDelegate.getAppDelegate().log.debug("\(mqttMessage)")
        var initialMsgList = topicToInitialMessagesMap?[topicName]
        if initialMsgList == nil {
            initialMsgList = [String]()
        }
        initialMsgList?.append(mqttMessage)
        topicToInitialMessagesMap![topicName] = initialMsgList
    }
    private func addMessageToDelayedDispatchingList(topicName : String, message : QuickRideMessageEntity){
        AppDelegate.getAppDelegate().log.debug("\(String(describing: message.uniqueID))")
        var initialMsgList : [QuickRideMessageEntity]? = topicToInitialQuickRideMessagesMap?[topicName]
        if initialMsgList == nil {
            initialMsgList = [QuickRideMessageEntity]()
        }
        initialMsgList?.append(message)
        topicToInitialQuickRideMessagesMap![topicName] = initialMsgList
    }
    public func subscribe(topicName : String, topicListener : TopicListener){
        AppDelegate.getAppDelegate().log.debug("\(topicName)")
        if (isTopicAlreadySubscribed(topicName: topicName)) {
            return
        }
        var subscribed = false
        if let rmqMqttConnection = mqttConnection,rmqMqttConnection.checkConnectionStatus() {
            rmqMqttConnection.subscribe(topicName: topicName)
            subscribed = true
        }
        if let awsIotCoreConnection = iotConnection,awsIotCoreConnection.isConnected(){
            awsIotCoreConnection.subscribe(topicName: topicName)
            subscribed = true
        }
        if !subscribed{
            addListenerToPendingMap(topicName: topicName,topicListener: topicListener)
        }else{
            addListenerToLocalMap(topicName: topicName, topicListener: topicListener)
        }
    }
    
    public func publishMessage(topicName : String, mqttMessage : String){
        var eventBrokerType = getEventBrokerType()
        if eventBrokerType == nil || eventBrokerType!.isEmpty {
            eventBrokerType = EVENT_BROKER_TYPE_RMQ
        }
        if eventBrokerType!.caseInsensitiveCompare(EVENT_BROKER_TYPE_IOT) == .orderedSame {
            if let publishMainEventsOnRMQBroker = ConfigurationCache.getInstance()?.mqttDataForApp?.publishMainEventsOnRMQBroker, publishMainEventsOnRMQBroker {
                publishThroghMqtt(topicName: topicName, mqttMessage: mqttMessage)
            }
            publishThroghIOT(topicName: topicName, mqttMessage: mqttMessage)
        } else {
            publishThroghMqtt(topicName: topicName, mqttMessage: mqttMessage)
        }
    }
    
    private func publishThroghMqtt(topicName : String, mqttMessage : String) {
        AppDelegate.getAppDelegate().log.debug("\(mqttMessage)")
        if let rmqMqttConnection = mqttConnection {
            if rmqMqttConnection.checkConnectionStatusAndReconnectIfRequired() == false{
                appendToPendingMessageToPublish(topicName: topicName,mqttMessage: mqttMessage)
            }else{
                mqttConnection?.publishMessage(topicName: topicName, mqttMessage : mqttMessage)
            }
        }
    }
    private func publishThroghIOT(topicName : String, mqttMessage : String) {
        AppDelegate.getAppDelegate().log.debug("\(mqttMessage)")
        if let awsMqttConnection = iotConnection {
            if awsMqttConnection.checkConnectionStatusAndReconnectIfRequired() == false{
                appendToPendingMessageToPublish(topicName: topicName,mqttMessage: mqttMessage)
            }else{
                iotConnection?.publishMessage(topicName: topicName, mqttMessage : mqttMessage)
            }
        }
    }
    func appendToPendingMessageToPublish(topicName : String, mqttMessage : String){
        let message = MQTTMessageAndTopic(topic: topicName, message: mqttMessage)
        pendingMessageToPublish.append(message)
    }
    
    public func unSubscribe(topicName : String, topicListener : TopicListener){
        AppDelegate.getAppDelegate().log.debug("")
        if topicToListenerMap?[topicName] == nil {
            return
        }
        removeListenerFromLocalMap(topicName: topicName, listener: topicListener)
        if topicToListenerMap?[topicName] == nil {
            mqttConnection?.unSubscribe(topicName: topicName)
            iotConnection?.unSubscribe(topicName: topicName)
        }
    }
    func addListenerToPendingMap(topicName : String, topicListener : TopicListener){
        if pendingTopicToListenerMap == nil{
            pendingTopicToListenerMap = [String : TopicListener]()
        }
        pendingTopicToListenerMap![topicName] = topicListener
    }
    
    
    public func removeListenerFromLocalMap(topicName : String, listener : TopicListener){
        AppDelegate.getAppDelegate().log.debug("")
        topicToListenerMap?.removeValue(forKey: topicName)
    }
    
    public func isTopicAlreadySubscribed(topicName : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("")
        if topicToListenerMap == nil{
            return false
        }
        if topicToListenerMap![topicName] != nil {
            return true
        }
        return false
    }
    
    public func addListenerToLocalMap(topicName : String, topicListener : TopicListener){
        AppDelegate.getAppDelegate().log.debug("\(topicName)")
        if topicToListenerMap == nil{
            topicToListenerMap = [String : TopicListener]()
        }
        topicToListenerMap![topicName] = topicListener
        
        dispatchInitialMessagesIfAny(topicName: topicName, topicListener: topicListener)
    }
    
    func getEventBrokerURL() -> String?{
        return nil
    }
    func getEventBrokerPort() -> Int32?{
        return nil
    }
    func getEventBrokerType() -> String? {
        return nil
    }
    func getRmqBrokerConnectInfo() -> RmqBrokerConnectInfo? {
        return nil
    }
    func getAwsIotConnectCredentials() -> AWSIosConnectCredentials? {
        return nil
    }
    func getCleanSession()-> Bool{
        return false
    }
    func getClientId() -> String{
        return clientIdPrefix+QRSessionManager.getInstance()!.getUserId()
    }
    
    public func dispatchAllMessagesArrivedBeforeSessionWasInitialized(){
        AppDelegate.getAppDelegate().log.debug("")
        delayMsgDispatchUntilAllModulesAreInitialized = false
        
        GCDUtils.GlobalUserInitiatedQueue.async(execute: { () -> Void in
            var topic : String?
            var listener : TopicListener?
            var initialMessageList : [String]?
            
            for topicName in (self.topicToInitialMessagesMap?.keys)! {
                topic = topicName
                initialMessageList = self.topicToInitialMessagesMap![topic!]
                listener = self.topicToListenerMap?[topic!]
                if listener != nil {
                    for mqttMessage in initialMessageList! {
                        MessageDispatchUtils.dispatchMessageToListeners(topicName: topic!, mqttMessage: mqttMessage, topicListener: listener!)
                    }
                }
            }
            var messagesList : [QuickRideMessageEntity]?
            for topicName in (self.topicToInitialQuickRideMessagesMap?.keys)! {
                topic = topicName
                messagesList = self.topicToInitialQuickRideMessagesMap![topic!]
                listener = self.topicToListenerMap?[topic!]
                if listener != nil {
                    for message in messagesList! {
                        DispatchQueue.main.async(execute: { () -> Void in
                            listener!.onMessageRecieved(message: topicName, messageObject: message.toJSONString() as AnyObject)
                        })
                    }
                }
            }
            
            let delay = AppConfiguration.waitTimeBeforeClearingInitialMessagesInEventService
            DispatchQueue.main.asyncAfter(deadline: .now()+delay , execute: {
                self.clearInitialMsgCache()
            })
        })
    }
    
    private func dispatchInitialMessagesIfAny(topicName : String, topicListener : TopicListener) {
        AppDelegate.getAppDelegate().log.debug("\(topicName)")
        let initialMessageList = topicToInitialMessagesMap![topicName]
        if (initialMessageList != nil) {
            for mqttMessage in initialMessageList! {
                MessageDispatchUtils.dispatchMessageToListeners(topicName: topicName, mqttMessage: mqttMessage, topicListener: topicListener)
            }
        }
        let messageList = topicToInitialQuickRideMessagesMap![topicName]
        if (messageList != nil) {
            let listenerList = [topicListener]
            for message in messageList! {
                for topicListener in listenerList{
                    DispatchQueue.main.async(execute: { () -> Void in
                        topicListener.onMessageRecieved(message: topicName, messageObject: message.toJSONString() as AnyObject)
                    })
                }
            }
        }
    }
    
    private func clearInitialMsgCache() {
        AppDelegate.getAppDelegate().log.debug("")
        holdMsgInInitialMsgCache = false
        
        topicToInitialMessagesMap?.removeAll()
        topicToInitialQuickRideMessagesMap?.removeAll()
    }
    
    public func clearLocalMemoryOnSessionInitializationFailure() {
        clearInstance()
    }
    
    class MQTTMessageAndTopic {
        var topic : String
        var message : String
        init(topic : String,message : String){
            self.topic = topic
            self.message = message
        }
    }
 }
