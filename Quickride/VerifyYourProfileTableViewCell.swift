//
//  VerifyYourProfileTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 29/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class VerifyYourProfileTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var verifyLabel: UILabel!
    
    
    func initailiseView(){
        if let profileVarificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData,profileVarificationData.profileVerified == false{
            verifyLabel.text = Strings.verify_your_profile
        }else{
            verifyLabel.text = Strings.profile_verified
            verifyLabel.textColor = Colors.green
        }
    }
}
