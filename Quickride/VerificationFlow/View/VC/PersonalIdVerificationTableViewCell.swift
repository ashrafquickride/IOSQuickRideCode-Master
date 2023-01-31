//
//  PersonalIdVerificationTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 10/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PersonalIdVerificationTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var personalVerificationTypeLabel: UILabel!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var verifiedLabelHeightConstraint: NSLayoutConstraint!

    func initialiseView(type: String) {
        var verificationType = ""
        switch type {
        case PersonalIdDetail.ADHAR:
            verificationType = Strings.adhar_id_verification
        case PersonalIdDetail.PAN:
            verificationType = Strings.pan_id_verification
        case PersonalIdDetail.VOTER_ID:
            verificationType = Strings.voter_id_verification
        case PersonalIdDetail.DL:
            verificationType = Strings.driving_license_verification
        default:
            break
        }
        personalVerificationTypeLabel.text = verificationType
        handleVerifiedType(type: type)
    }
    
    private func handleVerifiedType(type: String) {
        let persVerifSource = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData()?.persVerifSource
        if let persVerifSource = persVerifSource, persVerifSource.contains(type) {
            verifiedLabel.isHidden = false
            verifiedLabelHeightConstraint.constant = 30
        } else {
            verifiedLabel.isHidden = true
            verifiedLabelHeightConstraint.constant = 0
        }
    }
}
