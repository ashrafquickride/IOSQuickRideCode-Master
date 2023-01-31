//
//  VehicleSavingViewController.swift
//  Quickride
//
//  Created by KNM Rao on 28/12/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper


class VehicleSavingViewController: VehicleSavingBaseViewController{
    
    @IBOutlet weak var carImage: UIImageView!
    
    @IBOutlet weak var editCarImage: UIButton!
    
    @IBOutlet weak var addvehicalDetails: UIView!
    @IBOutlet weak var addvehicalHeightCon: NSLayoutConstraint!
    @IBOutlet weak var additionalFacilitiesTextField: UITextField!
    
    @IBOutlet weak var makeAndCategoryTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    var responseError : ResponseError?
    var error : NSError?
    
    override func viewDidLoad() {
    AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
    definesPresentationContext = true
    if self.vehicle == nil{
        self.navigationItem.title = "Add Vehicle"
        self.saveButton.setTitle(Strings.SAVE_VEHICLE_CAPS, for: .normal)
    }
    else{
        self.navigationItem.title = "Edit Vehicle"
        self.saveButton.setTitle(Strings.UPDATE_VEHICLE_CAPS, for: .normal)
    }
    super.viewDidLoad()
    vehicleFareTextField.delegate = self
    makeAndCategoryTextField.delegate = self
    additionalFacilitiesTextField.delegate = self
     if vehicle?.vehicleType == nil || vehicle?.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
            addVehicleSegmentController.selectedSegmentIndex = 0
     }else{
            addVehicleSegmentController.selectedSegmentIndex = 1
        }
        if self.vehicle!.defaultVehicle{
            markAsDefaultView.isHidden = true
        }else{
            markAsDefaultView.isHidden = false
            markAsDefaultView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VehicleSavingViewController.markAsdefaultVehicleTapped(_:))))
        }
        removeVehicleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VehicleSavingViewController.removeVehicleTapped(_:))))
        checkPointsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VehicleSavingViewController.checkPointsTableTapped(_:))))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
        super.viewWillAppear(animated)
        if presentedFromActivationView{

            self.navigationController?.isNavigationBarHidden = true
        }else{
           
            self.navigationController?.isNavigationBarHidden = false
        }
         if self.vehicle!.registrationNumber.isEmpty{
                   addvehicalDetails.isHidden = false
                   addvehicalHeightCon.constant = 40
              } else {
                   addvehicalDetails.isHidden = true
                   addvehicalHeightCon.constant = 0
               }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: self.saveButton, cornerRadius: 8.0)
        CustomExtensionUtility.changeBtnColor(sender: self.saveButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        offeringSeatsBtn1.addShadow()
        offeringSeatsBtn2.addShadow()
        offeringSeatsBtn3.addShadow()
        offeringSeatsBtn4.addShadow()
        offeringSeatsBtn5.addShadow()
        offeringSeatsBtn6.addShadow()
    }

   override func populateDataInView(){
    self.intialFare = self.vehicle?.fare
    self.initialCapacity = self.vehicle?.capacity
    super.populateDataInView()
    self.vehicleNumberTextField.text = self.vehicle?.registrationNumber
    self.additionalFacilitiesTextField.text = vehicle?.additionalFacilities
    makeAndCategoryTextField.text = vehicle?.makeAndCategory
    setVehicleFareBasedOnApp(fare: vehicle!.fare)

  }

    func setVehicleFareBasedOnApp(fare : Double){
        self.vehicleFareTextField.isEnabled = true
        self.vehicleFareTextField.text = String(fare)
        self.vehicleFareTextField.alpha = 1.0
    }
  override func initializeAddImageView(){
    
     ImageCache.getInstance().setVehicleImage(imageView: self.carImage, imageUrl: vehicle!.imageURI, model: vehicle!.vehicleModel, imageSize: ImageCache.DIMENTION_SMALL)
    if vehicle!.imageURI != nil && vehicle!.imageURI!.isEmpty==false{
      isRemoveOptionApplicableForVehiclePic = true
     self.vehicleImageURI = self.vehicle!.imageURI
    }
    if rideConfigurationDelegate != nil{
      editCarImage.isHidden = true
    }else{
      editCarImage.isHidden = false
    }
    
  }
    
    override func handleMarkAsDefaultViewAndRemoveView() {
        if self.vehicle!.registrationNumber.isEmpty{
            addvehicalDetails.isHidden = false
            addvehicalHeightCon.constant = 40
            self.removeVehicleView.isHidden = true
        }
        else{
            addvehicalDetails.isHidden = true
            addvehicalHeightCon.constant = 0
            self.removeVehicleView.isHidden = false
        }
        if self.isDefaultVehicle{
            let vehicles = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
            if vehicles.count == 1{
                self.removeVehicleView.isHidden = false
            }
            else{
                self.removeVehicleView.isHidden = true
            }
            markAsDefault = true
            markAsDefaultBtn.setImage(UIImage(named: "group_tick_icon"), for: .normal)
            makeAsDefaultVehicleHeightConstraint.constant = 0
        }else{
            markAsDefault = false
            makeAsDefaultVehicleHeightConstraint.constant = 50
            let vehicles = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
            if vehicles.count == 0{
                markAsDefaultBtn.setImage(UIImage(named: "group_tick_icon"), for: .normal)
            }
            else{
                markAsDefaultBtn.setImage(UIImage(named: "tick_icon"), for: .normal)
            }
        }
    }
    
    @objc func removeVehicleTapped(_ gesture : UITapGestureRecognizer)
    {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: false, message1: Strings.do_you_want_to_remove_vehicle, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle: Strings.yes_caps, linkButtonText: nil, viewController: self) { (result) in
            if result == Strings.yes_caps{
                self.vehicle?.status = Vehicle.VEHICLE_STATUS_INACTIVE
                self.deleteVehicle()
            }
        }
    }
    
    func deleteVehicle(){
        QuickRideProgressSpinner.startSpinner()
        ProfileRestClient.updateVehicle(params: self.vehicle!.getParamsMap(), targetViewController: self) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.vehicle = Mapper<Vehicle>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.deleteVehicle(vehicle: self.vehicle!)
                self.isVehicleUpdated = false
                self.isVehiclePicUpdated = false
                self.checkCompletionOfSavingProfileAndTerminate()
                
            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    override func vehicleModelTapped(_ gesture: UITapGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("vehicleTypeClicked()")
        if vehicle == nil{
            return
        }
        let vehicleModelAlertController = VehicleModelAlertController(viewController: self,vehicleType: vehicleType,showTaxi: false)
        vehicleModelAlertController.displayVehicleModelAlertController { (vehicle) -> Void in
            
            self.vehicleModelLabel.text = vehicle!.vehicleModel
            self.initialCapacity = vehicle!.capacity
            self.setNoOfSeat(capacity: self.initialCapacity!)
            if self.vehicleType == self.vehicle!.vehicleType && self.vehicle!.imageURI != nil{
                ImageCache.getInstance().setVehicleImage(imageView: self.carImage, imageUrl: self.vehicle!.imageURI, model: self.vehicle?.vehicleModel, imageSize: ImageCache.DIMENTION_SMALL)
            }else{
                self.carImage.image = ImageCache.getInstance().getDefaultVehicleImage(model: self.vehicleModelLabel.text)
            }
            self.isVehicleUpdated = true
        }
    }
    override func fillVehicleDetails(vehicle : Vehicle)
    {
        super.fillVehicleDetails(vehicle: vehicle)
        if self.vehicleType == self.vehicle!.vehicleType && self.vehicleModelLabel.text == self.vehicle?.vehicleModel{
            ImageCache.getInstance().setVehicleImage(imageView: self.carImage, imageUrl: self.vehicle!.imageURI, model: self.vehicle?.vehicleModel, imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            self.carImage.image = ImageCache.getInstance().getDefaultVehicleImage(model: self.vehicleModelLabel.text)
        }
    }
    

    override func carVehicleTypeViewTapped()
    {
        super.carVehicleTypeViewTapped()
        if self.vehicle!.vehicleType == Vehicle.VEHICLE_TYPE_CAR && self.vehicle != nil && self.vehicle!.imageURI != nil{
            ImageCache.getInstance().setVehicleImage(imageView: self.carImage, imageUrl: self.vehicle!.imageURI, model: self.vehicle?.vehicleModel, imageSize: ImageCache.DIMENTION_SMALL)
            isRemoveOptionApplicableForVehiclePic = true
            self.vehicleImageURI = self.vehicle!.imageURI
        }else{
            self.carImage.image = ImageCache.getInstance().getDefaultVehicleImage(model: self.vehicleModelLabel.text)
            self.vehicleImageURI = nil
        }
    }
    override func bikeVehicleTypeViewTapped()
    {
        super.bikeVehicleTypeViewTapped()
        
        if self.vehicle!.vehicleType == Vehicle.VEHICLE_TYPE_BIKE && self.vehicle != nil && self.vehicle!.imageURI != nil{
            isRemoveOptionApplicableForVehiclePic = true
            ImageCache.getInstance().setVehicleImage(imageView: self.carImage, imageUrl: self.vehicle!.imageURI, model: self.vehicle?.vehicleModel, imageSize: ImageCache.DIMENTION_SMALL)
            self.vehicleImageURI = self.vehicle!.imageURI
        }else{
            self.carImage.image = ImageCache.getInstance().getDefaultVehicleImage(model: self.vehicleModelLabel.text)
            self.vehicleImageURI = nil
        }
    }
    override func updteVehicleDetailsWhenModelChanged(vehicle : Vehicle)
    {
        super.updteVehicleDetailsWhenModelChanged(vehicle: vehicle)
        setVehicleFareBasedOnApp(fare: vehicle.fare)
        self.intialFare = vehicle.fare
        if vehicleType == self.vehicle?.vehicleType && vehicleModelLabel.text == self.vehicle?.vehicleModel{
            ImageCache.getInstance().setVehicleImage(imageView: carImage, imageUrl: self.vehicle!.imageURI, model: self.vehicle?.vehicleModel, imageSize: ImageCache.DIMENTION_SMALL)
            if self.vehicle!.imageURI != nil && self.vehicle!.imageURI?.isEmpty == false{
                isRemoveOptionApplicableForVehiclePic = true
            }
            self.additionalFacilitiesTextField.text = self.vehicle!.additionalFacilities
            self.makeAndCategoryTextField.text = self.vehicle!.makeAndCategory
        }else{
            
            isRemoveOptionApplicableForVehiclePic = false
            self.additionalFacilitiesTextField.text = nil
            self.additionalFacilitiesTextField.placeholder = Strings.features_placeholder
            self.makeAndCategoryTextField.text = nil
            self.makeAndCategoryTextField.placeholder = Strings.make_and_category_placeholder
        }
    }
  override func enableVehicleTypeControlsBasedOnselectedType(){
    super.enableVehicleTypeControlsBasedOnselectedType()
    if vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
      self.vehicleSeatsView.isHidden = true
      self.additionalFacilitiesTextField.placeholder = "Features (Ex. Helmet)"
      self.makeAndCategoryTextField.placeholder = "Make & Category (Ex. Red CBR)"
    }else{
      self.vehicleSeatsView.isHidden = false
      self.setNoOfSeat(capacity: self.initialCapacity!)
      self.additionalFacilitiesTextField.placeholder = "Features (Ex. AC,Music,WIFI)"
      self.makeAndCategoryTextField.placeholder = "Make & Category (Ex. Red Swift)"
    }
  }
  @IBAction func changePhoto(_ sender: UIButton) {
    self.view.endEditing(false)
    AppDelegate.getAppDelegate().log.debug("changePhoto()")
    let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: isRemoveOptionApplicableForVehiclePic, viewController: self, delegate: self){ [weak self] (isUpdated, imageURi, image) in
        self?.receivedImage(image: image, isUpdated: isUpdated)
    }
    uploadImageAlertController.handleImageSelection()
  }
  
  
  
 func getUpdatedVehicle()->Vehicle{
    let vehicle = Vehicle()
    
    vehicle.vehicleId = self.vehicle!.vehicleId
    vehicle.registrationNumber =  self.vehicleNumberTextField.text!
    
    vehicle.ownerId = Double((QRSessionManager.getInstance()?.getUserId())!)!
    
    if (self.vehicleFareTextField.text != nil && self.vehicleFareTextField.text?.isEmpty == false) {
      vehicle.fare = Double(self.vehicleFareTextField.text!)!
    }
    
    
    if makeAndCategoryTextField.text!.isEmpty == false{
      vehicle.makeAndCategory = makeAndCategoryTextField.text!
    }else{
      vehicle.makeAndCategory = nil
    }
    if additionalFacilitiesTextField.text?.isEmpty == false{
      vehicle.additionalFacilities = additionalFacilitiesTextField.text
    }else{
      vehicle.additionalFacilities = nil
    }
    
    vehicle.vehicleModel =  self.vehicleModelLabel.text!
    vehicle.imageURI =  self.vehicleImageURI
    vehicle.vehicleType = vehicleType
    vehicle.defaultVehicle = isDefaultVehicle
    vehicle.riderHasHelmet = self.riderHasHelmet
    vehicle.capacity = self.initialCapacity!
    return vehicle
  }
  
  
  func validateFieldsAndReturnErrorMsgIfAny() -> String? {
    
    let errorMsg = VehicleRelatedValidations.validateFieldsAndReturnErrorMsg(offeredSeats: String(self.initialCapacity!), vehicleNumber:vehicleNumberTextField.text! , vehicleFare: vehicleFareTextField.text!, makeAndCategory: makeAndCategoryTextField.text!,vehicleModel: vehicleModelLabel.text!,vehicleType : vehicleType)

    return errorMsg
  }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        AppDelegate.getAppDelegate().log.debug("backButtonPressed()")
        checkWhetherVehicleInfoIsChangedWithValidData()
        
        if( isVehicleUpdated || isVehiclePicUpdated)
        {
            displayConfirmationDialogueForSavingData()
        }
        else if(presentedFromActivationView == true)
        {
            let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
            let centerNavigationController = UINavigationController(rootViewController: routeViewController)
            AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController
            BaseRouteViewController.SHOULD_DISPLAY_RIDE_CREATION_LINK = true
        }
        else{
            self.navigationController?.popViewController(animated: false)
        }
        
    }

    override func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            bottomSpaceConstraint.constant = keyBoardSize.height + 20
        }
    }
    override func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomSpaceConstraint.constant = 15
    }
    
    func checkAndSaveUserVehicle(){
        let vehicles = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
        
        if vehicles.isEmpty 
        {
            vehicle?.defaultVehicle = true
        }
        if self.vehicle!.vehicleId == 0 {
            
            if vehicle!.registrationNumber.isEmpty
            {
                MessageDisplay.displayAlert(messageString: Strings.valid_registration_number_alert, viewController: self, handler: nil)
                return
            }
            for currentVehicle in vehicles{
                if currentVehicle.registrationNumber.caseInsensitiveCompare(vehicle!.registrationNumber) == ComparisonResult.orderedSame{
                    MessageDisplay.displayAlert(messageString: Strings.duplicate_vehicle_alert, viewController: self, handler: nil)
                    return
                }
            }
            self.createOrUpdateVehicle(isUpdateRequired: false)
        }
        else {
            for currentVehicle in vehicles{
                if currentVehicle.vehicleId != vehicle?.vehicleId && currentVehicle.registrationNumber.caseInsensitiveCompare(vehicle!.registrationNumber) == ComparisonResult.orderedSame{
                    MessageDisplay.displayAlert(messageString: Strings.duplicate_vehicle_alert, viewController: self, handler: nil)
                    return
                }
            }
            self.createOrUpdateVehicle(isUpdateRequired: true)
        }
    }
    
    func createOrUpdateVehicle(isUpdateRequired: Bool) {
        QuickRideProgressSpinner.startSpinner()
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        group.enter()
        queue.async(group: group) {
            if !isUpdateRequired
            {
                ProfileRestClient.createVehicle(params: self.vehicle!.getParamsMap(), targetViewController: self, completionHandler: { (responseObject, error) -> Void in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                        self.vehicle = Mapper<Vehicle>().map(JSONObject: responseObject!["resultData"])
                        UserDataCache.getInstance()?.storeVehicle(vehicle: self.vehicle!)
                        if self.markAsDefault{
                            UserDataCache.getInstance()?.updateUserDefaultVehicle(vehicle: self.vehicle!)
                        }
                        self.responseError = nil
                        self.error = nil
                        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.VEHICLE_ADDED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "","Car/Bike": self.vehicle?.vehicleType ?? ""], uniqueField: User.FLD_USER_ID)
                    }
                    else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                        
                        let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        self.responseError = responseError
                        self.error = error
                    }else{
                        self.responseError = nil
                        self.error = error
                    }
                    group.leave()
                })
            }else{
                ProfileRestClient.updateVehicle(params: self.vehicle!.getParamsMap(), targetViewController: self) { (responseObject, error) -> Void in
                    
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                        self.vehicle = Mapper<Vehicle>().map(JSONObject: responseObject!["resultData"])
                        UserDataCache.getInstance()?.updateVehicle(vehicle: self.vehicle!)
                        if self.markAsDefault{
                            UserDataCache.getInstance()?.updateUserDefaultVehicle(vehicle: self.vehicle!)
                        }
                        self.responseError = nil
                        self.error = nil
                    }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                        
                        let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        self.responseError = responseError
                        self.error = error
                    }else{
                        self.responseError = nil
                        self.error = error
                    }
                    group.leave()
                }
            }
        }
        group.enter()
        queue.async(group: group) {
            if self.isVehiclePicUpdated && self.carImage.image != nil
            {
                let image = ImageUtils.RBResizeImage(image: self.vehicleImage!, targetSize: CGSize(width: 256, height: 256))
                UserRestClient.saveOrUpdateVehicleImage(userId: self.currentUserId!, photo: ImageUtils.convertToBase64String(imageToConvert: image), imageURI: self.vehicle!.imageURI, vehicleId : self.vehicle!.vehicleId, viewController: self, responseHandler: { (responseObject, error) in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        
                        self.vehicle?.imageURI = responseObject!["resultData"] as? String
                        ImageCache.getInstance().storeImageToCache(imageUrl: self.vehicle!.imageURI!, image: self.vehicleImage!)
                        UserDataCache.getInstance()?.updateVehicle(vehicle: self.vehicle!)
                        self.responseError = nil
                        self.error = nil
                        group.leave()
                    }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                        
                        let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        self.responseError = responseError
                        self.error = error
                        group.leave()
                    }else{
                        self.responseError = nil
                        self.error = error
                        group.leave()
                    }
                    
                })
            }
            else{
                group.leave()
            }
        }
        group.notify(queue: queue) {
            QuickRideProgressSpinner.stopSpinner()
            if self.responseError != nil || self.error != nil{
                ErrorProcessUtils.handleResponseError(responseError: self.responseError, error: self.error, viewController: self)
            }
            else{
                self.isVehiclePicUpdated = false
                self.isVehicleUpdated = false
                self.checkCompletionOfSavingProfileAndTerminate()
            }
        }
    }
    
    func displayConfirmationDialogueForSavingData(){
        AppDelegate.getAppDelegate().log.debug("displayConfirmationDialogueForSavingData()")
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.save_changes, message2: nil, positiveActnTitle: Strings.save_caps, negativeActionTitle : Strings.discard_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.save_caps == result{
                self.saveVehicleChanges()
            }else{
                self.navigationController?.popViewController(animated: false)
            }
        })
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        saveVehicleChanges()
        self.dismiss(animated: true)
    }
    func saveVehicleChanges() {
        AppDelegate.getAppDelegate().log.debug("saveProfileChanges()")
        self.view.endEditing(true)
        let errorMsg = validateFieldsAndReturnErrorMsgIfAny()
        if (errorMsg != nil) {
            MessageDisplay.displayAlert( messageString: errorMsg!, viewController: self,handler: nil)
            return
        }
        checkWhetherVehicleInfoIsChangedWithValidData()
        
        if rideConfigurationDelegate != nil{
            vehicle = getUpdatedVehicle()
            self.navigationController?.popViewController(animated: false)
            rideConfigurationDelegate!.vehicleConfigurationConfirmed(vehicle: vehicle!)
        }
            
        else{
            self.continueProfileSaving()
        }
        
    }
    
    func continueProfileSaving(){
        
        if self.isVehicleUpdated || self.isVehiclePicUpdated {
            if QRReachability.isConnectedToNetwork() == false {
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
                return
            }
            updateUserProfileWithNewDetails()
            
        }else{
            self.checkCompletionOfSavingProfileAndTerminate()
        }
    }
    
    func updateUserProfileWithNewDetails(){
        
        
        // prepare vehicle dictionary for Rest call
        
        vehicle = getUpdatedVehicle()
        checkAndSaveUserVehicle()
    }
    
    func checkCompletionOfSavingProfileAndTerminate(){
        
        if isVehicleUpdated == false && isVehiclePicUpdated == false{
            if intialFare != Double(self.vehicleFareTextField.text!)!
            {
                UIApplication.shared.keyWindow?.makeToast( Strings.update_fare_action)
            }
            popToRideCreationViewController()
            self.listener?.VehicleDetailsUpdated()
        }
    }
    func popToRideCreationViewController(){
        if(presentedFromActivationView == true)
        {
            let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
            let centerNavigationController = UINavigationController(rootViewController: routeViewController)
            AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController
            BaseRouteViewController.SHOULD_DISPLAY_RIDE_CREATION_LINK = true
        }else{
            self.navigationController?.popViewController(animated: false)
        }
        
    }
    func checkWhetherVehicleInfoIsChangedWithValidData(){
        AppDelegate.getAppDelegate().log.debug("checkWhetherVehicleInfoIsChangedWithValidData()")
        var input :String?
        let fare = Double(vehicleFareTextField.text!)
        if vehicle!.fare != fare
        {
            isVehicleUpdated = true
        }
        input = vehicleNumberTextField.text
        if (vehicle!.registrationNumber.isEmpty == true && input!.isEmpty == false) || (vehicle!.registrationNumber.isEmpty == false && input!.isEmpty == true) || (vehicle!.registrationNumber != input){
            isVehicleUpdated = true
        }
        input = makeAndCategoryTextField.text
        if ((vehicle!.makeAndCategory == nil || vehicle!.makeAndCategory?.isEmpty == true) && input!.isEmpty == false) || ((vehicle!.makeAndCategory != nil && vehicle!.makeAndCategory?.isEmpty == false) && input!.isEmpty == true ) || (vehicle!.makeAndCategory != nil && vehicle!.makeAndCategory != input){
            isVehicleUpdated = true
        }
        input = additionalFacilitiesTextField.text
        if (vehicle!.additionalFacilities == nil && input!.isEmpty == false) || (vehicle!.additionalFacilities != nil && input!.isEmpty == true) || (vehicle!.additionalFacilities != nil && vehicle!.additionalFacilities != input){
            isVehicleUpdated = true
        }
        if vehicle!.vehicleType == Vehicle.VEHICLE_TYPE_BIKE && vehicle!.riderHasHelmet != self.riderHasHelmet
        {
            isVehicleUpdated = true
        }
        
        if vehicle!.defaultVehicle != self.markAsDefault{
            isVehicleUpdated = true
        }
        
        if vehicle!.capacity != self.initialCapacity{
            isVehicleUpdated = true
        }
    }
    
    // Delegate methods
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        
       if textField == vehicleFareTextField{
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 385))
        }else{
            let y = textField.superview!.frame.origin.y+textField.frame.origin.y
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: y-100))
        }
        
        
        if textField == vehicleFareTextField{
            addDoneButton(textField: vehicleFareTextField)
        }else{
            textField.becomeFirstResponder()
            
        }
    }
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var threshold : Int?
        if textField == vehicleNumberTextField{
            threshold = 15
        }else if textField == vehicleFareTextField{
            threshold = 4
        }
        else if textField == makeAndCategoryTextField{
            threshold = 70
        }
        else if textField == additionalFacilitiesTextField{
            threshold = 150
        }
        else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
        
    }
}
extension VehicleSavingViewController: UIImagePickerControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppDelegate.getAppDelegate().log.debug("imagePickerControllerDidCancel()")
        receivedImage(image: nil, isUpdated: false)
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        AppDelegate.getAppDelegate().log.debug("imagePickerController()")
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        let normalizedImage = UploadImageUtils.fixOrientation(img: image)
        let newImage = UIImage(data: normalizedImage.uncompressedPNGData as Data)
        receivedImage(image: newImage, isUpdated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func receivedImage(image: UIImage?,isUpdated: Bool){
        if image != nil{
            self.isVehiclePicUpdated = isUpdated
            self.isRemoveOptionApplicableForVehiclePic = true
            self.vehicleImage = image!.roundedCornerImage
            self.carImage.image = self.vehicleImage
        }
        else{
            self.vehicle!.imageURI = nil
            self.isVehicleUpdated = isUpdated
            self.vehicleImageURI = nil
            self.isRemoveOptionApplicableForVehiclePic = false
            ImageCache.getInstance().setVehicleImage(imageView: self.carImage, imageUrl: nil, model: self.vehicleModelLabel.text, imageSize: ImageCache.DIMENTION_SMALL)
        }
    }
}
