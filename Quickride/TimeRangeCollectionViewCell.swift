//
//  TimeRangeCollectionViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 03/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TimeRangeCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var plusIcon: UILabel!
    @IBOutlet weak var minusIcon: UILabel!
    
    func initializeCell(timeValue: String, isSelected:Bool,hideMinus: Bool) {
        timeTitleLabel.text = timeValue
        ViewCustomizationUtils.addCornerRadiusToView(view: outerView, cornerRadius: 10)
        if isSelected{
            timeTitleLabel.textColor = UIColor(netHex: 0x007AFF)
            ViewCustomizationUtils.addBorderToView(view: outerView, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
            plusIcon.textColor = UIColor(netHex: 0x007AFF)
            minusIcon.textColor = UIColor(netHex: 0x007AFF)
        }else{
            timeTitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            ViewCustomizationUtils.addBorderToView(view: outerView, borderWidth: 1, color: UIColor(netHex: 0xf1f1f1))
            plusIcon.textColor = UIColor.black.withAlphaComponent(0.6)
            minusIcon.textColor = UIColor.black.withAlphaComponent(0.6)
        }
        if hideMinus{
            minusIcon.isHidden = true
        }
    }
}

