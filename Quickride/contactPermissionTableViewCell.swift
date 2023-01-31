//
//  contactPermissionTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 04/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class contactPermissionTableViewCell: UITableViewCell {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction func enableContactsClicked(_ sender: Any) {
        NotificationCenter.default.post(name: .contactPermission, object: nil)
    }
}
