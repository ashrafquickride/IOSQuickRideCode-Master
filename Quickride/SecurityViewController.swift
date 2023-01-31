//
//  SecurityViewController.swift
//  Quickride
//
//  Created by KNM Rao on 07/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SecurityViewController: UIViewController,SelectContactDelegate,SecurityPreferencesUpdateReceiver,UITextFieldDelegate {
  
    @IBOutlet weak var allowMaskedCallSwitch: UISwitch!
    
  @IBOutlet var allowCallsVIew: UIView!
  
  @IBOutlet var allowCallsResrtictionLabel: UILabel!
  
  @IBOutlet var verifiedUsersRestrictionSwitch: UISwitch!
  
  @IBOutlet var emergencyLabel: UITextField!
 
  @IBOutlet var sameGenderRestrictionSwitch: UISwitch!
  
  @IBOutlet var sameCompanyRestrictionSwitch: UISwitch!
  
  @IBOutlet var sameGroupCompanyRestrictionSwitch: UISwitch!
  
  @IBOutlet var sameGroupCompanyView: UIView!
  
  @IBOutlet var sameCompanyView: UIView!
  @IBOutlet var blockedUserView: UIView!
  
  @IBOutlet var resetToDefaultsView: UIView!
    
  @IBOutlet weak var trustedCompaniesInfoBtn: UIButton!
    
 @IBOutlet var rideShareRestrictionsViewHeight: NSLayoutConstraint!
  
  @IBOutlet var rideCompletionOnTimeSwitch: UISwitch!
  
  @IBOutlet var routeDeviationSecuritySwitch: UISwitch!
  
  @IBOutlet weak var cancelButton: UIButton!
  
  @IBOutlet weak var allowChatAndCallFromUnverifiedUsersSwitch: UISwitch!
    
  var securityPreferences : SecurityPreferences?
  var securityPreferencesUpdated = false
  var isSafeGuardValueChanged = false
  private var  modelLessDialogue: ModelLessDialogue?
  override func viewDidLoad() {
    definesPresentationContext = true
    handleBrandingChanges()
    let securityPreferences = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences()
   if securityPreferences != nil{
      self.securityPreferences = securityPreferences!.copy() as? SecurityPreferences
      populateViews()
    }
  }

  func handleBrandingChanges(){
  
      sameCompanyView.isHidden = false
      sameGroupCompanyView.isHidden = false
      rideShareRestrictionsViewHeight.constant = 250
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
   hideCancelButton()
  }
    
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    return true
  }
  func textFieldDidEndEditing(_ textField: UITextField) {
    emergencyLabel.endEditing(false)
  }

  func populateViews(){
    AppDelegate.getAppDelegate().log.debug("populateViews()")
    
    allowChatAndCallFromUnverifiedUsersSwitch.setOn(securityPreferences!.allowChatAndCallFromUnverifiedUsers, animated: false)
    sameCompanyRestrictionSwitch.setOn(securityPreferences!.shareRidesWithUsersFromMyCompanyOnly!, animated: false)
    sameGenderRestrictionSwitch.setOn(securityPreferences!.shareRidesWithSameGenderUsersOnly!, animated: false)
    verifiedUsersRestrictionSwitch.setOn(securityPreferences!.shareRidesWithUnVeririfiedUsers!, animated: false)
    sameGroupCompanyRestrictionSwitch.setOn(securityPreferences!.shareRidesWithUsersFromSameComapnyGroupOnly!, animated: false)
    
    rideCompletionOnTimeSwitch.setOn(securityPreferences!.emergencyOnNonCompletionOfRideOnTime, animated: false)
    routeDeviationSecuritySwitch.setOn(securityPreferences!.emergencyOnRideGiverDeviatesRoute, animated: false)
    
    allowCallsVIew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.selectCallPreference(_:))))
    allowCallsResrtictionLabel.text = UserProfile.getSupportCallPreference(supportCall: securityPreferences!.allowCallsFrom)
    emergencyLabel.text = securityPreferences!.emergencyContact
    
    //emergencyLabel.delegate = self
    
    blockedUserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.blockedUsersTapped(_:))))
    resetToDefaultsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.resetToDefaultsViewTapped(_:))))
    
    if securityPreferences!.numSafeguard == SecurityPreferences.SAFEGAURD_STATUS_VIRTUAL {
        allowMaskedCallSwitch.setOn(true, animated: false)
    }else{
        allowMaskedCallSwitch.setOn(false, animated: false)
    }
  }
    @objc func blockedUsersTapped(_ gesture : UITapGestureRecognizer){
    let blockedUsersDisplayViewController = UIStoryboard(name: StoryBoardIdentifiers.blockeduser_storyboard, bundle: nil).instantiateViewController(withIdentifier: "BlockedUsersDisplayViewController") as! BlockedUsersDisplayViewController
    self.navigationController?.pushViewController(blockedUsersDisplayViewController, animated: false)
  }
    @objc func resetToDefaultsViewTapped(_ gesture : UITapGestureRecognizer){
    
    if UserDataCache.getInstance()!.getCurrentUserGender() == User.USER_GENDER_FEMALE
    {
        allowCallsResrtictionLabel.text = StringUtils.getSupportCallString(supportCallInt: SecurityPreferences.ALLOW_CALL_AFTER_JOINED)
    }
    else
    {
        allowCallsResrtictionLabel.text = StringUtils.getSupportCallString(supportCallInt: SecurityPreferences.ALLOW_CALL_ALWAYS)
    }
    verifiedUsersRestrictionSwitch.isOn = true
    sameCompanyRestrictionSwitch.isOn = false
    sameGenderRestrictionSwitch.isOn = false
    sameGroupCompanyRestrictionSwitch.isOn = false
    routeDeviationSecuritySwitch.isOn = false
    rideCompletionOnTimeSwitch.isOn = false
    allowChatAndCallFromUnverifiedUsersSwitch.isOn = true
    allowMaskedCallSwitch.isOn = false
    updateSecurityPreferences(receiver: nil)
        
  }
    @objc func selectCallPreference(_ sender : UITapGestureRecognizer){
    AppDelegate.getAppDelegate().log.debug("selectCallPreference()")
    let callPreferencesAlertController = CallPreferencesAlertController(viewController: self)
    callPreferencesAlertController.displayCallPreferencesAlertController { (selectedCallPreference) in
      self.allowCallsResrtictionLabel.text = selectedCallPreference.0
    }
  }
  
    @IBAction func trustedCompanyBtnTapped(_ sender: Any) {
        MessageDisplay.displayAlert(messageString: Strings.same_level_companies_info, viewController: self, handler: nil)
    }
  
    func updateSecurityPreferences(receiver: SecurityPreferencesUpdateReceiver?) {
    securityPreferences!.allowCallsFrom = StringUtils.getSupportCallInt(supportCallString: allowCallsResrtictionLabel.text!)
    securityPreferences!.allowChatAndCallFromUnverifiedUsers = allowChatAndCallFromUnverifiedUsersSwitch.isOn
    securityPreferences!.shareRidesWithSameGenderUsersOnly = sameGenderRestrictionSwitch.isOn
    securityPreferences!.shareRidesWithUnVeririfiedUsers = verifiedUsersRestrictionSwitch.isOn
    securityPreferences!.shareRidesWithUsersFromMyCompanyOnly = sameCompanyRestrictionSwitch.isOn
    securityPreferences!.shareRidesWithUsersFromSameComapnyGroupOnly = sameGroupCompanyRestrictionSwitch.isOn
    securityPreferences?.emergencyOnNonCompletionOfRideOnTime = rideCompletionOnTimeSwitch.isOn
    securityPreferences?.emergencyOnRideGiverDeviatesRoute = routeDeviationSecuritySwitch.isOn
    securityPreferences!.emergencyContact = emergencyLabel.text
    if allowMaskedCallSwitch.isOn {
        securityPreferences!.numSafeguard = SecurityPreferences.SAFEGAURD_STATUS_VIRTUAL
    } else {
        securityPreferences!.numSafeguard = SecurityPreferences.SAFEGAURD_STATUS_DIRECT
    }
    SecurityPreferencesUpdateTask(viewController: self, securityPreferences: securityPreferences!, securityPreferencesUpdateReceiver: receiver).updateSecurityPreferences()
  }
  func securityPreferenceUpdated(){
    UIApplication.shared.keyWindow?.makeToast( Strings.preference_changes_saved)
    self.navigationController?.popViewController(animated: false)
  }
  func checkIfFieldsChanged(){
    AppDelegate.getAppDelegate().log.debug("checkIfFieldsChanged()")
    if securityPreferences!.allowChatAndCallFromUnverifiedUsers != allowChatAndCallFromUnverifiedUsersSwitch.isOn{
        securityPreferencesUpdated = true
    }
    if securityPreferences!.shareRidesWithUsersFromMyCompanyOnly != sameCompanyRestrictionSwitch.isOn{
      securityPreferencesUpdated = true
    }
    if securityPreferences!.shareRidesWithSameGenderUsersOnly != sameGenderRestrictionSwitch.isOn{
      securityPreferencesUpdated = true
    }
    
    
    if UserProfile.getSupportCallPreference(supportCall: securityPreferences!.allowCallsFrom) !=  allowCallsResrtictionLabel.text{
      securityPreferencesUpdated = true
    }
    
    let input = emergencyLabel.text
    if ((securityPreferences!.emergencyContact == nil || securityPreferences!.emergencyContact!.isEmpty) && input?.isEmpty == false) || ((securityPreferences!.emergencyContact != nil && !securityPreferences!.emergencyContact!.isEmpty) && input!.isEmpty == true) || (securityPreferences!.emergencyContact != nil && securityPreferences!.emergencyContact != input){
      securityPreferencesUpdated = true
    }
    
    if securityPreferences!.shareRidesWithUsersFromSameComapnyGroupOnly != sameGroupCompanyRestrictionSwitch.isOn{
      securityPreferencesUpdated = true
    }
    if securityPreferences!.emergencyOnNonCompletionOfRideOnTime != rideCompletionOnTimeSwitch.isOn{
      securityPreferencesUpdated = true
    }
    if securityPreferences!.emergencyOnRideGiverDeviatesRoute != routeDeviationSecuritySwitch.isOn{
      securityPreferencesUpdated = true
    }
    if securityPreferences!.shareRidesWithUnVeririfiedUsers != verifiedUsersRestrictionSwitch.isOn{
      securityPreferencesUpdated = true
    }
    if isSafeGuardValueChanged {
       securityPreferencesUpdated = true
    }
  }
  func checkAndSetCompanyConstraintsIfValid() -> Bool
  {
    var invalidConstraint = false
    if(sameCompanyRestrictionSwitch.isOn)
    {
      invalidConstraint = true
      sameCompanyRestrictionSwitch.setOn(false, animated: false)
    }
    if(sameGroupCompanyRestrictionSwitch.isOn)
    {
      invalidConstraint = true
      sameGroupCompanyRestrictionSwitch.setOn(false, animated: false)
    }
    if(invalidConstraint)
    {
         modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
        modelLessDialogue?.initializeViews(message: Strings.company_email_profile, actionText: Strings.set_company_email)
        modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileEditingVC(_:))))
        modelLessDialogue?.isUserInteractionEnabled = true
        modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width, height: 80)
        self.view.addSubview(modelLessDialogue!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.removeModelLessDialogue()
        }
        return false
    }
    return true
  }
    
    private func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }
    
    @objc private func profileEditingVC(_ recognizer: UITapGestureRecognizer) {
        let vc = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func sameCompanySwitchChanged(_ sender: Any) {
    if sameCompanyRestrictionSwitch.isOn && sameGroupCompanyRestrictionSwitch.isOn{
      sameGroupCompanyRestrictionSwitch.isOn = false
    }
    if sameCompanyRestrictionSwitch.isOn && verifiedUsersRestrictionSwitch.isOn
    {
        verifiedUsersRestrictionSwitch.isOn = false
    }
  }
  @IBAction func sameGroupOfCompanySwitchChanged(_ sender: Any) {
    
    if sameGroupCompanyRestrictionSwitch.isOn && sameCompanyRestrictionSwitch.isOn{
      sameCompanyRestrictionSwitch.isOn = false
    }
    if sameGroupCompanyRestrictionSwitch.isOn && verifiedUsersRestrictionSwitch.isOn
    {
        verifiedUsersRestrictionSwitch.isOn = false
    }
  }
  
    @IBAction func verifiedUserRestrictionTapped(_ sender: Any) {
        if verifiedUsersRestrictionSwitch.isOn && sameCompanyRestrictionSwitch.isOn
        {
            sameCompanyRestrictionSwitch.isOn = false
        }
        if verifiedUsersRestrictionSwitch.isOn && sameGroupCompanyRestrictionSwitch.isOn
        {
            sameGroupCompanyRestrictionSwitch.isOn = false
        }
    }
  
  @IBAction func emergencyContactNumberAction(_ sender: Any) {
  
    let selectContactViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SelectContactViewController") as! SelectContactViewController
    selectContactViewController.initializeDataBeforePresenting(selectContactDelegate: self, requiredContacts: Contacts.mobileContacts)
    selectContactViewController.modalPresentationStyle = .overFullScreen
    self.present(selectContactViewController, animated: false, completion: nil)
  }
  
  func selectedContact(contact: Contact) {
    let emergencyContact = EmergencyContactUtils.getEmergencyContactNumberWithName(contact: contact)
    emergencyLabel.text = emergencyContact
    self.securityPreferencesUpdated = true
  }
    @IBAction func safeGuardSwitchChanged(_ sender: UISwitch) {
        isSafeGuardValueChanged = true
    }
    
  @IBAction func allowCallRestrictionAction(_ sender: Any) {
    
    AppDelegate.getAppDelegate().log.debug("viewReceiveCall()")
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.left
    
    let strings = [["text" : Strings.Anyone, "font" : UIFont(name: "HelveticaNeue-Bold", size: 15)!, "alignment" : paragraphStyle],
                   ["text" : "\n", "font" : UIFont(name: "HelveticaNeue-Bold", size: 15)!, "alignment" : paragraphStyle],
                   ["text" : Strings.call_info_open, "font" : UIFont(name: "Helvetica Neue", size: 15)!, "alignment" : paragraphStyle], ["text" : "\n\n", "font" : UIFont(name: "HelveticaNeue-Bold", size: 15)!, "alignment" : paragraphStyle],
                   ["text" : Strings.Ride_partners, "font" : UIFont(name: "HelveticaNeue-Bold", size: 15)!, "alignment" : paragraphStyle], ["text" : "\n", "font" : UIFont(name: "HelveticaNeue-Bold", size: 15)!, "alignment" : paragraphStyle],
                   ["text" : Strings.call_info_ride_partners, "font" : UIFont(name: "Helvetica Neue", size: 15)!, "alignment" : paragraphStyle],
                   ["text" : "\n\n", "font" : UIFont(name: "HelveticaNeue-Bold", size: 15)!, "alignment" : paragraphStyle],
                   ["text" : Strings.calls_please, "font" : UIFont(name: "HelveticaNeue-Bold", size: 15)!, "alignment" : paragraphStyle],
                   ["text" : "\n", "font" : UIFont(name: "HelveticaNeue-Bold", size: 15)!, "alignment" : paragraphStyle],
                   ["text" : Strings.call_info_closed, "font" : UIFont(name: "Helvetica Neue", size: 15)!, "alignment" : paragraphStyle]];
    
    let attributedString = NSMutableAttributedString()
    
    for configDict in strings {
      if let text = configDict["text"] as? String, let font =  configDict["font"], let alignment = configDict["alignment"]{
        attributedString.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : alignment]))
      }
    }
    
    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: Strings.ok, style: .cancel , handler: nil))
    
    alert.setValue(attributedString, forKey: "attributedMessage")
    
    alert.view.tintColor = Colors.alertViewTintColor
    present(alert, animated: false, completion: {
      alert.view.tintColor = Colors.alertViewTintColor
        alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))

    })
  }
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
  
  @IBAction func backButtonAction(_ sender: Any) {
    if securityPreferences == nil {
      AppDelegate.getAppDelegate().log.debug("Profile data is not retrieved")
      self.navigationController?.popViewController(animated: false)
      return
    }
    let profile = UserDataCache.getInstance()?.getLoggedInUserProfile()

    if  profile!.email == nil {
        if !checkAndSetCompanyConstraintsIfValid()
        {
            return
        }        
    }
    if self.sameGenderRestrictionSwitch.isOn  && ( profile!.gender == nil || profile!.gender?.isEmpty == true ||  profile!.gender == User.USER_GENDER_UNKNOWN){
        UIApplication.shared.keyWindow?.makeToast( Strings.save_gender_and_then)
        
        sameGenderRestrictionSwitch.setOn(false, animated: false)
        return
    }
    checkIfFieldsChanged()
    if(securityPreferencesUpdated)
    {
        updateSecurityPreferences(receiver: self)
    }else{
      self.navigationController?.popViewController(animated: false)
    }
  }
  
  @IBAction func completeRideOnTimeInfoAction(_ sender: Any) {
    MessageDisplay.displayAlert(messageString: Strings.rideCompletionOnTimeInfo, viewController: self) { (result) in
      
    }
  }
  
  @IBAction func routeDeviationInfoAction(_ sender: Any) {
    MessageDisplay.displayAlert(messageString: Strings.route_deviation_info, viewController: self) { (result) in
      
    }
  }
  func hideCancelButton(){
    if self.emergencyLabel.text == nil || self.emergencyLabel.text?.isEmpty == true{
      self.cancelButton.isHidden = true
    }
    else{
      self.cancelButton.isHidden = false
    }
  }
  
    @IBAction func cancelButtonClicked(_ sender: Any) {
        emergencyLabel.text = nil
        emergencyLabel.placeholder = Strings.emergency_number_placeholder
        hideCancelButton()
    }
}
