//
//  QRMapView.swift
//  Quickride
//
//  Created by rakesh on 1/17/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
class QRMapView: UIView {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    static func getQRMapView(mapViewContainer :UIView) -> GMSMapView{
        let mapView = (loadFromNibNamed(nibNamed: "QuickRideMapView") as? QRMapView)
        do {
            if let styleURL = Bundle.main.url(forResource: "google_map_style", withExtension: "json") {
                mapView!.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        mapView!.frame = CGRect(x: 0, y: 0, width: mapViewContainer.frame.size.width, height: mapViewContainer.frame.size.height)
        mapViewContainer.addSubview(mapView!)
        mapView!.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 40)
        return mapView!.mapView
    }
}
