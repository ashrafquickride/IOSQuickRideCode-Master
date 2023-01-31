//
//  StopOverInfoView.swift
//  Quickride
//
//  Created by Vinutha on 19/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class StopOverInfoView : UIView{
    
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var stopOverTimeLabel: UILabel!
    @IBOutlet weak var markerTitleImageView: UIImageView!
    
    func initializeViews(stopOverTime: Int, zoomState: String?){
        ViewCustomizationUtils.addCornerRadiusToView(view: markerView, cornerRadius: 5)
        markerView.addShadow()
        stopOverTimeLabel.text = String(stopOverTime) + " MIN"
        markerTitleImageView.isHidden = false
        if zoomState == RideDetailMapViewModel.ZOOMED_IN {
            markerTitleImageView.image = UIImage(named: "zoomout_icon")
        } else if zoomState == RideDetailMapViewModel.ZOOMED_OUT {
            markerTitleImageView.image = UIImage(named: "zoomin_icon")
        } else {
            markerTitleImageView.isHidden = true
        }
    }
}
