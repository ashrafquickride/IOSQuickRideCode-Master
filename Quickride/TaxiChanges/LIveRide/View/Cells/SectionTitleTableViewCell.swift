//
//  SectionTitleTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 03/12/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SectionTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    func initialiseData(tripType: String?){
        if tripType == TaxiRidePassenger.oneWay {
            subTitleLabel.isHidden = false
            subTitleLabel.text = Strings.one_way
        }else if tripType == TaxiRidePassenger.roundTrip {
            subTitleLabel.isHidden = false
            subTitleLabel.text = Strings.round_trip
        }else {
            subTitleLabel.isHidden = true
        }
    }
}
