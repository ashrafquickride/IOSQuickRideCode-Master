//
//  LevelBenefitsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 07/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class LevelBenefitsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var benefitsLabel: UILabel!
    @IBOutlet weak var benefitsImage: UIImageView!
    
    
    func initializeBenefits(benefit: String?){
        benefitsLabel.text = benefit
        benefitsImage.image = benefitsImage.image?.withRenderingMode(.alwaysTemplate)
        benefitsImage.tintColor = UIColor.black.withAlphaComponent(0.6)
    }
}
