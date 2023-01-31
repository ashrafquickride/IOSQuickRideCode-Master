//
//  VacationViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 4/12/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class VacationViewController : UIViewController, SelectDateDelegate {
    
    @IBOutlet weak var vacationLabel: UILabel!
    
    @IBOutlet weak var goingForVacAndChangePlanLabel: UILabel!
    
    @IBOutlet weak var letUsKnowLabel: UILabel!
    
    @IBOutlet weak var vacationImageView: UIImageView!
    
    @IBOutlet weak var setVactionView: UIView!
    
    @IBOutlet weak var startTimeView: UIView!
    
    @IBOutlet weak var endTimeView: UIView!
    
    @IBOutlet weak var startTimeTextField: UITextField!
    
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var editVacationView: UIView!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var setAndEndVacationBtn: UIButton!
    
    @IBOutlet weak var dataView: UIView!
    
    @IBOutlet weak var dontWantToUpdateBtn: UIButton!
    
    var startDate : Double?
    var endDate : Double?
    var userVacation : UserVacation?
    var fromDate = false
    var toDate = false
    
    override func viewDidLoad() {
         definesPresentationContext = true
        self.userVacation = UserDataCache.getInstance()!.getLoggedInUserVacation()
        ViewCustomizationUtils.addCornerRadiusToView(view: self.setAndEndVacationBtn, cornerRadius: 8.0)
        self.initializeViews()
        startTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VacationViewController.selectStartDate(_:))))
        endTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VacationViewController.selectEndDate(_:))))
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: dataView, cornerRadius: 20.0, corner1: .topLeft, corner2: .topRight)
        if setVactionView.isHidden == false{
            CustomExtensionUtility.changeBtnColor(sender: setAndEndVacationBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        }else{
            CustomExtensionUtility.changeBtnColor(sender: setAndEndVacationBtn, color1: UIColor(netHex:0xB5000C), color2: UIColor(netHex:0x8A0000))
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func initializeViews()
    {
        if userVacation != nil && userVacation!.fromDate != nil && userVacation!.toDate != nil{
            goingForVacAndChangePlanLabel.text = Strings.vacation_end_text
            letUsKnowLabel.isHidden = true
            vacationImageView.image = UIImage(named: "vacation_end")
            setVactionView.isHidden = true
            editVacationView.isHidden = false
            dontWantToUpdateBtn.isHidden = true
            setAndEndVacationBtn.setTitle(Strings.end_vacation,for: .normal)
                startDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: userVacation!.fromDate, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
                startDate = userVacation!.fromDate
                endDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: userVacation!.toDate, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
                endDate = userVacation!.toDate
        }else{
            goingForVacAndChangePlanLabel.text = Strings.vacation_set_text
            letUsKnowLabel.isHidden = false
            vacationImageView.image = UIImage(named: "vacation_start")
            setVactionView.isHidden = false
            editVacationView.isHidden = true
            setAndEndVacationBtn.setTitle(Strings.set_vacation,for: .normal)
            dontWantToUpdateBtn.isHidden = true
        }
    }
    @objc func selectStartDate(_ sender: UITapGestureRecognizer)
    {
        self.fromDate = true
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleLater.initializeDataBeforePresentingView(minDate : NSDate().timeIntervalSince1970,maxDate: nil, defaultDate: nil, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.date, datePickerTitle: nil, handler: nil)
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    @objc func selectEndDate(_ sender: UITapGestureRecognizer)
    {
        self.toDate = true
        var defaultDate : Double?
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        if startDate != nil{
            defaultDate = DateUtils.getNSDateFromTimeStamp(timeStamp: startDate)!.addDays(daysToAdd: 1).timeIntervalSince1970
        }else{
            defaultDate = nil
        }
        scheduleLater.initializeDataBeforePresentingView(minDate : NSDate().timeIntervalSince1970,maxDate: nil, defaultDate: defaultDate, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.date, datePickerTitle: nil, handler: nil)
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    
    func getTime(date: Double) {
        if fromDate == true
        {
            startTimeTextField.text = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: date), dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
            let time = DateUtils.getDateFromString(date: startTimeTextField.text, dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
            startDate = DateUtils.getDoubleFromNSDate(date: (time!.addHours(hoursToAdd: 0)).addMinutes(minutesToAdd: 1), dateFormat : DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)
            self.fromDate = false
        }else{
            endTimeTextField.text = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: date), dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
            let time = DateUtils.getDateFromString(date: endTimeTextField.text, dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
            endDate = DateUtils.getDoubleFromNSDate(date: (time!.addHours(hoursToAdd: 23)).addMinutes(minutesToAdd: 59), dateFormat : DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)
            self.toDate = false
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    private func isUserVacationChanged() -> Bool
    {
        var isChanged : Bool = false
        
        if userVacation != nil{
            if startDate != userVacation?.fromDate
            {
                isChanged = true
            }else if endDate != userVacation?.toDate{
                isChanged = true
            }
        }else if startDate != nil || endDate != nil{
            isChanged = true
        }
        return isChanged
    }
    
    private func validateChanges() -> Bool
    {
        if startDate == nil && endDate == nil{
            return true
        }else if startDate == nil{
            UIApplication.shared.keyWindow?.makeToast( Strings.start_time_cannot_empty)
            return false
            
        }else if endDate == nil{
            UIApplication.shared.keyWindow?.makeToast( Strings.end_time_cannot_empty)
            return false
        }else if startDate! > endDate!{
            UIApplication.shared.keyWindow?.makeToast( Strings.start_date_more_than_end_date)
            return false
        }
        return true
    }
    
    @IBAction func resestBtnTapped(_ sender: Any)
    {
        self.startTimeTextField.text = nil
        self.endTimeTextField.text = nil
        startDate = nil
        endDate = nil
        self.updateUserVacationChanges(isVactionReseted: true)
    }
    
    
    private func updateUserVacationChanges(isVactionReseted: Bool)
    {
        if userVacation != nil{
            userVacation?.fromDate = startDate
            userVacation?.toDate = endDate
        }else{
            userVacation = UserVacation(id: 0, userId: Double(QRSessionManager.getInstance()!.getUserId())!,fromDate: startDate,toDate: endDate)
        }
        self.updateUserVacation(isVactionReseted: isVactionReseted)
    }
    
    func updateUserVacation(isVactionReseted: Bool)
    {
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updateUserVacation(userVacation: userVacation!, viewController: self, responseHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.userVacation = Mapper<UserVacation>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()!.storeUserVacation(userVacation: self.userVacation)
                if self.userVacation!.fromDate != nil && self.userVacation!.toDate != nil{
                    self.checkForRidesDuringVacationAndDisplayAlertToCancel(isVactionReseted: isVactionReseted)
                }else{
                    self.displaySuccessMsgAndPopView(isVactionReseted: isVactionReseted)
                }
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    func checkForRidesDuringVacationAndDisplayAlertToCancel(isVactionReseted: Bool){
        let result = MyActiveRidesCache.getRidesCacheInstance()?.isRidesPostedOnVaction(userVacation: userVacation!)
        let riderRides = result!.1
        let passengerRides = result!.2
        if !result!.0 {
            self.displaySuccessMsgAndPopView(isVactionReseted: isVactionReseted)
        }else{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: false, message1: Strings.confirm_ride_cancel_during_vacation, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, viewController: self) { (result) in
                if result == Strings.yes_caps{
                    QuickRideProgressSpinner.startSpinner()
                    RideCancelActionProxy.cancelAllRidesInBulk(riderRides: riderRides, passengerRides: passengerRides, viewController: self,handler: { (success) in
                        QuickRideProgressSpinner.stopSpinner()
                        if success{
                            UIApplication.shared.keyWindow?.makeToast( Strings.ride_cancelled_during_vacation)
                            self.displaySuccessMsgAndPopView(isVactionReseted: isVactionReseted)
                        }else{
                            MessageDisplay.displayAlert(messageString: "Failed to cancel the rides, please cancel it manually in upcoming rides", viewController: self, handler: { (result) in
                                if result == Strings.ok_caps{
                                    self.displaySuccessMsgAndPopView(isVactionReseted: isVactionReseted)
                                }
                            })
                        }
                    })
                }else{
                    self.displaySuccessMsgAndPopView(isVactionReseted: isVactionReseted)
                }
            }
        }
    }
    func displaySuccessMsgAndPopView(isVactionReseted: Bool){
        
        if !isVactionReseted{
            UIApplication.shared.keyWindow?.makeToast( Strings.vacation_set_successfully)
            self.navigationController?.popViewController(animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.vacation_ended)
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func SetAndEndVacationBtnTapped(_ sender: Any) {
        if setAndEndVacationBtn.titleLabel!.text == Strings.set_vacation || setAndEndVacationBtn.titleLabel!.text == Strings.update_caps{
            if isUserVacationChanged()
            {
                if self.validateChanges(){
                    self.updateUserVacationChanges(isVactionReseted: false)
                }
            }
        }else{
            self.startTimeTextField.text = nil
            self.endTimeTextField.text = nil
            startDate = nil
            endDate = nil
            self.updateUserVacationChanges(isVactionReseted: true)
        }
    }
    
    @IBAction func editDatesBtnTapped(_ sender: Any) {
        setVactionView.isHidden = false
        editVacationView.isHidden = true
        setAndEndVacationBtn.setTitle(Strings.update_caps,for: .normal)
        startTimeTextField.text = startDateLabel.text
        endTimeTextField.text = endDateLabel.text
        dontWantToUpdateBtn.isHidden = false
    }
    
    @IBAction func dontWantToUpdateBtnTapped(_ sender: Any) {
        setVactionView.isHidden = true
        editVacationView.isHidden = false
        dontWantToUpdateBtn.isHidden = true
        setAndEndVacationBtn.setTitle(Strings.end_vacation,for: .normal)
    }
    
}
