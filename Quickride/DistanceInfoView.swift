//
//  DIstanceInfoView.swift
//  Quickride
//
//  Created by Admin on 24/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class DistanceInfoView : UIView{
    
   @IBOutlet weak var arrowImageView: UIImageView!
    
   @IBOutlet weak var distanceLbl: UILabel!
    
    @IBOutlet weak var distanceView: UIView!
    func initializeDataBeforePresenting(distance : Double?){
        ViewCustomizationUtils.addCornerRadiusToView(view: distanceView, cornerRadius: 3.0)
          let roundedDistance = Int(distance!.rounded())
          distanceLbl.text = String(roundedDistance) + " KM"
         arrowImageView.image = arrowImageView.image!.withRenderingMode(.alwaysTemplate)
          arrowImageView.tintColor = UIColor(netHex: 0x2F77F2)
    }
}
