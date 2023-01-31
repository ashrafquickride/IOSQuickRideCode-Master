//
//  AdditionalDetailsForRegistrationViewController.swift
//  Quickride
//
//  Created by KNM Rao on 10/11/16.
//  Copyright © 2016 iDisha. All rights reserved.
//

import Foundation
import SwiftSpinner
import ObjectMapper
import CoreLocation
class AdditionalDetailsForRegistrationViewController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate,SendOtpForAccountVerification {
  
  
  var employee : Employee?
  var primaryArea : String?
  var locationChangeListener = CLLocationManager()
  @IBOutlet var phoneNUmberTextField: UITextField!
  
  @IBOutlet var havePromoCodeButton: UIButton!
  
  @IBOutlet var promocodeView: UIView!
  
  @IBOutlet var promoCodeLabel: UILabel!
  
  
  @IBOutlet var welcomeMessageLabel: UILabel!
  
  @IBOutlet var phoneTextFiledTopConstraint: NSLayoutConstraint!
  
  
  func initializeDataBeforePresenting(employee : Employee){
    self.employee = employee
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    promocodeView.hidden = true
    phoneNUmberTextField.delegate = self
    welcomeMessageLabel.text = "\(Strings.welcome) \(employee!.userName) \(Strings.please_confirm_your_mobile_number)"
    locationChangeListener.requestWhenInUseAuthorization()
    locationChangeListener.delegate = self
    locationChangeListener.startUpdatingLocation()
    if locationChangeListener.location != nil{
      MapUtils().getReverseGeocodeAddress(locationChangeListener.location!.coordinate, handler: { (location,error) in
        if self.primaryArea == nil{
          self.primaryArea = location!.state
        }
        
      })
    }
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AdditionalDetailsForRegistrationViewController.keyBoardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AdditionalDetailsForRegistrationViewController.keyBoardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  func keyBoardWillShow(notification : NSNotification){
    AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
    
      self.phoneTextFiledTopConstraint.constant =  110
  }
  
  func keyBoardWillHide(notification: NSNotification){
    AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
    self.phoneTextFiledTopConstraint.constant =  170
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    manager.stopUpdatingLocation()
    LocationCache.getCacheInstance().putRecentLocationOfUser(locations.last)
    if manager.location != nil && locations.last!.distanceFromLocation(manager.location!) < 20{
      return
    }
    
    MapUtils().getReverseGeocodeAddress(locations.last!.coordinate, handler: { (location,error) in
      if location != nil{
        self.primaryArea = location!.state
      }
    })
  }
  @IBAction func submitButtonTapped(sender: AnyObject) {
    doSignup()
  }
  func textFieldDidBeginEditing(textField: UITextField) {
    
      addDoneButton(textField)
    
  }
  func addDoneButton(textField :UITextField){
    let keyToolBar = UIToolbar()
    keyToolBar.sizeToFit()
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: view, action: #selector(UIView.endEditing(_:)))
    keyToolBar.items = [flexBarButton,doneBarButton]
    
    textField.inputAccessoryView = keyToolBar
  }
  private func doSignup() {
    AppDelegate.getAppDelegate().log.debug("doSignup()")
    if phoneNUmberTextField.text == nil || !AppUtil.isValidPhoneNo(phoneNUmberTextField.text!)
     {
      MessageDisplay.displayAlert(Strings.enter_valid_phone_no, viewController: self,handler: nil)
      return
    }
    
    if Reachability.isConnectedToNetwork() == false {
      ErrorProcessUtils.displayNetworkError(self)
      return
    }
    
    SwiftSpinner.show(Strings.registering+" "+self.employee!.userName+" "+Strings.please_wait)
    
    
    
    
    var employeeDetails = [String : String]()
    employeeDetails[User.FLD_PHONE] = phoneNUmberTextField!.text!
    employeeDetails[User.FLD_NAME] = employee!.userName
    employeeDetails[User.GENDER] = employee!.gender
    employeeDetails[User.FLD_PWD] = employee!.password
    
    if (promoCodeLabel.text != nil) {
      employeeDetails[User.FLD_PROMO_CODE] = promoCodeLabel.text!
    }
    employeeDetails[User.FLD_PRIMARY_AREA] = primaryArea
    employeeDetails[Employee.LOGIN_ID] = employee!.loginId!
    employeeDetails[UserProfile.FLD_COMPANY_NAME] = employee!.companyName
    employeeDetails[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
    
//    EmployeeRestClient.createEmployee(employeeDetails, targetViewController: self){
//      responseObject, error in
//      AppDelegate.getAppDelegate().log.debug("responseObject = \(responseObject); error = \(error)")
//      SwiftSpinner.hide()
//      if responseObject != nil {
//        if responseObject![HttpUtils.RESULT] as! String == HttpUtils.RESPONSE_SUCCESS{
//          
//          self.navigateToVerificationViewController(false)
//        }
//        else if responseObject!["result"] as! String == "FAILURE" {
//          SwiftSpinner.hide()
//          let responseError = Mapper<ResponseError>().map(responseObject!["resultData"])
//          
//          if responseError!.errorCode == UserMangementException.USER_ALREADY_EXIST{
//            self.showLoginOrSkipDialog(responseError!.userMessage!)
//          }else{
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//              MessageDisplay.displayErrorAlert(responseError!, targetViewController: self,handler: nil)
//            })
//
//          }
//          
//        }
//      }
//      else {
//        SwiftSpinner.hide()
//        ErrorProcessUtils.handleError(error, viewController: self, operationCode: nil, networkStatusListener: nil)
//      }
//    }
}
  func navigateToVerificationViewController(isExistingUser : Bool){
    let verificationViewController : VerificationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewControllerWithIdentifier("VerificationViewController") as! VerificationViewController
    
    verificationViewController.initializeDataBeforePresenting(self.phoneNUmberTextField.text!, password: self.employee!.password, email : self.employee?.loginId,companyName : self.employee?.companyName,userObj: self.employee!, userProfile: createUserProfileFromExistingData(),isExistingUser : isExistingUser)
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.navigationController?.pushViewController(verificationViewController, animated: false)
    })
  }
  func createUserProfileFromExistingData() -> UserProfile{
    let userProfile : UserProfile = UserProfile()
    userProfile.userName = self.employee!.userName
    userProfile.userId = Double(self.employee!.phoneNumber)
    userProfile.confirmType = false
    userProfile.gender = self.employee!.gender
    
    var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
    if clientConfiguration == nil{
      clientConfiguration = ClientConfigurtion()
    }
    userProfile.rideMatchPercentageAsRider = clientConfiguration!.rideMatchDefaultPercentageRider
    userProfile.rideMatchPercentageAsPassenger = clientConfiguration!.rideMatchDefaultPercentagePassenger
    return userProfile
  }
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    var threshold : Int?
    if textField == phoneNUmberTextField {
      threshold = 10
    }else{
      return true
    }
    let currentCharacterCount = textField.text?.characters.count ?? 0
    if (range.length + range.location > currentCharacterCount){
      return false
    }
    let newLength = currentCharacterCount + string.characters.count - range.length
    return newLength <= threshold
  }
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.endEditing(false)
    return false
  }
  
  @IBAction func havePromocodeButtonClicked(sender: AnyObject) {
    applyPromoCode()
  }
  
  func applyPromoCode(){
    AppDelegate.getAppDelegate().log.debug("applyPromoCode()")
    
    if Reachability.isConnectedToNetwork() == false {
      ErrorProcessUtils.displayNetworkError(self)
      return
    }
    
    var promoCodeTextField: UITextField?
    let promoAlertMessage = UIAlertController(title: Strings.apply_promo_code, message: nil, preferredStyle: .Alert)
    promoAlertMessage.addTextFieldWithConfigurationHandler({
      textField -> Void in
      textField.textColor = UIColor.blackColor()
      textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
      
      promoCodeTextField = textField
      promoCodeTextField?.delegate = self
    })
    promoAlertMessage.addAction(UIAlertAction(title: Strings.cancel, style: .Cancel , handler: nil))
    promoAlertMessage.addAction(UIAlertAction(title: Strings.apply, style: .Default , handler: {
      Void -> Void in
      promoCodeTextField?.endEditing(true)
      let promocode = promoCodeTextField!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters
      if promocode.count == 0{
        
        UIApplication.sharedApplication().keyWindow?.makeToast(Strings.enter_promo_code)
        return
      }
      if Reachability.isConnectedToNetwork() == false {
        ErrorProcessUtils.displayNetworkError(self)
        return
      }
      
      SwiftSpinner.show(Strings.confirming_promo_code)
      
      UserRestClient.verifyReferral(String(promocode), uiViewController: self, completionHandler: {
        responseObject, error in
        if responseObject != nil {
          AppDelegate.getAppDelegate().log.debug("responseObject = \(responseObject); error = \(error)")
          if responseObject!["result"] as! String == "SUCCESS" {
            SwiftSpinner.hide()
            UIApplication.sharedApplication().keyWindow?.makeToast(Strings.referral_code_applied)
            self.applyPromoCodeAndEnableChangePromoCodeButton((promoCodeTextField?.text!)!)
          } else if responseObject!["result"] as! String == "FAILURE" {
            SwiftSpinner.hide()
            let responseError = Mapper<ResponseError>().map(responseObject!["resultData"])
            MessageDisplay.displayErrorAlert(responseError!, targetViewController: self,handler: nil)
          }
        }
        else{
          SwiftSpinner.hide()
          ErrorProcessUtils.handleError(error, viewController: self, operationCode: nil, networkStatusListener: nil)
        }
      })
    }))
    promoAlertMessage.view.tintColor = Colors.alertViewTintColor
    self.presentViewController(promoAlertMessage, animated: false, completion: {
        promoAlertMessage.view.tintColor = Colors.alertViewTintColor
    })
  }
  @IBAction func weRideTermsClicked(sender: AnyObject) {
    let termsViewController = UIStoryboard(name: "Common",bundle: nil).instantiateViewControllerWithIdentifier("TermsViewController") as! TermsViewController
    self.navigationController?.pushViewController(termsViewController, animated: false)
  }
  
  @IBAction func changePromocodeButtonClicked(sender: AnyObject) {
    
    applyPromoCode()
  }
  func applyPromoCodeAndEnableChangePromoCodeButton(promoCodeString: String){
    AppDelegate.getAppDelegate().log.debug("applyPromoCodeAndEnableChangePromoCodeButton()")
    self.havePromoCodeButton.hidden = true
    promoCodeLabel.text = promoCodeString

    promocodeView.hidden = false

  }
  func showLoginOrSkipDialog(errorMsg : String)
  {
    MessageDisplay.displayErrorAlertWithAction(nil, isDismissViewRequired : false, message1: errorMsg, message2: nil, positiveActnTitle: Strings.reset_caps, negativeActionTitle : Strings.skip_caps,linkButtonText: nil, viewController: self, handler: { (result) in
        if Strings.reset_caps == result{
            UserOTPSenderHandler(userId: self.phoneNUmberTextField!.text!,email: "",countryCode: nil, viewController: self, sendOtpForAccountVerification: self).sendOTP()
        }
    })
  }
  func sent() {
    navigateToVerificationViewController(true)
  }
  @IBAction func backButtonClicked(sender: AnyObject) {
    self.navigationController?.popViewControllerAnimated(false)
  }
}
