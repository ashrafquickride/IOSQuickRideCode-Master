//
//  MyRidePreferencesViewController.swift
//  Quickride
//
//  Created by KNM Rao on 10/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper

class MyRidePreferencesViewController: UIViewController,SaveRidePreferencesReceiver {
    
    @IBOutlet weak var autoConfirmView: UIView!
    
    @IBOutlet weak var autoConfirmLbl: UILabel!
    
    @IBOutlet weak var autoConfirmSwitch: UISwitch!
    
    @IBOutlet var preferredVehicleAsPassengerLabel: UILabel!
    
    @IBOutlet var preferredVehicleAsPassengerView: UIView!
    
    @IBOutlet var offerRideMatachedPercentage: UILabel!
    
    @IBOutlet var offerRideMatchPercentageView: UIView!
    
    @IBOutlet var findRideMatchPercentage: UILabel!
    
    @IBOutlet var findRideMatchPercentageVIew: UIView!
    
    @IBOutlet var rideMatchTimeWindowView: UIView!
    
    @IBOutlet var ridMatchWindowLabel: UILabel!
    
    @IBOutlet var inactiveOptionSwitch: UISwitch!
    
    @IBOutlet var dontShowTaxiOptionSwitch: UISwitch!
    
    @IBOutlet var showOverSpeedAlertSwitch: UISwitch!
    
    @IBOutlet weak var bottomSpaceToSuperView: NSLayoutConstraint!
   
    @IBOutlet weak var locationAccuracySelectionView: UIView!
    
    @IBOutlet weak var locationAccuracyLAbel: UILabel!
    
    @IBOutlet weak var rideNotesLabel: UILabel!
    
    @IBOutlet weak var rideNotesView: UIView!
    
    @IBOutlet weak var rideRestrictionToJoinedGroupsSwitch: UISwitch!
    
    @IBOutlet weak var tripInsuranceView: UIView!
    
    @IBOutlet weak var showMeToJoinedGrpsSwitch: UISwitch!
    
    @IBOutlet weak var dontShowMatchesAfterStartPointSwitch: UISwitch!
    
    @IBOutlet weak var tripInsuranceSwitch: UISwitch!
    
    @IBOutlet weak var nomineeDetailsBtn: UIButton!
    @IBOutlet weak var rideModerationSwitch: UISwitch!
    
    var homeLocation,officeLocation : UserFavouriteLocation?
    var ridePreferences : RidePreferences?
    var isRidePreferencesChanged = false
    var isKeyBoardVisible = false
    var newLocationAccuracyValue : Int?
    var changedNote: String?
    
    override func viewDidLoad() {
        
        ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences
        
        if ridePreferences == nil{
            return
        }
        autoConfirmView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(MyRidePreferencesViewController.moveToAutoConfirmSettings(_:))))
        preferredVehicleAsPassengerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyRidePreferencesViewController.selectPreferredVehicleAsPassengerView(_:))))
        offerRideMatchPercentageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyRidePreferencesViewController.selectOfferRideMatchPercentageView(_:))))
        findRideMatchPercentageVIew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyRidePreferencesViewController.selectFindRideMatchPercentageView(_:))))
        rideMatchTimeWindowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyRidePreferencesViewController.rideMatchTimeWindowViewTapped(_:))))
        locationAccuracySelectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyRidePreferencesViewController.selectLocationAccuracy(_:))))
        rideNotesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyRidePreferencesViewController.updateRideNotes(_:))))
        preferredVehicleAsPassengerLabel.text = StringUtils.getDisplayableStringForPreferredVehicle(storableString: ridePreferences!.preferredVehicle)
        offerRideMatachedPercentage.text = String(ridePreferences!.rideMatchPercentageAsRider)
        findRideMatchPercentage.text = String(ridePreferences!.rideMatchPercentageAsPassenger)
        ridMatchWindowLabel.text = String(ridePreferences!.rideMatchTimeThreshold)
        inactiveOptionSwitch.setOn(ridePreferences!.dontShowWhenInActive, animated: false)
        rideRestrictionToJoinedGroupsSwitch.setOn(ridePreferences!.allowRideMatchToJoinedGroups, animated: false)
        showMeToJoinedGrpsSwitch.setOn(ridePreferences!.showMeToJoinedGroups, animated: false)
        dontShowTaxiOptionSwitch.setOn(ridePreferences!.dontShowTaxiOptions, animated: false)
        showOverSpeedAlertSwitch.setOn(ridePreferences!.alertOnOverSpeed, animated: false)
        dontShowMatchesAfterStartPointSwitch.setOn(ridePreferences!.restrictPickupNearStartPoint, animated: false)
        rideModerationSwitch.setOn(ridePreferences!.rideModerationEnabled, animated: false)
        if ridePreferences!.locationUpdateAccuracy == 0{
            locationAccuracyLAbel.text = Strings.locationAccuracyOff
        }else if Float(ridePreferences!.locationUpdateAccuracy) == 1{
            locationAccuracyLAbel.text = Strings.locationAccuracyBalanced
        }else if ridePreferences!.locationUpdateAccuracy == 2{
            locationAccuracyLAbel.text = Strings.locationAccuracyHigh
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MyRidePreferencesViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyRidePreferencesViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if ridePreferences!.rideNote == nil || ridePreferences!.rideNote == ""{
          self.rideNotesLabel.text = nil
            self.changedNote = nil
        }
        else{
            self.rideNotesLabel.text = Strings.ride_note
            self.changedNote = ridePreferences!.rideNote
        }
        
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if clientConfiguration!.isRideInsuranceOptionVisible{
            tripInsuranceSwitch.isHidden = false
            tripInsuranceSwitch.setOn(ridePreferences!.rideInsuranceEnabled, animated: false)
        }else{
            tripInsuranceSwitch.isHidden = true
        }
        tripInsuranceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyRidePreferencesViewController.tripInsuranceViewTapped(_:))))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func setAutoConfirmLabel(ridePreferences : RidePreferences){
        
        if ridePreferences.autoConfirmEnabled{
            autoConfirmSwitch.setOn(true, animated: false)
            if ridePreferences.autoconfirm == RidePreferences.AUTO_CONFIRM_ALL{
                       autoConfirmLbl.text = Strings.all
                   }else if ridePreferences.autoconfirm == RidePreferences.AUTO_CONFIRM_VERIFIED{
                       autoConfirmLbl.text = Strings.verified_users
                   }else if ridePreferences.autoconfirm == RidePreferences.AUTO_CONFIRM_FAVORITE_PARTNERS{
                       autoConfirmLbl.text = Strings.favourite_partners
                   }
        }else{
            autoConfirmLbl.text = ""
            autoConfirmSwitch.setOn(false, animated: false)
        }
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            bottomSpaceToSuperView.constant = keyBoardSize.height
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomSpaceToSuperView.constant = 0
    }
    @objc func moveToAutoConfirmSettings(_ sender : UITapGestureRecognizer){
        goToAutoConfirmSettingVC()
    }
    
    @objc func selectPreferredVehicleAsPassengerView(_ sender : UITapGestureRecognizer){
        PreferredVehicleAlertController(viewController: self).displayPreferredVehicleController { (preferredVehicle) in
            self.preferredVehicleAsPassengerLabel.text = preferredVehicle
        }
    }
    @objc func selectOfferRideMatchPercentageView(_ sender : UITapGestureRecognizer){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        let minValue = clientConfiguration.rideMatchMinPercentageRider
        let currentValue = Int(self.offerRideMatachedPercentage.text!) ?? ridePreferences!.rideMatchPercentageAsRider
        showSliderView(title: Strings.minimumRouteMatchPercentageOfferRide, firstValue: 0, lastValue: clientConfiguration.rideMatchMaxPercentageRider, minValue: clientConfiguration.rideMatchMinPercentageRider, currentValue: currentValue) { (value) in
            if value < minValue {
                UIApplication.shared.keyWindow?.makeToast(String(format: Strings.min_range_alert, arguments: [String(minValue)]),duration: 2.0, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                self.offerRideMatachedPercentage.text = String(self.ridePreferences!.rideMatchPercentageAsRider)
            }else{
            self.offerRideMatachedPercentage.text = String(value)
            }
        }
    }
    @objc func rideMatchTimeWindowViewTapped(_ sender : UITapGestureRecognizer){
        showSliderView(title: Strings.rideMatchTimeWindowInMins, firstValue: 0, lastValue: 120, minValue: 10, currentValue: ridePreferences!.rideMatchTimeThreshold) { (value) in
            if value < 10 {
                UIApplication.shared.keyWindow?.makeToast(String(format: Strings.min_range_alert, arguments: ["10"]),duration: 2.0, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                self.ridMatchWindowLabel.text = String(self.ridePreferences!.rideMatchTimeThreshold)
            }else{
                self.ridMatchWindowLabel.text = String(value)
            }
        }
    }
    @objc func selectFindRideMatchPercentageView(_ sender : UITapGestureRecognizer){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        let minValue = clientConfiguration.rideMatchMinPercentagePassenger
        let currentValue = Int(self.findRideMatchPercentage.text!) ?? ridePreferences!.rideMatchPercentageAsPassenger
        showSliderView(title: Strings.minimumRouteMatchPercentageFindRide, firstValue: 0, lastValue: clientConfiguration.rideMatchMaxPercentagePassenger, minValue: minValue, currentValue: currentValue) { (value) in
            if value < minValue {                
                UIApplication.shared.keyWindow?.makeToast(String(format: Strings.min_range_alert, arguments: [String(minValue)]),duration: 2.0, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                self.findRideMatchPercentage.text = String(self.ridePreferences!.rideMatchPercentageAsPassenger)
            }else{
                self.findRideMatchPercentage.text = String(value)
            }
        }
    }
    @objc func selectLocationAccuracy(_ sender : UITapGestureRecognizer)
    {
        let locationAccuracySlider = UIStoryboard(name: "MyPreferences", bundle: nil).instantiateViewController(withIdentifier: "LocationAccuracySliderViewController") as! LocationAccuracySliderViewController
        locationAccuracySlider.initializeDataBeforePresentingView(currentValue: locationAccuracyLAbel.text!, viewController: self) { (locationAccuracyValue) in
            if locationAccuracyValue == 0{
                self.locationAccuracyLAbel.text = Strings.locationAccuracyOff
                self.newLocationAccuracyValue = 0
            }else if locationAccuracyValue == 1{
                self.locationAccuracyLAbel.text = Strings.locationAccuracyBalanced
                 self.newLocationAccuracyValue = 1
            }else if locationAccuracyValue == 2{
                self.locationAccuracyLAbel.text = Strings.locationAccuracyHigh
                  self.newLocationAccuracyValue = 2
            }
            
        }
        
    }
    @objc func updateRideNotes(_ sender : UITapGestureRecognizer)
    {
        let textViewAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "TextViewAlertController") as! TextViewAlertController
        textViewAlertController.initializeDataBeforePresentingView(title: Strings.ride_notes_title, positiveBtnTitle: Strings.save_caps, negativeBtnTitle: Strings.cancel_caps, placeHolder: Strings.ride_notes, textAlignment: NSTextAlignment.left, isCapitalTextRequired: false, isDropDownRequired: false, dropDownReasons: nil,existingMessage: self.changedNote, viewController: self, handler: { (text, result) in
            if Strings.save_caps == result
            {
                self.changedNote = text!
                if text == ""{
                    self.rideNotesLabel.text = nil
                }
                else{
                    self.rideNotesLabel.text = Strings.ride_note
                }
            }
        })
        self.navigationController?.view.addSubview(textViewAlertController.view!)
        self.navigationController?.addChild(textViewAlertController)
    }
    func checkIfRidePreferencesChanged(){

        if Int(offerRideMatachedPercentage.text!)! != ridePreferences!.rideMatchPercentageAsRider
        {
            isRidePreferencesChanged = true
        }
        
        if Int(findRideMatchPercentage.text!)! != ridePreferences!.rideMatchPercentageAsPassenger{
            isRidePreferencesChanged = true
        }
        if Int(ridMatchWindowLabel.text!)! != ridePreferences!.rideMatchTimeThreshold{
            isRidePreferencesChanged = true
        }
        
        if ridePreferences!.preferredVehicle != StringUtils.getStorableStringForPreferredVehicle(displayString: preferredVehicleAsPassengerLabel.text){
            isRidePreferencesChanged = true
        }
        
        if ridePreferences!.dontShowWhenInActive != inactiveOptionSwitch.isOn{
            isRidePreferencesChanged = true
        }
        
        if ridePreferences!.allowRideMatchToJoinedGroups != rideRestrictionToJoinedGroupsSwitch.isOn{
            isRidePreferencesChanged = true
        }
        
        if ridePreferences!.showMeToJoinedGroups != showMeToJoinedGrpsSwitch.isOn{
            isRidePreferencesChanged = true
        }
        
        if ridePreferences!.dontShowTaxiOptions != dontShowTaxiOptionSwitch.isOn{
            isRidePreferencesChanged = true;
        }
        if ridePreferences!.alertOnOverSpeed != showOverSpeedAlertSwitch.isOn{
            isRidePreferencesChanged = true;
        }
        if newLocationAccuracyValue != nil && newLocationAccuracyValue != ridePreferences!.locationUpdateAccuracy{
            isRidePreferencesChanged = true
        }
        if self.changedNote != ridePreferences!.rideNote{
            isRidePreferencesChanged = true
        }
        if ridePreferences!.restrictPickupNearStartPoint != dontShowMatchesAfterStartPointSwitch.isOn{
            isRidePreferencesChanged = true;
            
        }
        if ridePreferences!.rideInsuranceEnabled != tripInsuranceSwitch.isOn{
            isRidePreferencesChanged = true
        }
        if ridePreferences!.rideModerationEnabled != rideModerationSwitch.isOn{
            isRidePreferencesChanged = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences
        setAutoConfirmLabel(ridePreferences: ridePreferences!)
        if UserDataCache.getInstance()?.getNomineeDetails() != nil{
            self.nomineeDetailsBtn.setTitle(Strings.update_nominee_details, for: .normal)
        }
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func resetToDefatultsAction(_ sender: Any) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        autoConfirmSwitch.isOn = false
        autoConfirmLbl.text = ""
        ridePreferences!.autoConfirmEnabled = false
        ridePreferences!.autoConfirmPartnerEnabled = false
        ridePreferences!.autoconfirm = clientConfiguration.autoConfirmDefaultValue
        ridePreferences!.autoConfirmRideMatchPercentageAsRider = clientConfiguration.autoConfirmDefaultRideMatchPercentageAsRider
        ridePreferences!.autoConfirmRideMatchPercentageAsPassenger = clientConfiguration.autoConfirmDefaultRideMatchPercentageAsPassenger
        ridePreferences!.autoConfirmRideMatchTimeThreshold = clientConfiguration.autoConfirmDefaultRideMatchTimeThreshold
       	ridePreferences!.autoConfirmRidesType = clientConfiguration.autoConfirmTypeDefaultValue
        preferredVehicleAsPassengerLabel.text = StringUtils.getDisplayableStringForPreferredVehicle(storableString: RidePreferences.PREFERRED_VEHICLE_BOTH)
        offerRideMatachedPercentage.text = String(clientConfiguration.rideMatchDefaultPercentageRider)
        findRideMatchPercentage.text = String(clientConfiguration.rideMatchDefaultPercentagePassenger)
        ridMatchWindowLabel.text = String(clientConfiguration.rideMatchTimeDefaultInMins)
        dontShowTaxiOptionSwitch.isOn = false
        showOverSpeedAlertSwitch.isOn = false
        inactiveOptionSwitch.isOn = false
        rideRestrictionToJoinedGroupsSwitch.isOn = false
        showMeToJoinedGrpsSwitch.isOn = false
        tripInsuranceSwitch.isOn = true
        dontShowMatchesAfterStartPointSwitch.isOn = false
        resetAllowFareChange()
        resetMinfare(minFare: clientConfiguration.defaultMinFareForRide)
        rideNotesLabel.text = nil
        savePreferences(receiver: nil)
        rideModerationSwitch.isOn = false
    }       
    func resetAllowFareChange(){}
    func resetMinfare(minFare : Int){}
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        
        if ridePreferences == nil {
            AppDelegate.getAppDelegate().log.debug("Profile data is not retrieved")
            self.navigationController?.popViewController(animated: false)
            return
        }
        checkIfRidePreferencesChanged()
        
        if(isRidePreferencesChanged)
        {
            savePreferences(receiver: self)
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func autoConfirmSwitchClicked(_ sender: UISwitch) {
        if sender.isOn {
            ridePreferences?.autoConfirmEnabled = true
            autoConfirmLbl.text = Strings.verified_users
        } else {
            ridePreferences?.autoConfirmEnabled = false
            autoConfirmLbl.text = ""
        }
        isRidePreferencesChanged = true
    }
    
    private func goToAutoConfirmSettingVC() {
        let rideAutoConfirmationSettingViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAutoConfirmationSettingViewController") as! RideAutoConfirmationSettingViewController
         rideAutoConfirmationSettingViewController.initializeViews(ridePreferences: ridePreferences!)
        self.navigationController?.pushViewController(rideAutoConfirmationSettingViewController, animated: false)
    }
    
    
    func savePreferences(receiver: SaveRidePreferencesReceiver?){
        self.view.endEditing(false)
        updateRidePreferencesWithNewData()
        QuickRideProgressSpinner.startSpinner()
        SaveRidePreferencesTask(ridePreferences: ridePreferences!, viewController: self, receiver: receiver).saveRidePreferences()
    }
    func updateRidePreferencesWithNewData()
    {
        ridePreferences!.rideMatchPercentageAsPassenger = Int(findRideMatchPercentage.text!)!
        ridePreferences!.rideMatchTimeThreshold = Int(ridMatchWindowLabel.text!)!
        ridePreferences!.rideMatchPercentageAsRider = Int(offerRideMatachedPercentage.text!)!
        ridePreferences!.preferredVehicle = StringUtils.getStorableStringForPreferredVehicle( displayString: preferredVehicleAsPassengerLabel.text!)
        ridePreferences!.dontShowWhenInActive = inactiveOptionSwitch.isOn
        ridePreferences!.dontShowTaxiOptions = dontShowTaxiOptionSwitch.isOn
        ridePreferences!.alertOnOverSpeed = showOverSpeedAlertSwitch.isOn
        ridePreferences!.allowRideMatchToJoinedGroups = rideRestrictionToJoinedGroupsSwitch.isOn
        ridePreferences!.showMeToJoinedGroups = showMeToJoinedGrpsSwitch.isOn
        ridePreferences!.restrictPickupNearStartPoint = dontShowMatchesAfterStartPointSwitch.isOn
        saveLocationAccuracyValueToRidePreferences()
        ridePreferences!.rideNote = self.changedNote
        ridePreferences!.rideInsuranceEnabled = tripInsuranceSwitch.isOn
        ridePreferences!.rideModerationEnabled = rideModerationSwitch.isOn
      }
    
    func ridePreferencesSaved() {
        QuickRideProgressSpinner.stopSpinner()
        UIApplication.shared.keyWindow?.makeToast( Strings.preference_changes_saved)
        self.navigationController?.popViewController(animated: false)
    }
    
    func ridePreferencesSavingFailed() {
        QuickRideProgressSpinner.stopSpinner()
    }
    func saveLocationAccuracyValueToRidePreferences(){
        
        if locationAccuracyLAbel.text == Strings.locationAccuracyOff{
            ridePreferences!.locationUpdateAccuracy = RidePreferences.LOCATION_ACCURACY_OFF
        }else if locationAccuracyLAbel.text == Strings.locationAccuracyBalanced{
            ridePreferences!.locationUpdateAccuracy = RidePreferences.LOCATION_ACCURACY_BALANCE
        }else if locationAccuracyLAbel.text == Strings.locationAccuracyHigh{
            ridePreferences!.locationUpdateAccuracy = RidePreferences.LOCATION_ACCURACY_HIGH
        }

    }
    
    
    @objc func tripInsuranceViewTapped(_ gesture : UITapGestureRecognizer){
        let addNomineeDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddNomineeDetailsViewController") as! AddNomineeDetailsViewController
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: addNomineeDetailsViewController, animated: false)
    }
    
    func showSliderView(title: String, firstValue: Int,lastValue: Int, minValue: Int, currentValue: Int,receiveSelectedValue : receiveSelectedValue?){
        let routeMatchPercentageAndTimeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SelectValueFromSliderViewController") as! SelectValueFromSliderViewController
        routeMatchPercentageAndTimeSelectionViewController.initializeViewWithData(title: title, firstValue: firstValue,lastValue: lastValue, minValue: minValue, currentValue: currentValue, handler: receiveSelectedValue)
        ViewControllerUtils.addSubView(viewControllerToDisplay: routeMatchPercentageAndTimeSelectionViewController)
    }
}

