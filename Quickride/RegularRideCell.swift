//
//  RegularRideCell.swift
//  Quickride
//
//  Created by QuickRideMac on 26/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class RegularRideCell: UITableViewCell {
    
    @IBOutlet weak var rideOptionsButton: UIButton!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var   toLocation: UILabel!
    @IBOutlet weak var  rideTypeIndicator : UIImageView!
    @IBOutlet weak var fromLocation: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dayToDayView: UIView!
    @IBOutlet weak var fromDayLabel: UILabel!
    @IBOutlet weak var toDayLabel: UILabel!
}
