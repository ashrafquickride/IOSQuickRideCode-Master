//
//  ProductDescriptionTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductDescriptionTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func initialiseDescriptionView(descriptionText: String){
        descriptionLabel.text = descriptionText
    }
    
}
