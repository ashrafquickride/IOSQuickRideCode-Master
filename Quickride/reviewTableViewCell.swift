//
//  reviewTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 05/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import StoreKit

protocol reviewTableViewCellDelegate: class {
    func haveAconcernTapped()
    func rateUsClicked()
}

class reviewTableViewCell: UITableViewCell {

    @IBOutlet weak var rateUsButton: UIButton!
    @IBOutlet weak var haveAConcernButton: UIButton!
    weak var delegate: reviewTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setUpUI() {
        ViewCustomizationUtils.addCornerRadiusWithBorderToView(view: rateUsButton, cornerRadius: 10.0, borderWidth: 1.0, color: UIColor(netHex: 0x2196F3))
        ViewCustomizationUtils.addCornerRadiusWithBorderToView(view: haveAConcernButton, cornerRadius: 10.0, borderWidth: 1.0, color: .lightGray)
    }
    
    @IBAction func rateBtnPressed(_ sender: UIButton) {
        delegate?.rateUsClicked()
    }
    @IBAction func haveAConcernButtonPressed(_ sender: UIButton) {
        delegate?.haveAconcernTapped()
    }    
    
    
}
