//
//  RecurringRideDaysCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 05/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RecurringRideDaysCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var daysBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ViewCustomizationUtils.addCornerRadiusToView(view: contentView, cornerRadius: 17)
    }
}
