//
//  RentalTaxiDropOtpTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 02/11/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalTaxiDropOtpTableViewCell: UITableViewCell {

    @IBOutlet weak var dropOtpLabel: UILabel!
    
    func initialiseData(dropOtp: String){
        dropOtpLabel.text = dropOtp
    }
}
