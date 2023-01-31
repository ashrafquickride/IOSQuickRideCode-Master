//
//  LinkedWalletTransactionStatusListener.swift
//  Quickride
//
//  Created by Vinutha on 15/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LinkedWalletTransactionStatusListener: TopicListener {
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let linkedWalletTransactionStatus = Mapper<LinkedWalletTransactionStatus>().map(JSONString: messageObject as! String)! as LinkedWalletTransactionStatus
        UserDataCache.getInstance()?.notifyLinkedWalletTrasactionUpdatedStatus(linkedWalletTransactionStatus: linkedWalletTransactionStatus)
    }
}
