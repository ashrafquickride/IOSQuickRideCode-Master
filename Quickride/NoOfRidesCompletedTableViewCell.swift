//
//  NoOfRidesCompletedTableViewCell.swift
//  Quickride
//
//  Created by Admin on 28/02/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class NoOfRidesCompletedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelNoOfRides: UILabel!
    
    static let totalRides = "Total Rides"
    static let asRider = "As Rider"
    static let asPassenger = "As Passenger"
    
    //MARK: Methods
    func setUpUI(row: Int, noOfRides: String) {
        labelNoOfRides.text = noOfRides
        if row == 0 {
            labelNoOfRides.text = noOfRides + " " + NoOfRidesCompletedTableViewCell.totalRides
        } else if row == 1 {
            labelNoOfRides.text = noOfRides + " " + NoOfRidesCompletedTableViewCell.asRider
        } else {
            labelNoOfRides.text = noOfRides + " " + NoOfRidesCompletedTableViewCell.asPassenger
        }
    }
}
