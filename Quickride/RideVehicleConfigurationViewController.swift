//
//  RideVehicleConfigurationViewController.swift
//  Quickride
//
//  Created by Admin on 03/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper
import DropDown
import BottomPopup

protocol RideConfigurationDelegate{
    func vehicleConfigurationConfirmed(vehicle : Vehicle)
}


class RideVehicleConfigurationViewController : BottomPopupViewController,UITextFieldDelegate,RideConfigurationDelegate,VehicleDetailsUpdateListener{

    @IBOutlet weak var vehicleSegmentController: UISegmentedControl!

    @IBOutlet weak var vehicleImageView: UIImageView!

    @IBOutlet weak var setVehicleImageView: UIView!

    @IBOutlet weak var vehicleFacilitiesLbl: UILabel!

    @IBOutlet weak var vehicleModelLbl: UILabel!

    @IBOutlet weak var vehicleNumberLbl: UILabel!

    @IBOutlet weak var vehiclePageControl: UIPageControl!

    @IBOutlet weak var vehicleFareTextField: UITextField!

    @IBOutlet weak var vehicleSeatsTextField: UITextField!

    @IBOutlet weak var vehicleSeatsView: UIView!

    @IBOutlet weak var helmetOrSeatsLbl: UILabel!

    @IBOutlet weak var helmetSwitch: UISwitch!

    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var confirmButton: UIButton!

    @IBOutlet weak var segmentControllerTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var segmentControllerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var vehicleConfigurationView: UIView!

    @IBOutlet weak var txtFieldButton: UIButton!

    @IBOutlet weak var vehicleAdditionalFacilitiesHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var vehiclePageControlHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var helmetView: UIView!

    @IBOutlet weak var helmetTxtLbl: UILabel!

    @IBOutlet weak var vehicleView: UIView!

    @IBOutlet weak var vehicleSeatsSeparatorView: UIView!

    @IBOutlet weak var rightArrowContainerView: UIView!

    @IBOutlet weak var leftArrorContainerView: UIView!

    var rideConfigurationDelegate : RideConfigurationDelegate?
    var vehicle : Vehicle?
    var carVehicles = [Vehicle]()
    var bikeVehicles = [Vehicle]()
    var currentPage : Int = 0
    var seatsDropDown = DropDown()
    var isKeyBoardVisible = false
    var dialogDismissCompletionHandler : DialogDismissCompletionHandler?

    func initializeDataBeforePresenting(vehicle : Vehicle,rideConfigurationDelegate : RideConfigurationDelegate,dismissHandler : DialogDismissCompletionHandler?){
        self.vehicle = vehicle
        self.rideConfigurationDelegate = rideConfigurationDelegate
        self.dialogDismissCompletionHandler = dismissHandler
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePopupHeight(to: 420)
        ViewCustomizationUtils.addCornerRadiusToView(view: vehicleConfigurationView, cornerRadius: 5.0)
        vehicleFareTextField.delegate = self
        vehicleSeatsTextField.delegate = self
        populateVehicleView()
        setVehicleImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideVehicleConfigurationViewController.editVehicleImageTapped(_:))))
        vehicleSeatsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideVehicleConfigurationViewController.showSeatsDropDown(_:))))
        helmetSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cancelButton.addShadow()
        ViewCustomizationUtils.addCornerRadiusToView(view: cancelButton, cornerRadius: 10)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func VehicleDetailsUpdated() {
        populateVehicleView()
    }

    func populateVehicleView(){
        storeCarAndBikeVehicles(vehicles: UserDataCache.getInstance()?.getAllCurrentUserVehicles())
        handleVisibilityOfSegmentView()
        checkVehicleTypeAndSetCurrentPageValue()
        setupSeatsDropDown()
        setVehicleData()
    }

    private func handleArrowButtonVisibility(){
        if !vehicleSegmentController.isHidden{
            if vehicleSegmentController.selectedSegmentIndex == 0 && carVehicles.count > 0{
                handleArrowButtonVisibilityForVehicleType(vehicleList: carVehicles)
            }else if vehicleSegmentController.selectedSegmentIndex == 1 && bikeVehicles.count > 0{
                handleArrowButtonVisibilityForVehicleType(vehicleList: bikeVehicles)
            }
        }else{
            if carVehicles.count > 0{
                handleArrowButtonVisibilityForVehicleType(vehicleList: carVehicles)
            }else if bikeVehicles.count > 0{
                handleArrowButtonVisibilityForVehicleType(vehicleList: bikeVehicles)
            }
        }
    }

    private func handleArrowButtonVisibilityForVehicleType(vehicleList: [Vehicle]){
        guard vehicleList.count > 1 else {
            rightArrowContainerView.isHidden = true
            leftArrorContainerView.isHidden = true
            return
        }
        if currentPage == vehicleList.count - 1{
            rightArrowContainerView.isHidden = true
        }else {
            rightArrowContainerView.isHidden = false
        }
        if currentPage == 0 {
            leftArrorContainerView.isHidden = true
        }else {
            leftArrorContainerView.isHidden = false
        }
    }

    func checkVehicleTypeAndSetCurrentPageValue(){
        if vehicle?.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
            for (index,vehicle) in carVehicles.enumerated(){
                if vehicle.defaultVehicle{
                    self.vehicle = vehicle
                    self.currentPage = index
                }
            }
            handlePageViewBasedOnCount(vehicles: carVehicles)
        }else{
            for (index,vehicle) in bikeVehicles.enumerated(){
                if self.vehicle?.vehicleId == vehicle.vehicleId{
                    self.currentPage = index
                }
            }
            handlePageViewBasedOnCount(vehicles: bikeVehicles)
        }
    }

    @objc func showSeatsDropDown(_ gesture : UITapGestureRecognizer){
        seatsDropDown.show()
    }

    func handleLeftSwipeBasedOnSegmentValueAndSetData(){
        if !vehicleSegmentController.isHidden{
            if vehicleSegmentController.selectedSegmentIndex == 0 && carVehicles.count > 0{
                if currentPage > carVehicles.count - 1{
                    currentPage = carVehicles.count - 1
                }

                self.vehicle = carVehicles[currentPage]

            }else if vehicleSegmentController.selectedSegmentIndex == 1 && bikeVehicles.count > 0{
                if currentPage > bikeVehicles.count - 1{
                    currentPage = bikeVehicles.count - 1
                }
                self.vehicle = bikeVehicles[currentPage]
            }
        }else{
            if carVehicles.count > 0{
                if currentPage > carVehicles.count - 1{
                    currentPage = carVehicles.count - 1
                }

                self.vehicle = carVehicles[currentPage]
            }else if bikeVehicles.count > 0{
                if currentPage > bikeVehicles.count - 1{
                    currentPage = bikeVehicles.count - 1
                }
                self.vehicle = bikeVehicles[currentPage]
            }
        }

    }

    func handleRightSwipeBasedOnSegmentValueAndSetData(){
        if !vehicleSegmentController.isHidden{
            if vehicleSegmentController.selectedSegmentIndex == 0{

                if currentPage < 0
                {
                    currentPage = 0
                }
                self.vehicle = carVehicles[currentPage]
            }else if vehicleSegmentController.selectedSegmentIndex == 1{
                if currentPage < 0
                {
                    currentPage = 0
                }
                self.vehicle = bikeVehicles[currentPage]
            }
        }else{
            if carVehicles.count > 0{
                if currentPage < 0
                {
                    currentPage = 0
                }
                self.vehicle = carVehicles[currentPage]
            }else if bikeVehicles.count > 0{
                if currentPage < 0
                {
                    currentPage = 0
                }
                self.vehicle = bikeVehicles[currentPage]
            }
        }
    }


    @objc func keyBoardWillShow(notification : NSNotification){
         AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
         if isKeyBoardVisible == true{
             AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
             return
         }
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil{
             isKeyBoardVisible = true
         }
     }

     @objc func keyBoardWillHide(notification: NSNotification){
         AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
         if isKeyBoardVisible == false{
             AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
             return
         }
         isKeyBoardVisible = false
         updatePopupHeight(to: 420)
         txtFieldButton.isHidden = false
     }


    @objc func editVehicleImageTapped(_ gesture : UITapGestureRecognizer){
        let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
        vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false,rideConfigurationDelegate: self,vehicle: self.vehicle, listener: nil)
        ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: vehicleSavingViewController, animated: false, completion: nil)
    }

    func handlePageViewBasedOnCount(vehicles : [Vehicle]){
        if vehicles.count > 1 {
            vehiclePageControl.isHidden = false
            vehiclePageControl.numberOfPages = vehicles.count
            vehiclePageControlHeightConstraint.constant = 30
            self.vehiclePageControl.currentPage = self.currentPage
         }else{
            vehiclePageControl.isHidden = true
            vehiclePageControlHeightConstraint.constant = 0

        }
        handleArrowButtonVisibility()
    }

    func handleVisibilityOfSegmentView(){
        if !carVehicles.isEmpty && !bikeVehicles.isEmpty{
            vehicleSegmentController.isHidden = false
            segmentControllerTopSpaceConstraint.constant = 30
            segmentControllerHeightConstraint.constant = 30
            if self.vehicle?.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
                self.vehicleSegmentController.selectedSegmentIndex = 0
            }else{
                self.vehicleSegmentController.selectedSegmentIndex = 1
            }

            enableVehicleTypeControlsBasedOnselectedType()
        }else{
            vehicleSegmentController.isHidden = true
            segmentControllerTopSpaceConstraint.constant = 0
            segmentControllerHeightConstraint.constant = 0
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }



    func setVehicleData(){


        vehicleNumberLbl.text = vehicle!.registrationNumber

        vehicleFareTextField.text = String(vehicle!.fare)

        if vehicle!.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
            vehicleSeatsView.isHidden = false
            helmetView.isHidden = true
            vehicleSeatsSeparatorView.isHidden = false
            helmetOrSeatsLbl.text = Strings.offering_seats
            vehicleSeatsTextField.text = String(vehicle!.capacity)
        }else{
            vehicleSeatsView.isHidden = true
            helmetView.isHidden = false
            vehicleSeatsSeparatorView.isHidden = true
            helmetOrSeatsLbl.text = Strings.extra_helmet
            initializeHelmetSelectionView()
            vehicle!.capacity = 1

        }

        if vehicle!.makeAndCategory != nil && !vehicle!.makeAndCategory!.isEmpty{
            vehicleFacilitiesLbl.isHidden = false
            vehicleAdditionalFacilitiesHeightConstraint.constant = 21
            vehicleFacilitiesLbl.text = vehicle!.makeAndCategory!.capitalized
            vehicleModelLbl.font = UIFont(name: "HelveticaNeue", size: 15.0)
            vehicleModelLbl.textColor = UIColor.black.withAlphaComponent(0.7)
            vehicleModelLbl.text = vehicle!.vehicleModel

        }else{
            vehicleFacilitiesLbl.isHidden = true
            vehicleAdditionalFacilitiesHeightConstraint.constant = 5
            vehicleModelLbl.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
            vehicleModelLbl.textColor = UIColor.black.withAlphaComponent(1)
            vehicleModelLbl.text = vehicle!.vehicleModel.capitalized

        }

        if !self.vehicle!.riderHasHelmet{
          helmetTxtLbl.text = Strings.i_have
          helmetSwitch.setOn(true, animated: false)
        }else{
          helmetTxtLbl.text = Strings.i_dont_have
          helmetSwitch.setOn(false, animated: false)
        }

        setVehicleImage(vehicle: vehicle!)

    }

    func setVehicleImage(vehicle : Vehicle){
        if vehicle.imageURI != nil{
            ImageCache.getInstance().setVehicleImage(imageView: self.vehicleImageView, imageUrl: self.vehicle!.imageURI, model: self.vehicle?.vehicleModel, imageSize: ImageCache.DIMENTION_TINY)
        }else{
            self.vehicleImageView.image = ImageCache.getInstance().getDefaultVehicleImage(model: self.vehicle?.vehicleModel)
        }
    }

    func initializeHelmetSelectionView()
    {
        if !self.vehicle!.riderHasHelmet
        {
           helmetTxtLbl.text = Strings.i_have
        }
        else
        {
            helmetTxtLbl.text = Strings.i_dont_have
        }
    }



    func storeCarAndBikeVehicles(vehicles : [Vehicle]?){
        guard let vehicles = vehicles else {
            return
        }
        carVehicles.removeAll()
        bikeVehicles.removeAll()
        for vehicle in vehicles{
            if vehicle.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
                carVehicles.append(vehicle)
            }else{
                bikeVehicles.append(vehicle)
            }
        }
        if let vehicle = vehicle, let vehicleType = vehicle.vehicleType  {
            let vehicleOfRide = vehicles.first(where: { vehicle.registrationNumber == $0.registrationNumber})
            if vehicleOfRide == nil {
                if vehicleType == Vehicle.VEHICLE_TYPE_CAR {
                    carVehicles.insert(vehicle, at: 0)
                }else {
                    bikeVehicles.insert(vehicle, at: 0)
                }
            }else {
                if vehicleType == Vehicle.VEHICLE_TYPE_CAR, let index = carVehicles.firstIndex(where: { vehicle.registrationNumber == $0.registrationNumber}) {
                    carVehicles.swapAt(0, index)
                }else if let index = bikeVehicles.firstIndex(where: { vehicle.registrationNumber == $0.registrationNumber}){
                    bikeVehicles.swapAt(0, index)
                }
            }
        }
    }



    @IBAction func confirmBtnClicked(_ sender: Any) {
        self.dismiss(animated: true)
        if vehicleFareTextField.text == nil || vehicleFareTextField.text!.isEmpty == true || Vehicle.isVehicleFareValid(selectedFare: vehicleFareTextField.text!) == false {
            var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil{
                clientConfiguration = ClientConfigurtion()
            }

            MessageDisplay.displayAlert( messageString: String(format: Strings.enter_valid_vehicle_fare, arguments: [StringUtils.getStringFromDouble(decimalNumber: clientConfiguration!.vehicleMaxFare)]), viewController: self,handler: nil)
            return
        }

        guard let vehicle = self.vehicle else { return }
        if let fareString = vehicleFareTextField.text , let fare = Double(fareString), vehicle.fare != fare{
            vehicle.fare = fare
        }

        if vehicle.vehicleType == Vehicle.VEHICLE_TYPE_CAR, let seatsString = vehicleSeatsTextField.text,let seats = Int(seatsString), vehicle.capacity != seats && !seatsString.isEmpty {
            vehicle.capacity = seats
        }
        removeCurrentViewAndNavigateToCalledViewController(vehicle: vehicle)
     }


    func removeCurrentViewAndNavigateToCalledViewController(vehicle: Vehicle){
        if dialogDismissCompletionHandler != nil{
            dialogDismissCompletionHandler!()
        }
        self.rideConfigurationDelegate?.vehicleConfigurationConfirmed(vehicle: vehicle)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }



    @IBAction func txtFieldBtnTapped(_ sender: Any) {
           if UIDevice.current.hasNotch {
                       updatePopupHeight(to: 630)
                   }else {
                       updatePopupHeight(to: 540)
                   }
           vehicleFareTextField.becomeFirstResponder()
           txtFieldButton.isHidden = true
       }




    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true)
        removeCurrentViewAndNavigateToCalledViewController(vehicle: self.vehicle!)

    }


    @IBAction func addNewVehicleBtnClicked(_ sender: Any) {


        let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
        vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false,rideConfigurationDelegate: nil,vehicle: nil, listener: self)
        ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: vehicleSavingViewController, animated: false, completion: nil)
    }


    @IBAction func segmentControllerValueChanged(_ sender: Any) {
        self.currentPage = 0
        enableVehicleTypeControlsBasedOnselectedType()

    }

    func enableVehicleTypeControlsBasedOnselectedType()
    {

        if vehicleSegmentController.selectedSegmentIndex == 0{
            self.vehicle = carVehicles[currentPage]
            handlePageViewBasedOnCount(vehicles: carVehicles)
        }else{
            self.vehicle = bikeVehicles[currentPage]
            handlePageViewBasedOnCount(vehicles: bikeVehicles)
        }
        setupSeatsDropDown()
        setVehicleData()
    }

    func setupSeatsDropDown() {
        seatsDropDown.anchorView = vehicleSeatsTextField
        seatsDropDown.dataSource = [Vehicle.VEHICLE_SEAT_CAPACITY_1,Vehicle.VEHICLE_SEAT_CAPACITY_2,Vehicle.VEHICLE_SEAT_CAPACITY_3,Vehicle.VEHICLE_SEAT_CAPACITY_4,Vehicle.VEHICLE_SEAT_CAPACITY_5,Vehicle.VEHICLE_SEAT_CAPACITY_6]


        seatsDropDown.selectionAction = { [weak self] (index, item) in
            self?.vehicleSeatsTextField.text = item
         }
    }

    @IBAction func helmetSwitchChanged(_ sender: UISwitch) {
        if sender.isOn{
          self.vehicle?.riderHasHelmet = false
        }else{
          self.vehicle?.riderHasHelmet = true
        }
        initializeHelmetSelectionView()
    }

    @IBAction func vehicleChangeButtonTapped(_ sender: UIButton) {
        if sender.tag == 1 {
            currentPage += 1
            handleLeftSwipeBasedOnSegmentValueAndSetData()
        }else if sender.tag == 0  {
            currentPage -= 1
            handleRightSwipeBasedOnSegmentValueAndSetData()
        }
        self.vehiclePageControl.currentPage = self.currentPage
        setVehicleData()
        handleArrowButtonVisibility()
    }

    func displayView(){
        ViewControllerUtils.addSubView(viewControllerToDisplay: self)
    }

    func vehicleConfigurationConfirmed(vehicle: Vehicle) {
        self.vehicle = vehicle
        var vehicleIndex : Int?
        if vehicle.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
            for (index,carVehicle) in carVehicles.enumerated(){
                if carVehicle.vehicleId == vehicle.vehicleId{
                    vehicleIndex = index
                }
            }
            if vehicleIndex != nil{
                carVehicles.remove(at: vehicleIndex!)
                carVehicles.append(vehicle)
            }

        }else{
            for (index,bikeVehicle) in bikeVehicles.enumerated(){
                if bikeVehicle.vehicleId == vehicle.vehicleId{
                    vehicleIndex = index
                }
            }
            if vehicleIndex != nil{
                bikeVehicles.remove(at: vehicleIndex!)
                bikeVehicles.append(vehicle)
            }
        }
        setVehicleData()
    }

}
