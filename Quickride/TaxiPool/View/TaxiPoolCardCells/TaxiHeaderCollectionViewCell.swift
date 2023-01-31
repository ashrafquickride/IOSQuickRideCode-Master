//
//  TaxiHeaderCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 7/13/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpUI(headerText: String) {
        headerLabel.text = headerText
    }
}
