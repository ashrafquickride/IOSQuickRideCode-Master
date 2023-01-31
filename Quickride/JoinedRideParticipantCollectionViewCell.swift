//
//  JoinedRideParticipantCollectionViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class JoinedRideParticipantCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    
    @IBOutlet weak var labelNoOfSeats: UILabel!
    
    @IBOutlet weak var invitationStatusIcon: UIImageView!
    
    var userId : Double?
    
    var status:String? = ""
    
    override func awakeFromNib() {
        RideViewUtils.setBorderToUserImageBasedOnStatus(image: imageViewProfilePic,status: self.status!)
    }
    
}
