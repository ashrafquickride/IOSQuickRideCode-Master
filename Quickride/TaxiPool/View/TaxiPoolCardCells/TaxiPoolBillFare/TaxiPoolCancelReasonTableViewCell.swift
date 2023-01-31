//
//  TaxiPoolCancelReasonTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 7/20/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiPoolCancelReasonTableViewCell: UITableViewCell {

    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var cancelReasonLabel: UILabel!

    @IBOutlet weak var pleaseContact: UILabel!
    
    @IBOutlet weak var callIconBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpUI(selectedIndex: Int?,index: Int,reasonText: String) {
        if selectedIndex == index{
            let image = UIImage(named: "ic_radio_button_checked")?.withRenderingMode(.alwaysTemplate)
            cancelImageView.image = image
            cancelImageView.tintColor = UIColor(netHex:0x000000)
            cancelReasonLabel.text = reasonText
        }else{
            cancelReasonLabel.text = reasonText
            cancelImageView.image = UIImage(named: "radio_button_1")
        }
    }
    
    @IBAction func callIconBtn(_ sender: UIButton) {
        if let phoneNumber = ConfigurationCache.getInstance()?.getClientConfiguration()?.quickRideSupportNumberForTaxi, let vc = self.parentViewController {
            AppUtilConnect.callSupportNumber(phoneNumber: phoneNumber, targetViewController: vc)
        }
    }
}

