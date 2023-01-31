//
//  UserGroupChatCache.swift
//  Quickride
//
//  Created by QuickRideMac on 3/19/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol GroupConversationListener {
    func newChatMessageRecieved(newMessage : GroupConversationMessage)
}

class UserGroupChatCache {
    static var singleCacheInstance : UserGroupChatCache?
    var groupConvesationMessages = [Double : [GroupConversationMessage]]()
    var groupConversationListeners = [Double: GroupConversationListener]()
    var unreadMessagesCountForGroups = [Double: Int]()
    
    
    static func getInstance() -> UserGroupChatCache?{
        if singleCacheInstance == nil{
          createNewInstance()
        }
        return self.singleCacheInstance
    }
    
    init(){
        
    }
    
    static func createNewInstance(){
        singleCacheInstance = UserGroupChatCache()
        let groups = UserDataCache.getInstance()?.joinedGroups
        if (groups == nil){
            return
        }
        for group in groups!{
            if(group.currentUserStatus != GroupMember.MEMBER_STATUS_CONFIRMED){
                continue
            }
            GroupConversationMessageMQTTListener().subscribeToGroup(groupId: group.id)
            CoreDataHelper.getNSMangedObjectContext().perform {
                singleCacheInstance?.getMessagesFromServer(groupId : group.id)
            }
            
        }
    }
    func getMessagesFromServer(groupId : Double){
        let messages = getMessagesOfAGroup(groupId: groupId)
        var lastMessageTime : Double?
        if !messages.isEmpty{
            lastMessageTime = messages.last?.time
        }
        GroupRestClient.getGroupConversationMessages(groupId: groupId, lastMessageTime: lastMessageTime, viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let messages = Mapper<GroupConversationMessage>().mapArray(JSONObject: responseObject!["resultData"])
                if messages != nil && !messages!.isEmpty{
                    for message in messages!{
                        if StringUtils.getStringFromDouble(decimalNumber : message.senderId) != QRSessionManager.sharedInstance!.getUserId() && !MessageUtils.isMessageAllowedToDisplay(message: message.message!, latitude: 0, longitude: 0){
                            continue
                        }
                        else{
                            let isMessageAdded = self.addMessage(message: message)
                            if isMessageAdded{
                                self.putUnreadMessageFlagOfAGroup(groupId: groupId)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addMessage(message:GroupConversationMessage) -> Bool{
        var messages = groupConvesationMessages[message.groupId]
        
        if messages == nil
        {
            messages = [GroupConversationMessage]()
        }
        if isDuplicate(messages: messages!, newMessage: message){
            AppDelegate.getAppDelegate().log.debug("Duplicate message")
            return false
        }
        messages!.append(message)
        groupConvesationMessages[message.groupId] = messages!
        UserGroupChatCoreDataHelper.addGroupConversationMessage(message: message)
        return true
        
    }
    
    func isDuplicate(messages : [GroupConversationMessage],newMessage : GroupConversationMessage) -> Bool{
        for message in messages{
            if message.uniqueID == newMessage.uniqueID || (message.message == newMessage.message && message.time == newMessage.time){
                return true
            }
            
        }
        return false
    }
    
    func getMessagesOfAGroup(groupId:Double) -> [GroupConversationMessage]{
        var messages = groupConvesationMessages[groupId]
        if messages == nil{
                messages = UserGroupChatCoreDataHelper.getChatMessagesForGroup(groupId: groupId)
        }
        if messages == nil{
            messages = [GroupConversationMessage]()
        }
        
        messages!.sort(by: { $0.time < $1.time})
        groupConvesationMessages[groupId] = messages
        return messages!
    }
    func getLastMessageOfGroup(groupId : Double) -> GroupConversationMessage?{
        let messages = getMessagesOfAGroup(groupId : groupId)
        if (messages.isEmpty){
            return nil
        }
        return messages.last
    }
    func newGroupAdded(group : Group) {
        GroupConversationMessageMQTTListener().subscribeToGroup(groupId: group.id)
    }
    
    func receiveNewMessage(newMessage :GroupConversationMessage){
   
        let group = UserDataCache.getInstance()?.getGroupWithGroupId(groupId: newMessage.groupId)
        if group == nil{
            return
        }
        if StringUtils.getStringFromDouble(decimalNumber : newMessage.senderId) != QRSessionManager.sharedInstance!.getUserId(){
            if !MessageUtils.isMessageAllowedToDisplay(message: newMessage.message!, latitude: 0, longitude: 0){
                return
            }
            let isMessageAdded = addMessage(message: newMessage)
            if isMessageAdded{
                let listener = groupConversationListeners[newMessage.groupId]
                if listener != nil{
                    listener!.newChatMessageRecieved(newMessage: newMessage )
                }else{
                    putUnreadMessageFlagOfAGroup(groupId: newMessage.groupId)
                    let handler  = OfflineGroupConversationMessageNotificationHandler()
                    handler.handleNewUserNotification(clientNotification: getNotificationObjectFromMessage(newMessage: newMessage, group: group!))
                }
            }
            
        }
        
    }
    
    func getNotificationObjectFromMessage(newMessage:GroupConversationMessage,group:Group) -> UserNotification{
        let userNotification = UserNotification()
        userNotification.notificationId = Int(newMessage.groupId)
        userNotification.time = (newMessage.time)/1000
        userNotification.title = newMessage.senderName!+"@"+group.name!
        userNotification.description = newMessage.message
        userNotification.type = UserNotification.NOT_TYPE_USER_GROUP_CHAT
        userNotification.isActionRequired = true
        userNotification.groupName = UserNotification.NOT_USER_GRP_CHAT
        userNotification.iconUri = group.imageURI
        userNotification.groupValue = String(newMessage.groupId)
        userNotification.uniqueId = NSDate().getTimeStamp()
        userNotification.msgObjectJson = Mapper().toJSONString(newMessage , prettyPrint: true)!
        
        return userNotification
    }
    
    func addUserGroupChatListener(groupId : Double, listener : GroupConversationListener){
        groupConversationListeners[groupId] = listener
    }
    
    func removeUserGroupChatListener(groupId : Double){
        groupConversationListeners.removeValue(forKey: groupId)
    }
    
    func getUnreadMessageCountOfGroup(groupId:Double) ->Int{
        
        var unreadMessageFlag = unreadMessagesCountForGroups[groupId]
        if unreadMessageFlag == nil {
            unreadMessageFlag = SharedPreferenceHelper.getUnreadMessageCountOfGroup(groupId: groupId)
        }
        return unreadMessageFlag!
    }
    
    func resetUnreadMessageOfGroup(groupId:Double){
        unreadMessagesCountForGroups.removeValue(forKey: groupId)
        SharedPreferenceHelper.resetUnreadMessageForUserGroup(groupId:groupId)
    }
    
    func putUnreadMessageFlagOfAGroup(groupId:Double){
        var count  = unreadMessagesCountForGroups[groupId]
        if count == nil{
            count = 0
        }
        count = count! + 1
        SharedPreferenceHelper.incrementUnreadMessageForUserGroup(groupId:groupId)
        unreadMessagesCountForGroups[groupId] = count
    }
    
    
    func deleteChatMessagesOfGroup(groupId : Double){
        
        groupConvesationMessages.removeValue(forKey: groupId)
        UserGroupChatCoreDataHelper.deleteChatMessagesOfGroup(groupId: groupId)
        resetUnreadMessageOfGroup(groupId: groupId)
        GroupConversationMessageMQTTListener().unSubscribeToGroup(groupId: groupId)
    }
    
    static func clearUserSession(){
        UserGroupChatCoreDataHelper.clearData()
        singleCacheInstance?.removeCacheInstance()
    }
    func removeCacheInstance() {
        
        groupConvesationMessages.removeAll()
        groupConversationListeners.removeAll()
        unreadMessagesCountForGroups.removeAll()
        UserGroupChatCache.singleCacheInstance = nil
        
    }

    func clearLocalMemoryOnSessionInitializationFailure(){
        AppDelegate.getAppDelegate().log.debug("")
        removeCacheInstance()
    }
    
}
