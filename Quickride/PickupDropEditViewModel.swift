//
//  PickupDropEditViewModel.swift
//  Quickride
//
//  Created by Vinutha on 10/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import Polyline

class PickupDropEditViewModel {
    
    var matchedRoutePolyline: GMSPolyline?
    
    var isLocationChanged = false
    var isFromEditPickup = true
    
    var currentLatLng = CLLocationCoordinate2D()
    var currentAddress: String?
    var changedLatLng = CLLocationCoordinate2D()
    var changedAddress: String?
    var matchedUserRoute: [CLLocationCoordinate2D]?
    var note: String?
    var isFromTaxi = false

    
    init() {}
    
    init(currentLatLng: CLLocationCoordinate2D,currentAddress: String?,isFromEditPickup: Bool,routePolyline: String,note: String?) {
        self.currentLatLng = currentLatLng
        self.currentAddress = currentAddress
        self.isFromEditPickup = isFromEditPickup
        let polyLine = Polyline(encodedPolyline: routePolyline)
        self.matchedUserRoute = polyLine.coordinates
        self.note = note
    }
}
