//
//  TopReferrerTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 30/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TopReferrerTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCompanyNameLabel: UILabel!
    @IBOutlet weak var noOfReferralsLabel: UILabel!
    @IBOutlet weak var earnedPointsLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankStar: UIImageView!
    @IBOutlet weak var userIamge: UIImageView!
    @IBOutlet weak var userVerificationImage: UIImageView!
    @IBOutlet weak var rankLabelHieghtConstraint: NSLayoutConstraint!
    
    func initializeLeaderCell(referralLeader: ReferralLeader){
        rankLabel.text = String(referralLeader.leaderRank)
        userNameLabel.text = referralLeader.userName?.capitalized
        if let companyName = referralLeader.companyName{
            userCompanyNameLabel.text = (companyName.capitalized) + "  ."
        }else{
         userCompanyNameLabel.text = ("-") + "  ."
        }
        if referralLeader.activatedReferralCount > 1{
            userCompanyNameLabel.text = (userCompanyNameLabel.text ?? "") + " " + String(format: Strings.referrals, arguments: [String(referralLeader.activatedReferralCount)])
        }else{
           userCompanyNameLabel.text = (userCompanyNameLabel.text ?? "") + " " +  String(format: Strings.referral, arguments: [String(referralLeader.activatedReferralCount)])
        }
        earnedPointsLabel.text = String(referralLeader.bonusEarned)
        userVerificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: referralLeader.profileVerificationData)
        if let leaderGender = referralLeader.gender{
            ImageCache.getInstance().setImageToView(imageView: userIamge, imageUrl: referralLeader.imageUrl, gender: leaderGender,imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            userIamge.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
        }
        if referralLeader.leaderRank <= 3{
            rankLabelHieghtConstraint.constant = -10
            rankLabel.textColor = UIColor(netHex: 0xD17500)
            rankStar.isHidden = false
        }else{
            rankLabelHieghtConstraint.constant = 0
            rankStar.isHidden = true
            rankLabel.textColor = .black
        }
    }
}
