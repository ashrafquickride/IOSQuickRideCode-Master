//
//  MyAccountTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 17/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyAccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var cellTypeImage: UIImageView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(profileData:UserProfile, title: String,subtitle: String, imageString: String, section: Int, row: Int) {
        if section == 1 {
            if row == 0 {
                if profileData.profileVerificationData == nil || (!profileData.profileVerificationData!.imageVerified && !profileData.profileVerificationData!.emailVerified && !profileData.profileVerificationData!.profileVerified) {
                    let subTitle = Strings.user_not_verified_subtitle
                    setUpUI(title: title,subtitle: subTitle, imageString: imageString,infoBtnVisibility: false,subtitleColorStatus: false, separatorViewHidingStatus: false)
                } else {
                    setUpUI(title: title,subtitle: subtitle, imageString: imageString,infoBtnVisibility: true,subtitleColorStatus: true, separatorViewHidingStatus: false)
                }
                
            } else if row == 2 {
                if UserDataCache.sharedInstance?.getAllLinkedWallets().count == 0 && profileData.preferredRole == UserProfile.PREFERRED_ROLE_PASSENGER {
                    setUpUI(title: title,subtitle: Strings.no_payment_option, imageString: imageString,infoBtnVisibility: false,subtitleColorStatus: false, separatorViewHidingStatus: false)
                } else {
                    setUpUI(title: title,subtitle: subtitle, imageString: imageString,infoBtnVisibility: true,subtitleColorStatus: true, separatorViewHidingStatus: false)
                }
            } else {
                var hideSeparator = false
                if row == 7{
                    hideSeparator = true
                }
                setUpUI(title: title,subtitle: subtitle, imageString: imageString,infoBtnVisibility: true,subtitleColorStatus: true, separatorViewHidingStatus: hideSeparator)
            }
            
        } else {
            let separatorHide = false
            setUpUI(title: title,subtitle: subtitle, imageString: imageString,infoBtnVisibility: true,subtitleColorStatus: true, separatorViewHidingStatus: separatorHide)
        }
    }
    
    private func setUpUI(title: String,subtitle: String, imageString: String,infoBtnVisibility: Bool,subtitleColorStatus: Bool,separatorViewHidingStatus: Bool) {
        titleLabel.text = title
        if subtitle.isEmpty{
            subTitleLabel.isHidden = true
            titleTopConstraint.constant = 0
        }else{
            subTitleLabel.isHidden = false
            titleTopConstraint.constant = -10
            subTitleLabel.text = subtitle
        }
        if imageString.isEmpty{
            cellTypeImage.isHidden = true
            titleLeadingConstraint.constant = 20
        }else{
            cellTypeImage.isHidden = false
            titleLeadingConstraint.constant = 63
            cellTypeImage.image = UIImage(named: imageString)
        }
        infoImageView.isHidden = infoBtnVisibility
        assignColorForSubTitleLabel(status: subtitleColorStatus)
        separatorView.isHidden = separatorViewHidingStatus
    }
    
    private func assignColorForSubTitleLabel(status: Bool) {
        if status{
            subTitleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        }else{
            subTitleLabel.textColor = UIColor(netHex: 0xff4b4b)
        }
    }
}
