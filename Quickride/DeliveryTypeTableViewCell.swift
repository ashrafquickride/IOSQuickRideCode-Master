//
//  DeliveryTypeTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class DeliveryTypeTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var deliveryTypeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func initialiseDeliveryType(deliveryType: String,address: String){
        addressLabel.text = address
    }
    
    @IBAction func EditButtonTapped(_ sender: Any) {
        
    }
}
