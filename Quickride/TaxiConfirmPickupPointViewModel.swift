//
//  TaxiConfirmPickupPointViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 03/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps

class TaxiConfirmPickupPointViewModel {
    
    var taxiRide: TaxiRidePassenger?
    var delegate: TaxiPickupSelectionDelegate?
    
    init() {}
    
    init(taxiRide: TaxiRidePassenger,delegate: TaxiPickupSelectionDelegate) {
        self.taxiRide = taxiRide
        self.delegate = delegate
    }
    func assignChangedValues(changedLatLng: CLLocationCoordinate2D,address: String?,note: String?) {
        taxiRide?.startLat = changedLatLng.latitude
        taxiRide?.startLng = changedLatLng.longitude
        taxiRide?.startAddress = address
        if let pickupNote = note {
            taxiRide?.pickupNote = pickupNote
        }
    }
}
