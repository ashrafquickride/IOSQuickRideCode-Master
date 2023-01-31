//
//  HPPayRegistrationViewController.swift
//  Quickride
//
//  Created by Vinutha on 02/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import DropDown

class HPPayRegistrationViewController: UIViewController,UITextFieldDelegate{

    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var salutationView: UIView!
    @IBOutlet weak var salutationTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var birthDateView: UIView!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tickMarkButton: UIButton!
    @IBOutlet weak var termsAndCondtionLabel: UILabel!
    
    //MARK: Variables
    private var isKeyBoardVisible = false
    private var salutationDropDown = DropDown()
    private var hPPayRegistrationViewModel = HPPayRegistrationViewModel()
    
    func initializeDataBeforePresentingView (fuelCardRegistrationReceiver : @escaping fuelCardRegistrationReceiver){
        hPPayRegistrationViewModel.initailizeData(fuelCardRegistrationReceiver: fuelCardRegistrationReceiver)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        mobileNumberTextField.delegate = self
        birthDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(birthDateViewTapped(_:))))
        salutationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSalutationDropDown)))
        termsAndCondtionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsAndCondtionTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(HPPayRegistrationViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HPPayRegistrationViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        termsAndCondtionLabel.attributedText = ViewCustomizationUtils.getAttributedString(string: Strings.hp_pay_terms, rangeofString: "Terms & Conditions", textColor: UIColor(netHex: 0x007AFF), textSize: 12)
        SetUPUi()
        prepareSalutationDropDown()
    }
    private func SetUPUi(){
        firstNameTextField.autocapitalizationType = UITextAutocapitalizationType.words
        lastNameTextField.autocapitalizationType = UITextAutocapitalizationType.words
        let userName = UserDataCache.getInstance()?.getLoggedInUserProfile()?.userName
        if let firstName = userName?.components(separatedBy: " ").first{
            firstNameTextField.text = firstName.capitalized
        }
        if let range = userName?.range(of: " ") {
            let LastName = userName?[range.upperBound...]
            lastNameTextField.text = String(LastName!.capitalized)
        }
        mobileNumberTextField.text = StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.currentUser?.contactNo)
        if UserDataCache.getInstance()?.currentUser?.gender == User.USER_GENDER_MALE{
            salutationTextField.text = "Mr"
        }else{
            salutationTextField.text = "Ms"
        }
    }
    
    func prepareSalutationDropDown() {
        salutationDropDown.anchorView = salutationTextField
        salutationDropDown.dataSource = ["Mr","Ms","Mrs"]
        salutationDropDown.selectionAction = { [weak self] (index, item) in
            self?.salutationTextField.text = item
        }
    }
    
    @objc func showSalutationDropDown(_ gesture : UITapGestureRecognizer){
        salutationDropDown.show()
    }
    
    @objc func termsAndCondtionTapped(_ sender: UITapGestureRecognizer){
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  AppConfiguration.hpPay_terms_conditions)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.terms_and_conditions, url: (urlcomps?.url!)!, actionComplitionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        bottomSpaceConstraint.constant = 25
    }
    @objc func keyBoardWillHide(notification: NSNotification) {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomSpaceConstraint.constant = 30
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLblHeightConstraint.constant = 0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == firstNameTextField{
            threshold = 50
        }else if textField == lastNameTextField{
            threshold = 50
        }else if textField == mobileNumberTextField{
            threshold = 10
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount{
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    private func validateAllFields() -> Bool{
         if firstNameTextField.text!.isEmpty{
            errorLabel.text = Strings.first_name_error
            errorLblHeightConstraint.constant = 20
            return false
        }else if lastNameTextField.text!.isEmpty{
            errorLabel.text = Strings.last_name_error
            errorLblHeightConstraint.constant = 20
            return false
        }else if mobileNumberTextField.text!.isEmpty{
            errorLabel.text = Strings.enter_mobile_number
            errorLblHeightConstraint.constant = 20
            return false
        }else if dateOfBirthTextField.text!.isEmpty{
            errorLabel.text = Strings.dob_error
            errorLblHeightConstraint.constant = 20
            return false
         }else{
            errorLblHeightConstraint.constant = 0
            return true
        }
    }
    @objc func birthDateViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.endEditing(false)
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        let maxDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        let timeInterval = Double(maxDate!.timeIntervalSince1970)
        scheduleLater.initializeDataBeforePresentingView(minDate : nil,maxDate: timeInterval, defaultDate: timeInterval, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.date, datePickerTitle: nil, handler: nil)
        birthDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(birthDateViewTapped(_:))))
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    
    @IBAction func tickMarkTapped(_ sender: Any) {
        if hPPayRegistrationViewModel.acceptedTermsAndConditions{
            tickMarkButton.setImage(UIImage(named: "insurance_tick_disabled"), for: .normal)
            hPPayRegistrationViewModel.acceptedTermsAndConditions = false
        }else{
            tickMarkButton.setImage(UIImage(named: "insurance_tick"), for: .normal)
            hPPayRegistrationViewModel.acceptedTermsAndConditions = true
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func submitClicked(_ sender: Any){
        self.view.endEditing(false)
        if validateAllFields(){
            if QRReachability.isConnectedToNetwork() == false {
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
                return
            }
            if !hPPayRegistrationViewModel.acceptedTermsAndConditions{
                return
            }
           registerForHpPay()
        }
    }
    
    private func registerForHpPay(){
        let dateOfBirth = DateUtils.getDateStringFromString(date: dateOfBirthTextField.text, requiredFormat: DateUtils.DATE_FORMAT_YYYY_MM_DD_HH_SS, currentFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy) ?? ""
        QuickRideProgressSpinner.startSpinner()
        hPPayRegistrationViewModel.registerHpPayForUser(userId: UserDataCache.getInstance()?.userId ?? "", mobileNo: mobileNumberTextField.text ?? "", salutation: salutationTextField.text ?? "", firstName: firstNameTextField.text ?? "", lastName: lastNameTextField.text ?? "", dob: dateOfBirth,delegate: self)
    }
}
extension HPPayRegistrationViewController: SelectDateDelegate{ 
    func getTime(date: Double) {
        dateOfBirthTextField.text = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: date), dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
    }
}
extension HPPayRegistrationViewController: HPPayRegistrationViewModelDelegate{
    func handleSucessResponse() {
        QuickRideProgressSpinner.stopSpinner()
        hPPayRegistrationViewModel.fuelCardRegistrationReceiver!(true)
        self.navigationController?.popViewController(animated: false)
    }
    
    func handleFailureResponse(responseObject: NSDictionary?,error : NSError?) {
        QuickRideProgressSpinner.stopSpinner()
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
}
