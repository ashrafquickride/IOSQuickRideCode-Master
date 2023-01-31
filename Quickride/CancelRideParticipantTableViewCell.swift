//
//  CancelRideParticipantTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 05/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancelRideParticipantTableViewCell: UITableViewCell {

    //MARK: outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    
    func initializeCell(oppositeUser: OppositeUser?){
        userNameLabel.text = oppositeUser?.name
        typeLabel.text = oppositeUser?.type
        feeLabel.text = oppositeUser?.feeType
        feeLabel.textColor = oppositeUser?.color
        if let userGender = oppositeUser?.gender{
            ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl: oppositeUser?.imageUrl, gender: userGender,imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            userImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
        }
    }
}
