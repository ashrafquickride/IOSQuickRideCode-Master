//
//  DrivingLicenseTableViewCell.swift
//  Quickride
//
//  Created by Admin on 10/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class DrivingLicenseTableViewCell : UITableViewCell{
    
    
    @IBOutlet weak var backGroundView: UIView!
    
    func initializeViews(){
        self.backGroundView.addShadow()
    }
}
