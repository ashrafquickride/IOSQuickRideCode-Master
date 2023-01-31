//
//  AccountDetailsViewModel.swift
//  Quickride
//
//  Created by Ashutos on 17/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AccountDetailsViewModel {
    
    let titleArrayFor2ndSection = [Strings.user_verification,Strings.my_payments,Strings.refer_earn,Strings.offers,Strings.settings]
    let subtitleArrayFor2ndSection = [Strings.verification_subTitle, Strings.payment_subtitle, Strings.refer_subtititle,Strings.offer_subtititle,Strings.setting_subtitle]
    

    
    let ImageArrayForSecondSection = ["userVerification", "myPayments","referandearn","promotion","setting"]
    
    var userId = QRSessionManager.getInstance()?.getUserId()
    var isLoaderShowing = true
    
    func numberOfRowsForSection(indexPath: Int) -> Int {
        if indexPath == 1 {
            return titleArrayFor2ndSection.count
        } else {
            return 1
        }
    }
    
}
