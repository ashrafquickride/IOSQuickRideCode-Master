//
//  Conversation.swift
//  Quickride
//
//  Created by QuickRideMac on 07/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class Conversation {
    var phone : Double?
    var messages : [ConversationMessage] = [ConversationMessage]()
    init(){
        
    }
    init(phone : Double,messages : [ConversationMessage]){
        self.phone = phone
        self.messages = messages
    }
    init(phone : Double,name: String,messages : [ConversationMessage]){
        self.phone = phone
        self.messages = messages
    }

    func getAllNewStatusMessagesOfOtherPerson() -> Array<ConversationMessage>
    {
        AppDelegate.getAppDelegate().log.debug("")
        var statusPendingMessages : [ConversationMessage] = []
        if !messages.isEmpty == true
        {
            for conversationMessage in messages
            {
                if (ConversationMessage.MSG_STATUS_NEW == conversationMessage.msgStatus && (Double)(QRSessionManager.getInstance()!.getUserId()) != conversationMessage.destId)
                {
                    statusPendingMessages.append(conversationMessage)
                }
            }
        }
        return statusPendingMessages
    }
    
    func updateAllChatMessagesStatus(status : Int)
    {
        AppDelegate.getAppDelegate().log.debug("\(status)")
        if messages.isEmpty == true
        {
            return
        }
        for conversationItr in messages
        {
            if (ConversationMessage.MSG_STATUS_READ != conversationItr.msgStatus)
            {
                conversationItr.msgStatus = status
            }
        }
    }

}
