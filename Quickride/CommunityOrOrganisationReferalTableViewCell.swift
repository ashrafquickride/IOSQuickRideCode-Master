//
//  CommunityOrOrganisationReferalTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 10/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol CommunityOrOrganisationReferalTableViewCellDelegate: class {
    func rewardsInfoClicked(rewardType: String?)
}

class CommunityOrOrganisationReferalTableViewCell: UITableViewCell {

    @IBOutlet weak var referImage: UIImageView!
    @IBOutlet weak var referBenifitLabel: UILabel!
    @IBOutlet weak var referApplyForLabel: UILabel!
    
    weak private var delegate: CommunityOrOrganisationReferalTableViewCellDelegate?
    private var rewardType: String?
    
    func updateUI(referralImage: UIImage?,rewardType: String,offerDetails: String,delegate: CommunityOrOrganisationReferalTableViewCellDelegate) {
        self.delegate = delegate
        referImage.image = referralImage
        referBenifitLabel.text = offerDetails
        self.rewardType = rewardType
        if rewardType == RewardsTermsAndConditions.REFER_COMMUNITY{
            referApplyForLabel.text = Strings.refer_community
        }else if rewardType == RewardsTermsAndConditions.REFER_ORGANIZATION{
            referApplyForLabel.text = Strings.refer_organization
        }
    }
    
    //MARK: Actions
    @IBAction func rewardsInfoClicked(_ sender: UIButton) {
        delegate?.rewardsInfoClicked(rewardType: rewardType)
    }
}
