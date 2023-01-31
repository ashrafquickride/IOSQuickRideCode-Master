//
//  UserMessageTopicListener.swift
//  Quickride
//
//  Created by KNM Rao on 21/10/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class UserMessageTopicListener: TopicListener {
    
    static let USER_MSG_TOPIC = "userMsg/"
    override func getMessageClassName() -> AnyClass {
        return type(of: self)
    }
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved() \(String(describing: messageObject))")
        if let quickRideEntity = Mapper<QuickRideMessageEntity>().map(JSONString: messageObject as! String) {
            CommunicationRestClient.updateEventStatus(uniqueId: quickRideEntity.uniqueID!, sendTo : QRSessionManager.getInstance()!.getUserId(), viewController: nil) { (responseObject, error) in
                
            }
            if let uniqueId = quickRideEntity.uniqueID, quickRideEntity.payloadType == QuickRideMessageEntity.PAYLOAD_PARTIAL {
                getEventUpdateAndContinue(uniqueId: uniqueId)
            } else {
                TopicListenerFactory.getTopicListener(type: quickRideEntity.msgObjType)?.onMessageRecieved(message: message, messageObject: messageObject)
            }
        }
    }
    
    private func getEventUpdateAndContinue(uniqueId: String){
        AppDelegate.getAppDelegate().log.debug("getEventUpdateAndContinue()")
        CommunicationRestClient.getEventUpdateForRefId(uniqueId: uniqueId, viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let eventUpdate = Mapper<EventUpdate>().map(JSONObject: responseObject!["resultData"]), let topicName = eventUpdate.topic, let eventObjectJson = eventUpdate.eventObjectJson {
                    EventServiceProxyFactory.getEventServiceProxy(topicName: topicName)?.onNewMessageArrivedFromRemoteNotification(topicName: topicName, message: eventObjectJson)
                }
            } else {
                AppDelegate.getAppDelegate().log.debug("failed to get event update(): \(String(describing: error))")
            }
        }
    }
    func subscribeToProfileUpdates(){
        AppDelegate.getAppDelegate().log.debug("subscribeToProfileUpdates()")
        let userId = QRSessionManager.sharedInstance?.getUserId()
        let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : UserMessageTopicListener.USER_MSG_TOPIC + userId!)
        EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.subscribe(topicName: topic, topicListener: self)
    }
    static func getTopicName() -> String{
        let userId = QRSessionManager.sharedInstance?.getUserId()
        return TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : UserMessageTopicListener.USER_MSG_TOPIC + userId!)
    }
    
    func unSubscribeToProfileUpdateTopic(){
        AppDelegate.getAppDelegate().log.debug("unSubscribeToProfileUpdateTopic()")
        let userId = QRSessionManager.sharedInstance?.getUserId()
        let topic = UserMessageTopicListener.USER_MSG_TOPIC + userId!
        
        EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.unSubscribe(topicName: topic, topicListener: self)
    }
}
