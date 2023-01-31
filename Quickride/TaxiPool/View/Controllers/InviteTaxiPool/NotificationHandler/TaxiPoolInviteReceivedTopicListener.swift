//
//  TaxiPoolInviteReceivedTopicListener.swift
//  Quickride
//
//  Created by Ashutos on 9/16/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiPoolInviteReceivedTopicListener: TopicListener {
    
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
    AppDelegate.getAppDelegate().log.debug("\(String(describing: messageObject))")
        _ = Mapper<TaxiInviteEntity>().map(JSONString: messageObject as! String)
        TaxiPoolInvitationCache.getInstance().invitationReceived()
    }
}



