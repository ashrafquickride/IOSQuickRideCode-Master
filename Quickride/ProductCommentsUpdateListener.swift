//
//  ProductCommentsUpdateListener.swift
//  Quickride
//
//  Created by QR Mac 1 on 18/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ProductCommentsUpdateListener: TopicListener{
    
    override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: messageObject))")
        if let messageObjectString = messageObject as? String, let newComment = Mapper<ProductComment>().map(JSONString: messageObjectString){
            QuickShareCache.getInstance()?.receivedNewProductComment(productComment: newComment)
        }
    }
}
