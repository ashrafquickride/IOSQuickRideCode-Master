//
//  RentalPackageCollectionViewCell.swift
//  Quickride
//
//  Created by Rajesab on 22/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalPackageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var packageBackGroundView: UIView!
    @IBOutlet weak var packageDistanceLabel: UILabel!
    @IBOutlet weak var packageDurationLabel: UILabel!
    
    func setupUI(packageDistance: Int, packageDuration: Int){
        packageDistanceLabel.text = String(format: Strings.x_hr, arguments: [String(packageDuration/60)])
        packageDurationLabel.text = String(format: Strings.distance_in_km, arguments: [String(packageDistance)])
        packageBackGroundView.layer.cornerRadius = 5
        packageBackGroundView.layer.shadowColor = UIColor(netHex: 0x868686).cgColor
        packageBackGroundView.layer.shadowOffset = CGSize(width: -1, height: 1)
        packageBackGroundView.layer.shadowOpacity = 0.5
        packageBackGroundView.layer.shadowRadius = 5
    }
}
