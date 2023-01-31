//
//  LinkedWalletListener.swift
//  Quickride
//
//  Created by Admin on 28/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LinkedWalletListener : TopicListener{
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let linkedWallet = Mapper<LinkedWallet>().map(JSONString: messageObject as! String)! as LinkedWallet
        if linkedWallet.userId != nil && linkedWallet.userId != 0{
            UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet)
            UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet)
        }
        else{
            UserDataCache.getInstance()?.deleteLinkedWallet(linkedWallet: linkedWallet)
            UserCoreDataHelper.deleteLinkedWallet(linkedWallet: linkedWallet)
        }
    }
}
