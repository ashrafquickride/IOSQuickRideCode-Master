//
//  CancelAutoInvitesTableViewCell.swift
//  Quickride
//
//  Created by Halesh K on 07/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancelAutoInvitesTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var routeMatchLabel: UILabel!
    
    @IBOutlet weak var verificationImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func initailizeCell(name: String?, imageUrl: String?,gender: String?, verificationData: ProfileVerificationData?,company: String?, routeMatchPer: Int){
        nameLabel.text = name
        companyName.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: verificationData, companyName: company?.capitalized)
        if companyName.text == Strings.not_verified {
            companyName.textColor = UIColor.black
        }else{
            companyName.textColor = UIColor(netHex: 0x24A647)
        }
        routeMatchLabel.text = String(routeMatchPer) + " %"
        verificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: verificationData)
        
        if let contactGender = gender{
            ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: imageUrl, gender: contactGender,imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            userImageView.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
        }
    }
}
