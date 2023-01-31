//
//  CommunicationPreferencesViewController.swift
//  Quickride
//
//  Created by KNM Rao on 15/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class CommunicationPreferencesViewController: UIViewController,SaveCommunicationPreferences {
  
  @IBOutlet var receiveRideTripReportsSwitch: UISwitch!
  @IBOutlet var newsAndUpdatesSwitch: UISwitch!
  @IBOutlet var promotionsAndOffersSwitch: UISwitch!
  @IBOutlet var rideInvitesSMSSwitch: UISwitch!
  @IBOutlet var rideMatchesSMSSwitch: UISwitch!
  @IBOutlet var rideStatusSMSSwitch: UISwitch!
  @IBOutlet weak var remaindersAndSuggestionsSwitch: UISwitch!
  @IBOutlet weak var bonusReportsSwitch: UISwitch!
  @IBOutlet weak var monthlyReportsSwitch: UISwitch!
  @IBOutlet weak var unSubscribeMailsSwitch: UISwitch!
  @IBOutlet weak var enableWhatsAppSwitch: UISwitch!
  @IBOutlet weak var receiveAutoConfirmStatusSwitch: UISwitch!
  @IBOutlet weak var enableCallSwitch: UISwitch!
    
  var isEmailPreferenceChanged :Bool = false
  var isSMSPreferenceChanged :Bool = false
  var isWhatsAppPreferencesChanged :Bool = false
  var isCallPreferencesChanged :Bool = false
  var emailPreferences :EmailPreferences?
  var smsPreferences :SMSPreferences?
  var whatsAppPreferences : WhatsAppPreferences?
  var callPreferences : CallPreferences?
    
  override func viewDidLoad() {
    emailPreferences
     = UserDataCache.getInstance()?.getLoggedInUsersEmailPreferences().copy() as? EmailPreferences
    smsPreferences = UserDataCache.getInstance()?.getLoggedInUsersSMSPreferences().copy() as? SMSPreferences
    whatsAppPreferences = UserDataCache.getInstance()?.getLoggedInUserWhatsAppPreferences().copy() as? WhatsAppPreferences
    callPreferences = UserDataCache.getInstance()?.getLoggedInUserCallPreferences().copy() as? CallPreferences
    populateViews()
    unSubscribeMailsSwitch.addTarget(self, action: #selector(onunsubscribeSwitchValueChanged), for: .valueChanged)
    receiveRideTripReportsSwitch.addTarget(self, action: #selector(handleOtherEmailPreferenceChangeIfUnSubscribeEnabled), for: .valueChanged)
    newsAndUpdatesSwitch.addTarget(self, action: #selector(handleOtherEmailPreferenceChangeIfUnSubscribeEnabled), for: .valueChanged)
    promotionsAndOffersSwitch.addTarget(self, action: #selector(handleOtherEmailPreferenceChangeIfUnSubscribeEnabled), for: .valueChanged)
    remaindersAndSuggestionsSwitch.addTarget(self, action: #selector(handleOtherEmailPreferenceChangeIfUnSubscribeEnabled), for: .valueChanged)
    bonusReportsSwitch.addTarget(self, action: #selector(handleOtherEmailPreferenceChangeIfUnSubscribeEnabled), for: .valueChanged)
    monthlyReportsSwitch.addTarget(self, action: #selector(handleOtherEmailPreferenceChangeIfUnSubscribeEnabled), for: .valueChanged)
  }

   @objc func handleOtherEmailPreferenceChangeIfUnSubscribeEnabled(_ swiitch : UISwitch){
        if unSubscribeMailsSwitch.isOn{
            unSubscribeMailsSwitch.setOn(false, animated: true)
        }
    }
   
    @objc func onunsubscribeSwitchValueChanged(_ unsubscribeSwitch: UISwitch) {
    if unsubscribeSwitch.isOn{
       receiveRideTripReportsSwitch.setOn(false, animated: true)
       newsAndUpdatesSwitch.setOn(false, animated: true)
       promotionsAndOffersSwitch.setOn(false, animated: true)
       remaindersAndSuggestionsSwitch.setOn(false, animated: true)
       bonusReportsSwitch.setOn(false, animated: true)
       monthlyReportsSwitch.setOn(false, animated: true)
    }else{
        receiveRideTripReportsSwitch.setOn(emailPreferences!.receiveRideTripReports, animated: true)
        newsAndUpdatesSwitch.setOn(emailPreferences!.receiveNewsAndUpdates, animated: true)
        promotionsAndOffersSwitch.setOn(emailPreferences!.receivePromotionsAndOffers, animated: true)
        remaindersAndSuggestionsSwitch.setOn(emailPreferences!.receiveSuggestionsAndRemainders, animated: true)
        bonusReportsSwitch.setOn(emailPreferences!.recieveBonusReports, animated: true)
        monthlyReportsSwitch.setOn(emailPreferences!.receiveMonthlyReports, animated: true)
    }
  }
    
  func populateViews(){
    receiveRideTripReportsSwitch.isOn = emailPreferences!.receiveRideTripReports
    newsAndUpdatesSwitch.isOn = emailPreferences!.receiveNewsAndUpdates
    promotionsAndOffersSwitch.isOn = emailPreferences!.receivePromotionsAndOffers
    remaindersAndSuggestionsSwitch.isOn = emailPreferences!.receiveSuggestionsAndRemainders
    bonusReportsSwitch.isOn = emailPreferences!.recieveBonusReports
    monthlyReportsSwitch.isOn = emailPreferences!.receiveMonthlyReports
    unSubscribeMailsSwitch.isOn = emailPreferences!.unSubscribe
    rideInvitesSMSSwitch.isOn = smsPreferences!.receiveRideInvites
    rideMatchesSMSSwitch.isOn = smsPreferences!.receiveRideMatches
    rideStatusSMSSwitch.isOn = smsPreferences!.receiveRideStatus
    receiveAutoConfirmStatusSwitch.isOn = smsPreferences!.receiveAutoConfirm
    enableWhatsAppSwitch.isOn = whatsAppPreferences!.enableWhatsAppPreferences
    enableCallSwitch.isOn = callPreferences!.enableCallPreferences
  }
  
  func updateDataAndCallAsyncTask(receiver: SaveCommunicationPreferences?)
  {
  emailPreferences!.receiveRideTripReports = receiveRideTripReportsSwitch.isOn
  emailPreferences!.receiveNewsAndUpdates = newsAndUpdatesSwitch.isOn
  emailPreferences!.receivePromotionsAndOffers = promotionsAndOffersSwitch.isOn
  emailPreferences!.receiveSuggestionsAndRemainders = remaindersAndSuggestionsSwitch.isOn
  emailPreferences!.recieveBonusReports = bonusReportsSwitch.isOn
  emailPreferences!.receiveMonthlyReports = monthlyReportsSwitch.isOn
  emailPreferences!.unSubscribe = unSubscribeMailsSwitch.isOn
  smsPreferences!.receiveRideInvites = rideInvitesSMSSwitch.isOn
  smsPreferences!.receiveRideMatches = rideMatchesSMSSwitch.isOn
  smsPreferences!.receiveRideStatus = rideStatusSMSSwitch.isOn
  smsPreferences!.receiveAutoConfirm = receiveAutoConfirmStatusSwitch.isOn
  whatsAppPreferences!.enableWhatsAppPreferences = enableWhatsAppSwitch.isOn
  callPreferences!.enableCallPreferences = enableCallSwitch.isOn

  
    CommunicationPreferencesUpdateTask(emailPreferences: emailPreferences!, smsPreferences: smsPreferences!, whatsAppPreferences: whatsAppPreferences!,callPreferences: callPreferences!, emailPreferencesUpdated: isEmailPreferenceChanged, smsPreferencesUpdated: isSMSPreferenceChanged, whatsAppPreferencesUpdated:isWhatsAppPreferencesChanged, callPreferencesUpdated: isCallPreferencesChanged,viewController: self, receiver: receiver).saveCommunicationPreferences()
    isEmailPreferenceChanged = false
    isSMSPreferenceChanged = false
    isWhatsAppPreferencesChanged = false
    isCallPreferencesChanged = false
  }
  
  
  func checkIfEmailPreferencesChanged(){
    if emailPreferences!.receiveRideTripReports != receiveRideTripReportsSwitch.isOn{
      isEmailPreferenceChanged = true
    }
    if emailPreferences!.receiveNewsAndUpdates != newsAndUpdatesSwitch.isOn{
      isEmailPreferenceChanged = true
    }
    if emailPreferences!.receivePromotionsAndOffers != promotionsAndOffersSwitch.isOn {
      isEmailPreferenceChanged = true
    }
    if emailPreferences!.receiveSuggestionsAndRemainders != remaindersAndSuggestionsSwitch.isOn {
        isEmailPreferenceChanged = true
    }
    if emailPreferences!.recieveBonusReports != bonusReportsSwitch.isOn{
        isEmailPreferenceChanged = true
    }
    
    if emailPreferences!.receiveMonthlyReports != monthlyReportsSwitch.isOn{
        isEmailPreferenceChanged = true
    }
    
    if emailPreferences!.unSubscribe != unSubscribeMailsSwitch.isOn{
        isEmailPreferenceChanged = true
    }
  }
  
  func checkIfSMSPreferencesChanged(){
    if smsPreferences!.receiveRideInvites != rideInvitesSMSSwitch.isOn{
      isSMSPreferenceChanged = true
    }
    if smsPreferences!.receiveRideMatches != rideMatchesSMSSwitch.isOn{
      isSMSPreferenceChanged = true
    }
    if smsPreferences!.receiveRideStatus != rideStatusSMSSwitch.isOn{
      isSMSPreferenceChanged = true
    }
    if smsPreferences!.receiveAutoConfirm != receiveAutoConfirmStatusSwitch.isOn{
        isSMSPreferenceChanged = true
    }
  }
  
    func checkIfWhatsAppPreferencesChanged(){
        if whatsAppPreferences!.enableWhatsAppPreferences != enableWhatsAppSwitch.isOn{
            isWhatsAppPreferencesChanged = true
        }
    }
    func checkIfCallPreferencesChanged(){
        if callPreferences!.enableCallPreferences != enableCallSwitch.isOn{
            isCallPreferencesChanged = true
        }
    }
  @IBAction func notificationSettingsAction(_ sender: Any){
    
    let notificationSettings = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationSettingsViewController") as! NotificationSettingsViewController
    self.navigationController?.pushViewController(notificationSettings, animated: false)
  }
  
  @IBAction func backButtonAction(_ sender: Any) {
    if emailPreferences == nil || smsPreferences == nil {
      AppDelegate.getAppDelegate().log.debug("Profile data is not retrieved")
      self.navigationController?.popViewController(animated: false)

      return
    }
    checkIfEmailPreferencesChanged()
    checkIfSMSPreferencesChanged()
    checkIfWhatsAppPreferencesChanged()
    checkIfCallPreferencesChanged()
    if isEmailPreferenceChanged || isSMSPreferenceChanged || isWhatsAppPreferencesChanged || isCallPreferencesChanged
    {
        updateDataAndCallAsyncTask(receiver: self)
    }else{
        self.navigationController?.popViewController(animated: false)
    }
  }
  @IBAction func resetToDefaultsAction(_ sender: Any){
    receiveRideTripReportsSwitch.isOn = false
    newsAndUpdatesSwitch.isOn = true
    promotionsAndOffersSwitch.isOn  = true
    remaindersAndSuggestionsSwitch.isOn  = true
    bonusReportsSwitch.isOn = false
    monthlyReportsSwitch.isOn = true
    unSubscribeMailsSwitch.isOn = false
    rideInvitesSMSSwitch.isOn = true
    rideMatchesSMSSwitch.isOn = true
    rideStatusSMSSwitch.isOn = true
    receiveAutoConfirmStatusSwitch.isOn = true
    enableWhatsAppSwitch.isOn = false
    enableCallSwitch.isOn = true
    isEmailPreferenceChanged = true
    isSMSPreferenceChanged = true
    isWhatsAppPreferencesChanged = true
    isCallPreferencesChanged = true
    updateDataAndCallAsyncTask(receiver: nil)
  }
  func communicationPreferencesUpdated(){
    UIApplication.shared.keyWindow?.makeToast( Strings.preference_changes_saved)
    self.navigationController?.popViewController(animated: false)
  }
    
    @IBAction func enableOrDisableWhatsAppPreference(_ sender: UISwitch) {
        if sender.isOn{
            enableWhatsAppSwitch.setOn(true, animated: true)
        }else{
           enableWhatsAppSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func enableOrDisableCallPreference(_ sender: UISwitch) {
        if sender.isOn{
            enableCallSwitch.setOn(true, animated: true)
        }else{
           enableCallSwitch.setOn(false, animated: true)
        }
    }
}
