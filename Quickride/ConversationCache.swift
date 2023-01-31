//
//  ConversationCache.swift
//  Quickride
//
//  Created by QuickRideMac on 07/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
//import AVFoundation


typealias ConversationReceiveHandler = (_ conversation: Conversation) -> Void
typealias PendingMessageRetrievalCompletionHandler = () -> Void

class ConversationCache {
    
    static var  singleInstance : ConversationCache?
    var unreadMessagesCountOfUser = [Double: Int]()
  
    var chatDialogConversationReceiver : [Double : ConversationReceiver] =  [Double : ConversationReceiver]()
    var applicationVersions : [Double : AppVersion] =  [Double : AppVersion]()
    var totalConvers : [Double : Conversation] = [Double : Conversation]()
    var userId : Double?
    static var currentChatUserId : Double?
    
    
    static func getInstance() -> ConversationCache{
        if singleInstance == nil{
            singleInstance = ConversationCache()
          
        }
        return singleInstance!
    }
  init(){
    self.userId = Double(QRSessionManager.getInstance()!.getUserId())
    getAllPendingChatMessages()
  }
    func addParticularConversationListener(number : Double, conversationReceiver : ConversationReceiver){
        AppDelegate.getAppDelegate().log.debug("\(number)")
        if chatDialogConversationReceiver[number] != nil{
            chatDialogConversationReceiver.removeValue(forKey: number)
        }
        chatDialogConversationReceiver[number] = conversationReceiver
    }
    func removeParticularConversationListener(number : Double)
    {
        AppDelegate.getAppDelegate().log.debug("\(number)")
        if chatDialogConversationReceiver[number] != nil{
            chatDialogConversationReceiver.removeValue(forKey: number)
        }
    }
    func updateConversationMessageStatus(conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("Message : \(conversationMessage)")
        updateChatMessageStatusInCache(conversationMessage: conversationMessage)
        updateChatMessageStatusToDialogReceiver(conversationMessage: conversationMessage)
    }
  
  func getAllPendingChatMessages(){
    AppDelegate.getAppDelegate().log.debug("");
    ChatRestClient.getAllPendingChatMessages(destId: userId!) { (responseObject, error) in
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
        let messages = Mapper<ConversationMessage>().mapArray(JSONObject: responseObject!["resultData"])
        if messages != nil && messages!.isEmpty == false{
          for message in messages!{
              if ((Double)(QRSessionManager.getInstance()!.getUserId()) != message.sourceId)
              {
                let messageAckSenderTask  : MessageAckSenderTask = MessageAckSenderTask(conversationMessage: message,status: ConversationMessage.MSG_STATUS_DELIVERED)
                messageAckSenderTask.publishMessage()
              }
              self.receiveNewConversationMessage(conversationMessage: message)
          }
          
        }
      }
    }
  }
  
    func getPendingMessagesOfUser(destId : Double,sourceId : Double,handler : PendingMessageRetrievalCompletionHandler?)
    {
        AppDelegate.getAppDelegate().log.debug("destId: \(destId) sourceId: \(sourceId)")
        ChatRestClient.getPendingConversationMessages(destId: destId, sourceId: sourceId) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let messages = Mapper<ConversationMessage>().mapArray(JSONObject: responseObject!["resultData"])
                if messages != nil && messages?.isEmpty == false{
                    for message in messages!{
                        self.receiveNewConversationMessage(conversationMessage: message)
                    
                    }
                    
                }
            }
            handler?()
        }
    }
    
    func updateChatMessageStatusToDialogReceiver( conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("Message : \(conversationMessage)")
        if (chatDialogConversationReceiver[conversationMessage.destId!]) != nil
        {
            chatDialogConversationReceiver[conversationMessage.destId!]!.receiveConversationMessageStatus(statusMessage: conversationMessage)
        }
        if (chatDialogConversationReceiver[Double(QRSessionManager.getInstance()!.getUserId())!]) != nil
        {
            chatDialogConversationReceiver[Double(QRSessionManager.getInstance()!.getUserId())!]!.receiveConversationMessageStatus(statusMessage: conversationMessage)
        }
    }
    
    func getConversationObject(userBasicInfo : UserBasicInfo) -> Conversation
    {
        AppDelegate.getAppDelegate().log.debug("\(userBasicInfo)")
        var conversation = totalConvers[userBasicInfo.userId!]
        if conversation == nil{
            let conversationMessages = ConversationCachePersistenceHelper.getAllPersonalChatMessagesWithAPerson(phone: userBasicInfo.userId!)
            
            conversation = Conversation(phone: userBasicInfo.userId!, messages: conversationMessages)
            ConversationCache.getInstance().addConversationToCache(conversation: conversation!)
            
        }
        return conversation!
    }
    
    func getLastConversationMessageWithUser(contact : Contact) -> ConversationMessage?
    {
        AppDelegate.getAppDelegate().log.debug("contact : \(contact)")
        let conversation = totalConvers[Double(contact.contactId!)!]
        if conversation == nil
        {
            let conversationMessages = ConversationCachePersistenceHelper.getAllPersonalChatMessagesWithAPerson(phone: Double(contact.contactId!)!)
            
            let conversation = Conversation(phone: Double(contact.contactId!)!, messages: conversationMessages)
            addConversationToCache(conversation: conversation)
            if conversation.messages.count > 0 {
                return conversationMessages[conversationMessages.count-1]
            }else{
                return nil
            }
        }
        else if conversation!.messages.count > 0
        {
            return conversation!.messages[conversation!.messages.count - 1]
        }
        else{
            return nil
        }
    }
    
    func updateChatMessageStatusForAllQualifiedMessages( conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("Message : \(conversationMessage)")
        let conversation = totalConvers[conversationMessage.destId!]
        if conversation != nil
        {
            conversation!.updateAllChatMessagesStatus(status: conversationMessage.msgStatus!)
            ConversationCachePersistenceHelper.updateChatMessageStatus(destId: conversationMessage.destId!, uniqueId: conversationMessage.actualMessageId!, status: conversationMessage.msgStatus!)
            updateChatMessageStatusToDialogReceiver(conversationMessage: conversationMessage)
        }
    }
    func updateConversationStatusInCacheAndPersistance(conversationMessage : ConversationMessage){
        let conversation = totalConvers[conversationMessage.sourceId!]
        if conversation != nil{
            conversation!.updateAllChatMessagesStatus(status: conversationMessage.msgStatus!)
            ConversationCachePersistenceHelper.updateChatMessageStatus(destId: conversationMessage.sourceId!, uniqueId: conversationMessage.actualMessageId!, status: conversationMessage.msgStatus!)
        }
    }
    
    func updateChatMessageStatusInCache( conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("Message : \(conversationMessage)")
        let conversation = totalConvers[conversationMessage.destId!]
        if conversation == nil || conversation?.messages == nil || conversation?.messages.isEmpty == true
        {
            return
        }
        for conversationMessageItr in conversation!.messages
        {
            if conversationMessage.actualMessageId == conversationMessageItr.uniqueID
            {
                if ConversationMessage.MSG_STATUS_READ != conversationMessageItr.msgStatus
                {
                    conversationMessageItr.msgStatus = conversationMessage.msgStatus
                }
                break
            }
        }
    }
    
    
    func getAllConversations() -> [Double : Conversation]
    {
        AppDelegate.getAppDelegate().log.debug("")
        return totalConvers
    }
    
    func handleUserBlockedScenario(blockedUserId : Double)
    {
        AppDelegate.getAppDelegate().log.debug("blockedUserId : \(blockedUserId)")
        ConversationCachePersistenceHelper.removeAllConversationMessages(blockedUserId: blockedUserId);
        totalConvers.removeValue(forKey: blockedUserId)
    }
    
    func handleChatClearScenario(userId : Double) {
        AppDelegate.getAppDelegate().log.debug("userId : \(userId)")
        ConversationCachePersistenceHelper.removeAllConversationMessages(blockedUserId: userId)
        totalConvers.removeValue(forKey: userId)
    }
    func updateConversationMessageStatusAsFailed( conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("Message : \(conversationMessage)")
        let statusMessage = ConversationMessage()
        statusMessage.msgType = ConversationMessage.MSG_TYPE_STATUS
        statusMessage.msgStatus = ConversationMessage.MSG_STATUS_FAILED
        statusMessage.destId = conversationMessage.destId
        statusMessage.actualMessageId = conversationMessage.uniqueID
        updateConversationMessageStatus(conversationMessage: statusMessage);
    }
    
    func addConversationToCache( conversation : Conversation){
        AppDelegate.getAppDelegate().log.debug("Messages: \(conversation.messages)")
        if  totalConvers[conversation.phone!] == nil {
            storeNewContact(userId: conversation.phone!)
        }
        totalConvers[conversation.phone!] = conversation
    }
    
  
    
    func addMessageToConversation( conversationMessage : ConversationMessage) -> (Conversation,Bool)
    {
        AppDelegate.getAppDelegate().log.debug("\(conversationMessage)")
        var messages : [ConversationMessage]
        if let  conversation = totalConvers[conversationMessage.sourceId!]{
            messages = conversation.messages
        }else{
            messages = ConversationCachePersistenceHelper.getAllPersonalChatMessagesWithAPerson(phone: conversationMessage.sourceId!)
        }
        let duplicate = self.isDuplicateMessage(messages: messages,newMessage : conversationMessage)
        if  !duplicate{
            messages.append(conversationMessage)
            ConversationCachePersistenceHelper.addPersonalChatMessage(conversationMessage: conversationMessage, phone: conversationMessage.sourceId!)
        }
        
        let conversation = Conversation(phone: conversationMessage.sourceId!,  messages: messages)
        self.addConversationToCache(conversation: conversation)
        return (conversation,duplicate)
        
    }
    func storeNewContact(userId: Double)
    {
        UserDataCache.getInstance()?.getUserBasicInfo(userId: userId, handler: {(userBasicInfo,responseError,error ) in
            AppDelegate.getAppDelegate().log.debug("storeNewContact userBasicInfo : \(String(describing: userBasicInfo))")
            guard let userBasicInfo = userBasicInfo else { return  }
            let contact = Contact( userId : Double((QRSessionManager.getInstance()?.getUserId())!)!, contactId : StringUtils.getStringFromDouble(decimalNumber: userBasicInfo.userId), contactName : (userBasicInfo.name)!, contactGender : userBasicInfo.gender, contactType : Contact.NEW_USER, imageURI : userBasicInfo.imageURI, supportCall : userBasicInfo.callSupport,contactNo: nil,defaultRole: UserProfile.PREFERRED_ROLE_BOTH)
            UserDataCache.getInstance()?.storeRidePartnerContact(contact: contact)
        })
        
        
    }
    
    func isDuplicateMessage(messages: [ConversationMessage],newMessage : ConversationMessage) -> Bool
    {
        for msg in messages
        {
            if msg.uniqueID == newMessage.uniqueID
            {
                AppDelegate.getAppDelegate().log.debug("\(newMessage) is duplicate Message")
                return true
            }
        }
        return false
    }
    func receiveNewConversationMessage(conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("\(conversationMessage)")
        
        if conversationMessage.message != nil && StringUtils.getStringFromDouble(decimalNumber: conversationMessage.sourceId) != QRSessionManager.sharedInstance?.getUserId() && !MessageUtils.isMessageAllowedToDisplay(message: conversationMessage.message!, latitude: conversationMessage.latitude, longitude: conversationMessage.longitude){
            return
        }
//        let conversationReceiver = self.chatDialogConversationReceiver[Double(QRSessionManager.getInstance()!.getUserId())!]
//        if conversationReceiver != nil{
//            conversationReceiver!.receiveConversationMessage(conversationMessage: conversationMessage)
//        }
        
        if Double(QRSessionManager.getInstance()!.getUserId()) == conversationMessage.sourceId{
            if ConversationMessage.MSG_TYPE_STATUS == conversationMessage.msgType!
            {
                updateChatMessageStatusForAllQualifiedMessages(conversationMessage: conversationMessage)
            }
            return
        }
        
         let conversationData = addMessageToConversation(conversationMessage: conversationMessage)
            let conversationReceiver = self.chatDialogConversationReceiver[conversationMessage.sourceId!]
            if conversationReceiver != nil  && !conversationData.1 {
                conversationReceiver!.receiveConversationMessage(conversationMessage: conversationMessage)
            }
           
            if let currentUserId = ConversationCache.currentChatUserId{
                if currentUserId != conversationMessage.sourceId! {
                    self.putUnreadMessageFlagOfUser(sourceId: conversationMessage.sourceId!)
                }
            }else{
                self.putUnreadMessageFlagOfUser(sourceId: conversationMessage.sourceId!)
            }
            
            self.showConversationMessage(conversationMessage: conversationMessage,conversation: conversationData.0)
            
        
    }
    func showConversationMessage(conversationMessage : ConversationMessage,conversation :Conversation)
    {
        AppDelegate.getAppDelegate().log.debug("\(conversationMessage)")
        
        if let currentChatUserId = ConversationCache.currentChatUserId {
           if currentChatUserId != conversationMessage.sourceId {
                addOfflineNotification(newMessage: conversationMessage)
            }
        }else if !UserDataCache.SUBSCRIPTION_STATUS{
            let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
            viewController.initializeDataBeforePresentingView(ride: nil, userId: conversationMessage.sourceId!,isRideStarted: false, listener: nil)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: viewController, animated: false)
            ConversationCache.currentChatUserId = conversationMessage.sourceId
        }
    }
    func addOfflineNotification(newMessage:ConversationMessage)
    {
        UserDataCache.getInstance()?.getUserBasicInfo(userId: newMessage.sourceId!, handler: { (userBasicInfo,responseError,error) in
            if let userBasicInfo = userBasicInfo {
                AppDelegate.getAppDelegate().log.debug("\(newMessage)")
                let userNotification : UserNotification = UserNotification()
                userNotification.notificationId = Int(NSDate().timeIntervalSince1970)
                
                userNotification.time = NSDate().timeIntervalSince1970
                
                userNotification.title = userBasicInfo.name! + " says..."
                userNotification.description = newMessage.message
                userNotification.type = UserNotification.NOT_TYPE_PERSONAL_CHAT
                userNotification.isActionRequired = true
                userNotification.groupName = UserNotification.NOT_PERSONAL_CHAT
                userNotification.iconUri = userBasicInfo.imageURI
                userNotification.groupValue = StringUtils.getStringFromDouble(decimalNumber : newMessage.sourceId)
                userNotification.uniqueId = NSDate().getTimeStamp()
                userNotification.msgObjectJson = Mapper().toJSONString(userBasicInfo , prettyPrint: true)
                NotificationHandlerFactory.getNotificationHandler(clientNotification: userNotification)?.handleNewUserNotification(clientNotification: userNotification)
            }
        })
        
    }
    func getAppVersion(userId : Double,handler : @escaping AppVersionCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("userId: \(userId)")
        var appVersion = applicationVersions[userId]
        if appVersion == nil{
            ChatRestClient.getAppVersion(userId: userId, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    appVersion = Mapper<AppVersion>().map(JSONObject: responseObject!["resultData"])
                    if appVersion != nil{
                        self.applicationVersions[userId] = appVersion
                        handler(appVersion)
                    }else{
                        handler(appVersion)
                    }
                }
            })
            
        }else{
            handler(appVersion)
        }
    }
    static func clearCacheInstance(){
        AppDelegate.getAppDelegate().log.debug("")
        if singleInstance != nil{
            singleInstance!.totalConvers.removeAll()
            singleInstance = nil
        }
    }
   static func speakTextIfRideStarted(msgText: String){
        let notificationSettings = UserDataCache.getInstance()?.getLoggedInUserNotificationSettings()
        
        if notificationSettings != nil && notificationSettings!.playVoiceForNotifications == true{
//            do {
//                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
//                let speechSynthesizer = AVSpeechSynthesizer()
//                let speechUtterance = AVSpeechUtterance(string: msgText)
//                speechSynthesizer.speak(speechUtterance)
//            } catch {
//                print(error)
//            }
            
        }
    }
    
    func getUnreadMessageCountOfUser(sourceId:Double) ->Int{
        
        var unreadMessageFlag = unreadMessagesCountOfUser[sourceId]
        if unreadMessageFlag == nil {
            unreadMessageFlag = SharedPreferenceHelper.getUnreadMessageCountOfUser(sourceId: sourceId)
        }
        return unreadMessageFlag!
    }
    
    func resetUnreadMessageCountOfUser(sourceId:Double){
        unreadMessagesCountOfUser.removeValue(forKey: sourceId)
        SharedPreferenceHelper.resetUnreadMessageOfUser(sourceId: sourceId)
    }
    
    func putUnreadMessageFlagOfUser(sourceId:Double){
        
        var count  = unreadMessagesCountOfUser[sourceId]
        if count == nil{
            count = 0
        }
        count = count! + 1
        SharedPreferenceHelper.incrementUnreadMessageOfUser(sourceId: sourceId)
        unreadMessagesCountOfUser[sourceId] = count
        
    }
}
protocol ConversationReceiver{
    func receiveConversationMessage(conversationMessage : ConversationMessage)
    func receiveConversationMessageStatus(statusMessage : ConversationMessage)
}

