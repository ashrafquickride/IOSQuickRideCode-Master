//
//  ViaPointTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 6/17/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
class ViaPointTableViewCell : UITableViewCell{
    
    @IBOutlet weak var viaPointName: UILabel!
    
    @IBOutlet weak var viaPointView: UIView!
    
    @IBOutlet weak var removeViaPoint: UIButton!

    @IBOutlet weak var viaPointsLabel: UILabel!
    
    @IBOutlet weak var viaPointSeqView: UIView!
    
    
    func setUpUI(viaPoint : Location,index : Int,sequenceAlphabat : String,newViaPoint : Location?,selectedViaPointIndex : Int){
        
        let location : Location
        if selectedViaPointIndex == index && newViaPoint != nil {
            location = newViaPoint!
            self.viaPointView.backgroundColor = UIColor.white
        }else{
            location =  viaPoint
            self.viaPointView.backgroundColor = UIColor(netHex: 0xF5F5F5)
        }
        
        ViewCustomizationUtils.addCornerRadiusToView(view: viaPointView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: viaPointView, borderWidth: 1, color: UIColor(netHex: 0xE0E0E0))
        ViewCustomizationUtils.addCornerRadiusToView(view: viaPointSeqView, cornerRadius: 7.5)
        if selectedViaPointIndex != -1{
            if selectedViaPointIndex == index{
                removeViaPoint.isHidden = false
                removeViaPoint.imageView?.image = UIImage(named: "ref")
            }else{
                
                removeViaPoint.isHidden = true
            }
        }else{
            removeViaPoint.isHidden = false
            removeViaPoint.imageView?.image = UIImage(named: "ic_cancel")
        }
        
        if let address = location.completeAddress{
            self.viaPointName.text = address
        }else if let address = location.shortAddress{
            self.viaPointName.text = address
        }else if let address = location.address{
            self.viaPointName.text = address
        }else{
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.ViaPointCell", coordinate: CLLocationCoordinate2DMake(viaPoint.latitude, viaPoint.longitude)) { (location, error) in
                if let _ = location{
                    viaPoint.address = location!.address
                    self.viaPointName.text = location!.address
                }
            }
            
        }
        self.viaPointsLabel.text = sequenceAlphabat
        self.removeViaPoint.tag = index
    }
    
}
