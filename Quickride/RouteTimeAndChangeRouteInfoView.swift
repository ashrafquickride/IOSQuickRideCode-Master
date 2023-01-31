//
//  RouteTimeAndChangeRouteInfoView.swift
//  Quickride
//
//  Created by Halesh on 07/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RouteTimeAndChangeRouteInfoView : UIView{

    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var viewWidth: NSLayoutConstraint!
    
    func initializeView(distance : Double?, duration: Double?){
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
    
    }
    
    
}
