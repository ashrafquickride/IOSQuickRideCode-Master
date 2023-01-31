//
//  UserBlockTask.swift
//  Quickride
//
//  Created by QuickRideMac on 1/6/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol UserBlockReceiver
{
    func userBlocked()
    func userBlockingFailed(responseError : ResponseError)
}
class UserBlockTask
{
    static func blockUser(phoneNumber : Double, viewController : UIViewController, receiver : UserBlockReceiver, isContactNumber : Bool, reason : String?)
    {
        if isContactNumber
        {
          UserRestClient.getUserIdForPhoneNo(phoneNo: StringUtils.getStringFromDouble(decimalNumber: phoneNumber),countryCode: nil, uiViewController: nil, completionController: { (responseObject, error) -> Void in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let blockUserId = responseObject!["resultData"] as? Double
                    blocking(blockUserId: blockUserId!, reason : reason, receiver: receiver, viewController : viewController)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            })
        }
        else
        {
            blocking(blockUserId: phoneNumber, reason : reason, receiver: receiver, viewController : viewController)
        }
    }
    
    static func blocking(blockUserId : Double, reason : String?, receiver : UserBlockReceiver, viewController : UIViewController)
    {
        UserRestClient.blockUser(userId: (QRSessionManager.getInstance()?.getUserId())!, blockUserId: blockUserId,reason : reason, viewController: viewController, completionHandler: { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let blockedUser = Mapper<BlockedUser>().map(JSONObject: responseObject!["resultData"])!
                UserDataCache.getInstance()!.addBlockedUser(blockedUser: blockedUser)
                UserDataCache.getInstance()?.removeRidePartners(contactId: StringUtils.getStringFromDouble(decimalNumber: blockedUser.blockedUserId))
                UserDataCache.getInstance()!.deletePreferredRidePartner(favouritePartnerUserId: blockedUser.blockedUserId)
                ConversationCache.getInstance().handleUserBlockedScenario(blockedUserId: blockedUser.blockedUserId!);
                
                receiver.userBlocked()
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: viewController,handler: nil)
            }
        })
    }
}
