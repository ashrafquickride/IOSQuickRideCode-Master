//
//  SafeKeeperTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class SafeKeeperTableViewCell: UITableViewCell {
    

    @IBOutlet var messageLabel: UILabel!
    
    func initializeData(message: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.3
        let attributedString1 = NSMutableAttributedString(string: message)
        attributedString1.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString1.length))
        messageLabel.attributedText = attributedString1
    }
}
