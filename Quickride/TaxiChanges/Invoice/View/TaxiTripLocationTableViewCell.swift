//
//  TaxiTripLocationTableViewCell.swift
//  Quickride
//
//  Created by HK on 27/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiTripLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var journeyTypeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    func initialiseLocations(taxiRide: TaxiRidePassenger?,taxiRideInvoice: TaxiRideInvoice?){
        fromLabel.text = taxiRide?.startAddress
        toLabel.text = taxiRide?.endAddress
        distanceLabel.text = String(taxiRide?.finalDistance?.roundToPlaces(places: 1) ?? 0) + " Km"
        if taxiRide?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
            journeyTypeLabel.text = taxiRide?.journeyType
        }
        idLabel.text = "ID " + StringUtils.getStringFromDouble(decimalNumber: taxiRideInvoice?.id)
    }
}
