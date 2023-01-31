//
//  AddVehicleDetailsViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 9/20/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AddVehicleDetailsViewController: VehicleSavingBaseViewController
{
    //MARK: Outlets
    @IBOutlet weak var continueActnBtn: UIButton!
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var vehicleDetailsView: UIView!
    
    @IBOutlet weak var carTypeSelectedImageView: UIImageView!
    
    @IBOutlet weak var bikeTypeSelectedImageView: UIImageView!
    
    
    //MARK: Properties
    private var addVehicleDetailsViewModel = AddVehicleDetailsViewModel()
    
    func initialiseData(isFromSignUpFlow: Bool){
        self.addVehicleDetailsViewModel = AddVehicleDetailsViewModel(isFromSignUpFlow: isFromSignUpFlow)
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad()
    {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        continueActionColorChange()
    }
    
    
    //MARK: Action
    @IBAction func continueBtnTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("")
        if QRReachability.isConnectedToNetwork() == false{
            view.endEditing(true)
            UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
            return
        }
        let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny()
        if (validationErrorMsg != nil) {
            view.endEditing(true)
            UIApplication.shared.keyWindow?.makeToast( validationErrorMsg!)
            return
        }
        
        if vehicle!.registrationNumber != vehicleNumberTextField.text || vehicle!.vehicleModel != vehicleModelLabel.text{
            saveVehicleDetails()
        }
    }
    
    //MARK: Methods
    
    func setupUI(){
        navigationController?.setNavigationBarHidden(false, animated: false)
        vehicleNumberTextField.text = vehicle!.registrationNumber
        animateUI()
        vehicleModelLabel.text = vehicle!.vehicleModel
        ViewCustomizationUtils.addCornerRadiusToView(view: continueActnBtn, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: vehicleDetailsView, cornerRadius: 30.0, corner1: .topLeft, corner2: .topRight)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddVehicleDetailsViewController.dismissViewTapped(_:))))
        vehicleNumberTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        ViewCustomizationUtils.addCornerRadiusToView(view: carVehicleTypeView, cornerRadius: 5.0)
        carVehicleTypeView.isUserInteractionEnabled = true
        carVehicleTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddVehicleDetailsViewController.carVehicleTypeViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: bikeVehicleTypeView, cornerRadius: 5.0)
        bikeVehicleTypeView.isUserInteractionEnabled = true
        bikeVehicleTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddVehicleDetailsViewController.bikeVehicleTypeViewTapped(_:))))
        handleVehicleChange()
    }
    
    func animateUI(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: {
                        self.vehicleDetailsView.frame = CGRect(x: 0, y: -300, width: self.vehicleDetailsView.frame.width, height: self.vehicleDetailsView.frame.height)
                        self.vehicleDetailsView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func saveVehicleDetails() {
        view.endEditing(true)
        vehicle!.registrationNumber =  vehicleNumberTextField.text!
        vehicle!.ownerId = Double(currentUserId ?? "0")!
        vehicle!.vehicleModel =  vehicleModelLabel.text!
        vehicle!.vehicleType = vehicleType
        vehicle!.defaultVehicle = true
        vehicle!.riderHasHelmet = riderHasHelmet
        saveUserVehicle()
    }
    @objc func dismissViewTapped(_ sender: UITapGestureRecognizer) {
        closeView(isdismissViewTapped: true)
    }
    func validateFieldsAndReturnErrorMsgIfAny() -> String? {
        let input = vehicleNumberTextField.text
        if input == nil || input!.isEmpty{
            return Strings.valid_registration_number_alert
        }
        else
        {
            return nil
        }
    }
    
    override func vehicleModelTapped(_ gesture: UITapGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("vehicleTypeClicked()")
        if vehicle == nil{
            return
        }
        let vehicleModelAlertController = VehicleModelAlertController(viewController: self,vehicleType: vehicleType,showTaxi: false)
        vehicleModelAlertController.displayVehicleModelAlertController { [weak self](vehicle) -> Void in
            self?.vehicleModelLabel.text = vehicle!.vehicleModel
            self?.vehicle!.capacity = vehicle!.capacity
            self?.vehicle!.fare = vehicle!.fare
            self?.isVehicleUpdated = true
        }
    }
    
    override func updteVehicleDetailsWhenModelChanged(vehicle : Vehicle)
    {
        super.updteVehicleDetailsWhenModelChanged(vehicle: vehicle)
        let newVehicle = VehicleModelAlertController().getVehicleObjectForModel(vehicleModel: vehicle.vehicleModel,vehicleType: vehicleType)
        self.vehicle!.capacity = newVehicle.capacity
        self.vehicle!.fare = newVehicle.fare
    }
    
    private func handleUIChangeBasedOnVehicleType(){
        if vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            ViewCustomizationUtils.addBorderToView(view: bikeVehicleTypeView, borderWidth: 1.0, color: UIColor(netHex: 0x6c6c6c))
            ViewCustomizationUtils.addBorderToView(view: carVehicleTypeView, borderWidth: 1.0, color: UIColor(netHex: 0xcdcdcd))
            bikeTypeSelectedImageView.isHidden = false
            carTypeSelectedImageView.isHidden = true
            helmetView.isHidden = false
            helmetViewHeight.constant = 80
        }else{
            ViewCustomizationUtils.addBorderToView(view: bikeVehicleTypeView, borderWidth: 1.0, color: UIColor(netHex: 0xcdcdcd))
            ViewCustomizationUtils.addBorderToView(view: carVehicleTypeView, borderWidth: 1.0, color: UIColor(netHex: 0x6c6c6c))
            bikeTypeSelectedImageView.isHidden = true
            carTypeSelectedImageView.isHidden = false
            helmetView.isHidden = true
            helmetViewHeight.constant = 0
        }
    }
    
    @objc func carVehicleTypeViewTapped(_ gesture : UITapGestureRecognizer){
        vehicleType = Vehicle.VEHICLE_TYPE_CAR
        handleVehicleChange()
        
    }
    @objc func bikeVehicleTypeViewTapped(_ gesture : UITapGestureRecognizer){
        vehicleType = Vehicle.VEHICLE_TYPE_BIKE
        handleVehicleChange()
    }
    
    private func handleVehicleChange(){
        handleUIChangeBasedOnVehicleType()
        if vehicleType == Vehicle.VEHICLE_TYPE_CAR{
            initialCapacity = vehicle?.capacity
            carVehicleTypeViewTapped()
        }else{
            initialCapacity = 1
            bikeVehicleTypeViewTapped()
            setHelmetOptionView()
        }
    }
    
    private func saveUserVehicle()
    {
        let vehicleStatus = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_VEHICLE_DETAILS)
        if vehicleStatus == nil || vehicleStatus == false{
            QuickRideProgressSpinner.startSpinner()
            addVehicleDetailsViewModel.createVehicle(vehicle: vehicle!, viewController: self) { [weak self](responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                self?.handleResponseOfVehicleCreation(responseObject: responseObject, error: error)
            }
        }else{
            QuickRideProgressSpinner.startSpinner()
            addVehicleDetailsViewModel.updateVehicle(vehicle: vehicle!, viewController: self) { [weak self] (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                self?.handleResponseOfVehicleUpdation(responseObject: responseObject, error: error)
            }
        }
    }
    private func handleResponseOfVehicleCreation(responseObject : NSDictionary?,error : NSError?){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
            guard let vehicle = Mapper<Vehicle>().map(JSONObject: responseObject!["resultData"]) else { return }
            self.vehicle = vehicle
            UserDataCache.getInstance()?.storeVehicle(vehicle: vehicle)
            SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_VEHICLE_DETAILS, value: true)
            closeView(isdismissViewTapped: false)
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.VEHICLE_ADDED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "","Car/Bike": self.vehicle?.vehicleType ?? ""], uniqueField: User.FLD_USER_ID)
        }else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
        listener?.VehicleDetailsUpdated()
    }
    
    private func handleResponseOfVehicleUpdation(responseObject : NSDictionary?,error : NSError?){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            vehicle = Mapper<Vehicle>().map(JSONObject: responseObject!["resultData"])
            UserDataCache.getInstance()?.vehicle = vehicle
            closeView(isdismissViewTapped: false)
        }else{
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
        
        listener?.VehicleDetailsUpdated()
    }
    
    private func continueActionColorChange(){
        if vehicleNumberTextField.text != nil && vehicleNumberTextField.text?.isEmpty == false{
            CustomExtensionUtility.changeBtnColor(sender: continueActnBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            continueActnBtn.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: continueActnBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            continueActnBtn.isUserInteractionEnabled = false
        }
    }
    
    private func closeView(isdismissViewTapped : Bool){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.vehicleDetailsView.center.y += self.vehicleDetailsView.bounds.height
            self.vehicleDetailsView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
            if !isdismissViewTapped{
                self.navigateToRecurringRideCreationVC()
            }
         }
    }
     private func navigateToQuickRidePledgeVC(){
        let qrPledgeVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickridePledgeViewController") as! QuickridePledgeViewController
        qrPledgeVC.initializeDataBeforePresenting(titles: Strings.pledge_titles, messages: Strings.pledge_details_ride_giver, images: Strings.pledgeImages, actionName: Strings.i_agree_caps, heading: Strings.pledge_title_text) {() in
            SharedPreferenceHelper.setDisplayStatusForRideGiverPledge(status: true)
            self.navigateToRecurringRideCreationVC()
        }
         ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: qrPledgeVC, animated: false)
     }
     
     private func navigateToRecurringRideCreationVC(){
         let rideCreationVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCreateViewController") as! RideCreateViewController
        if !addVehicleDetailsViewModel.isFromSignUpFlow{
            rideCreationVC.initiliseData(isFromSignUpFlow: false)
        }
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: rideCreationVC, animated: false)
     }
    
    
    
    //MARK: UITextFieldDelegate Methods
    override func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    
    
    @objc func textFieldDidChange(textField : UITextField){
        continueActionColorChange()
    }
    
 
    
}
