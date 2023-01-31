//
//  RequestSuccesDetailsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RequestSuccesDetailsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!    
    @IBOutlet weak var categoryTypeLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    
    func initialiseView(postedRequest: PostedRequest){
        titleLabel.text = postedRequest.title
        productDescriptionLabel.text = postedRequest.description
        let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: postedRequest.categoryCode ?? "")
        categoryTypeLabel.text = category?.displayName
        switch postedRequest.tradeType {
        case Product.SELL:
            sellView.isHidden = false
            rentView.isHidden = true
        case Product.RENT:
            sellView.isHidden = true
            rentView.isHidden = false
        default:
            sellView.isHidden = false
            rentView.isHidden = false
        }
    }
}
