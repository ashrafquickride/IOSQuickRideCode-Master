//
//  RidesGroupChatCache.swift
//  Quickride
//
//  Created by Anki on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RidesGroupChatCache : RideParticipantsListener {
  
  static var singleCacheInstance : RidesGroupChatCache?
  var groupChatMessage : GroupChatMessage?
  var rideGroupChatMessages = [Double : [GroupChatMessage]]()
  var rideGroupChatListeners = [Double: GroupChatMessageListener]()
  var unreadMessagesFlagsOfRides = [Double: Int]()
  var rideParticipantsListener : RideParticipantsListener?
  var currentlyDisplayingGroupChatViewContrller : GroupChatViewController?
  
  private init(){
    
  }
  
  func clearUserSession(){
    
  }
  
  static func getInstance() -> RidesGroupChatCache?{
    return self.singleCacheInstance
  }
  
  static func createNewInstance(){
    singleCacheInstance = RidesGroupChatCache()
  }
  
  static func clearUserSession(){
    AppDelegate.getAppDelegate().log.debug("")
    if(singleCacheInstance != nil){
      singleCacheInstance?.removeCacheInstance()
    }
  }
  
  func removeCacheInstance(){
    AppDelegate.getAppDelegate().log.debug("")
    RidesGroupChatCache.singleCacheInstance = nil
    rideGroupChatMessages.removeAll()
    rideGroupChatListeners.removeAll()
    unreadMessagesFlagsOfRides.removeAll()
  }
  
  func addMessage(groupChatMessage:GroupChatMessage,rideId :Double){
    AppDelegate.getAppDelegate().log.debug("rideId: \(rideId)")

    var groupChatMessages = rideGroupChatMessages[rideId]
    
    if(groupChatMessages == nil)
    {
        AppDelegate.getAppDelegate().log.debug("No groupchat messages")
        groupChatMessages = [GroupChatMessage]()
    }
    if isDuplicate(messages: groupChatMessages!, newMessage: groupChatMessage){
        AppDelegate.getAppDelegate().log.debug("Duplicate message")
        return
    }
    groupChatMessages!.append(groupChatMessage)
    rideGroupChatMessages[rideId] = groupChatMessages!
  }
  
  func isDuplicate(messages : [GroupChatMessage],newMessage : GroupChatMessage) -> Bool{
    for message in messages{
      if message.uniqueID == newMessage.uniqueID{
        return true
      }
      else if message.rideId == newMessage.rideId && message.chatTime == newMessage.chatTime && message.message == newMessage.message{
        return true
      }
    }
    return false
  }
  
  
  func addAllMessagesOfARide(messages:[GroupChatMessage],rideId:Double){
    AppDelegate.getAppDelegate().log.debug("messages: \(messages) rideId: \(rideId)")
    var chatMessageArray = [GroupChatMessage]()
    for message in messages{
        if StringUtils.getStringFromDouble(decimalNumber : message.phonenumber) != QRSessionManager.sharedInstance!.getUserId() && !MessageUtils.isMessageAllowedToDisplay(message: message.message, latitude: message.latitude, longitude: message.longitude){
            continue
        }
        else{
            chatMessageArray.append(message)
        }
    }
    rideGroupChatMessages[rideId] = chatMessageArray
  }
  
  func getGroupChatMessagesOfARide(rideId:Double) -> [GroupChatMessage]?{
    AppDelegate.getAppDelegate().log.debug("rideId: \(rideId)")
    return rideGroupChatMessages[rideId]
    
  }
    func getGroupChatLastMessageOfRide(rideId:Double) -> GroupChatMessage?{
        return rideGroupChatMessages[rideId]?.last
    }
  
  func deleteChatMessagesOfARide(rideId : Double){
    AppDelegate.getAppDelegate().log.debug("rideId: \(rideId)")
    rideGroupChatMessages.removeValue(forKey: rideId)
  }
  
  func loadAllRideChatMessages(){
    AppDelegate.getAppDelegate().log.debug("")
    
    let activeRiderRides = MyActiveRidesCache.getInstance(userId: QRSessionManager.sharedInstance?.getUserId())!.getActiveRiderRides()
    loadActiveRiderRidesGroupChatMessages(activeRides: activeRiderRides)
    
    let activePassengerRides = MyActiveRidesCache.getInstance(userId: QRSessionManager.sharedInstance?.getUserId())!.getActivePassengerRides()
    loadActivePassengerRidesGroupChatMessages(activeRides: activePassengerRides)
    
    guard let closedRiderRides = MyClosedRidesCache.getClosedRidesCacheInstance().getClosedRiderRides() else { return }
    loadClosedRiderRidesGroupChatMessages(closedRides: closedRiderRides)
    guard let closedPassengerRides = MyClosedRidesCache.getClosedRidesCacheInstance().getClosedPasssengerRides() else { return }
    loadClosedPassengerRidesGroupChatMessages(closedRides: closedPassengerRides)
  }
  
  func loadActiveRiderRidesGroupChatMessages(activeRides : [Double:RiderRide]){
    AppDelegate.getAppDelegate().log.debug("\(activeRides)")
    if activeRides.count != 0{
      for riderRide in activeRides.values{
        if riderRide.noOfPassengers != 0{
            loadGroupChatMessagesOfARide(rideId: riderRide.rideId)
        }
      }
    }
  }
  
  func loadActivePassengerRidesGroupChatMessages(activeRides:[Double:PassengerRide]){
    AppDelegate.getAppDelegate().log.debug("\(activeRides)")
    if(activeRides.count != 0){
      for value in activeRides.values{
        if(value.riderRideId != 0){
          loadGroupChatMessagesOfARide(rideId: value.riderRideId)
        }
      }
    }
  }
    func loadClosedRiderRidesGroupChatMessages(closedRides : [Double:RiderRide]){
      AppDelegate.getAppDelegate().log.debug("\(closedRides)")
      if(closedRides.count != 0){
        for riderRide in closedRides.values{
            let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: riderRide.startTime, time2: NSDate().getTimeStamp())
            if riderRide.noOfPassengers != 0 && (timeDiff/60) <= 24{
              loadGroupChatMessagesOfARide(rideId: riderRide.rideId)
            }
        }
      }
    }
    
    func loadClosedPassengerRidesGroupChatMessages(closedRides:[Double:PassengerRide]){
      AppDelegate.getAppDelegate().log.debug("\(closedRides)")
      if(closedRides.count != 0){
        for passengerRide in closedRides.values{
            let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: passengerRide.startTime, time2: NSDate().getTimeStamp())
          if passengerRide.riderRideId != 0 && (timeDiff/60) <= 24{
            loadGroupChatMessagesOfARide(rideId: passengerRide.riderRideId)
          }
        }
      }
    }
  
  func addRideGroupChatListener(rideId: Double, listener:GroupChatMessageListener){
    AppDelegate.getAppDelegate().log.debug("rideId: \(rideId)")
    self.rideGroupChatListeners[rideId] =  listener
  }
  
    func loadGroupChatMessagesOfARide(rideId:Double){
        AppDelegate.getAppDelegate().log.debug("rideId: \(rideId)")
        let groupChatClient = GroupChatClient()
        groupChatClient.getGroupChatMessagesOfRide(id: String(describing: NSNumber(value:rideId))) {
            (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"]! as! String == "SUCCESS" {
                let groupChatResponseMessages : [GroupChatMessage]
                    = Mapper<GroupChatMessage>().mapArray(JSONObject: responseObject!["resultData"])!
                
                self.receiveGroupChatMessages(messages: groupChatResponseMessages, rideId: rideId)
            }else{
                if let chatMsgListener  = self.rideGroupChatListeners[rideId]{
                    chatMsgListener.handleException()
                }
            }
        }
    }
  
  func removeRideGroupChatListener(rideId:Double){
    AppDelegate.getAppDelegate().log.debug("rideId: \(rideId)")
    rideGroupChatListeners.removeValue(forKey: rideId)
  }

  
  func receivedNewGroupChatMessage(newMessage :GroupChatMessage){
    AppDelegate.getAppDelegate().log.debug("\(newMessage)")
    let rideId:Double = newMessage.rideId
    
    if StringUtils.getStringFromDouble(decimalNumber : newMessage.phonenumber) != QRSessionManager.sharedInstance!.getUserId(){
        if !MessageUtils.isMessageAllowedToDisplay(message: newMessage.message, latitude: newMessage.latitude, longitude: newMessage.longitude){
            return
        }
        addMessage(groupChatMessage: newMessage, rideId: rideId)
        let listener = rideGroupChatListeners[rideId]
        if listener != nil{
            listener!.newChatMessageRecieved(newMessage: newMessage)
        }else{
            putUnreadMessageFlagOfARide(rideId: rideId)
            AppDelegate.getAppDelegate().log.debug("listener is not available()")
            self.groupChatMessage = newMessage
            MyActiveRidesCache.singleCacheInstance?.getRideParicipants(riderRideId: newMessage.rideId, rideParticipantsListener: self)
        }
    }
    
  }
  
  
  func getRideParticipants(rideParticipants : [RideParticipant]){
    AppDelegate.getAppDelegate().log.debug("")
    if self.groupChatMessage == nil{
      return
    }
    for rideParticipant in rideParticipants{
      if(rideParticipant.userId == groupChatMessage!.phonenumber){
        AppDelegate.getAppDelegate().log.debug("ride participant available()")
        let offlineChatMessageNotificationHandler:OfflineChatMessageNotificationHandler = OfflineChatMessageNotificationHandler()
        
        offlineChatMessageNotificationHandler.handleNewUserNotification(clientNotification: getNotificationObjectFromMessage(newMessage: groupChatMessage!, imageURI: rideParticipant.imageURI, gender: rideParticipant.gender))
        self.groupChatMessage = nil
        return
      }
    }
  }
  
  func onFailure(responseObject: NSDictionary?, error: NSError?) {
    
  }
  
  func getNotificationObjectFromMessage(newMessage:GroupChatMessage,imageURI:String?,gender:String?) -> UserNotification{
    AppDelegate.getAppDelegate().log.debug("\(newMessage)")
    let userNotification : UserNotification = UserNotification()
    userNotification.notificationId = Int(newMessage.rideId)
    
    userNotification.time = (newMessage.chatTime)/1000
    AppDelegate.getAppDelegate().log.debug("\(userNotification.time!)")
    userNotification.title = newMessage.userName + " says..."
    userNotification.description = newMessage.message
    userNotification.type = UserNotification.NOT_TYPE_GROUP_CHAT
    userNotification.isActionRequired = true
    userNotification.groupName = UserNotification.NOT_GRP_CHAT
    userNotification.iconUri = imageURI
    userNotification.groupValue = String(newMessage.rideId)
    userNotification.uniqueId = NSDate().getTimeStamp()
    let dynamicData = NotificationDynamicData()
    dynamicData.gender = gender
    dynamicData.id = newMessage.rideId
    userNotification.msgObjectJson = Mapper().toJSONString(dynamicData , prettyPrint: true)!
    
    return userNotification
  }
  
  
    func getUnreadMessageCountOfRide(rideId:Double) -> Int{
        AppDelegate.getAppDelegate().log.debug("\(rideId)")
        if let unreadCount = unreadMessagesFlagsOfRides[rideId]{
            return unreadCount
        }else{
            return SharedPreferenceHelper.getUnreadMessageCountOfARide(rideId: StringUtils.getStringFromDouble(decimalNumber: rideId))
        }
    }
  
  func resetUnreadMessageCountOfARide(rideId:Double){
    AppDelegate.getAppDelegate().log.debug("\(rideId)")
    unreadMessagesFlagsOfRides.removeValue(forKey: rideId)
    SharedPreferenceHelper.resetUnreadMessagesOfRide(rideId: StringUtils.getStringFromDouble(decimalNumber: rideId))
  }
  
  func putUnreadMessageFlagOfARide(rideId:Double){
    AppDelegate.getAppDelegate().log.debug("\(rideId)")
    var count = unreadMessagesFlagsOfRides[rideId]
    if count == nil{
        count = 0
    }
    count = count! + 1
      unreadMessagesFlagsOfRides[rideId] = count
    SharedPreferenceHelper.incrementUnreadMessageCountOfARide(rideId: StringUtils.getStringFromDouble(decimalNumber: rideId))
  }
  
  func receiveGroupChatMessages(messages :[GroupChatMessage],rideId:Double){
    AppDelegate.getAppDelegate().log.debug("\(rideId)")
    addAllMessagesOfARide(messages: messages, rideId: rideId)
    
    let chatMsgListener : GroupChatMessageListener? = rideGroupChatListeners[rideId]
    if(messages.count > 0 && chatMsgListener != nil){
      chatMsgListener!.chatMessagesInitializedFromSever()
    }
  }
  
  func clearLocalMemoryOnSessionInitializationFailure(){
    AppDelegate.getAppDelegate().log.debug("")
    removeCacheInstance()
  }
  
}
enum RidesGroupChatCacheInitializationStatus {
  case Uninitialized
  case InitializationComplete
  case InitializationFailure
  case InitializationStarted
}
