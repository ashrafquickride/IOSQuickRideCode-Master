//
//  VehicleFilterTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 24/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol VehicleFilterTableViewCellDelegate: class {
    func selectedVehicleOption(vehicleType: String)
}

class VehicleFilterTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak fileprivate var carButton: UIButton!
    @IBOutlet weak fileprivate var bikeButton: UIButton!
    @IBOutlet weak fileprivate var carLabel: UILabel!
    @IBOutlet weak fileprivate var bikeLabel: UILabel!
    @IBOutlet weak fileprivate var carImage: UIImageView!
    @IBOutlet weak fileprivate var bikeImage: UIImageView!
    
    //MARK: Properties
    weak var delegate: VehicleFilterTableViewCellDelegate?
    private var vehicleOption: String?
    
    func initializeVehicleFilterOption(vehicleCriteria: String?){
        vehicleOption = vehicleCriteria
        if vehicleCriteria == DynamicFiltersCache.PREFERRED_VEHICLE_CAR{
            carOptionTapped()
        }else if vehicleCriteria == DynamicFiltersCache.PREFERRED_VEHICLE_BIKE{
            bikeOptionTapped()
        }else{
            vehicleOptionNotSelected()
        }
    }
    
    private func carOptionTapped(){
        //selecetd
        ViewCustomizationUtils.addBorderToView(view: carButton, borderWidth: 1, colorCode: 0x007AFF)
        carImage.image = UIImage(named: "car_blue")
        carLabel.textColor = UIColor(netHex: 0x007AFF)
        
        //Diselected
        ViewCustomizationUtils.addBorderToView(view: bikeButton, borderWidth: 1, colorCode: 0xF1F1F1)
        let image = UIImage(named: "blue_bike_icon")
        bikeImage.image = image?.withRenderingMode(.alwaysTemplate)
        bikeImage.tintColor = UIColor.black.withAlphaComponent(0.4)
        bikeLabel.textColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    private func bikeOptionTapped(){
        //selecetd
        ViewCustomizationUtils.addBorderToView(view: bikeButton, borderWidth: 1, colorCode: 0x007AFF)
        bikeImage.image = UIImage(named: "blue_bike_icon")
        bikeLabel.textColor = UIColor(netHex: 0x007AFF)
        
        //Diselected
        ViewCustomizationUtils.addBorderToView(view: carButton, borderWidth: 1, colorCode: 0xF1F1F1)
        carImage.image = UIImage(named: "car_gray")
        carLabel.textColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    private func vehicleOptionNotSelected(){
        ViewCustomizationUtils.addBorderToView(view: bikeButton, borderWidth: 1, colorCode: 0xF1F1F1)
        let image = UIImage(named: "blue_bike_icon")
        bikeImage.image = image?.withRenderingMode(.alwaysTemplate)
        bikeImage.tintColor = UIColor.black.withAlphaComponent(0.4)
        bikeLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        ViewCustomizationUtils.addBorderToView(view: carButton, borderWidth: 1, colorCode: 0xF1F1F1)
        carImage.image = UIImage(named: "car_gray")
        carLabel.textColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    //MARK: Action
    @IBAction func carButtonTapped(_ sender: UIButton) {
        if vehicleOption == DynamicFiltersCache.PREFERRED_VEHICLE_CAR{
            vehicleOptionNotSelected()
            vehicleOption = DynamicFiltersCache.PREFERRED_ALL
            delegate?.selectedVehicleOption(vehicleType: DynamicFiltersCache.PREFERRED_ALL)
        }else{
            carOptionTapped()
            vehicleOption = DynamicFiltersCache.PREFERRED_VEHICLE_CAR
            delegate?.selectedVehicleOption(vehicleType: DynamicFiltersCache.PREFERRED_VEHICLE_CAR)
        }
    }
    
    @IBAction func bikeButtonTapped(_ sender: UIButton) {
        if vehicleOption == DynamicFiltersCache.PREFERRED_VEHICLE_BIKE{
            vehicleOptionNotSelected()
            vehicleOption = DynamicFiltersCache.PREFERRED_ALL
            delegate?.selectedVehicleOption(vehicleType: DynamicFiltersCache.PREFERRED_ALL)
        }else{
            bikeOptionTapped()
            vehicleOption = DynamicFiltersCache.PREFERRED_VEHICLE_BIKE
            delegate?.selectedVehicleOption(vehicleType: DynamicFiltersCache.PREFERRED_VEHICLE_BIKE)
        }
    }
    
}

