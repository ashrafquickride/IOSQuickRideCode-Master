//
//  NeedHelpTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 23/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class NeedHelpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var needHelpImage: UIImageView!

    func initializeCell(){
        needHelpImage.image = needHelpImage.image?.withRenderingMode(.alwaysTemplate)
        needHelpImage.tintColor = UIColor(netHex: 0x007AFF)
    }
    
}
