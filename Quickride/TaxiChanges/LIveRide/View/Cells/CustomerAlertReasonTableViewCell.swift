//
//  CustomerAlertReasonTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CustomerAlertReasonTableViewCell: UITableViewCell {


    @IBOutlet weak var reasonSelectImage: UIImageView!
    
    @IBOutlet weak var customerReasonLabel: UILabel!
    
   func toSetUpUi(selectedIndex: Int?,index: Int,reasonText: String){
        customerReasonLabel.text = reasonText
        if selectedIndex == index{
            reasonSelectImage.image = UIImage(named: "ic_radio_button_checked")
        }else {
            reasonSelectImage.image = UIImage(named: "radio_button_1")
        }

    }
    
    
    

}
