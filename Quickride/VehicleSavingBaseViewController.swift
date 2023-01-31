    //
//  VehicleSavingBaseViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 22/05/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper
    class VehicleSavingBaseViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate
    
{
    
    @IBOutlet weak var vehicleModelView: UIView!
    
    @IBOutlet weak var vehicleModelLabel: UILabel!
    
    @IBOutlet weak var vehicleNumberTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
   
    @IBOutlet weak var helmetView: UIView!
    
    @IBOutlet weak var helmetViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleFareTextField: UITextField!

    @IBOutlet weak var checkPointsView: UIView!
    
   @IBOutlet weak var markAsDefaultView: UIView!
    
   @IBOutlet weak var vehicleSeatsView: UIView!
    
    @IBOutlet weak var offeringSeatsBtn1: UIButton!
    
    @IBOutlet weak var offeringSeatsBtn2: UIButton!
    
    @IBOutlet weak var offeringSeatsBtn3: UIButton!
    
    @IBOutlet weak var offeringSeatsBtn4: UIButton!
    
    @IBOutlet weak var offeringSeatsBtn5: UIButton!
    
    @IBOutlet weak var offeringSeatsBtn6: UIButton!
    
    @IBOutlet weak var addVehicleSegmentController: UISegmentedControl!
    
    @IBOutlet weak var piilionRiderShouldCarryHelmetView: UIView!
    
    @IBOutlet weak var pillionRiderCarryingHelmetNotMandatoryView: UIView!
    
    @IBOutlet weak var pillionRiderShouldCarryHelmetImageView: UIImageView!
    
    @IBOutlet weak var pillionRiderCarryingHelmetNotMandatoryImageView: UIImageView!
    
    @IBOutlet weak var markAsDefaultBtn: UIButton!
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var featuresFieldTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var carVehicleTypeView: UIView!
    
    @IBOutlet weak var bikeVehicleTypeView: UIView!
    
    @IBOutlet weak var carVehicleTypeIcon: UIImageView!
    
    @IBOutlet weak var bikeVehicleTypeIcon: UIImageView!
    
    @IBOutlet weak var bikeVehicleTypeLabel: UILabel!
    
    @IBOutlet weak var carVehicleTypeLabel: UILabel!
        
    @IBOutlet weak var removeVehicleView: UIView!
        
    @IBOutlet weak var makeAsDefaultVehicleHeightConstraint: NSLayoutConstraint!
    
    var listener : VehicleDetailsUpdateListener?
    var rideConfigurationDelegate: RideConfigurationDelegate?
    var isVehiclePicUpdated : Bool = false
    var isVehicleUpdated : Bool = false
    var isKeyBoardVisible : Bool = false
    var presentedFromActivationView = false
    var presentedFromRideCreationView = false
    var vehicle : Vehicle?
    var currentUserId : String?
    var vehicleType : String = Vehicle.VEHICLE_TYPE_CAR
    var vehicleImage : UIImage?
    var intialFare : Double?
    var initialCapacity : Int?
    var isRemoveOptionApplicableForVehiclePic = false
    var riderHasHelmet = false
    var vehicleImageURI: String?
    var isDefaultVehicle = false
    var markAsDefault = false
    
    func initializeDataBeforePresentingView (presentedFromActivationView : Bool,rideConfigurationDelegate: RideConfigurationDelegate?,vehicle : Vehicle?,listener : VehicleDetailsUpdateListener?) {
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresentingView()")
        self.presentedFromActivationView = presentedFromActivationView
        self.rideConfigurationDelegate = rideConfigurationDelegate
        self.listener = listener
        if vehicle != nil{
            self.vehicle = vehicle!.copy() as? Vehicle
        }
        
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        if QRSessionManager.getInstance()?.getUserId() == "0"{
            let userObj = SharedPreferenceHelper.getUserObject()
            if userObj != nil{
                currentUserId = StringUtils.getStringFromDouble(decimalNumber: userObj!.phoneNumber)
            }
        }
        else{
            currentUserId = QRSessionManager.getInstance()?.getUserId()
        }
        vehicleNumberTextField.delegate = self
        vehicleNumberTextField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        initializeUserProfileFromCache()
        vehicleNumberTextField.clearButtonMode = .never
        self.automaticallyAdjustsScrollViewInsets = false
        NotificationCenter.default.addObserver(self, selector: #selector(VehicleSavingBaseViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VehicleSavingBaseViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        piilionRiderShouldCarryHelmetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VehicleSavingViewController.piilionRiderShouldCarryHelmetView(_:))))
        pillionRiderCarryingHelmetNotMandatoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VehicleSavingViewController.pillionRiderCarryingHelmetNotMandatoryView(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
        super.viewWillAppear(animated)
    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
        bottomSpaceConstraint.constant = keyBoardSize.height + 20
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        bottomSpaceConstraint.constant = 20
    }
    
    func initializeUserProfileFromCache(){
        AppDelegate.getAppDelegate().log.debug("")
        if vehicle == nil{
            vehicle = Vehicle.getDeFaultVehicle()
        }
        self.populateDataInView()
    }
    func populateDataInView(){
        AppDelegate.getAppDelegate().log.debug("populateDataInView()")
        self.vehicleModelLabel.text = self.vehicle!.vehicleModel
        initializeVehicleModelController()
        initializeAbdDisplayVehicleType()
        initializeAddImageView()
        self.isDefaultVehicle = vehicle!.defaultVehicle
        handleMarkAsDefaultViewAndRemoveView()
    }
    func initializeAddImageView(){ }
    
    func handleMarkAsDefaultViewAndRemoveView(){ }
    
    func initializeVehicleModelController(){
        vehicleModelView.isUserInteractionEnabled = true
        vehicleModelView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(VehicleSavingViewController.vehicleModelTapped(_:))))
    }
    func initializeAbdDisplayVehicleType(){
      
        if vehicle!.vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            self.vehicleType = Vehicle.VEHICLE_TYPE_BIKE
        }else{
            self.vehicleType = Vehicle.VEHICLE_TYPE_CAR
        }
        enableVehicleTypeControlsBasedOnselectedType()
    }
    @objc func vehicleModelTapped(_ gesture: UITapGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("vehicleTypeClicked()")
        if vehicle == nil{
            return
        }
        self.view.endEditing(true)
        let vehicleModelAlertController = VehicleModelAlertController(viewController: self,vehicleType: vehicleType,showTaxi: false)
        vehicleModelAlertController.displayVehicleModelAlertController { (vehicle) -> Void in
            self.fillVehicleDetails(vehicle: vehicle!)
        }
    }
    func fillVehicleDetails(vehicle : Vehicle)
    {
        self.vehicleModelLabel.text = vehicle.vehicleModel
        self.isVehicleUpdated = true
    }
     func carVehicleTypeViewTapped(){
        if self.vehicle != nil && vehicleType == self.vehicle!.vehicleType{
            updteVehicleDetailsWhenModelChanged(vehicle: self.vehicle!)
        }
        else{
            let vehicle = VehicleModelAlertController().getVehicleObjectForModel(vehicleModel: nil,vehicleType: vehicleType)
            updteVehicleDetailsWhenModelChanged(vehicle: vehicle)
        }
    }
   func bikeVehicleTypeViewTapped(){
        if self.vehicle != nil && vehicleType == self.vehicle!.vehicleType{
            updteVehicleDetailsWhenModelChanged(vehicle: self.vehicle!)
        }
        else{
            let vehicle = VehicleModelAlertController().getVehicleObjectForModel(vehicleModel: nil,vehicleType: vehicleType)
            updteVehicleDetailsWhenModelChanged(vehicle: vehicle)
        }

    }
    
    func updteVehicleDetailsWhenModelChanged(vehicle : Vehicle){
        self.isVehicleUpdated = true
        self.vehicleModelLabel.text = vehicle.vehicleModel
        self.initialCapacity = vehicle.capacity
        if vehicleModelLabel.text == self.vehicle?.vehicleModel{

            if !vehicle.registrationNumber.isEmpty{
                self.vehicleNumberTextField.text = vehicle.registrationNumber
            }else{
                self.vehicleNumberTextField.text = nil
                self.vehicleNumberTextField.placeholder = Strings.registration_number_placeholder
            }
        }else{
        
            isRemoveOptionApplicableForVehiclePic = false
            if !vehicle.registrationNumber.isEmpty{
                self.vehicleNumberTextField.text = vehicle.registrationNumber
            }
            else{
                self.vehicleNumberTextField.text = nil
                self.vehicleNumberTextField.placeholder = Strings.registration_number_placeholder
            }
      }
    }
    
    func enableVehicleTypeControlsBasedOnselectedType(){
        if vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
      
            self.helmetView.isHidden = false
            setHelmetOptionView()
        }else{
            self.helmetView.isHidden = true
            self.riderHasHelmet = false
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    

  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var threshold : Int?
        if textField == vehicleNumberTextField{
            threshold = 15
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
    func textFieldDidEndEditing(_ textField: UITextField) {
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 0))
        textField.endEditing(true)
    }
    func addDoneButton(textField: UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        textField.inputAccessoryView = keyToolBar
    }
    
    override func didReceiveMemoryWarning() {
        AppDelegate.getAppDelegate().log.debug("didReceiveMemoryWarning()")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func segmentControllerValueChanged(_ sender: Any) {
        
        if addVehicleSegmentController.selectedSegmentIndex == 0{
            vehicleType = Vehicle.VEHICLE_TYPE_CAR
            self.initialCapacity = vehicle?.capacity
            featuresFieldTopSpaceConstraint.constant = -35
            carVehicleTypeViewTapped()
        }else if addVehicleSegmentController.selectedSegmentIndex == 1{
            vehicleType = Vehicle.VEHICLE_TYPE_BIKE
            self.initialCapacity = 1
            featuresFieldTopSpaceConstraint.constant = 0
            bikeVehicleTypeViewTapped()
        }
        
        enableVehicleTypeControlsBasedOnselectedType()
   }
    
    func setNoOfSeat(capacity: Int){
        self.initialCapacity = capacity
        switch capacity {
        case 1:
            setSeatBtnColor(selectedBtn: offeringSeatsBtn1, unselectedBtn1: offeringSeatsBtn2, unselectedBtn2: offeringSeatsBtn3, unselectedBtn3: offeringSeatsBtn4, unselectedBtn4: offeringSeatsBtn5, unselectedBtn5: offeringSeatsBtn6)
        case 2:
            setSeatBtnColor(selectedBtn: offeringSeatsBtn2, unselectedBtn1: offeringSeatsBtn1, unselectedBtn2: offeringSeatsBtn3, unselectedBtn3: offeringSeatsBtn4, unselectedBtn4: offeringSeatsBtn5, unselectedBtn5: offeringSeatsBtn6)
        case 3:
            setSeatBtnColor(selectedBtn: offeringSeatsBtn3, unselectedBtn1: offeringSeatsBtn1, unselectedBtn2: offeringSeatsBtn2, unselectedBtn3: offeringSeatsBtn4, unselectedBtn4: offeringSeatsBtn5, unselectedBtn5: offeringSeatsBtn6)
        case 4:
            setSeatBtnColor(selectedBtn: offeringSeatsBtn4, unselectedBtn1: offeringSeatsBtn1, unselectedBtn2: offeringSeatsBtn2, unselectedBtn3: offeringSeatsBtn3, unselectedBtn4: offeringSeatsBtn5, unselectedBtn5: offeringSeatsBtn6)
        case 5:
            setSeatBtnColor(selectedBtn: offeringSeatsBtn5, unselectedBtn1: offeringSeatsBtn1, unselectedBtn2: offeringSeatsBtn2, unselectedBtn3: offeringSeatsBtn3, unselectedBtn4: offeringSeatsBtn4, unselectedBtn5: offeringSeatsBtn6)
        default:
            setSeatBtnColor(selectedBtn: offeringSeatsBtn6, unselectedBtn1: offeringSeatsBtn1, unselectedBtn2: offeringSeatsBtn2, unselectedBtn3: offeringSeatsBtn3, unselectedBtn4: offeringSeatsBtn4, unselectedBtn5: offeringSeatsBtn5)
        }
    }
    
    func setSeatBtnColor(selectedBtn: UIButton, unselectedBtn1: UIButton, unselectedBtn2: UIButton, unselectedBtn3: UIButton, unselectedBtn4: UIButton, unselectedBtn5: UIButton){
        selectedBtn.backgroundColor = UIColor.gray
        selectedBtn.setTitleColor(UIColor.white, for: .normal)
        unselectedBtn1.backgroundColor = UIColor.white
        unselectedBtn1.setTitleColor(UIColor.black, for: .normal)
        unselectedBtn2.backgroundColor = UIColor.white
        unselectedBtn2.setTitleColor(UIColor.black, for: .normal)
        unselectedBtn3.backgroundColor = UIColor.white
        unselectedBtn3.setTitleColor(UIColor.black, for: .normal)
        unselectedBtn4.backgroundColor = UIColor.white
        unselectedBtn4.setTitleColor(UIColor.black, for: .normal)
        unselectedBtn5.backgroundColor = UIColor.white
        unselectedBtn5.setTitleColor(UIColor.black, for: .normal)
    }
    
    
    @IBAction func offerSeats1BtnClicked(_ sender: Any) {
         setNoOfSeat(capacity: 1)
    }
    
    @IBAction func offeringSeats2BtnClicked(_ sender: Any) {
         setNoOfSeat(capacity: 2)
    }
    
    @IBAction func offeringSeats3BtnClicked(_ sender: Any) {
         setNoOfSeat(capacity: 3)
    }
    
    @IBAction func offeringSeats4BtnClicked(_ sender: Any) {
         setNoOfSeat(capacity: 4)
    }
    
    @IBAction func offeringSeats5BtnClicked(_ sender: Any) {
         setNoOfSeat(capacity: 5)
    }
    
    @IBAction func offeringSeats6BtnClicked(_ sender: Any) {
         setNoOfSeat(capacity: 6)
    }
    
    @objc func piilionRiderShouldCarryHelmetView (_ gestureRecognizer: UITapGestureRecognizer) {
        riderHasHelmet = true
     
        initializeHelmetSelectionView()
    }
    @objc func pillionRiderCarryingHelmetNotMandatoryView (_ gestureRecognizer: UITapGestureRecognizer) {
        
        riderHasHelmet = false
        initializeHelmetSelectionView()
        
    }
    
    func initializeHelmetSelectionView(){
        if riderHasHelmet{
            pillionRiderShouldCarryHelmetImageView.image = UIImage(named: "radio_button_checked")
            pillionRiderCarryingHelmetNotMandatoryImageView.image = UIImage(named: "radio_button_unchecked")
        }else{
            pillionRiderShouldCarryHelmetImageView.image = UIImage(named: "radio_button_unchecked")
            pillionRiderCarryingHelmetNotMandatoryImageView.image = UIImage(named: "radio_button_checked")
        }
    }
    
    func setHelmetOptionView(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if !clientConfiguration.helmetMandatoryForRegion{
            self.riderHasHelmet = false
        }
        else{
            self.riderHasHelmet = vehicle!.riderHasHelmet
        }
        initializeHelmetSelectionView()
    }
    
    @objc func markAsdefaultVehicleTapped(_ gesture : UITapGestureRecognizer)
    {
        if isDefaultVehicle {
            markAsDefault = false
            isDefaultVehicle = false
            markAsDefaultBtn.setImage(UIImage(named: "tick_icon"), for: .normal)
        }else{
            markAsDefault = true
            isDefaultVehicle = true
            markAsDefaultBtn.setImage(UIImage(named: "group_tick_icon"), for: .normal)
        }
    }
    
    @objc func checkPointsTableTapped(_ gesture : UITapGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("viewPricingScheme()")
        let discountFareDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.discountFareDetailsViewController)
        self.navigationController?.view.addSubview(discountFareDetailsViewController.view)
        self.navigationController?.addChild(discountFareDetailsViewController)
    }
}


