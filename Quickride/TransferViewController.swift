//
//  TTransferViewController.swift
//  Quickride
//
//  Created by KNM Rao on 12/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper
import MRCountryPicker

public typealias transferUserNameCompletionHandler = (_ name: String?) -> Void

class TransferViewController: UIViewController,UITextFieldDelegate, SelectContactDelegate, MRCountryPickerDelegate{
  
  

    
    
  

    @IBOutlet weak var topTextLbl: QRHeaderLabel!
    
    @IBOutlet weak var navigationView: UINavigationItem!
    @IBOutlet weak var transferReasonEditText: UITextField!
  
  @IBOutlet weak var scollViewTransfer: UIScrollView!
  
  @IBOutlet weak var transferToNumberEditText: UITextField!
  
  @IBOutlet weak var contactSelectionBtn: UIButton!
  
  
  @IBOutlet weak var transferPointsEditText: UITextField!
  
  
  @IBOutlet weak var transferButton: UIButton!
  
  @IBOutlet weak var transferTitleText: UILabel!
  
  @IBOutlet weak var serviceFeeTextView: UITextView!
    
  @IBOutlet weak var countryPickerView: UIView!
    
  @IBOutlet weak var countryPickerFlag: UIImageView!
    
  @IBOutlet weak var countryLabel: UILabel!
    
  @IBOutlet weak var countryPickerLabel: UILabel!
    
  @IBOutlet weak var countryPicker: MRCountryPicker!
    
  @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
  @IBOutlet weak var rewardsImageView: UIImageView!
    
  @IBOutlet weak var arrowIcon: UIImageView!
    
  @IBOutlet weak var paymentPendingView: UIView!
    
   @IBOutlet weak var paymentPendingViewHeightConstraint: NSLayoutConstraint!
    
    
  // Not in We Ride
  
  @IBOutlet weak var serviceFeeText: UILabel!
    
  var clientConfiguration : ClientConfigurtion?
  static let USER_NOT_REGISTERED = 1004
  static let ACCOUNT_DOESNOT_EXIST = 1202
  var isFromMissingPayment: Bool?
  var selectedCountryCode : String?
  var isKeyBoardVisible : Bool = false
  var amountTransferRequest : AmountTransferRequest?
  var transferRequestCompletionHandler : transferRequestCompletionHandler?
  var contactNo : String?
    
    func initializeDataBeforePresenting(amountTransferRequest : AmountTransferRequest?, isFromMissingPayment: Bool?, transferRequestCompletionHandler : transferRequestCompletionHandler?){
      self.amountTransferRequest = amountTransferRequest
      self.transferRequestCompletionHandler = transferRequestCompletionHandler
        self.isFromMissingPayment = isFromMissingPayment
  }
  
  override func viewDidLoad() {
    AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
    definesPresentationContext = true
    super.viewDidLoad()
      if isFromMissingPayment == false {
          topTextLbl.text = "Pay For a Ride"
          transferButton.setTitle(Strings.transfer, for: .normal)
      } else {
          topTextLbl.text = "Missed Payments"
          transferButton.setTitle(Strings.request_caps, for: .normal)
      }
    clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
    if clientConfiguration == nil{
      clientConfiguration = ClientConfigurtion()
    }
    let user = UserDataCache.getInstance()?.currentUser!.copy() as? User
    if user!.countryCode != nil && user!.countryCode!.isEmpty == false{
        countryPicker.countryPickerDelegate = self
        countryPicker.setCountryByPhoneCode(user!.countryCode!)
    }else{
        let countryCode = AppConfiguration.DEFAULT_COUNTRY_CODE
        countryPicker?.countryPickerDelegate = self
        countryPicker?.setCountry(countryCode)
        self.selectedCountryCode = countryCode
    }
    countryPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TransferViewController.selectCountryCode(_:))))

    handleBrandingChanges()
    scollViewTransfer.contentSize = CGSize(width: 320, height: 800)
    scollViewTransfer.isScrollEnabled = true
    transferPointsEditText.delegate = self
    transferToNumberEditText.delegate = self
    transferReasonEditText.delegate = self
    if amountTransferRequest != nil{
        self.contactNo = StringUtils.getStringFromDouble(decimalNumber: amountTransferRequest!.requestorContactNo)
        transferPointsEditText.text = StringUtils.getStringFromDouble(decimalNumber: amountTransferRequest!.amount)
        transferToNumberEditText.text =  NumberUtils.getMaskedMobileNumber(mobileNumber: amountTransferRequest!.requestorContactNo)
      if amountTransferRequest!.reason != nil{
        transferReasonEditText.text = amountTransferRequest!.reason!
      }
    }
    NotificationCenter.default.addObserver(self, selector: #selector(TransferViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(TransferViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    handleVisibilityOfPendingBillView()
  
  }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        self.navigationController?.isNavigationBarHidden = true
    }

  func handleBrandingChanges(){
      ViewCustomizationUtils.addCornerRadiusToView(view: transferButton, cornerRadius: 2.0)
      transferButton.backgroundColor = Colors.mainButtonColor
      transferTitleText.text = Strings.transfer_title_text
      transferToNumberEditText.placeholder = Strings.registered_mobile_placeholder_text
      serviceFeeText.text = "\(Strings.service_fees) \(clientConfiguration!.dishaServiceFeesPercentageForTransfer)\(Strings.percentage_symbol) \(Strings.applicable_for_transfers)"
  }
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.countryPickerFlag.image = flag
        self.countryPickerLabel.text = phoneCode
        self.selectedCountryCode = countryCode
        self.countryLabel.text = countryCode

    }
    @objc func selectCountryCode(_ gesture : UITapGestureRecognizer){
        self.view.endEditing(false)
        let countryCodeSelector = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "CountryPickerViewController") as! CountryPickerViewController
        countryCodeSelector.initializeDataBeforePresenting(currentCountryCode: self.selectedCountryCode) { (name, countryCode, phoneCode, flag) in
            self.countryPickerLabel.text = phoneCode
            self.countryPickerFlag.image = flag
            self.selectedCountryCode = countryCode
            self.countryLabel.text = countryCode
        }
        self.present(countryCodeSelector, animated: false, completion: {
            
        })
    }

  func navigateToEmergencyContactSelection(){
    let selectContactViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SelectContactViewController") as! SelectContactViewController
    selectContactViewController.initializeDataBeforePresenting(selectContactDelegate: self, requiredContacts: Contacts.rideParticipants)
    selectContactViewController.modalPresentationStyle = .overFullScreen
    self.present(selectContactViewController, animated: false, completion: nil)
  }
  
  func selectedContact(contact: Contact) {
    self.contactNo = StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)
    transferToNumberEditText.text = NumberUtils.getMaskedMobileNumber(mobileNumber: contact.contactNo )
  }
  
 
  func textFieldShouldReturn(_ textField : UITextField) -> Bool{
    textField.endEditing(true)
    return false
  }
  func textFieldDidBeginEditing(_ textField: UITextField) {
    addDoneButton(textField: textField)
  }
  
  func addDoneButton(textField :UITextField){
    let keyToolBar = UIToolbar()
    keyToolBar.sizeToFit()
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
    keyToolBar.items = [flexBarButton,doneBarButton]
    textField.inputAccessoryView = keyToolBar
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    ScrollViewUtils.scrollToPoint(scrollView: scollViewTransfer, point: CGPoint(x: 0, y: 0))
    if textField == transferToNumberEditText{
        self.contactNo = textField.text
    }
   }
  
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
    }
    
  func clearAllFields()
  {
    transferPointsEditText.text = nil
    transferToNumberEditText.text = nil
    transferReasonEditText.text = nil
    transferToNumberEditText.placeholder = Strings.registered_mobile_placeholder_text
    transferPointsEditText.placeholder = Strings.number_of_points
    transferReasonEditText.placeholder = Strings.transfer_reason
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func transferPoints() {
    AppDelegate.getAppDelegate().log.debug("transferPoints()")
    
    
    if(!validateNumberOfPoints()){
      return
    }
    
    if(!validateUserPhone()){
      return
    }
    if QRReachability.isConnectedToNetwork() == false {
      ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
      return
    }
    getTransfereeUserName(handler: { (name) in
      self.displayTransferConfirmationDialog(name: name)
    })
  }
  private func validateNumberOfPoints()->Bool
  {
    let transferAmtStr = transferPointsEditText.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    if (transferAmtStr == nil || transferAmtStr!.isEmpty == true) {
        if isFromMissingPayment == false {
            MessageDisplay.displayAlert(messageString: Strings.enter_transfer_amount,viewController: self,handler: nil)
        } else if isFromMissingPayment == true {
            MessageDisplay.displayAlert(messageString: Strings.enter_request_amount,viewController: self,handler: nil)
        } else {
            return false
        }
        
    }
    if NumberUtils.validateTextFieldForSpecialCharacters(textField: transferPointsEditText, viewController: self){
        return false
    }
   
    let amount = Double(self.transferPointsEditText.text!)!
    if(amount == 0)
    {
      MessageDisplay.displayAlert(messageString: Strings.valid_amount,viewController: self,handler: nil)
      return false
    }
    
    return true
  }
  private func validateUserPhone() -> Bool
  {
    if QRReachability.isConnectedToNetwork() == false {
      ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
      return false
    }
    if self.contactNo == nil || self.contactNo!.isEmpty || AppUtil.isValidPhoneNo(phoneNo: self.contactNo!, countryCode: countryPickerLabel.text) == false
    {
      
      MessageDisplay.displayAlert(messageString: Strings.phone_no_not_valid,viewController: self,handler: nil)
      return false
    }
    let user = UserDataCache.getInstance()?.currentUser
    if user == nil || user!.countryCode == nil || user?.contactNo == nil || self.contactNo == nil
    {
        return false
    }
    if user!.countryCode! + StringUtils.getStringFromDouble(decimalNumber: user!.contactNo) == self.countryPickerLabel.text! + self.contactNo!
    {
      MessageDisplay.displayAlert(messageString: "Transferee number should be diffrent from your number",viewController: self,handler: nil)
      return false
    }
    return true
  }
  
  private func getTransfereeUserName(handler : @escaping transferUserNameCompletionHandler)
  {
    if validateUserPhone(){
      QuickRideProgressSpinner.startSpinner()
        var phoneCode : String?
        if countryPickerLabel.text != nil && countryPickerLabel.text!.isEmpty == false{
            phoneCode = countryPickerLabel.text
        }
        UserRestClient.getUserNameUsingContactNo(phoneNo: self.contactNo!, phoneCode : phoneCode, targetViewController: self, completionHandler: { (responseObject, error) in
        QuickRideProgressSpinner.stopSpinner()
        if responseObject == nil
        {
          ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self, handler: nil)
        }
        else if responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
          handler(responseObject!["resultData"] as? String)
        }
        else if responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] == nil {
          handler(nil)
        }
        else if responseObject!["result"] as! String == "FAILURE"{
          
          let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
          
          if (responseError!.errorCode == TransferViewController.USER_NOT_REGISTERED || responseError!.errorCode == TransferViewController.ACCOUNT_DOESNOT_EXIST)
          {
            
            MessageDisplay.displayAlert(messageString: Strings.not_registered,  viewController: self,handler: nil)
          }
          else
          {
            ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self, handler: nil)
          }
        }
        else{
          ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self, handler: nil)
        }
      })
    }
  }
  
  private func displayTransferConfirmationDialog(name : String?)
  {

    var title : String?
      
      if isFromMissingPayment == false {
          
          title = Strings.confirm_transfer
          MessageDisplay.displayErrorAlertWithAction(title: title, isDismissViewRequired : false, message1: getTransferConfirmationMessage(name: name), message2: getServiceFeeMessage(), positiveActnTitle: Strings.confirm_caps,negativeActionTitle : Strings.cancel_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.confirm_caps == result{
                self.doSendTransfer(name: name)
            }
          })
    }else{
      self.doRequestTransfer(name: name)
    }
   
  }
  func doSendTransfer(name : String?)  {
    QuickRideProgressSpinner.startSpinner()
    var phoneCode : String?
    if countryPickerLabel.text != nil && countryPickerLabel.text?.isEmpty == false{
        phoneCode = countryPickerLabel.text
    }
    var params : [String : String] = [String : String]()
    params[Account.TRANSFER_USER] = QRSessionManager.getInstance()?.getUserId()
    params[Account.TRANSFEREE_USER] = self.contactNo!
    params[Account.POINTS] = self.transferPointsEditText.text!
    params[Account.REASON] = self.transferReasonEditText.text
    if name != nil
    {
        params[Account.TRANSFEREE_NAME] = name!
    }
    params[User.FLD_COUNTRY_CODE] = phoneCode
    AccountRestClient.handleTransferRequest(body: params, targetViewController: self,completionHandler: { (responseObject, error) -> Void in
      self.handleTransferResponse(responseObject: responseObject, error: error)
    })
  }
  func doRequestTransfer(name : String?){
    QuickRideProgressSpinner.startSpinner()
    AccountRestClient.requestPoints(date: NSDate().timeIntervalSince1970*1000, reason: self.transferReasonEditText.text, points: Double(self.transferPointsEditText.text!)!, requestorUserId: UserDataCache.getInstance()!.currentUser!.phoneNumber, senderContactNo: Double(self.contactNo!)!, viewController: self) { (responseObject, error) in
      QuickRideProgressSpinner.stopSpinner()
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
        FaceBookEventsLoggingUtils.logAmountCreditsEvent(contentData: "Spent Credits", contentId: "", contentType: "", totalValue: Double(self.transferPointsEditText.text!)!)
        if name != nil
        {
            UIApplication.shared.keyWindow?.makeToast( String(format: Strings.requesting_transfer_ack, arguments: [self.transferPointsEditText.text!,name!]))
        }
        else
        {
            UIApplication.shared.keyWindow?.makeToast( String(format: Strings.requesting_transfer_ack, arguments: [self.transferPointsEditText.text!,self.transferToNumberEditText!.text!]))
        }
        self.clearAllFields()
      }else{
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
      }
    }
  }
  private func handleTransferResponse(responseObject: NSDictionary?, error: NSError?) {
    AppDelegate.getAppDelegate().log.debug("handleTransferResponse()")
    QuickRideProgressSpinner.stopSpinner()
    if responseObject != nil {
      if responseObject!["result"]! as! String == "SUCCESS"{
        FaceBookEventsLoggingUtils.logAmountDebitEvent(amount: Double(self.transferPointsEditText.text!)!, currency: "INR")
       
        if transferRequestCompletionHandler != nil
        {
            self.transferRequestCompletionHandler?()
        }
        UserDataCache.getInstance()?.refreshAccountInformationInCache()
      }
      else if responseObject!["result"]! as! String == "FAILURE"{
        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
        if responseError?.errorCode == AccountException.ACCOUNT_DOESNOT_EXIST{
          MessageDisplay.displayAlert(messageString: Strings.not_registered,  viewController: self,handler: nil)
        }
        else
        {
            MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self,handler: nil)
        }
      }
    }else {
      ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self, handler: nil)
    }
    clearAllFields()
  }
  
  private func getTransferConfirmationMessage(name : String?) -> String
  {
    let amount = Int(self.transferPointsEditText.text!)!
      
      if isFromMissingPayment == false {
          
          if name == nil{
            return "\(Strings.transferring) \(amount) \(Strings.pts) \(Strings.to) \(transferToNumberEditText!.text!)"
          }
          else
          {
            return "\(Strings.transferring) \(amount) \(Strings.pts) \(Strings.to) \(name!)(\(transferToNumberEditText!.text!))"
          }
          
  }else{
      if name == nil{
        return "\(Strings.requesting) \(amount) \(Strings.pts) \(Strings.to) \(transferToNumberEditText!.text!)"
      }
      else
      {
        return "\(Strings.requesting) \(amount) \(Strings.pts) \(Strings.to) \(name!)(\(transferToNumberEditText!.text!))"
      }
    }
    
  }
  private func getServiceFeeMessage() -> String
  {
    let amount = Int(self.transferPointsEditText.text!)!
    var serviceFee : Double = Double(amount * clientConfiguration!.dishaServiceFeesPercentageForTransfer)/100
    
    return String(serviceFee.roundToPlaces(places: 2))+" "+Strings.rs_will_be_deducted_as_service_fee
}
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var threshold : Int?
    if textField == transferToNumberEditText{
      threshold = 14
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
  
  @IBAction func contactsBtnTapped(_ sender: Any) {
    AppDelegate.getAppDelegate().log.debug("contactsBtnTapped()")
    navigateToEmergencyContactSelection()
  }
  @IBAction func btnTransferTapped(_ sender: Any) {
    transferPointsEditText.endEditing(false)
    transferToNumberEditText.endEditing(false)
    transferReasonEditText.endEditing(false)
    self.transferPoints()
  }
  

    @IBAction func backBtnClicked(_ sender: Any) {
        
        ViewControllerUtils.finishViewController(viewController: self)
    }
    
    private func handleVisibilityOfPendingBillView(){
        if let pendingBills = UserDataCache.getInstance()?.pendingLinkedWalletTransactions,pendingBills.count > 0 {
            openPendingLinkedWalletTransactionViewController(pendingLinkedWalletTransactions: pendingBills)
            paymentPendingView.isHidden = false
            paymentPendingViewHeightConstraint.constant = 50
            paymentPendingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TransferViewController.displayPendingBills(_:))))
            ImageUtils.setTintedIcon(origImage: UIImage(named: "notification_rewards")!, imageView: rewardsImageView, color: .white)
            ImageUtils.setTintedIcon(origImage: UIImage(named: "front_arrow")!, imageView: arrowIcon, color: .white)
        } else {
            paymentPendingView.isHidden = true
            paymentPendingViewHeightConstraint.constant = 0
        }
    }
    
    private func openPendingLinkedWalletTransactionViewController(pendingLinkedWalletTransactions : [LinkedWalletPendingTransaction]){
           let pendingLinkedWalletTransactionVC = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PendingUPILinkedWalletTransactionViewController") as! PendingUPILinkedWalletTransactionViewController
           pendingLinkedWalletTransactionVC.initializeDataBeforePresenting(pendingLinkedWalletTransactions: pendingLinkedWalletTransactions)
           ViewControllerUtils.addSubView(viewControllerToDisplay: pendingLinkedWalletTransactionVC)
     }
    
    @objc private func displayPendingBills(_ gesture : UITapGestureRecognizer){
        guard let pendingBills = UserDataCache.getInstance()?.pendingLinkedWalletTransactions,pendingBills.count > 0 else { return }
        openPendingLinkedWalletTransactionViewController(pendingLinkedWalletTransactions: pendingBills)
    }
}
