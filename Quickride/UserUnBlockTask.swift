//
//  UserUnBlockTask.swift
//  Quickride
//
//  Created by QuickRideMac on 1/7/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol UserUnBlockReceiver
{
  func userUnBlocked()
}

class UserUnBlockTask
{
  static func unBlockUser(phoneNumber : Double,viewController : UIViewController, receiver : UserUnBlockReceiver)
  {
    
    UserRestClient.unBlockUser(userId: (QRSessionManager.getInstance()?.getUserId())!, unBlockUserId: phoneNumber, viewController: nil, completionHandler: { (responseObject, error) -> Void in
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
        UserDataCache.getInstance()!.deleteBlockedUser(unBlockedUserId: phoneNumber)
        MatchedUsersCache.getInstance().refreshMatchedUsersCache()
        receiver.userUnBlocked()
      }else {
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
      }
    })
  }
}
