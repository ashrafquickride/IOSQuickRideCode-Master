//
//  CreateAccountTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias isTapped = (_ signupBtn : Bool) -> Void

class CreateAccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameOfBtn: UIButton!
    var walletType: String?
    var isTapped: isTapped?
    
    func intialiseDataForNumber(walletType: String, isTapped: @escaping isTapped){
        self.walletType = walletType
        self.isTapped = isTapped
    }
    @IBAction func accountSignUpTapped(_ sender: Any) {
        isTapped?(true)
        
    }
    
}
