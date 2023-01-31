//
//  SpecificFavouriteUserCell.swift
//  Quickride
//
//  Created by Halesh on 04/07/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation
class SpecificFavouriteUserCell: PreferredRidePartnersCell {
    
    override func initializeViews(preferredRidePartner : PreferredRidePartner,viewController : UIViewController){
        super.initializeViews(preferredRidePartner: preferredRidePartner, viewController: viewController)
        AutoConfirmSwitch.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        if preferredRidePartner.enableAutoConfirm!{
            AutoConfirmSwitch.setOn(true, animated: false)
        }else{
            AutoConfirmSwitch.setOn(false, animated: false)
        }
    }
    
    @IBAction func enableAndDisableUserForAutoConfirm(_ sender: UISwitch) {
        if sender.isOn{
            sender.setOn(true, animated: true)
           makeEnableOrDisableUserForAutoConfirmRide(enableAutoConfirm: true)
        }else{
            sender.setOn(false, animated: true)
        makeEnableOrDisableUserForAutoConfirmRide(enableAutoConfirm: false)
        }
    }
    
    func makeEnableOrDisableUserForAutoConfirmRide(enableAutoConfirm: Bool){
        UserRestClient.updateUserForAutoConfirm(userId: self.preferredRidePartner!.userId!, partnerUserId: preferredRidePartner!.favouritePartnerUserId!, enableAutoConfirm: enableAutoConfirm, viewController: self.viewController, completionHandler: { responseObject, error in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let preferredRidePartnersList = UserDataCache.getInstance()!.getAllPreferredRidePartners()
                for ridePartner in preferredRidePartnersList{
                    if ridePartner.favouritePartnerUserId == self.preferredRidePartner!.favouritePartnerUserId{
                        ridePartner.enableAutoConfirm = enableAutoConfirm
                    }
                }
                UserDataCache.getInstance()?.storePreferredRidePartnersInCache(preferredRidePartners: preferredRidePartnersList)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        })
    }
}
