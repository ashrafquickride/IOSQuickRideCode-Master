//
//  NewRideVehicleConfigurationViewController.swift
//  Quickride
//
//  Created by Admin on 16/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper
import DropDown

class NewRideVehicleConfigurationViewController : ModelViewController,UITextFieldDelegate{
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var vehicleConfigurationView: UIView!
    
    @IBOutlet weak var vehicleNumberTextField: UITextField!
    
    @IBOutlet weak var vehicleFareTextField: UITextField!
    
    @IBOutlet weak var vehicleSeatsTextField: UITextField!
    
    @IBOutlet weak var vehicleCategoryTextField: UITextField!
    
    @IBOutlet weak var vehicleFacilities: UITextField!
    
    @IBOutlet weak var vehicleConfigurationAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleModelLabel: UILabel!
    
    @IBOutlet weak var carView: UIView!
    
    @IBOutlet weak var carIcon: UIImageView!
    
    @IBOutlet weak var carLbl: UILabel!
    
    @IBOutlet weak var bikeView: UIView!
    
    @IBOutlet weak var bikeIcon: UIImageView!
    
    @IBOutlet weak var bikeLbl: UILabel!
    
    
    @IBOutlet weak var confirmButton: UIButton!
    
    
    @IBOutlet weak var totalVehicleHeight: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleModelView: UIView!
    
    
    @IBOutlet weak var helmetView: UIView!
    
    @IBOutlet weak var helmetViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pillionRiderRequiredToCarryHelmetBtn: UIButton!
    
    @IBOutlet weak var pillionRiderCarryingHelmetNotMandatoryBtn: UIButton!
    
    
    @IBOutlet weak var pillionRiderRequiredToCarryHelmetLbl: UILabel!
    
    @IBOutlet weak var pillionRiderCarryingHelmetNotMandatoryLbl: UILabel!
    
    
    @IBOutlet weak var fareTextFieldTopSpaceConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var offeringSeatsTextFieldTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var helmetViewTopSpaceConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var vehicleSeatsView: UIView!
    
    
    var rideConfigurationDelegate : RideConfigurationDelegate?
    var viewController : UIViewController?
    var vehicle : Vehicle?
    var vehicleType : String?
    var ride : RiderRide?
    var riderHasHelmet = false
    var seatsDropDown = DropDown()
    
    func initializeDataBeforePresenting(viewController: UIViewController,vehicle : Vehicle,ride : RiderRide?, rideConfigurationDelegate : RideConfigurationDelegate){
        self.viewController = viewController
        self.vehicle = vehicle
        self.ride = ride
        self.vehicleType = vehicle.vehicleType
        self.rideConfigurationDelegate = rideConfigurationDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewCustomizationUtils.addCornerRadiusToView(view: vehicleConfigurationView, cornerRadius: 5.0)
        vehicleNumberTextField.delegate = self
        vehicleFareTextField.delegate = self
        vehicleSeatsTextField.delegate = self
        vehicleCategoryTextField.delegate = self
        vehicleFacilities.delegate = self
        
        initializeAbdDisplayVehicleType()
        
        vehicleModelView.isUserInteractionEnabled = true
        
        vehicleModelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewRideVehicleConfigurationViewController.selectVehicleModel(_:))))
        pillionRiderRequiredToCarryHelmetBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewRideVehicleConfigurationViewController.piilionRiderShouldCarryHelmetView(_:))))
        pillionRiderRequiredToCarryHelmetLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewRideVehicleConfigurationViewController.piilionRiderShouldCarryHelmetView(_:))))
        pillionRiderCarryingHelmetNotMandatoryBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewRideVehicleConfigurationViewController.pillionRiderCarryingHelmetNotMandatoryView(_:))))
        pillionRiderCarryingHelmetNotMandatoryLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewRideVehicleConfigurationViewController.pillionRiderCarryingHelmetNotMandatoryView(_:))))
        vehicleSeatsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewRideVehicleConfigurationViewController.showSeatsDropDown(_:))))
        vehicleModelLabel.text = vehicle!.vehicleModel
        vehicleNumberTextField.text = vehicle!.registrationNumber
        setVehicleFareBasedOnApp(fare: vehicle!.fare)
        
        vehicleSeatsTextField.text = String(vehicle!.capacity)
        vehicleCategoryTextField.text = vehicle!.makeAndCategory
        vehicleFacilities.text = vehicle!.additionalFacilities
    
    }
    

    
    
    func initializeAbdDisplayVehicleType(){
        ViewCustomizationUtils.addCornerRadiusToView(view: carView, cornerRadius: 3.0)
        
        carView.isUserInteractionEnabled = true
        carView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewRideVehicleConfigurationViewController.carVehicleTypeViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: bikeView, cornerRadius: 3.0)
        
        bikeView.isUserInteractionEnabled = true
        bikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewRideVehicleConfigurationViewController.bikeVehicleTypeViewTapped(_:))))
        if vehicle!.vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            self.vehicleType = Vehicle.VEHICLE_TYPE_BIKE
        }else{
            self.vehicleType = Vehicle.VEHICLE_TYPE_CAR
        }
        enableVehicleTypeControlsBasedOnselectedType()
    }
    
    func enableVehicleTypeControlsBasedOnselectedType()
    {
        if vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            bikeView.backgroundColor = Colors.vehicleTypeSelcted
            bikeIcon.image = UIImage(named: "vehicle_type_bike_white")
            bikeLbl.textColor = UIColor(netHex: 0xFFFFFF)
            carView.backgroundColor = Colors.vehicleTypeNotSelcted
            carIcon.image = UIImage(named: "vehicle_type_car_grey")
            carLbl.textColor = UIColor(netHex: 0x606060)
            self.vehicleFacilities.placeholder = "Features (Ex. Helmet)"
            self.vehicleCategoryTextField.placeholder = "Make & Category (Ex. Black CBR)"
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            if !clientConfiguration.helmetMandatoryForRegion{
                self.helmetView.isHidden = true
                self.fareTextFieldTopSpaceConstraint.constant = 0
                self.helmetViewTopSpaceConstraint.constant = 0
                self.offeringSeatsTextFieldTopSpaceConstraint.constant = 0
                totalVehicleHeight.constant = totalVehicleHeight.constant - self.helmetViewHeightConstraint.constant
                self.helmetViewHeightConstraint.constant = 0
                self.riderHasHelmet = false
            }
            else{
                self.helmetView.isHidden = false
                self.helmetViewHeightConstraint.constant = 50
                self.helmetViewTopSpaceConstraint.constant = 10
                self.fareTextFieldTopSpaceConstraint.constant = 20
                self.offeringSeatsTextFieldTopSpaceConstraint.constant = 20
                totalVehicleHeight.constant = totalVehicleHeight.constant + self.helmetViewHeightConstraint.constant
                setHelmetOptionView()
            }
            
        }else{
            bikeView.backgroundColor = Colors.vehicleTypeNotSelcted
            bikeIcon.image = UIImage(named: "vehicle_type_bike_grey")
            bikeLbl.textColor = UIColor(netHex: 0x606060)
            carView.backgroundColor = Colors.vehicleTypeSelcted
            carIcon.image = UIImage(named: "vehicle_type_car_white")
            carLbl.textColor = UIColor(netHex: 0xFFFFFF)
            self.vehicleFacilities.placeholder = "Features (Ex. AC,Music,WIFI)"
            self.vehicleCategoryTextField.placeholder = "Make & Category (Ex. Red Swift)"
            self.helmetView.isHidden = true
            totalVehicleHeight.constant = totalVehicleHeight.constant - self.helmetViewHeightConstraint.constant
            self.helmetViewHeightConstraint.constant = 0
            self.riderHasHelmet = false
        }
        
        setupSeatsDropDown()
    }
    
    @objc func carVehicleTypeViewTapped(_ gesture : UITapGestureRecognizer){
        vehicleType = Vehicle.VEHICLE_TYPE_CAR
        enableVehicleTypeControlsBasedOnselectedType()
        if self.vehicle != nil && vehicleType == self.vehicle!.vehicleType{
            updteVehicleDetailsWhenModelChanged(vehicle: self.vehicle!, fillCompleteVehicleDeails : false)
        }
        else{
            let vehicle = VehicleModelAlertController().getVehicleObjectForModel(vehicleModel: nil,vehicleType: vehicleType!)
            updteVehicleDetailsWhenModelChanged(vehicle: vehicle, fillCompleteVehicleDeails : false)
        }
        
    }
    @objc func bikeVehicleTypeViewTapped(_ gesture : UITapGestureRecognizer){
        setHelmetOptionView()
        vehicleType = Vehicle.VEHICLE_TYPE_BIKE
        enableVehicleTypeControlsBasedOnselectedType()
        if self.vehicle != nil && vehicleType == self.vehicle!.vehicleType{
            updteVehicleDetailsWhenModelChanged(vehicle: self.vehicle!, fillCompleteVehicleDeails : false)
        }
        else{
            let vehicle = VehicleModelAlertController().getVehicleObjectForModel(vehicleModel: nil,vehicleType: vehicleType!)
            updteVehicleDetailsWhenModelChanged(vehicle: vehicle, fillCompleteVehicleDeails : false)
        }
    }
    
    func updteVehicleDetailsWhenModelChanged(vehicle : Vehicle, fillCompleteVehicleDeails : Bool){
        
        self.vehicleModelLabel.text = vehicle.vehicleModel
        self.vehicleSeatsTextField.text = String(vehicle.capacity)
        setVehicleFareBasedOnApp(fare: vehicle.fare)
        
        if (vehicleType == self.vehicle?.vehicleType && vehicleModelLabel.text == self.vehicle?.vehicleModel) || fillCompleteVehicleDeails{
            self.vehicleNumberTextField.text = self.vehicle!.registrationNumber
            self.vehicleFacilities.text = self.vehicle!.additionalFacilities
            self.vehicleCategoryTextField.text = self.vehicle!.makeAndCategory
        }else{
            self.vehicleNumberTextField.text = nil
            self.vehicleNumberTextField.placeholder = Strings.regNo_placeholder
        }
    }
    
    func setVehicleFareBasedOnApp(fare : Double){
        
        vehicleFareTextField.isEnabled = true
        vehicleFareTextField.text = String(fare)
        vehicleFareTextField.alpha = 1.0
        
    }
    
    
    func initializeHelmetView(){
        if riderHasHelmet{
        
            pillionRiderRequiredToCarryHelmetBtn.setImage(UIImage(named: "radio_button_checked"), for: .normal)
            pillionRiderCarryingHelmetNotMandatoryBtn.setImage(UIImage(named: "radio_button_unchecked"), for: .normal)

        }else{
            
            pillionRiderRequiredToCarryHelmetBtn.setImage(UIImage(named: "radio_button_unchecked"), for: .normal)
            pillionRiderCarryingHelmetNotMandatoryBtn.setImage(UIImage(named: "radio_button_checked"), for: .normal)
    
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        vehicleConfigurationAlignmentConstraint.constant = -150
        if textField == vehicleFareTextField || textField == vehicleSeatsTextField{
            addDoneButton(textField: textField)
        }
    }
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        
        textField.inputAccessoryView = keyToolBar
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        vehicleConfigurationAlignmentConstraint.constant = 0
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func removeKeyBoard(){
        
        vehicleNumberTextField.endEditing(false)
        vehicleFareTextField.endEditing(false)
        vehicleSeatsTextField.endEditing(false)
        vehicleCategoryTextField.endEditing(false)
        vehicleFacilities.endEditing(false)
    }
    
    @objc func selectVehicleModel(_ gesture : UITapGestureRecognizer){
        VehicleModelAlertController(viewController: viewController!,vehicleType: vehicleType!, showTaxi: true).displayVehicleModelAlertController { (vehicle) in
            vehicle?.vehicleId = self.vehicle!.vehicleId
            self.vehicle = vehicle
            self.vehicleModelLabel.text = vehicle!.vehicleModel
            self.setVehicleFareBasedOnApp(fare: vehicle!.fare)
            
            self.vehicleSeatsTextField.text = String(vehicle!.capacity)
            self.vehicleNumberTextField.text = nil
            self.vehicleNumberTextField.placeholder = Strings.regNo_placeholder
        }
    }
    
    @objc func piilionRiderShouldCarryHelmetView (_ gestureRecognizer: UITapGestureRecognizer) {
        riderHasHelmet = true
        
        initializeHelmetView()
    }
    @objc func pillionRiderCarryingHelmetNotMandatoryView (_ gestureRecognizer: UITapGestureRecognizer) {
        
        riderHasHelmet = false
        initializeHelmetView()
        
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        
        removeKeyBoard()
        
        let errorMsg = VehicleRelatedValidations.validateFieldsAndReturnErrorMsg(offeredSeats: vehicleSeatsTextField.text!, vehicleNumber:vehicleNumberTextField.text! , vehicleFare: vehicleFareTextField.text!, makeAndCategory: vehicleCategoryTextField.text!,vehicleModel: vehicleModelLabel.text!,vehicleType : vehicleType!)
        if (errorMsg != nil) {
            MessageDisplay.displayAlert( messageString: errorMsg!, viewController: self,handler: nil)
            return
        }
        vehicle?.ownerId = Double(QRSessionManager.getInstance()!.getUserId())!
        vehicle?.capacity = Int(vehicleSeatsTextField.text!)!
        vehicle?.vehicleModel = vehicleModelLabel.text!
        vehicle?.registrationNumber = vehicleNumberTextField.text!
        
        vehicle?.fare = Double(vehicleFareTextField.text!)!
        
        
        vehicle?.makeAndCategory = vehicleCategoryTextField.text!
        vehicle?.additionalFacilities = vehicleFacilities.text!
        vehicle?.vehicleType = vehicleType
        vehicle?.riderHasHelmet = self.riderHasHelmet
        if ride != nil
        {
            if (vehicle?.capacity)! < self.ride!.capacity - self.ride!.availableSeats{
                UIApplication.shared.keyWindow?.makeToast( Strings.vehicle_update_capacity)
                return
            }
        }
            vehicle?.defaultVehicle = true
            if vehicle!.registrationNumber.isEmpty
            {
                MessageDisplay.displayAlert(messageString: Strings.valid_registration_number_alert, viewController: self, handler: nil)
                return
            }
            QuickRideProgressSpinner.startSpinner()
            ProfileRestClient.createVehicle(params: vehicle!.getParamsMap(), targetViewController: self, completionHandler: { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    self.vehicle = Mapper<Vehicle>().map(JSONObject: responseObject!["resultData"])
                    UserDataCache.getInstance()?.storeVehicle(vehicle: self.vehicle!)
                    self.removeCurrentViewAndNavigateToCalledViewController(vehicle: self.vehicle!)
                    AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.VEHICLE_ADDED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "","Car/Bike": self.vehicle?.vehicleType ?? ""], uniqueField: User.FLD_USER_ID)
                }else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            })
      
    }
    
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        removeKeyBoard()
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
    
    func removeCurrentViewAndNavigateToCalledViewController(vehicle: Vehicle){
        self.rideConfigurationDelegate?.vehicleConfigurationConfirmed(vehicle: vehicle)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        
        if  textField == vehicleNumberTextField || textField == vehicleFareTextField || textField == vehicleCategoryTextField || textField == vehicleFacilities{
            threshold = 250
        }else if textField == vehicleSeatsTextField{
            threshold = 2
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    func setHelmetOptionView(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if !clientConfiguration.helmetMandatoryForRegion{
            self.riderHasHelmet = false
        }
        else{
            self.riderHasHelmet = vehicle!.riderHasHelmet
        }
        initializeHelmetView()
    }
    
    func setupSeatsDropDown() {
        seatsDropDown.anchorView = vehicleSeatsTextField
        seatsDropDown.dataSource = [Vehicle.VEHICLE_SEAT_CAPACITY_1,Vehicle.VEHICLE_SEAT_CAPACITY_2,Vehicle.VEHICLE_SEAT_CAPACITY_3,Vehicle.VEHICLE_SEAT_CAPACITY_4,Vehicle.VEHICLE_SEAT_CAPACITY_5,Vehicle.VEHICLE_SEAT_CAPACITY_6]
        
        
        seatsDropDown.selectionAction = { [weak self] (index, item) in
            self?.vehicleSeatsTextField.text = item
        }
    }
    
    @objc func showSeatsDropDown(_ gesture : UITapGestureRecognizer){
        seatsDropDown.show()
    }
}
