//
//  OutstationCustomerCareTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 10/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OutstationCustomerCareTableViewCell: UITableViewCell {
    
    @IBAction func callButtonTapped(_ sender: Any) {
        let phoneNumber = ConfigurationCache.getObjectClientConfiguration().taxiSupportMobileNumber
        if !phoneNumber.isEmpty,let vc = parentViewController{
            AppUtilConnect.callSupportNumber(phoneNumber: phoneNumber, targetViewController: vc)
        }
    }
    
}
