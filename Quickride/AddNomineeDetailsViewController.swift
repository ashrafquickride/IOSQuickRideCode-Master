//
//  AddNomineeDetailsViewController.swift
//  Quickride
//
//  Created by Admin on 29/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import DropDown
import ObjectMapper

class AddNomineeDetailsViewController : UIViewController,UITextFieldDelegate{
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var relationshipView: UIView!
    
    @IBOutlet weak var relationshipTextField: UITextField!
    
    @IBOutlet weak var addNomineeBtn: UIButton!
    
    @IBOutlet weak var mobileNumberTextField: UITextField!
    
    @IBOutlet weak var relationshipTextFieldSeparationView: UIView!
    
    @IBOutlet weak var navigationBarTitleLbl: UILabel!
    
    
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
   
    @IBOutlet weak var scrollView: UIScrollView!
    
    var nomineeRelationshipDropDown = DropDown()
    var isKeyBoardVisible = false
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        ageTextField.delegate = self
        mobileNumberTextField.delegate = self
        setupNomineeRelationshipDropDown()
        relationshipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddNomineeDetailsViewController.showRelationsDropDown(_:))))
        if let nomineeDetails = UserDataCache.getInstance()?.getNomineeDetails(){
            nameTextField.text = nomineeDetails.nomineeName
            ageTextField.text = String(nomineeDetails.nomineeAge!)
            relationshipTextField.text = nomineeDetails.nomineeRelation
            mobileNumberTextField.text = nomineeDetails.nomineeMobile
            addNomineeBtn.setTitle(Strings.update_nominee.uppercased(), for: .normal)
            navigationBarTitleLbl.text = Strings.update_nominee
         }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyRidePreferencesViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyRidePreferencesViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        ViewCustomizationUtils.addCornerRadiusToView(view: self.addNomineeBtn, cornerRadius: 8.0)
        CustomExtensionUtility.changeBtnColor(sender: self.addNomineeBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }
    
    @IBAction func addNomineeBtnClicked(_ sender: Any) {
        if let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny(){
            MessageDisplay.displayAlert( messageString: validationErrorMsg, viewController: self,handler: nil)
            return
        }
        let nomineeDetails = NomineeDetails(userId: Double(QRSessionManager.getInstance()!.getUserId()), nomineeName: nameTextField.text, nomineeAge: Int(ageTextField.text!), nomineeMobile: mobileNumberTextField.text, nomineeRelation: relationshipTextField.text)
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.saveNomineeDetails(nomineeDetails: nomineeDetails, viewController: self){ (responseObject, error) in
            
            QuickRideProgressSpinner.stopSpinner()
            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                if let nomineeDetails = Mapper<NomineeDetails>().map(JSONObject: responseObject!["resultData"]){
                    UserDataCache.getInstance()?.saveOrUpdateNomineeDetails(nomineeDetails: nomineeDetails)
                }
                if self.navigationBarTitleLbl.text == Strings.update_nominee{
                    UIApplication.shared.keyWindow?.makeToast( Strings.nominee_details_updated)
                }else{
                    UIApplication.shared.keyWindow?.makeToast( Strings.nominee_details_saved)
                }
                self.navigationController?.popViewController(animated: false)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func setupNomineeRelationshipDropDown() {
        nomineeRelationshipDropDown.anchorView = relationshipView
        nomineeRelationshipDropDown.dataSource = Strings.nomineeRelations
        nomineeRelationshipDropDown.selectionAction = { [weak self] (index, item) in
            self?.relationshipTextField.text = item
        }
    }
    
    @objc func showRelationsDropDown(_ gesture : UITapGestureRecognizer){
        nomineeRelationshipDropDown.show()
    }
    
    func validateFieldsAndReturnErrorMsgIfAny() -> String? {
        AppDelegate.getAppDelegate().log.debug("validateFieldsAndReturnErrorMsgIfAny()")
        if nameTextField.text == nil || nameTextField.text!.isEmpty{
            return Strings.enter_nominee_name
        }else if UserProfileValidationUtils.validateStringForAlphabatic(string: nameTextField.text!) == false{
            return Strings.enter_valid_name
        }else if ageTextField.text == nil || ageTextField.text!.isEmpty{
            return Strings.enter_nominee_age
        }else if ageTextField.text!.count > 2 || ageTextField.text == "0" || ageTextField.text == "00"{
            return Strings.enter_valid_age
        }else if relationshipTextField.text == nil || relationshipTextField.text!.isEmpty{
            return Strings.select_relation_with_nominee
        }else if mobileNumberTextField.text == nil || mobileNumberTextField.text!.isEmpty{
            return Strings.enter_nominee_mobile_number
        }else if !AppUtil.isValidPhoneNo(phoneNo: mobileNumberTextField.text!, countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND){
            return Strings.enter_valid_phone_no
        }
        
        return nil
    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            scrollViewBottomSpaceConstraint.constant = keyBoardSize.height + 40
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        scrollViewBottomSpaceConstraint.constant = 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == mobileNumberTextField || textField == ageTextField {
            addDoneButton(textField: textField)
        }
    }
    
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        
        textField.inputAccessoryView = keyToolBar
    }
    
}
