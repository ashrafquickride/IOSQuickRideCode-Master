//
//  NotificationSettingsViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 25/08/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class NotificationSettingsViewController: UIViewController, UITextFieldDelegate,SelectDateDelegate{
  
  @IBOutlet weak var rideMatchSwitch: UISwitch!
  
  @IBOutlet weak var rideStatusSwitch: UISwitch!
  
  @IBOutlet weak var regularRideSwitch: UISwitch!
  
  @IBOutlet weak var rideCreationSwitch: UISwitch!
  
  @IBOutlet weak var routeGroupSuggestionSwitch: UISwitch!
  
  @IBOutlet weak var rideCreationReminderSwitch: UISwitch!
  
  @IBOutlet weak var conversationMessagesSwitch: UISwitch!
  
  @IBOutlet weak var walletUpdatesSwitch: UISwitch!
  
  @IBOutlet weak var startTime: UIView!
  
  @IBOutlet weak var endTime: UIView!
  
  @IBOutlet weak var startTimeLabel: UILabel!
  
  @IBOutlet weak var endTimeLabel: UILabel!
  
  @IBOutlet weak var BackButton: UIButton!
    
  @IBOutlet var voiceNotificationSwitch: UISwitch!
  
  @IBOutlet var locationUpdateSuggestionsSwitch: UISwitch!
    
  @IBOutlet var rideRescheduleSuggestionsSwitch: UISwitch!
    
  var notificationSettings : UserNotificationSetting?
  var fromTime = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    definesPresentationContext = true
    AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
    handleBrandingChanges()
    self.startTimeLabel.tag = 100
    self.endTimeLabel.tag = 101
    self.automaticallyAdjustsScrollViewInsets = false
    
    startTime.isUserInteractionEnabled = true
    startTime.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(NotificationSettingsViewController.selectTime(_:))))
    endTime.isUserInteractionEnabled = true
    endTime.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(NotificationSettingsViewController.selectEndTime(_:))))
    
    notificationSettings = UserDataCache.getInstance()!.getLoggedInUserNotificationSettings()
    populateViews()
  }
  func handleBrandingChanges(){

      ViewCustomizationUtils.addBorderToView(view: startTime, borderWidth: 1, color: UIColor.lightGray)
      ViewCustomizationUtils.addCornerRadiusToView(view: startTime, cornerRadius: 2.0)
      
      ViewCustomizationUtils.addBorderToView(view: endTime, borderWidth: 1, color: UIColor.lightGray)
      ViewCustomizationUtils.addCornerRadiusToView(view: endTime, cornerRadius: 2.0)
  }
  func populateViews(){
    AppDelegate.getAppDelegate().log.debug("populateViews()")
    rideMatchSwitch.setOn(notificationSettings!.rideMatch, animated: false)
    rideStatusSwitch.setOn(notificationSettings!.rideStatus, animated: false)
    regularRideSwitch.setOn(notificationSettings!.regularRideNotification, animated: false)
    rideCreationSwitch.setOn(notificationSettings!.rideCreated, animated: false)
    rideCreationReminderSwitch.setOn(notificationSettings!.reminderToCreateRide, animated: false)
    routeGroupSuggestionSwitch.setOn(notificationSettings!.routeGroupSuggestions, animated: false)
    conversationMessagesSwitch.setOn(notificationSettings!.conversationMessages, animated: false)
    walletUpdatesSwitch.setOn(notificationSettings!.walletUpdates, animated: false)
    voiceNotificationSwitch.setOn(notificationSettings!.playVoiceForNotifications,animated: false)
    locationUpdateSuggestionsSwitch.setOn(notificationSettings!.locationUpdateSuggestions,animated: false)
    rideRescheduleSuggestionsSwitch.setOn(notificationSettings!.rideRescheduleSuggestions,animated: false)
    
    startTimeLabel.text = DateUtils.getTimeStringFromTime(time: notificationSettings!.dontDisturbFromTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
    endTimeLabel.text = DateUtils.getTimeStringFromTime(time: notificationSettings!.dontDisturbToTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
    self.navigationController?.isNavigationBarHidden = false
  }
  
  func saveUserUserNotificationSetting()
  {
    if !checkIfNotificationSettingsChanged(){
        self.navigationController?.popViewController(animated: false)
    }
    else{
        QuickRideProgressSpinner.startSpinner()
        updateTheUserNotificationSettingWithTheLatestData()
        let params : [String : String] = notificationSettings!.getParams()
        
        UserRestClient.updateUserUserNotificationSetting(targetViewController: self, params: params) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let userDataCache : UserDataCache? = UserDataCache.getInstance()
                if(userDataCache != nil)
                {
                    userDataCache!.storeUserUserNotificationSetting(userId: QRSessionManager.getInstance()!.getUserId(),notificationSettings: self.notificationSettings)
                }
                UIApplication.shared.keyWindow?.makeToast( Strings.preference_changes_saved)
                self.navigationController?.popViewController(animated: false)
            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
  }
    func checkIfNotificationSettingsChanged() -> Bool{
        
        if notificationSettings!.rideMatch != rideMatchSwitch.isOn{
            return true
        }
        if notificationSettings!.rideStatus != rideStatusSwitch.isOn{
           return true
        }
        if notificationSettings!.regularRideNotification != regularRideSwitch.isOn{
            return true
        }
        if notificationSettings!.rideCreated != rideCreationSwitch.isOn{
            return true
        }
        if notificationSettings!.reminderToCreateRide != rideCreationReminderSwitch.isOn{
            return true
        }
        if notificationSettings!.routeGroupSuggestions != routeGroupSuggestionSwitch.isOn{
            return true
        }
        if notificationSettings!.conversationMessages != conversationMessagesSwitch.isOn{
            return true
        }
        if notificationSettings!.walletUpdates != walletUpdatesSwitch.isOn{
            return true
        }
        if notificationSettings!.playVoiceForNotifications != voiceNotificationSwitch.isOn{
            return true
        }
        if notificationSettings!.dontDisturbFromTime != DateUtils.getDateStringFromString(date: startTimeLabel.text, requiredFormat: DateUtils.DATE_FORMAT_HH_mm_ss, currentFormat: DateUtils.TIME_FORMAT_hhmm_a)!{
            return true
        }
        if notificationSettings!.dontDisturbToTime != DateUtils.getDateStringFromString(date: endTimeLabel.text, requiredFormat: DateUtils.DATE_FORMAT_HH_mm_ss, currentFormat: DateUtils.TIME_FORMAT_hhmm_a)!{
            return true
        }
        if notificationSettings!.locationUpdateSuggestions != locationUpdateSuggestionsSwitch.isOn{
            return true
        }
        if notificationSettings!.rideRescheduleSuggestions != rideRescheduleSuggestionsSwitch.isOn{
            return true
        }
        return false
    }
  func updateTheUserNotificationSettingWithTheLatestData()
  {
    notificationSettings!.dontDisturbFromTime = DateUtils.getDateStringFromString(date: startTimeLabel.text, requiredFormat: DateUtils.DATE_FORMAT_HH_mm_ss, currentFormat: DateUtils.TIME_FORMAT_hhmm_a)!
    notificationSettings!.dontDisturbToTime = DateUtils.getDateStringFromString(date: endTimeLabel.text, requiredFormat: DateUtils.DATE_FORMAT_HH_mm_ss, currentFormat: DateUtils.TIME_FORMAT_hhmm_a)!
    
    
    notificationSettings!.rideMatch = rideMatchSwitch.isOn
    notificationSettings!.rideStatus = rideStatusSwitch.isOn
    notificationSettings!.regularRideNotification = regularRideSwitch.isOn
    notificationSettings!.rideCreated = rideCreationSwitch.isOn
    notificationSettings!.reminderToCreateRide = rideCreationReminderSwitch.isOn
    notificationSettings!.routeGroupSuggestions = routeGroupSuggestionSwitch.isOn
    notificationSettings!.conversationMessages = conversationMessagesSwitch.isOn
    notificationSettings!.walletUpdates = walletUpdatesSwitch.isOn
    notificationSettings!.playVoiceForNotifications = voiceNotificationSwitch.isOn
    notificationSettings!.locationUpdateSuggestions = locationUpdateSuggestionsSwitch.isOn
    notificationSettings!.rideRescheduleSuggestions = rideRescheduleSuggestionsSwitch.isOn
  }
  
    @objc func selectTime(_ gesture: UITapGestureRecognizer) {
    
    let start = DateUtils.getTimeStampFromString(dateString: startTimeLabel.text!, dateFormat: DateUtils.TIME_FORMAT_hhmm_a)
    
    let storyboard = UIStoryboard(name: "Common", bundle: nil)
    
    let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleLater.initializeDataBeforePresentingView(minDate: nil,maxDate: nil, defaultDate: start!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.time, datePickerTitle: nil, handler: nil)
        scheduleLater.modalPresentationStyle = .overCurrentContext
    self.present(scheduleLater, animated: false, completion: nil)
    fromTime = true
  }
    @objc func selectEndTime(_ gesture: UITapGestureRecognizer) {
    let end = DateUtils.getTimeStampFromString(dateString: endTimeLabel.text!, dateFormat: DateUtils.TIME_FORMAT_hhmm_a)
    let storyboard = UIStoryboard(name: "Common", bundle: nil)
    let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleLater.initializeDataBeforePresentingView(minDate: nil,maxDate: nil, defaultDate: end!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.time, datePickerTitle: nil, handler: nil)
        scheduleLater.modalPresentationStyle = .overCurrentContext
    self.present(scheduleLater, animated: false, completion: nil)
    fromTime = false
    
  }
  
  func getTime(date: Double) {
    if fromTime == true{
      let starttime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: date*1000, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
      self.startTimeLabel.text = starttime
    }
    else {
      
      let endtime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: date*1000, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
      self.endTimeLabel.text = endtime
      
    }
  }

  @IBAction func BackButtonClicked(_ sender: Any) {
    saveUserUserNotificationSetting()
  }
}
