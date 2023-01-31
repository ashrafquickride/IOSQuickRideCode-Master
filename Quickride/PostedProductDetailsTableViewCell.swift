//
//  PostedProductDetailsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 08/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PostedProductDetailsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var conditionaLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func initialiseView(postedProduct: PostedProduct){
        conditionaLabel.text = postedProduct.productCondition
        if let description = postedProduct.description{
            descriptionView.isHidden = false
            descriptionLabel.text = description
        }else{
            descriptionView.isHidden = true
        }
    }
}
