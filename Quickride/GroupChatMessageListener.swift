//
//  GroupChatMessage.swift
//  Quickride
//
//  Created by Anki on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public protocol GroupChatMessageListener {
  
    func newChatMessageRecieved(newMessage : GroupChatMessage)
    func chatMessagesInitializedFromSever()
    func handleException()
  
}
