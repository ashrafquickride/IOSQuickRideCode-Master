//
//  CO2TableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 05/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CO2TableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var quanityCo2SavedLabel: UILabel!
    @IBOutlet weak var removedNumbersOfCarLabel: UILabel!
    @IBOutlet weak var fuelSaveLabel: UILabel!
    @IBOutlet weak var viewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var contributionInfoLabel: UILabel!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var contributionView: UIView!
    @IBOutlet weak var dropDownImage: UIImageView!
    
    
    func UpdateUI(rideContribution: RideContribution?) {
        if var co2Reduced = rideContribution?.co2Reduced, var petrolSaved = rideContribution?.petrolSaved{
            quanityCo2SavedLabel.text = String(format: Strings.co2Reduced, arguments: [String(co2Reduced.roundToPlaces(places: 1))]) 
            fuelSaveLabel.text = String(format: Strings.fuelSaved, arguments: [String(petrolSaved.roundToPlaces(places: 1))])
            contributionInfoLabel.text = String(format: Strings.contribution_info, arguments: [String(co2Reduced.roundToPlaces(places: 1)),String(petrolSaved.roundToPlaces(places: 1))])
        }
    }
    
    @IBAction func dropDownButtonTapped(_ sender: Any) {
        if contributionView.isHidden{
            contributionView.isHidden = false
            dropDownImage.image = UIImage(named: "arrow_up_grey")
        }else{
            contributionView.isHidden = true
            dropDownImage.image = UIImage(named: "arrow_down_grey")
        }
        NotificationCenter.default.post(name: .updateUiWithNewData, object: nil)
    }
}
