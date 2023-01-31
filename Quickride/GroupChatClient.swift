//
//  GroupChatClient.swift
//  Quickride
//
//  Created by Anki on 22/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class GroupChatClient {
  
  public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  public typealias responseStringCompletionHandler = (_ responseObject: String?, _ error: NSError?) -> Void
  static let groupChat = "QRGroupchat"
  public func getGroupChatMessagesOfRide(id : String, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getGroupChatMessagesOfRide() \(id)")
    let getGroupChatMessagesOfRideUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GroupChatClient.groupChat
    var params = [String : String]()
    params[Ride.FLD_ID] = id
    let rootViewController = UIApplication.shared.keyWindow?.rootViewController
    HttpUtils.getJSONRequestWithBody(url: getGroupChatMessagesOfRideUrl, targetViewController: rootViewController, params: params, handler: completionHandler)
  }
  
}
