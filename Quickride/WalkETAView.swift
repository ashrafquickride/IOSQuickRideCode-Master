//
//  WalkETAView.swift
//  Quickride
//
//  Created by Quick Ride on 9/5/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class WalkETAView: UIView {

    @IBOutlet weak var etaLabel: UILabel!
    
    
    @IBOutlet weak var view: UIView!
    
    func initailizeView(distance: Double) {
         ViewCustomizationUtils.addCornerRadiusToView(view: view, cornerRadius: 7)
        ViewCustomizationUtils.addBorderToView(view: view, borderWidth: 1, color: UIColor.black.withAlphaComponent(0.5))
        let seconds = Int(distance/1.7)
        if seconds <= 20 {
            etaLabel.text = "Reached Pickup"
        }else if seconds > 20 && seconds <= 60{
            etaLabel.text = "1 min"
        }else if seconds <= 3600{
            var mins = seconds/60
            let mod = seconds % 60
            if mod > 40 && mod <= 60{
                mins = mins+1
            }
            if mins == 1 {
                etaLabel.text = "\(mins) min"
            }else{
                etaLabel.text = "\(mins) mins"
            }
        }else{
            let hour = seconds/3600
            if hour == 1 {
                etaLabel.text = "\(hour) hour"
            }else{
                etaLabel.text = "\(hour) hours"
            }
        }
    }
}
