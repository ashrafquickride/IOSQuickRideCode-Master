//
//  AddVehicleTableViewCell.swift
//  Quickride
//
//  Created by QuickRideMac on 8/31/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class AddVehicleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addVehicleView: UIView!
    
    @IBOutlet weak var addVehicleTitle: UIButton!
    
    @IBOutlet weak var noVehicleView: UIView!
    
    func initializeViews(isEmptyVehicle : Bool)
    {
        if isEmptyVehicle
        {
            noVehicleView.isHidden = false
            addVehicleTitle.isHidden = true

        }
        else
        {
            noVehicleView.isHidden = true
            addVehicleTitle.isHidden = false
        }
    }
}
