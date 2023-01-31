//
//  LoadingTaxiListTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 24/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class LoadingTaxiListTableViewCell: UITableViewCell {

    @IBOutlet weak var taxiImageShimmerView: ShimmerView!
    @IBOutlet weak var titleView: ShimmerView!
    @IBOutlet weak var subTitleView: ShimmerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Initialization code
    }
    
    private func setUpUI() {
        taxiImageShimmerView.startAnimating()
        titleView.startAnimating()
        subTitleView.startAnimating()
    }
}
