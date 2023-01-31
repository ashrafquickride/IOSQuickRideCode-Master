//
//  AddFavouritePartnerTask.swift
//  Quickride
//
//  Created by rakesh on 2/3/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol AddFavPartnerReceiver
{
    func favPartnerAdded()
    func favPartnerAddingFailed(responseError : ResponseError)
    
}
class AddFavouritePartnerTask
{
 
    static func addFavoritePartner(userId : String,favouritePartnerUserIds : [Double], receiver : AddFavPartnerReceiver, viewController : UIViewController)
    {
        UserRestClient.addFavouritePartner(userId:  (QRSessionManager.getInstance()?.getUserId())!, favouritePartnerIds: favouritePartnerUserIds, viewController: viewController,completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let preferredRidePartners = Mapper<PreferredRidePartner>().mapArray(JSONObject: responseObject!["resultData"])
             
                UserDataCache.getInstance()!.addPreferredRidePartner(favoriteRidePartners: preferredRidePartners!)
                MatchedUsersCache.getInstance().refreshMatchedUsersCache()
                receiver.favPartnerAdded()
                AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.FAV_ADDED, params: ["favPartnerUserId" : favouritePartnerUserIds[0],"userId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: viewController,handler: nil)
            }
        })
    }
}


