//
//  RentalExtraDurationAndDistanceFareTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 01/03/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalExtraDurationAndDistanceFareTableViewCell: UITableViewCell {

    @IBOutlet weak var carTypeLabel: UILabel!
    @IBOutlet weak var extraDurationFareLabel: UILabel!
    @IBOutlet weak var extraDistanceFareLabel: UILabel!

    func setupUI(carType: String, extraDuration: String, extraDistance: String){
        if carType == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV_LUXURY{
            carTypeLabel.text = "SUV Luxury"
        } else{
            carTypeLabel.text = carType
        }
        extraDistanceFareLabel.text = String(format: Strings.point_per_km, arguments: [extraDistance])
        extraDurationFareLabel.text = String(format: Strings.points_per_min, arguments: [extraDuration])
    }
    
}
