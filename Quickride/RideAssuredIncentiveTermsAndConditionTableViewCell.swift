//
//  RideAssuredIncentiveTermsAndConditionTableViewCell.swift
//  Quickride
//
//  Created by Admin on 03/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideAssuredIncentiveTermsAndConditionTableViewCell : UITableViewCell{
    
    @IBOutlet weak var conditionsLbl: UILabel!
    
    func initializeViews(termsAndConditions : [String],row : Int){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.3
        let attributedString1 = NSMutableAttributedString(string: termsAndConditions[row])
        attributedString1.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString1.length))
        conditionsLbl.attributedText = attributedString1
    }
    
}
