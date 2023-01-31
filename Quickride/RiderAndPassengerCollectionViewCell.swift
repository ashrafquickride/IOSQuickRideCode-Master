//
//  RiderAndPassengerCollectionViewCell.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/16/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RiderAndPassengerCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    
    @IBOutlet weak var noSeatsLabel: UILabel!
        
    @IBOutlet weak var participantStatusImage: UIImageView!
    
    @IBOutlet weak var otpRequiredStartView: UIView!
    
    var userId : Double?
    
    var status:String? = ""
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        RideViewUtils.setBorderToUserImageBasedOnStatus(image: imgProfilePic,status: self.status!)
        
    }
}
