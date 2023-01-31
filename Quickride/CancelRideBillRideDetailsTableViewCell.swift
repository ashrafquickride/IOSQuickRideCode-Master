//
//  CancelRideBillRideDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancelRideBillRideDetailsTableViewCell: UITableViewCell {

   //MARK: Outlets
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var noOfRideTakerLabel: UILabel!
    
    //MARK: Variable
    
    func initailizeRideDetails(from: String,to: String){
        fromLabel.text = from
        toLabel.text = to
    }

}
