//
//  LocationInfoView.swift
//  Quickride
//
//  Created by Admin on 22/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class LocationInfoView : UIView{
    
    @IBOutlet weak var markerImageView: UIImageView!
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var markerTitleLbl: UILabel!
    @IBOutlet weak var markerTitleImageView: UIImageView!
    
    func initializeViews(markerTitle : String, markerImage : UIImage, zoomState: String?){
        ViewCustomizationUtils.addCornerRadiusToView(view: markerView, cornerRadius: 5)
        markerView.addShadow()
        markerImageView.image = markerImage
        markerTitleLbl.text = markerTitle
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
