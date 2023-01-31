//
//  TaxiEditDistanceInfoMarkerView.swift
//  Quickride
//
//  Created by Quick Ride on 4/29/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiEditDistanceInfoMarkerView: UIView {

    @IBOutlet weak var durationLable: UILabel!
    
    @IBOutlet weak var distanceAndTollLabel: UILabel!
        
    
    func initializeView(distance : Double?, duration: Double?){
        if let duration = duration {
            durationLable.text = TaxiUtils.getDurationDisplay(duration: Int(duration))
            durationLable.isHidden = false
        }else{
            durationLable.isHidden = true
        }
        var distanceAndTolls = ""
        if distance != nil {
            let roundedDistance = Int(distance!.rounded())
            distanceAndTolls = String(roundedDistance) + " KM"
        }
        
        distanceAndTollLabel.isHidden = false
        distanceAndTollLabel.text = distanceAndTolls
            

    }
}
