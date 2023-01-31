//
//  OutstationTaxiDetailsTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 01/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OutstationTaxiDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var taxiNameLabel: UILabel!
    @IBOutlet weak var taxiImageView: UIImageView!
    @IBOutlet weak var taxiModelNameLabel: UILabel!
    @IBOutlet weak var taxiSeatesLabel: UILabel!
    
    var fareForVehicleClass: FareForVehicleClass?
    var taxiridePassenger: TaxiRidePassenger?
    private var actionComplitionHandler: actionComplitionHandler?
    
    func setupUI(fareForVehicleClass: FareForVehicleClass, destinationCity: String?, tripType: String?, actionComplitionHandler: @escaping actionComplitionHandler){
        self.actionComplitionHandler = actionComplitionHandler
        self.fareForVehicleClass = fareForVehicleClass
        setImageAndNameOfVehicle(taxiClass: fareForVehicleClass.vehicleClass ?? "")
        
        taxiSeatesLabel.text = "\(fareForVehicleClass.seatCapacity ?? 0) Seater"
        if let tripType = tripType, tripType != "", let destinationCity = destinationCity, destinationCity != "", let city = destinationCity.components(separatedBy: ",").first {
            if tripType == TaxiRidePassenger.oneWay{
                headerLabel.text = Strings.one_way + " to " + city
            }else if tripType == TaxiRidePassenger.roundTrip {
                headerLabel.text = Strings.round_trip + " to " + city
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        actionComplitionHandler!(true)
    }
    private func setImageAndNameOfVehicle(taxiClass: String) {
        taxiModelNameLabel.text = fareForVehicleClass?.vehicleDescription
        switch taxiClass {
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_HATCH_BACK:
            taxiImageView.image = UIImage(named: "icon_hatchback")
            taxiNameLabel.text = Strings.hatchBack
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SEDAN:
            taxiImageView.image = UIImage(named: "sedan_taxi")
            taxiNameLabel.text = Strings.sedan
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV:
            taxiImageView.image = UIImage(named: "outstation_SUV")
            taxiNameLabel.text = Strings.suv
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_CROSS_OVER:
            taxiImageView.image = UIImage(named: "outstation_SUV")
            taxiNameLabel.text = Strings.suv
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_TT:
            taxiImageView.image = UIImage(named: "Tempo")
            taxiNameLabel.text = "Tempo"
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_BIKE:
            taxiImageView.image = UIImage(named: "bike_taxi_pool")
            taxiNameLabel.text = Strings.bike
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_AUTO:
            taxiImageView.image = UIImage(named: "auto")
            taxiNameLabel.text = "Auto"
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_ANY:
            taxiImageView.image = UIImage(named: "sharing")
            taxiNameLabel.text = Strings.sharing
        default:
            taxiImageView.image = UIImage(named: "sedan_taxi")
            taxiNameLabel.text = Strings.sedan
        }
    }
}
