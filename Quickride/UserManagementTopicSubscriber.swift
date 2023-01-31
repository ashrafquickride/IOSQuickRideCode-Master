//
//  UserModuleSessionHandler.swift
//  Quickride
//
//  Created by KNM Rao on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class UserManagementTopicSubscriber {
  
  private static var singleInstance : UserManagementTopicSubscriber?
  private var userMessageTopicListener : UserMessageTopicListener?
  private var conversationListener : ConversationListener?
  
  private init(){
    self.userMessageTopicListener = UserMessageTopicListener()
    self.conversationListener = ConversationListener()
  }
  
  public static func getInstance() -> UserManagementTopicSubscriber?{
    AppDelegate.getAppDelegate().log.debug("getInstance()")
    
    if singleInstance == nil {
      singleInstance = UserManagementTopicSubscriber()
    }
    return singleInstance
  }
  
  public func subscribeToTopics() {
    AppDelegate.getAppDelegate().log.debug("subscribeToTopics()")
    userMessageTopicListener?.subscribeToProfileUpdates()
    conversationListener?.subscribeToConversationTopic()
  }
  
  public func unSubscribeToTopics() {
    AppDelegate.getAppDelegate().log.debug("unSubscribeToTopics()")
    userMessageTopicListener?.unSubscribeToProfileUpdateTopic()
    conversationListener?.unSubscribeToConversationTopic()
  }
}
