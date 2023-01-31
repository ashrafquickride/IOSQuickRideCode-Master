//
//  DistanceAndDurationWithTollsView.swift
//  Quickride
//
//  Created by Quick Ride on 5/5/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class DistanceAndDurationWithTollsView: UIView {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tollsLable: UILabel!
    @IBOutlet weak var noOfTollsLbl: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
        
    func initializeView(distance : Double?, duration: Double?, noOfTolls : Int){
        if distance != nil {
            distanceLabel.isHidden = false
            let roundedDistance = Int(distance!.rounded())
            distanceLabel.text = String(roundedDistance) + " KM"
        } else {
            distanceLabel.isHidden = true
        }
        if let duration = duration, duration > 0 {
            self.durationLabel.isHidden = false
            self.durationLabel.text = TaxiUtils.getDurationDisplay(duration: Int(duration))
        }else{
            self.durationLabel.isHidden = true
        }
        
        tollsLable.isHidden = false
        noOfTollsLbl.isHidden = false
        noOfTollsLbl.text = String(noOfTolls)
        ViewCustomizationUtils.addCornerRadiusToView(view: noOfTollsLbl, cornerRadius: 6)
        ViewCustomizationUtils.addBorderToView(view: noOfTollsLbl, borderWidth: 1, color: .white)
        
    }

}
