//
//  BlockedUserStatusListener.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 07/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class BlockedUserStatusListener: TopicListener {
    
    
     override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let blockedUserStatus : BlockedUserStatus = Mapper<BlockedUserStatus>().map(JSONString: messageObject as! String)! as BlockedUserStatus
        if blockedUserStatus.blocked == true
        {
            UserDataCache.getInstance()?.removeRidePartners(contactId: String(describing: blockedUserStatus.userId))
        }
        else
        {
            if(blockedUserStatus.contact != nil)
            {
                UserDataCache.getInstance()?.storeRidePartnerContact(contact: blockedUserStatus.contact!)
            }
        }
    }

}
