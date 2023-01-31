//
//  ReferredUserInfoTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 27/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
protocol ReferredUserInfoTableViewCellDelegate {
    func referredUserMenuButtonTapped()
}

class ReferredUserInfoTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCompanyNameLabel: UILabel!
    @IBOutlet weak var verificationPointsLabel: UILabel!
    @IBOutlet weak var ridePointsLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userverificationImage: UIImageView!
    
    //MARK: Variables
    
    func initializeReferredUserInfo(referredUserInfo: ReferredUserInfo){
        userNameLabel.text = referredUserInfo.referredUserName?.capitalized
        if referredUserInfo.verificationBonus <= 0{
          verificationPointsLabel.text = "- "
        }else{
          verificationPointsLabel.text = StringUtils.getPointsInDecimal(points: referredUserInfo.verificationBonus)
        }
        if referredUserInfo.firstRideBonus + referredUserInfo.serviceFeeShare <= 0{
           ridePointsLabel.text = "- "
        }else{
           ridePointsLabel.text = StringUtils.getPointsInDecimal(points: referredUserInfo.firstRideBonus + referredUserInfo.serviceFeeShare)
        }
        userCompanyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: referredUserInfo.profileVerificationData, companyName: referredUserInfo.referredUserCompany?.capitalized)
        userverificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: referredUserInfo.profileVerificationData)
        if userCompanyNameLabel.text == Strings.not_verified {
            userCompanyNameLabel.textColor = UIColor.black
        }else{
            userCompanyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if let referredUserGender = referredUserInfo.gender{
            ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl: referredUserInfo.referredUserImageUri, gender: referredUserGender,imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            userImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
        }
    }
}
