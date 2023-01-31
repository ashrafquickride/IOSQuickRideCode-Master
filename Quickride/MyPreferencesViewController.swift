//
//  MyPreferencesViewController.swift
//  Quickride
//
//  Created by KNM Rao on 07/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class MyPreferencesViewController : UIViewController,UITableViewDelegate,UITableViewDataSource{
  
  let myPreferencesTitles = Strings.myPreferencesTitles
  
    let myPreferencesIcons : [UIImage] = [
    UIImage(named : "settings_security")!,
    UIImage(named : "settings_ride")!,
    UIImage(named : "settings_com")!,
    UIImage(named : "bell_active")!,
    UIImage(named : "settings_fav")!,
    UIImage(named : "settings_group")!,
    UIImage(named : "icon_password_qr")!,
    UIImage(named : "settings_calendar")!,
    UIImage(named : "ic_restore")!,
    UIImage(named : "ic_power_settings")!]
  
  @IBOutlet var myPreferencesTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    myPreferencesTableView.dataSource = self
    myPreferencesTableView.delegate = self
    myPreferencesTableView.reloadData()
  }
    
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = false
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell  = tableView.dequeueReusableCell(withIdentifier: "myPrefererencesCell") as! MyPreferenceTableViewCell
    if myPreferencesIcons.endIndex <= indexPath.row || myPreferencesTitles.endIndex <= indexPath.row{
        return cell
    }
        let origImage = myPreferencesIcons[indexPath.row]
        let tintedImage = origImage.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cell.preferenceIcon.image = tintedImage
        cell.preferenceIcon.tintColor = Colors.mainButtonColor
    cell.preferenceTitle.text = myPreferencesTitles[indexPath.row]
    return cell
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myPreferencesTitles.count
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            moveToSelecteViewController(storyBoardIdentifier: StoryBoardIdentifiers.settings_storyboard, viewControllerIdentifier: "SecurityViewController")
            break
        case 1:
            moveToSelecteViewController(storyBoardIdentifier: StoryBoardIdentifiers.settings_storyboard, viewControllerIdentifier: ViewControllerIdentifiers.myridePreferencesViewController)
            break
        case 2:
            moveToSelecteViewController(storyBoardIdentifier: StoryBoardIdentifiers.settings_storyboard, viewControllerIdentifier: "CommunicationPreferencesViewController")
            break
        case 3:
            
            moveToSelecteViewController(storyBoardIdentifier: StoryBoardIdentifiers.settings_storyboard, viewControllerIdentifier: "NotificationSettingsViewController")
            
            break
        case 4:
            moveToSelecteViewController(storyBoardIdentifier: StoryBoardIdentifiers.favourites_storyboard, viewControllerIdentifier: "MyFavouritesViewController")
            break
        case 5:
           moveToSelecteViewController(storyBoardIdentifier: StoryBoardIdentifiers.groups_storyboard, viewControllerIdentifier: "RouteGroupsViewController")
           
            break
        case 6:
            moveToSelecteViewController(storyBoardIdentifier: StoryBoardIdentifiers.settings_storyboard, viewControllerIdentifier: "MyAccountViewController")
            break
        case 7:
            moveToSelecteViewController(storyBoardIdentifier: StoryBoardIdentifiers.settings_storyboard, viewControllerIdentifier: "VacationViewController")
            break
        case 8:
            resetUserPreferences()
            break
        case 9:
            takeConfirmationAndLogout()
            break
        default:
            break
        }

    tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    
  }
    private func takeConfirmationAndLogout () {
        
        AppDelegate.getAppDelegate().log.debug("takeConfirmationAndLogout()")
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LogOutViewController") as! LogOutViewController
        mainContentVC.initializeButton(handler: { (result) in
            if Strings.yes_caps == result{
                
                UserDataCache.SUBSCRIPTION_STATUS = false
                LogOutTask(viewController: self).userLogOutTask()
            }
            
        })        
        self.navigationController?.present( mainContentVC, animated: false, completion: nil)
        
    }
    
  func moveToSelecteViewController(storyBoardIdentifier: String,viewControllerIdentifier : String){
    let destViewController = UIStoryboard(name: storyBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: viewControllerIdentifier)
    ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: false)
  }
  
    func resetUserPreferences(){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.reset_to_defaults, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                self.resetPreferences()
            }
        })
    }
  
    func resetPreferences()
    {
        let securityPreferences = resetSecurityPreferences()
        let ridePreferences = resetRidePreferences()
        let emailPreferences = resetEmailPreferences()
        let smsPreferences = resetSMSPreferences()
        let whatsAppPreferences = resetWhatsAppPreferences()
        let callPreferences = resetCallPreferences()
        let notificationSettings = resetNotificationSettings()
        let userPreferences = UserPreferences()
        userPreferences.ridePreferences = ridePreferences
        userPreferences.securityPreferences = securityPreferences
        userPreferences.communicationPreferences =  CommunicationPreferences(userNotificationSetting: notificationSettings,emailPreferences: emailPreferences,smsPreferences: smsPreferences,whatsAppPreferences: whatsAppPreferences,callPreferences: callPreferences)
         UserPreferencesUpdateTask(viewController: self, userPreferences: userPreferences).updatePreferences()
    }
    
  func resetSecurityPreferences() -> SecurityPreferences
  {
    let securityPreferences =  SecurityPreferences()
    securityPreferences.userId = Double(QRSessionManager.getInstance()!.getUserId())
    let user = UserDataCache.getInstance()?.currentUser
    if User.USER_GENDER_FEMALE == user!.gender
    {
        securityPreferences.allowCallsFrom = SecurityPreferences.ALLOW_CALL_AFTER_JOINED
    }
    else
    {
        securityPreferences.allowCallsFrom = SecurityPreferences.ALLOW_CALL_ALWAYS
    }
    if User.USER_GENDER_MALE == user!.gender || User.USER_GENDER_UNKNOWN == user!.gender{
      securityPreferences.shareRidesWithUnVeririfiedUsers = true
    }else{
      securityPreferences.shareRidesWithUnVeririfiedUsers = false
    }
    securityPreferences.emergencyContact = UserDataCache.getInstance()!.getLoggedInUsersSecurityPreferences().emergencyContact
    securityPreferences.shareRidesWithUsersFromMyCompanyOnly = false
    securityPreferences.shareRidesWithUsersFromMyCompanyOnly = false
    securityPreferences.shareRidesWithSameGenderUsersOnly = false
    securityPreferences.shareRidesWithUsersFromSameComapnyGroupOnly = false
    return securityPreferences
  }
  
  func resetRidePreferences() -> RidePreferences{
    let ridePreferences =  RidePreferences()
    let clientConfiguration = getClientConfiguration()
    ridePreferences.userId = Double(QRSessionManager.getInstance()!.getUserId())!
    ridePreferences.preferredVehicle = RidePreferences.PREFERRED_VEHICLE_BOTH
    ridePreferences.rideMatchPercentageAsPassenger = clientConfiguration.rideMatchDefaultPercentagePassenger
    ridePreferences.rideMatchPercentageAsRider = clientConfiguration.rideMatchDefaultPercentageRider
    ridePreferences.dontShowTaxiOptions = false
    ridePreferences.dontShowWhenInActive = false
    ridePreferences.allowFareChange = true
    ridePreferences.minFare = clientConfiguration.defaultMinFareForRide
    ridePreferences.restrictPickupNearStartPoint = false
    ridePreferences.autoconfirm = clientConfiguration.autoConfirmDefaultValue
    ridePreferences.autoConfirmRideMatchTimeThreshold = clientConfiguration.autoConfirmDefaultRideMatchTimeThreshold
    ridePreferences.autoConfirmRideMatchPercentageAsRider = clientConfiguration.autoConfirmDefaultRideMatchPercentageAsRider
    ridePreferences.autoConfirmRideMatchPercentageAsPassenger = clientConfiguration.autoConfirmDefaultRideMatchPercentageAsPassenger
    ridePreferences.autoConfirmEnabled = false
    ridePreferences.autoConfirmPartnerEnabled = false
    ridePreferences.rideInsuranceEnabled = true
    
    
    return ridePreferences
  }
    
  func getClientConfiguration() -> ClientConfigurtion{
    return ConfigurationCache.getObjectClientConfiguration()
  }
  func resetEmailPreferences() -> EmailPreferences
  {
    let emailPreferences =  EmailPreferences()
    emailPreferences.userId = Double(QRSessionManager.getInstance()!.getUserId())
    emailPreferences.receivePromotionsAndOffers = true
    emailPreferences.receiveNewsAndUpdates = true
    emailPreferences.receiveRideTripReports = false
    emailPreferences.receiveSuggestionsAndRemainders = true
    emailPreferences.recieveBonusReports = false
    emailPreferences.receiveMonthlyReports = true
    emailPreferences.unSubscribe = false
    
    return emailPreferences
  }
  
  func resetSMSPreferences() -> SMSPreferences
  {
    let smsPreferences = SMSPreferences()
    smsPreferences.userId = Double(QRSessionManager.getInstance()!.getUserId())
    smsPreferences.receiveRideMatches = true
    smsPreferences.receiveRideStatus = true
    smsPreferences.receiveRideInvites = true
    smsPreferences.receiveAutoConfirm = true
    return smsPreferences
  }
    func resetWhatsAppPreferences() -> WhatsAppPreferences
    {
        return WhatsAppPreferences(userId: Double(QRSessionManager.getInstance()!.getUserId())!,enableWhatsAppPreferences: false)
    }
    func resetCallPreferences() -> CallPreferences
    {
        return CallPreferences(userId: Double(QRSessionManager.getInstance()!.getUserId())!, enableCallPreferences: true)
    }
  
  func resetNotificationSettings() -> UserNotificationSetting{
    let userNotificationSetting =  UserNotificationSetting(userId : Double(QRSessionManager.getInstance()!.getUserId())!,rideMatch : true,rideStatus : true,regularRideNotification : true,rideCreated : true,reminderToCreateRide : true,routeGroupSuggestions : true, conversationMessages : true,walletUpdates : true,playVoiceForNotifications: true,dontDisturbFromTime : "22:00:00",dontDisturbToTime : "06:00:00", locationUpdateSuggestions: true, rideRescheduleSuggestions: true)

    return userNotificationSetting
  }

  
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
