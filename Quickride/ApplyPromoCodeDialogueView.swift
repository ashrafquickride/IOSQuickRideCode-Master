//
//  ApplyPromoCodeDialogueView.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 17/10/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public typealias textFieldActionHandler = (_ text : String?, _ result : String) -> Void

class ApplyPromoCodeDialogueView: ModelViewController, UITextFieldDelegate{

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var positiveActnBtn: UIButton!
    @IBOutlet weak var negativeActnBtn: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var alertDialogueViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var errorAlertLabel: UILabel!
    @IBOutlet weak var errorAlertHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var successMessageLabel: UILabel!
    @IBOutlet weak var okActionBtn: UIButton!
    @IBOutlet weak var promoAppliedImageView: UIImageView!
    @IBOutlet weak var promoAppliedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var clearButton: UIButton!
    
    var isKeyBoardVisible = false
    var titleMessage : String?
    var promoCode : String?
    var positiveBtnTitle : String?
    var negativeBtnTitle : String?
    var viewController : UIViewController?
    var completionHandler : alertControllerTextFieldActionHandler?
    var isCapitalTextRequired = false
    var placeHolderText : String?
    var promoCodeAppliedMsg: String?
    
    func initializeDataBeforePresentingView(title : String?, positiveBtnTitle : String?, negativeBtnTitle : String?, promoCode : String?,isCapitalTextRequired : Bool,viewController: UIViewController?,placeHolderText : String?, promoCodeAppliedMsg: String?, handler : @escaping textFieldActionHandler){
        self.titleMessage = title
        self.positiveBtnTitle = positiveBtnTitle
        self.negativeBtnTitle = negativeBtnTitle
        self.promoCode = promoCode
        self.isCapitalTextRequired = isCapitalTextRequired
        self.viewController = viewController
        self.placeHolderText = placeHolderText
        self.promoCodeAppliedMsg = promoCodeAppliedMsg
        self.completionHandler = handler
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        titleLabel.text = titleMessage
        positiveActnBtn.setTitle(positiveBtnTitle, for: UIControl.State.normal)
        negativeActnBtn.setTitle(negativeBtnTitle, for: UIControl.State.normal)
        ViewCustomizationUtils.addCornerRadiusToView(view: infoView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: positiveActnBtn, cornerRadius: 10.0)
        ViewCustomizationUtils.addBorderToView(view: negativeActnBtn, borderWidth: 1.0, color: UIColor(netHex:0xcdcdcd))
        ViewCustomizationUtils.addCornerRadiusToView(view: negativeActnBtn, cornerRadius: 10.0)
        ViewCustomizationUtils.addBorderToView(view: okActionBtn, borderWidth: 1.0, color: UIColor(netHex: 0x0091EA))
        ViewCustomizationUtils.addCornerRadiusToView(view: okActionBtn, cornerRadius: 5.0)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ApplyPromoCodeDialogueView.dismissView(_:))))
        textField.delegate = self
        self.textField.text = self.promoCode
        if promoCode != nil && !promoCode!.isEmpty && promoCodeAppliedMsg != nil && !promoCodeAppliedMsg!.isEmpty {
            showPromoAppliedMessage(message: promoCodeAppliedMsg!)
        } else {
            self.textField.becomeFirstResponder()
        }
        self.textField.placeholder = placeHolderText
        
        if isCapitalTextRequired
        {
            self.textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        }
        NotificationCenter.default.addObserver(self, selector: #selector(ApplyPromoCodeDialogueView.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ApplyPromoCodeDialogueView.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        negativeActnBtn.addTarget(self, action:#selector(ApplyPromoCodeDialogueView.HoldCancelBtn(_:)), for: UIControl.Event.touchDown)
        textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    override func viewDidAppear(_ animated: Bool) {
        positiveActnColorChange()
    }
    @objc func textFieldDidChange(textField : UITextField){
        positiveActnColorChange()
    }
    @objc func HoldCancelBtn(_ sender:UIButton)
    {
        negativeActnBtn.backgroundColor = Colors.lightGrey
    }
    func HoldRelease(_ sender:UIButton){
        negativeActnBtn.backgroundColor = UIColor.white
    }
    func positiveActnColorChange(){
        if textField.text != nil && textField.text!.isEmpty == false {
            CustomExtensionUtility.changeBtnColor(sender: self.positiveActnBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            positiveActnBtn.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.positiveActnBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            positiveActnBtn.isUserInteractionEnabled = false
        }
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
            alertDialogueViewCenterYConstraint.constant = -keyBoardSize.height/2
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        alertDialogueViewCenterYConstraint.constant = 0
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.errorAlertLabel.isHidden = true
        self.errorAlertHeightConstraint.constant = 0
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
    func textFieldShouldReturn(_ textField : UITextField) -> Bool{
        textField.endEditing(true)
        return false
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        positiveActnColorChange()
        return true
    }
    @IBAction func ApplyBtnTapped(_ sender: Any) {
        self.view.endEditing(false)
        if textField.text!.isEmpty
        {
            self.errorAlertLabel.isHidden = false
            self.errorAlertHeightConstraint.constant = 20
            self.errorAlertLabel.text = "* " + Strings.enter_promo_code
            return
        }
        
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        
        self.completionHandler?(textField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces), self.positiveActnBtn.titleLabel!.text!)
  
    }
    
    func showPromoAppliedMessage(message: String){
        promoAppliedImageView.isHidden = false
        promoAppliedImageViewHeightConstraint.constant = 40
        self.successMessageLabel.isHidden = false
        self.successMessageLabel.text = message
        okActionBtn.isHidden = false
        positiveActnBtn.isHidden = true
        negativeActnBtn.isHidden = true
        textField.backgroundColor = UIColor.darkGray
        textField.textColor = UIColor.white
        clearButton.isHidden = false
    }
    
    func handleResponseError(responseError : ResponseError?, responseObject: NSDictionary?, error: NSError?){
        if responseError != nil {
            self.errorAlertLabel.isHidden = false
            self.errorAlertHeightConstraint.constant = 40
            self.errorAlertLabel.text = "* " + ErrorProcessUtils.getErrorMessageFromErrorObject(error: responseError!)
        } else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
    @IBAction func cancelBtnTapped(_ sender: Any) {
        completionHandler?(nil, negativeActnBtn.titleLabel!.text!)
        self.view?.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        completionHandler?(nil, okActionBtn.titleLabel!.text!)
        self.view?.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        textField.text = nil
        positiveActnColorChange()
        textField.backgroundColor = UIColor(netHex: 0xE8E8E8)
        textField.textColor = UIColor.black
        clearButton.isHidden = true
        promoAppliedImageView.isHidden = true
        promoAppliedImageViewHeightConstraint.constant = 0
        self.successMessageLabel.isHidden = true
        okActionBtn.isHidden = true
        positiveActnBtn.isHidden = false
        negativeActnBtn.isHidden = false
    }
    
    @objc func dismissView(_ sender: UITapGestureRecognizer)
    {
        completionHandler?(nil, negativeActnBtn.titleLabel!.text!)
        self.view?.removeFromSuperview()
        self.removeFromParent()
    }
}
