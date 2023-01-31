//
//  ChatRestClient.swift
//  Quickride
//
//  Created by QuickRideMac on 02/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ChatRestClient {
  
  typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  static let SEND_GROUP_CHAT_MESSAGES_VIA_GCM_SERVICE_PATH = "/QRGroupchat/sendViaDeviceNotification"
  static let PERSONAL_CHAT_MESSAGES_SENDING_SERVICE_PATH = "/QRConversation/conversationDeviceNotification"
  static let PENDING_CHAT_MESSAGES_SERVICE_PATH = "/QRConversation/pendingMessages"
  static let ALL_PENDING_CHAT_MESSAGES_SERVICE_PATH = "/QRConversation/allpendingMessages"
  static let USER_APP_VERSION_GETTING_SERVICE_PATH = "/QRUser/appversions"
  static let CONVERSATION_MESSAGES_ACK_SENDING_SERVICE_PATH = "/QRConversation/conversationDeviceNotification/ack"
  static let CONVERSATION_MESSAGES_SENDING_SERVICE_PATH = "/QRConversation/conversationDeviceNotification"
    
    static let communicationServerUrl = AppConfiguration.communicationServerUrlIP+AppConfiguration.CM_serverPort+AppConfiguration.communicationServerPath
  
  static func sendGroupChatMessageToOtherParticipantsViaGcm(chatMsg : GroupChatMessage, viewController : UIViewController?, handler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("\(chatMsg)")
    let url = communicationServerUrl + SEND_GROUP_CHAT_MESSAGES_VIA_GCM_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: chatMsg.getParams())
  }
  
  static func sendPersonalChatMessageViaGCM(conversationMessage : ConversationMessage, phone : String, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("\(phone)")
    var params = conversationMessage.getParams()
    let url = communicationServerUrl + PERSONAL_CHAT_MESSAGES_SENDING_SERVICE_PATH
    params[User.FLD_PHONE] =    phone
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
  }
  static func getPendingConversationMessages(destId : Double,sourceId : Double,handler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("\(destId) \(sourceId)")
    var params = [String:String]()
    params["sourceId"] = StringUtils.getStringFromDouble(decimalNumber: sourceId)
    params["destId"] =  StringUtils.getStringFromDouble(decimalNumber: destId)
    let url = communicationServerUrl + PENDING_CHAT_MESSAGES_SERVICE_PATH
    HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
  }
  static func getAllPendingChatMessages(destId : Double, handler : @escaping responseJSONCompletionHandler){
    var params = [String :String]()
    params[ConversationMessage.DEST_ID] = StringUtils.getStringFromDouble(decimalNumber:destId)
    let url = communicationServerUrl + ALL_PENDING_CHAT_MESSAGES_SERVICE_PATH
    HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
  }
  static func getAppVersion( userId : Double, handler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("\(userId)")
    var params = [String : String]()
    params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber: userId)
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + USER_APP_VERSION_GETTING_SERVICE_PATH
    HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    
  }
  
  static func notifyConversationMessageAckToServer(conversationMessage : ConversationMessage, phone : String, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler)
  {
    AppDelegate.getAppDelegate().log.debug("\(conversationMessage)")
    var params = conversationMessage.getParams()
    
    if conversationMessage.uniqueID != nil{
      params[QuickRideMessageEntity.UNIQUE_ID] = conversationMessage.uniqueID!
    }
    let url = communicationServerUrl + CONVERSATION_MESSAGES_ACK_SENDING_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
  }
  
  static func notifyConversationMessageToServer(conversationMessage : ConversationMessage, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler)
  {
    AppDelegate.getAppDelegate().log.debug("\(conversationMessage)")
    var params = conversationMessage.getParams()
    
    if conversationMessage.uniqueID != nil{
      params[QuickRideMessageEntity.UNIQUE_ID] = conversationMessage.uniqueID!
    }
    let url = communicationServerUrl + CONVERSATION_MESSAGES_SENDING_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
  }
}
