//
//  TaxiIntroductionTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 6/8/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiIntroductionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taxiViewHeaderHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var introductionHeaderLabel: UILabel!
    @IBOutlet weak var statusImageView: CircularImageView!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var stepForwardedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUpDataToUI(indexpath: Int, title: String, subTitle: String,totalSeats: Int,titleHeader: String) {
        introductionHeaderLabel.text = titleHeader
        headerLabel.text = title
        stepCountLabel.text = "\(indexpath+1)"
        if indexpath == 1 {
            subTitleLabel.text = String(format: Strings.taxi_confirm_sub,arguments: ["\(totalSeats)"])
        } else {
            subTitleLabel.text = subTitle
        }
        if indexpath == 0 {
            taxiViewHeaderHeightConstant.constant = 35
        } else {
            taxiViewHeaderHeightConstant.constant = 0
        }
        if indexpath == 3 {
            stepForwardedView.isHidden = true
        } else {
            stepForwardedView.isHidden = false
        }
    }
    
    func updateStatusAndUI(index: Int,status: Int) {
        colorForwardView(index: index,status: status)
        if index <= status {
            statusImageView.image = UIImage(named: "check")
            stepCountLabel.isHidden = true
            
        }else{
            statusImageView.image = nil
            stepCountLabel.isHidden = false
        }
    }
    
    func colorForwardView(index: Int,status: Int) {
        if index < status {
            stepForwardedView.backgroundColor = UIColor(netHex: 0x00B557)
        }else{
            stepForwardedView.backgroundColor = UIColor(netHex: 0xEEEEEE)
            
        }
    }
}
