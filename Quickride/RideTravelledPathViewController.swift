//
//  RideTravelledPathViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 28/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import GoogleMaps

class RideTravelledPathViewController : UIViewController,GMSMapViewDelegate {
    
    
    var travelledPath :String? = nil
    
    weak var viewMap: GMSMapView!
    
    @IBOutlet weak var mapViewContainer: UIView!
    override func viewDidLoad() {
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        viewMap.delegate = self
        let path = GMSPath(fromEncodedPath: travelledPath!)
        GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: path!.coordinate(at: 0), end: path!.coordinate(at: path!.count()-1), route: travelledPath!, map: viewMap, colorCode: UIColor(netHex: 0x1da0f9), width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_10)
        GoogleMapUtils.fitToScreen(route: travelledPath!, map: viewMap)
    }
    
    @IBAction func clickOnCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
