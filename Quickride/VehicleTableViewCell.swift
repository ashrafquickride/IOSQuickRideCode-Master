//
//  VehicleTableViewCell.swift
//  Quickride
//
//  Created by QuickRideMac on 8/31/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import UIKit
import ObjectMapper

protocol VehicleUpdateDelegate: class{
    func userVehicleInfoChanged()
}

class VehicleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vehicleName: UILabel!
    
    @IBOutlet weak var menuOptnBtn: UIButton!
    
    @IBOutlet weak var defaultLabel: UIButton!
    
    @IBOutlet weak var defaultLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleRegistrationNumber: UILabel!
    
    @IBOutlet weak var vehicleImage: UIImageView!
    
    @IBOutlet weak var vehicleCapacity: UILabel!
    
    @IBOutlet weak var vehicleFare: UILabel!
    
    @IBOutlet weak var seatLabel: UILabel!
    
    @IBOutlet weak var vehicleImageBackgroundView: UIView!
    
    @IBOutlet weak var defaultLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var seatLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleImageLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleImageViewHeightConstraint: NSLayoutConstraint!

    
    var vehicle : Vehicle?
    var isRiderProfile : Bool?
    weak var listener : VehicleUpdateDelegate?
    var isFromProfile = false
    var userVehiclesCount: Int?
    weak var viewController : UIViewController?
    
    func initializeViews(vehicle : Vehicle, isRiderProfile : Bool, isFromProfile : Bool, userVehiclesCount: Int, viewController : UIViewController, listener : VehicleUpdateDelegate)
    {
        self.vehicle = vehicle
        self.isRiderProfile = isRiderProfile
        self.viewController = viewController
        self.listener = listener
        self.isFromProfile = isFromProfile
        self.userVehiclesCount = userVehiclesCount
        
        if isRiderProfile
        {
            self.defaultLabel.isHidden = true
            self.defaultLabelHeightConstraint.constant = 0
            self.menuOptnBtn.isHidden = true
        }
        else
        {
            self.defaultLabel.isHidden = false
            self.defaultLabelHeightConstraint.constant = 15
            self.menuOptnBtn.isHidden = false
        }
        if self.vehicle!.defaultVehicle == true
        {
            if userVehiclesCount == 1 {
                self.menuOptnBtn.isHidden = false
                self.defaultLabel.isHidden = true
            }
            else{
                self.menuOptnBtn.isHidden = true
                self.defaultLabel.isHidden = false
                self.defaultLabelHeightConstraint.constant = 15
                self.defaultLabelWidthConstraint.constant = 65
                defaultLabel.layer.masksToBounds = true
                defaultLabel.layer.cornerRadius = 5.0
            }
        }
        else
        {
            self.defaultLabel.isHidden = true
            self.defaultLabelHeightConstraint.constant = 0
            self.defaultLabelWidthConstraint.constant = 0
        }
        
        ImageCache.getInstance().setVehicleImage(imageView: self.vehicleImage, imageUrl: vehicle.imageURI, model: vehicle.vehicleModel, imageSize: ImageCache.DIMENTION_SMALL)
        if self.vehicle!.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
            self.vehicleCapacity.isHidden = false
            self.seatLabel.isHidden = false
            self.vehicleCapacity.text = String(vehicle.capacity)
            seatLabelWidthConstraint.constant = 50
        }
        else{
            self.vehicleCapacity.isHidden = true
            self.seatLabel.isHidden = true
            seatLabelWidthConstraint.constant = 0
        }
        if vehicle.imageURI != nil{
            if isFromProfile{
                vehicleImageLeadingConstraint.constant = 0
                self.vehicleImage.layoutIfNeeded()
                vehicleImageViewWidthConstraint.constant = 70
                vehicleImageViewHeightConstraint.constant = 70
                vehicleImage.layer.cornerRadius = 8
                vehicleImage.clipsToBounds = true
            }
            else{
                vehicleImageViewWidthConstraint.constant = 89
                vehicleImageViewHeightConstraint.constant = 89
                vehicleImageLeadingConstraint.constant = 8
                vehicleImage.layer.cornerRadius = 8
                vehicleImage.clipsToBounds = true
                self.vehicleImage.layoutIfNeeded()
            }
            
        }
        else{
            if isFromProfile{
                vehicleImageLeadingConstraint.constant = 8
                self.vehicleImage.layoutIfNeeded()
                vehicleImageViewWidthConstraint.constant = 60
                vehicleImageViewHeightConstraint.constant = 50
            self.vehicleImageBackgroundView.backgroundColor = UIColor(netHex: 0xD4F4FF)
            }
            else{
                vehicleImageViewWidthConstraint.constant = 110
                vehicleImageViewHeightConstraint.constant = 110
                vehicleImageLeadingConstraint.constant = 20
                self.vehicleImage.layoutIfNeeded()
            }
        }
        if isFromProfile{
            self.seatLabel.isHidden = true
            self.vehicleCapacity.isHidden = true
            vehicleName.text = vehicle.vehicleModel
            vehicleRegistrationNumber.text = vehicle.registrationNumber
            ViewCustomizationUtils.addCornerRadiusToView(view: self.vehicleImageBackgroundView, cornerRadius: 10)
        }
        else{
            ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: self.vehicleImageBackgroundView, cornerRadius: 20, corner1: .topRight, corner2: .bottomRight)
            vehicleName.text = vehicle.vehicleModel
            if vehicle.makeAndCategory != nil && !vehicle.makeAndCategory!.isEmpty{
                vehicleRegistrationNumber.text = vehicle.makeAndCategory!+" - "+vehicle.registrationNumber
            }
            else{
                vehicleRegistrationNumber.text = vehicle.registrationNumber
            }
        }
        vehicleImage.layer.cornerRadius = 8

        self.vehicleFare.text = StringUtils.getPointsInDecimal(points: vehicle.fare)
    }
    
    @IBAction func menuBtntapped(_ sender: Any) {
        if viewController == nil{
            return
        }
        let alertController : VehicleSettingAlertController = VehicleSettingAlertController(viewController: self.viewController!) { (result) -> Void in
            if result == Strings.make_default
            {
                self.vehicle?.status = Vehicle.VEHICLE_STATUS_ACTIVE
                self.vehicle?.defaultVehicle = true
                self.updateVehicleStatus(status: Strings.make_default)
            }
            else if result ==  Strings.remove
            {
                self.vehicle?.status = Vehicle.VEHICLE_STATUS_INACTIVE
                self.updateVehicleStatus(status: Strings.remove)
            }
        }
        if self.vehicle!.defaultVehicle == false{
            alertController.defaultAlertAction()
        }
        alertController.removeAlertAction()
        alertController.cancelAlertAction()
        alertController.showAlertController()
    }
    
    func updateVehicleStatus(status : String)
    {
        QuickRideProgressSpinner.startSpinner()
        ProfileRestClient.updateVehicle(params: self.vehicle!.getParamsMap(), targetViewController: self.viewController) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.vehicle = Mapper<Vehicle>().map(JSONObject: responseObject!["resultData"])
                if status == Strings.remove
                {
                    UserDataCache.getInstance()?.deleteVehicle(vehicle: self.vehicle!)
                }
                else
                {
                    UserDataCache.getInstance()?.updateUserDefaultVehicle(vehicle: self.vehicle!)
                }
                self.listener?.userVehicleInfoChanged()
            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        }
    }
}
