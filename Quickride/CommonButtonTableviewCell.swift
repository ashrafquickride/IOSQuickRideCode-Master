//
//  CommonButtonTableviewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CommonButtonTableviewCell: UITableViewCell {

        @IBOutlet weak var commonBtn: UIButton!
        var walletType: String?
        var isTapped: isTapped?

        func intialiseDataForNumber(walletType: String, isTapped: @escaping isTapped){
            
            self.walletType = walletType
            self.isTapped = isTapped
        }
        @IBAction func btnTapped(_ sender: Any) {
            isTapped?(true)
        }
}
