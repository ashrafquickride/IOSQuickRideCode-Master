//
//  HowRentalWorksTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HowRentalWorksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var otherPointsView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var otherPointsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func showHowRentalWorks(isRequiredToShowFull: Bool){
        if isRequiredToShowFull{
            moreButton.isHidden = true
            otherPointsView.isHidden = false
            otherPointsViewHeightConstraint.constant = 282
            progressView.isHidden = true
        }else{
            moreButton.isHidden = false
            otherPointsView.isHidden = true
            otherPointsViewHeightConstraint.constant = 0
            progressView.isHidden = false
        }
    }
    
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .showHowRentalWorks, object: nil)
    }
}
