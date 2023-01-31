//
//  RemoveRideParticipantContactTask.swift
//  Quickride
//
//  Created by Vinutha on 8/18/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol RemoveRidePartnerContactReciever
{
    func RidePartnerRemoved()
}

class RemoveRideParticipantContactTask
{
    static func removeRidePartner(contactId: String, isFavPartner: Bool, viewController : UIViewController, receiver : RemoveRidePartnerContactReciever)
    {
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.removeRidePartnersContact(userId: (QRSessionManager.getInstance()?.getUserId())!, contactId: contactId, isFavPartner: isFavPartner, viewController: viewController, handler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UserDataCache.getInstance()?.removeRidePartners(contactId: contactId)
                if isFavPartner{
                    UserDataCache.getInstance()!.deletePreferredRidePartner(favouritePartnerUserId: Double(contactId)!)
                    MatchedUsersCache.getInstance().refreshMatchedUsersCache()
                }
                receiver.RidePartnerRemoved()
            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
}
