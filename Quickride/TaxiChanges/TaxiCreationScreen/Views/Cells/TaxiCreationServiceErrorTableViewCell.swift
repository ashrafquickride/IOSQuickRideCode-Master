//
//  TaxiCreationServiceErrorTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiCreationServiceErrorTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var callButton: QRCustomButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initialiseError(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        callButton.setTitle(clientConfiguration.taxiSupportMobileNumber, for: .normal)
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        let phoneNumber = ConfigurationCache.getObjectClientConfiguration().taxiSupportMobileNumber
        if !phoneNumber.isEmpty,let vc = parentViewController{
            AppUtilConnect.callSupportNumber(phoneNumber: phoneNumber, targetViewController: vc)
        }
    }
}
