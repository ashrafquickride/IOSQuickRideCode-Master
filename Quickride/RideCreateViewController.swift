//
//  RideCreateViewController.swift
//  Quickride
//
//  Created by Admin on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation
import TransitionButton

class RideCreateViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var titleHeadingLabel: UILabel!
    @IBOutlet weak var homeAndOfficeLocationView: UIView!
    @IBOutlet weak var homeLocationTextField: UITextField!
    @IBOutlet weak var homeLocationView: UIView!
    @IBOutlet weak var officeLocationTextField: UITextField!
    @IBOutlet weak var officeLocationView: UIView!
    @IBOutlet weak var continueButton: TransitionButton!
    @IBOutlet weak var infoTextLbl: UILabel!
    @IBOutlet weak var startAndReturnTimeView: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimeView: UIView!
    @IBOutlet weak var returnTimeLabel: UILabel!
    @IBOutlet weak var returnTimeView: UIView!
    @IBOutlet weak var repeatRideDaysSwitch: UISwitch!
    @IBOutlet weak var daysView: UIView!
    @IBOutlet weak var repeatRideDaysView: UIView!
    @IBOutlet weak var createRideButton: TransitionButton!
    @IBOutlet weak var homeCurrentLocationIcon: UIButton!
    @IBOutlet weak var officeCurrentLocationIcon: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var homeStartTimeView: UIView!
    @IBOutlet weak var officeStartTimeView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var homeLocationLabel: UILabel!
    @IBOutlet weak var numberOfUsersAtHomeLocationLabel: UILabel!
    @IBOutlet weak var officeLocationLabel: UILabel!
    @IBOutlet weak var numberOfUsersAtOfficeLocationLabel: UILabel!
    @IBOutlet weak var numberOfUsersAtHomeLocationLbl: UILabel!
    @IBOutlet weak var numberOfUsersAtOfficeLocationLbl: UILabel!
    @IBOutlet weak var skipButtonView: UIView!
    
    @IBOutlet weak var googleLocationimage: UIImageView!
    
    
    //MARK: Properties
    private var rideCreateViewModel = RideCreateViewModel()
    var weekdaysButtons = [UIButton]()
    var myRideDeleagte: HomeOfficeLocationSavingDelegate?
    
    func initiliseData(isFromSignUpFlow: Bool){
        self.rideCreateViewModel = RideCreateViewModel(isFromSignUpFlow: isFromSignUpFlow)
    }
   
    func initializeView(myRideDeleagte: HomeOfficeLocationSavingDelegate?) {
        self.myRideDeleagte = myRideDeleagte
    }
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setUpUI()
        getNumberOfUserAtLocation()
        rideCreateViewModel.enableLocationService(delegate: self)
        rideCreateViewModel.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        configureRideCreateUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
    }
    
    //MARK: Methods
    func setUpUI(){
        skipButtonView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        ViewCustomizationUtils.addCornerRadiusToView(view: homeLocationView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: officeLocationView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: homeStartTimeView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: officeStartTimeView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: startTimeView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: returnTimeView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: mondayButton, cornerRadius: mondayButton.frame.size.width/2)
        ViewCustomizationUtils.addCornerRadiusToView(view: tuesdayButton, cornerRadius: tuesdayButton.frame.size.width/2)
        ViewCustomizationUtils.addCornerRadiusToView(view: wednesdayButton, cornerRadius: wednesdayButton.frame.size.width/2)
        ViewCustomizationUtils.addCornerRadiusToView(view: thursdayButton, cornerRadius: thursdayButton.frame.size.height/2)
        ViewCustomizationUtils.addCornerRadiusToView(view: fridayButton, cornerRadius: fridayButton.frame.size.height/2)
        ViewCustomizationUtils.addCornerRadiusToView(view: saturdayButton, cornerRadius: saturdayButton.frame.size.height/2)
        ViewCustomizationUtils.addCornerRadiusToView(view: sundayButton, cornerRadius: sundayButton.frame.size.height/2)
        ViewCustomizationUtils.addBorderToView(view: saturdayButton, borderWidth: 1.0, color: UIColor(netHex: 0xe2e6e4))
        ViewCustomizationUtils.addBorderToView(view: sundayButton, borderWidth: 1.0, color: UIColor(netHex: 0xe2e6e4))
        ViewCustomizationUtils.addCornerRadiusToView(view: headerView, cornerRadius: 3.0)
        checkHomeOfficeLocationAndHandleUI()
        setDefaultHomeOfficeStartTime()
        startTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideCreateViewController.homeTimeViewTapped(_:))))
        returnTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideCreateViewController.officeTimeViewTapped(_:))))
        repeatRideDaysSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        weekdaysButtons = [mondayButton,tuesdayButton,wednesdayButton,thursdayButton,fridayButton,saturdayButton,sundayButton]
        if !rideCreateViewModel.isFromSignUpFlow{
            cancelButton.isHidden = false
            cancelButton.isUserInteractionEnabled = true
        }
     }
     
     func configureRideCreateUI() {
        if myRideDeleagte != nil {
            backButton.isHidden = false
            skipButton.isHidden = true
            createRideButton.setTitle(Strings.ok_caps, for: .normal)
            titleHeadingLabel.text = Strings.update_your_fav_location
        } else {
            backButton.isHidden = true
            skipButton.isHidden = false
            createRideButton.setTitle(Strings.continue_text.uppercased(), for: .normal)
            titleHeadingLabel.text = Strings.let_create_your_ride
        }
    }
    
    func setDefaultHomeOfficeStartTime(){
        startTimeLabel.text = "9:00 AM"
        let startDate = DateUtils.getTimStampFromTimeString(timeString: startTimeLabel.text!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        rideCreateViewModel.homeLocation?.leavingTime = startDate.getTimeStamp()
        rideCreateViewModel.homeStartTime = startDate.getTimeStamp()
        
        returnTimeLabel.text = "6:00 PM"
        let returnDate = DateUtils.getTimStampFromTimeString(timeString: returnTimeLabel.text!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        rideCreateViewModel.officeStartTime = returnDate.getTimeStamp()
        rideCreateViewModel.officeLocation?.leavingTime = returnDate.getTimeStamp()
    }
    
    func setWeekDaysButtonColor(tag : Int){
        if weekdaysButtons[tag].isSelected {
            weekdaysButtons[tag].isSelected = false
            weekdaysButtons[tag].backgroundColor = UIColor(netHex: 0xf6f6f6)
            weekdaysButtons[tag].setTitleColor(.lightGray, for: .normal)
            ViewCustomizationUtils.addBorderToView(view: weekdaysButtons[tag], borderWidth: 1.0, color: UIColor(netHex: 0xe2e6e4))
        }else{
            weekdaysButtons[tag].isSelected = true
            weekdaysButtons[tag].backgroundColor = UIColor(netHex: 0x4bd863)
            weekdaysButtons[tag].setTitleColor(.darkGray, for: .normal)
            ViewCustomizationUtils.addBorderToView(view: weekdaysButtons[tag], borderWidth: 1.0, color: UIColor(netHex: 0x4bd863))
        }
    }
    
    @objc func switchChanged(_ repeatRideDaysSwitch: UISwitch) {
        checkRepeatRideDaysSwitchStatusAndHandleUI()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    func checkRepeatRideDaysSwitchStatusAndHandleUI(){
        if repeatRideDaysSwitch.isOn{
            daysView.isHidden = false
        }else{
            daysView.isHidden = true
        }
    }
    
    func checkHomeOfficeLocationAndHandleUI(){
        if SharedPreferenceHelper.getHomeLocation() == nil || SharedPreferenceHelper.getOfficeLocation() == nil{
            homeAndOfficeLocationView.isHidden = false
            createRideButton.isHidden = true
            startAndReturnTimeView.isHidden = true
            repeatRideDaysView.isHidden = true
            homeLocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideCreateViewController.homeLocationEditViewTapped(_:))))
            officeLocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideCreateViewController.officeLocationEditViewTapped(_:))))
            infoTextLbl.text = Strings.address_text
            continueButton.isHidden = false
            createRideButton.isHidden = true
            handleColorChangeOfContinueButton()
        }else{
            homeAndOfficeLocationView.isHidden = true
            startAndReturnTimeView.isHidden = false
            repeatRideDaysView.isHidden = false
            checkRepeatRideDaysSwitchStatusAndHandleUI()
            createRideButton.isHidden = false
            continueButton.isHidden = true
            infoTextLbl.text = Strings.reschedule_text
            titleHeadingLabel.text = Strings.set_your_ride_timings
            rideCreateViewModel.homeLocation = SharedPreferenceHelper.getHomeLocation()
            rideCreateViewModel.officeLocation = SharedPreferenceHelper.getOfficeLocation()
            displayNumberOfUsersAtLocation()
        }
        skipButton.isHidden = false
    }
    
    @objc func homeLocationEditViewTapped(_ sender: UITapGestureRecognizer){
        if rideCreateViewModel.homeLocation != nil{
            moveToLocationSelection(requestedLocationType: ChangeLocationViewController.HOME, currentLocation:
                Location(favouriteLocation: rideCreateViewModel.homeLocation!))
        }else{
            moveToLocationSelection(requestedLocationType: ChangeLocationViewController.HOME, currentLocation:
                nil)
        }
    }
    
    @objc func officeLocationEditViewTapped(_ sender: UITapGestureRecognizer){
        if rideCreateViewModel.officeLocation != nil{
            moveToLocationSelection(requestedLocationType: ChangeLocationViewController.OFFICE, currentLocation:
                Location(favouriteLocation: rideCreateViewModel.officeLocation!))
        }else{
            moveToLocationSelection(requestedLocationType: ChangeLocationViewController.OFFICE, currentLocation:
                nil)
        }
    }
    
    @objc func homeTimeViewTapped(_ gesture : UITapGestureRecognizer){
        self.selectDate(datePickerTitle: Strings.date_picker_title_home, startTime: rideCreateViewModel.homeStartTime)
        { [weak self](date) in
            self?.startTimeLabel.text = AppUtil.getTimeInTimeStamp(date: date)
            self?.rideCreateViewModel.homeStartTime = date.getTimeStamp()
            self?.rideCreateViewModel.homeLocation?.leavingTime = date.getTimeStamp()
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_TIMINGS_ENTERED, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? "","Type" : "Home"], uniqueField: User.FLD_USER_ID)
            self?.handleVisibilityOfCreateRideButton()
        }
    }
    
    @objc func officeTimeViewTapped(_ gesture : UITapGestureRecognizer){
        var startTime = rideCreateViewModel.officeStartTime
        if let homeStartTime = rideCreateViewModel.homeStartTime{
            let date  = DateUtils.getNSDateFromTimeStamp(timeStamp: homeStartTime)
            startTime = date!.addHours(hoursToAdd: 8).getTimeStamp()
        }
        self.selectDate(datePickerTitle: Strings.date_picker_title_office, startTime: startTime)
        { [weak self](date) in
            self?.returnTimeLabel.text = AppUtil.getTimeInTimeStamp(date: date)
            self?.rideCreateViewModel.officeStartTime = date.getTimeStamp()
            self?.rideCreateViewModel.officeLocation?.leavingTime = date.getTimeStamp()
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_TIMINGS_ENTERED, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? "","Type" : "Office"], uniqueField: User.FLD_USER_ID)
            self?.handleVisibilityOfCreateRideButton()
        }
    }
    private func displayNumberOfUsersAtLocation(){
        homeLocationLabel.isHidden = false
        officeLocationLabel.isHidden = false
        homeLocationLabel.text = rideCreateViewModel.homeLocation?.address
        officeLocationLabel.text = rideCreateViewModel.officeLocation?.address
        if let numberOfUsers = rideCreateViewModel.numberOfUsersAtHomeLocation, numberOfUsers > 0{
        numberOfUsersAtHomeLocationLabel.isHidden = true
        numberOfUsersAtHomeLocationLabel.text = String(format: Strings.carpoolers_from_your_location, arguments: [StringUtils.getStringFromDouble(decimalNumber: numberOfUsers)]) + Strings.home
        }else {
            numberOfUsersAtHomeLocationLabel.isHidden = true
        }
        if let numberOfUsers = rideCreateViewModel.numberOfUsersAtOfficeLocation, numberOfUsers > 0 {
        numberOfUsersAtOfficeLocationLabel.isHidden = true
        numberOfUsersAtOfficeLocationLabel.text = String(format: Strings.carpoolers_from_your_location, arguments: [StringUtils.getStringFromDouble(decimalNumber: rideCreateViewModel.numberOfUsersAtOfficeLocation)]) + Strings.office
        } else {
            numberOfUsersAtOfficeLocationLabel.isHidden = true
        }
    }
    
    private func displayNumberOfUsers(){
        if let numberOfUsers = rideCreateViewModel.numberOfUsersAtHomeLocation, numberOfUsers > 0{
            numberOfUsersAtHomeLocationLbl.isHidden = false
            numberOfUsersAtHomeLocationLbl.text = String(format: Strings.carpoolers_from_your_location, arguments: [StringUtils.getStringFromDouble(decimalNumber: numberOfUsers)]) + Strings.home
        }else {
            numberOfUsersAtHomeLocationLbl.isHidden = true
        }
        if let numberOfUsers = rideCreateViewModel.numberOfUsersAtOfficeLocation, numberOfUsers > 0{
            numberOfUsersAtOfficeLocationLbl.isHidden = false
            numberOfUsersAtOfficeLocationLbl.text = String(format: Strings.carpoolers_from_your_location, arguments: [StringUtils.getStringFromDouble(decimalNumber: numberOfUsers)]) + Strings.office
        }else {
            numberOfUsersAtOfficeLocationLbl.isHidden = true
        }
    }
    
    func selectDate(datePickerTitle: String,startTime: Double? ,handler : @escaping dateCompletionHandler)
    {
        
        let scheduleLater = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleLater.initializeDataBeforePresentingView(minDate: nil, maxDate: nil, defaultDate: (startTime ?? 0)/1000, isDefaultDateToShow: true, delegate: nil, datePickerMode: UIDatePicker.Mode.time,datePickerTitle : datePickerTitle,handler :handler)
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    
    func  moveToLocationSelection(requestedLocationType : String,currentLocation : Location?){
           AppDelegate.getAppDelegate().log.debug("\(requestedLocationType) \(String(describing: currentLocation))")
           let changeLocationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationViewController.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: requestedLocationType, currentSelectedLocation: currentLocation, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
           ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationViewController, animated: false)
       }
    
    func handleColorChangeOfContinueButton(){
        if homeLocationTextField.text != nil && !homeLocationTextField.text!.isEmpty && officeLocationTextField.text != nil && !officeLocationTextField.text!.isEmpty {
            CustomExtensionUtility.changeBtnColor(sender: continueButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            continueButton.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: continueButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
            continueButton.isUserInteractionEnabled = false
        }
        getNumberOfUserAtLocation()
    }
    
    func handleVisibilityOfCreateRideButton(){
        if startTimeLabel.text != nil && !startTimeLabel.text!.isEmpty && returnTimeLabel.text != nil && !returnTimeLabel.text!.isEmpty{
            createRideButton.isHidden = false
        }
        else{
            createRideButton.isHidden = true
        }
    }
    
    func saveHomeLocation(homeLocation : UserFavouriteLocation,officeLocation : UserFavouriteLocation){
        continueButton.startAnimation()
        saveFavouriteLocation(location: homeLocation, name: UserFavouriteLocation.HOME_FAVOURITE) { [weak self] (responseObject, error) in
           
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let homeLocation = self?.rideCreateViewModel.getUserFavouriteLocation(responseObject: responseObject){
                    self?.rideCreateViewModel.homeLocation = homeLocation
                    self?.rideCreateViewModel.homeLocation?.leavingTime = self?.rideCreateViewModel.homeStartTime
                    self?.saveOfficeLocation(homeLocation: homeLocation, officeLocation: officeLocation)
                    UserDataCache.getInstance()?.saveFavoriteLocations(favoriteLocations: homeLocation)
                    SharedPreferenceHelper.storeHomeLocation(homeLocation: homeLocation)
                }
            }else{
                self?.continueButton.stopAnimation()
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func saveOfficeLocation(homeLocation : UserFavouriteLocation,officeLocation : UserFavouriteLocation){
        
        saveFavouriteLocation(location: officeLocation, name: UserFavouriteLocation.OFFICE_FAVOURITE) { [weak self](responseObject, error) in
            self?.continueButton.stopAnimation()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let officeLocation = self?.rideCreateViewModel.getUserFavouriteLocation(responseObject: responseObject){
                    self?.rideCreateViewModel.officeLocation = officeLocation
                    self?.rideCreateViewModel.officeLocation?.leavingTime = self?.rideCreateViewModel.officeStartTime
                    self?.rideCreateViewModel.officeStartTime = officeLocation.leavingTime
                    self?.rideCreateViewModel.createUserFavouriteRoutes(homeLocation: homeLocation, officeLocation: officeLocation)
                    SharedPreferenceHelper.storeOfficeLocation(officeLocation: officeLocation)
                    UserDataCache.getInstance()?.saveFavoriteLocations(favoriteLocations: officeLocation)
                    if let delegate = self?.myRideDeleagte {
                        self?.navigationController?.popViewController(animated: false)
                        delegate.navigateToRegularRideCreation()
                    } else {
                        self?.checkHomeOfficeLocationAndHandleUI()
                    }
                    
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func checkTagAndPopulateFields(tag : Int,location : Location?){
           if tag == 1{
               homeLocationTextField.text = location?.shortAddress
           }else{
               officeLocationTextField.text = location?.shortAddress
           }
       }
       
    func saveSelectedLocation(location : Location, locationType : String){
        if locationType == ChangeLocationViewController.HOME {
            if let officeLocation = rideCreateViewModel.officeLocation,LocationClientUtils.getDistance(fromLatitude: location.latitude , fromLongitude: location.longitude, toLatitude: officeLocation.latitude ?? 0, toLongitude: officeLocation.longitude ?? 0)/1000 > 100{ // location is less than 100 KM
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.home_office_location_to_far_error, message2: nil, positiveActnTitle: Strings.cancel_caps,negativeActionTitle : Strings.confirm_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                    if Strings.confirm_caps == result{
                        self.homeLocationTextField.text = location.shortAddress
                        self.rideCreateViewModel.updateHomeLocation(location: location)
                    }
                })
            }else{
                homeLocationTextField.text = location.shortAddress
                rideCreateViewModel.updateHomeLocation(location: location)
            }
        }else if locationType == ChangeLocationViewController.OFFICE {
            if let homeLocation = rideCreateViewModel.homeLocation, LocationClientUtils.getDistance(fromLatitude: location.latitude , fromLongitude: location.longitude, toLatitude: homeLocation.latitude ?? 0, toLongitude: homeLocation.longitude ?? 0)/1000 > 100{ // location is less than 100 KM
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.home_office_location_to_far_error, message2: nil, positiveActnTitle: Strings.cancel_caps,negativeActionTitle : Strings.confirm_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                    if Strings.confirm_caps == result{
                        self.officeLocationTextField.text = location.shortAddress
                        self.rideCreateViewModel.updateOfficeLocation(location: location)
                    }
                })
            }else{
                officeLocationTextField.text = location.shortAddress
                rideCreateViewModel.updateOfficeLocation(location: location)
            }
        }
        officeCurrentLocationIcon.isHidden = false
        homeCurrentLocationIcon.isHidden = false
        handleColorChangeOfContinueButton()
    }
       
       func checkAndPlaceCursorPosition()
       {
           if self.homeLocationTextField.text == nil || self.homeLocationTextField.text!.isEmpty{
               self.homeLocationTextField.becomeFirstResponder()
               
           }else if self.officeLocationTextField.text == nil || self.officeLocationTextField.text!.isEmpty{
               self.officeLocationTextField.becomeFirstResponder()
           }
       }
       
       func saveFavouriteLocation(location: UserFavouriteLocation, name :String,handler : @escaping UserRestClient.responseJSONCompletionHandler){
           rideCreateViewModel.saveFavouriteLocation(location: location, locationName: name, viewController: self, handler: handler)
       }
    
    private func getNumberOfUserAtLocation(){
        rideCreateViewModel.getNumberOfUsersAtStartAndEndLocation(startLatitude:  rideCreateViewModel.homeLocation?.latitude ?? 0, startLongitude:  rideCreateViewModel.homeLocation?.longitude ?? 0, endLatitude: rideCreateViewModel.officeLocation?.latitude ?? 0, endLongitude: rideCreateViewModel.officeLocation?.longitude ?? 0, rideType: nil) { result in
            if result{
                self.displayNumberOfUsers()
                self.displayNumberOfUsersAtLocation()
            }
        }
    }
    
    //MARK: Actions
    @IBAction func skipButtonClicked(_ sender: Any) {
        let skipWarningVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SkipWarningViewController") as! SkipWarningViewController
        if !rideCreateViewModel.isFromSignUpFlow{
            skipWarningVC.initialiseData(isFromSignUpFlow: false)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: skipWarningVC)
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        if let homeLocation = rideCreateViewModel.homeLocation,let officeLocation = rideCreateViewModel.officeLocation{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_ROUTE_DETAILS, params: ["userId": QRSessionManager.getInstance()?.getUserId()], uniqueField: User.FLD_USER_ID)
            if homeLocation.shortAddress == officeLocation.shortAddress{
                MessageDisplay.displayAlert(messageString: Strings.home_office_address_needs_to_be_diff, viewController: self, handler: nil)
                return
            }
            saveHomeLocation(homeLocation: homeLocation, officeLocation: officeLocation)
            getNumberOfUserAtLocation()
            
        }
        googleLocationimage.isHidden = true
    }
    
    @IBAction func createRideButtonClicked(_ sender: Any) {
        
        if repeatRideDaysSwitch.isOn{
            for (index,button) in weekdaysButtons.enumerated(){
                if button.isSelected{
                    rideCreateViewModel.weekdaysTimeForHomeToOffice[index] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideCreateViewModel.homeLocation?.leavingTime, timeFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
                    rideCreateViewModel.weekdaysTimeForOfficeToHome[index] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideCreateViewModel.officeLocation?.leavingTime, timeFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
                }
            }
           rideCreateViewModel.createRegularRide(homeToOfficeRoute: nil, officeToHomeRoute: nil, viewController: self) { [weak self](responseError, error) in
                if responseError != nil || error != nil{
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                }
            }
        }else{
            rideCreateViewModel.createRide(viewController: self)
        }
    }
    
    
    @IBAction func selectDayButtonClicked(_ sender: UIButton) {
        setWeekDaysButtonColor(tag: sender.tag)
    }
    
    @IBAction func currentLocationIconClicked(_ sender: UIButton) {
        rideCreateViewModel.fetchLocationFromLatLng { [weak self](location, error) in
            if error != nil && error == QuickRideErrors.NetworkConnectionNotAvailableError{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
            }else if location == nil{
                UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
            }else{
                self?.rideCreateViewModel.checkTagAndUpdateLocation(tag: sender.tag, location: location)
                self?.checkTagAndPopulateFields(tag: sender.tag, location: location)
                self?.handleColorChangeOfContinueButton()
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
}


//MARK: LocationDelegate
extension RideCreateViewController : ReceiveLocationDelegate,CLLocationManagerDelegate{
    
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        saveSelectedLocation(location: location, locationType: requestLocationType)
        checkAndPlaceCursorPosition()
    }
    
    func locationSelectionCancelled(requestLocationType: String) {
        if requestLocationType == ChangeLocationViewController.HOME{
            rideCreateViewModel.homeLocation = nil
            self.homeLocationTextField.text = nil
        }else if requestLocationType == ChangeLocationViewController.OFFICE{
            rideCreateViewModel.officeLocation = nil
            self.officeLocationTextField.text = nil
        }
        handleColorChangeOfContinueButton()
        checkAndPlaceCursorPosition()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        AppDelegate.getAppDelegate().log.debug("")
        if locations.isEmpty{
            return
        }
        rideCreateViewModel.locationManager.stopUpdatingLocation()
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppDelegate.getAppDelegate().log.debug(error)
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        AppDelegate.getAppDelegate().log.debug("\(status)")
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            rideCreateViewModel.locationManager.requestLocation()
        }
    }
    
   
}

extension RideCreateViewController : RideCreateViewModelDelegate{
    func startCreateRideButtonAnimation() {
        createRideButton.startAnimation()
    }
    
    func stopCreateRideButtonAnimation() {
        createRideButton.stopAnimation()
    }
    
   
}

