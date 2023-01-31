//
//  RentalStopPointDetailTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 01/11/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalStopPointDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var stopPointLocationButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var actionComplitionHandler: actionComplitionHandler?
    
    func initialiseData(stopPointLocation: String?, actionComplitionHandler: actionComplitionHandler?){
        self.actionComplitionHandler = actionComplitionHandler
        if let stopPointLocation = stopPointLocation {
            dotView.backgroundColor = UIColor(netHex: 0xFF1B21)
            stopPointLocationButton.setTitle(stopPointLocation, for: .normal)
            stopPointLocationButton.setTitleColor(UIColor.black, for: .normal)
            stopPointLocationButton.isUserInteractionEnabled = false
            bottomConstraint.constant = 2
        }else {
            dotView.backgroundColor = UIColor(netHex: 0x99D8A8)
            stopPointLocationButton.setTitleColor(UIColor.systemBlue, for: .normal)
            stopPointLocationButton.isUserInteractionEnabled = true
            bottomConstraint.constant = 8
        }
    }
    
    @IBAction func addStopPointButtonTapped(_ sender: Any) {
        if let actionComplitionHandler = actionComplitionHandler {
            actionComplitionHandler(true)
        }
    }
}
