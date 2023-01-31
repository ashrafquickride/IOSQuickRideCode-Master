//
//  TaxiEditViaPointTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 4/27/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

class TaxiEditViaPointTableViewCell: UITableViewCell {

    @IBOutlet weak var viaPointName: UILabel!
    
    @IBOutlet weak var viaPointView: UIView!
    
    @IBOutlet weak var removeViaPoint: UIButton!

    @IBOutlet weak var viaPointsLabel: UILabel!
    
    @IBOutlet weak var viaPointSeqView: UIView!
    
    var index: Int = -1
    
    @IBAction func removeViaPoint(_ sender: Any) {
        var userInfo = [String: Any]()
        userInfo["index"] = index
        NotificationCenter.default.post(name: .viaPointsChanged, object: self, userInfo: userInfo)
    }
    func setUpUI(viaPoint : Location,index : Int){
        self.index = index
        self.viaPointView.backgroundColor = UIColor(netHex: 0xF5F5F5)
        
        ViewCustomizationUtils.addCornerRadiusToView(view: viaPointView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: viaPointView, borderWidth: 1, color: UIColor(netHex: 0xE0E0E0))
        ViewCustomizationUtils.addCornerRadiusToView(view: viaPointSeqView, cornerRadius: 7.5)
        removeViaPoint.isHidden = false
        removeViaPoint.imageView?.image = UIImage(named: "ic_cancel")
        
        
         if let address = viaPoint.shortAddress{
            self.viaPointName.text = address
        }else if let address = viaPoint.completeAddress{
            self.viaPointName.text = address
        }else if let address = viaPoint.address{
            self.viaPointName.text = address
        }else{
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.ViaPointCell", coordinate: CLLocationCoordinate2DMake(viaPoint.latitude, viaPoint.longitude)) { (location, error) in
                if let _ = location{
                    viaPoint.address = location!.address
                    self.viaPointName.text = location!.address
                }
            }
            
        }
        self.viaPointsLabel.text = TaxiUtils.getSequenceAlphabetFor(index: index)
        self.removeViaPoint.tag = index
    }
    
    
    
}
