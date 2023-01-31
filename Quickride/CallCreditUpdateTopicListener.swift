//
//  CallCreditUpdateTopicListener.swift
//  Quickride
//
//  Created by QR Mac 1 on 18/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class CallCreditUpdateTopicListener: TopicListener {
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        let callCreditDetials =  Mapper<CallCreditDetails>().map(JSONString: messageObject! as! String)!
        if let userDataCache = UserDataCache.sharedInstance {
            userDataCache.callCreditDetails = callCreditDetials
        }
    }
    
}
