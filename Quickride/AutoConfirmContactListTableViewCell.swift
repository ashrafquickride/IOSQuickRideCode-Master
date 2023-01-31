//
//  AutoConfirmContactListTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 25/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AutoConfirmContactListTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageView: CircularImageView!
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var detailsButton: UIButton!
    
    @IBOutlet weak var circularView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        circularView.layer.cornerRadius = circularView.frame.size.height/2
    }
    
    func updateCellData(data:Contact) {
        if data.contactGender.isEmpty == false{
            ImageCache.getInstance().setImageToView(imageView: self.userProfileImageView, imageUrl: data.contactImageURI, gender: data.contactGender,imageSize: ImageCache.DIMENTION_TINY)
        }else{
            userProfileImageView.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
        }
        nameLabel.text = data.contactName
        if let userId = Double(data.contactId ?? ""), (UserDataCache.getInstance()?.isFavouritePartner(userId: userId))!{
            circularView.isHidden  = false
            favoriteImageView.image = UIImage(named: "fav_active")
            favoriteImageView.isHidden = false
        }else{
            circularView.isHidden  = true
            favoriteImageView.isHidden = true
        }
        switch data.autoConfirmStatus {
        case Contact.AUTOCONFIRM_FAVOURITE:
            matchLabel.isHidden = false
            matchLabel.text = Strings.auto_match
            matchLabel.textColor = UIColor(netHex: 0x00b557)
        case Contact.AUTOCONFIRM_UNFAVOURITE:
            matchLabel.isHidden = false
            matchLabel.text = Strings.auto_donotmatch
            matchLabel.textColor = UIColor(netHex: 0xe20000)
        default:
            matchLabel.isHidden = true
            matchLabel.text = ""
            matchLabel.textColor = .black
        }
    }

    
}
