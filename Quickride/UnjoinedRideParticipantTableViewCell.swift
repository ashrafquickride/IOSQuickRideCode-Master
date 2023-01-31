//
//  UnjoinedRideParticipantTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 10/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UnjoinedRideParticipantTableViewCell: UITableViewCell {

    //MARK: outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    
    func initializeCell(oppositeUser: OppositeUser?,rideType: String){
        userNameLabel.text = oppositeUser?.name
        feeLabel.text = oppositeUser?.feeType
        feeLabel.textColor = oppositeUser?.color
        if let userGender = oppositeUser?.gender{
            ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl: oppositeUser?.imageUrl, gender: userGender,imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            userImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
        }
        if rideType == Ride.PASSENGER_RIDE{
            typeLabel.text = ""
            titleLabel.isHidden = false
            titleLabelHeightConstraint.constant = 20
        }else{
            typeLabel.text = oppositeUser?.type
           titleLabel.isHidden = true
            titleLabelHeightConstraint.constant = 0
        }
    }
    
}
