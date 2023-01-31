//
//  ReferralFAQDetailsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 28/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReferralFAQDetailsTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var faqLabel: UILabel!
    func initializeFAQ(faq: String, index: Int){
        faqLabel.text = faq
        if index == Strings.referralFAQList.count - 1{
            faqLabel.textColor = UIColor(netHex: 0x007AFF)
        }
    }
    
}
