//
//  MessageStatusTracker.swift
//  Quickride
//
//  Created by KNM Rao on 13/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
class MessageStatusTracker : NSObject
{
  static var  singleInstance : MessageStatusTracker?
  var timer : Timer?
  var TIMER_TIME_PERIOD : Double = 15
  static var isTrackingStartedAlready: Bool = false
  
  static func getMessageStatusTrackerInstance() -> MessageStatusTracker
  {
    if singleInstance == nil
    {
      singleInstance = MessageStatusTracker()
    }
    return singleInstance!
  }
  static func cancelStatusTracker()
  {
    AppDelegate.getAppDelegate().log.debug("")
    if isTrackingStartedAlready == true && singleInstance != nil
    {
      singleInstance!.cancelTimer()
    }
    isTrackingStartedAlready = false
    singleInstance = nil
  }
  func cancelTimer()
  {
    AppDelegate.getAppDelegate().log.debug("")
    if timer == nil
    {
      return
    }
    timer!.invalidate()
    timer = nil
  }
  func startStatusTracker()
  {
    AppDelegate.getAppDelegate().log.debug("")
    if MessageStatusTracker.isTrackingStartedAlready
    {
      AppDelegate.getAppDelegate().log.debug("Tracking already started")
      return
    }
    MessageStatusTracker.isTrackingStartedAlready = true
    timer = Timer.scheduledTimer(timeInterval: TIMER_TIME_PERIOD, target: self, selector: #selector(MessageStatusTracker.handleTimer), userInfo: nil, repeats: true)
  }
    
    @objc func handleTimer()
  {
    AppDelegate.getAppDelegate().log.debug("")
    let activeConversations = ConversationCache.getInstance().getAllConversations()
    if activeConversations.isEmpty == true
    {
      AppDelegate.getAppDelegate().log.debug("Conversations are empty")
      MessageStatusTracker.cancelStatusTracker()
      return
    }
    let currentTime = NSDate().timeIntervalSince1970*1000
    var shouldTimerRunAgain = false
    for conv in   activeConversations
    {
      let conversation = conv.1
      let messages : [ConversationMessage] = conversation.getAllNewStatusMessagesOfOtherPerson()
      if messages.isEmpty == true {
        continue
      }
      for conversationMessage in messages
      {
        if ConversationMessage.MSG_STATUS_NEW != conversationMessage.msgStatus!
        {
          continue
        }
        
        if ((currentTime - conversationMessage.time!)/1000 > TIMER_TIME_PERIOD )
        {
          ConversationCache.getInstance().updateConversationMessageStatusAsFailed(conversationMessage: conversationMessage)
        }
        else
        {
          shouldTimerRunAgain = true
        }
      }
    }
    if shouldTimerRunAgain == false
    {
      MessageStatusTracker.cancelStatusTracker()
    }
  }
  
}
