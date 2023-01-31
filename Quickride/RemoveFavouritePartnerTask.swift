//
//  RemoveFavouritePartnerTask.swift
//  Quickride
//
//  Created by rakesh on 2/5/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol RemoveFavouritePartnerReciever
{
    func favouritePartnerRemoved()
}

class RemoveFavouritePartnerTask
{
    static func removeFavouritePartner(phoneNumber : Double,viewController : UIViewController, receiver : RemoveFavouritePartnerReciever)
    {
        UserRestClient.removeFavouritePartner(userId: (QRSessionManager.getInstance()?.getUserId())!, removeFavouritePartnerId: phoneNumber, viewController: viewController,completionHandler: { (responseObject, error) -> Void in
           QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UserDataCache.getInstance()!.deletePreferredRidePartner(favouritePartnerUserId: phoneNumber)
                MatchedUsersCache.getInstance().refreshMatchedUsersCache()
                receiver.favouritePartnerRemoved()
            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
}
