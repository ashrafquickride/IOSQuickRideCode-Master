//
//  TextViewCustomAlertController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 15/02/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias alertControllerTextFieldActionHandler = (_ text : String?, _ result : String) -> Void

class BaseTextViewCustomAlertController: ModelViewController
{
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var positiveActnBtn: UIButton!
    
    @IBOutlet weak var negativeActnBtn: UIButton!
    
    @IBOutlet weak var alertDialogueView: UIView!
    
    @IBOutlet weak var alertDialogueViewBtmHeightConstraint: NSLayoutConstraint!
    
    var isKeyBoardVisible = false
    var titleMessage : String?
    var placeHolder : String?
    var positiveBtnTitle : String?
    var negativeBtnTitle : String?
    var existedMessage : String?
    var textAlignment : NSTextAlignment?
    var viewController : UIViewController?
    var completionHandler : alertControllerTextFieldActionHandler?
    var isCapitalTextRequired = false
    var isDropDownRequired = false
    var dropDownReasonList : [String]?
    
    func initializeDataBeforePresentingView(title : String?, positiveBtnTitle : String?, negativeBtnTitle : String?, placeHolder : String?, textAlignment : NSTextAlignment,isCapitalTextRequired : Bool, isDropDownRequired : Bool, dropDownReasons : [String]?,existingMessage: String?,viewController: UIViewController?, handler : @escaping alertControllerTextFieldActionHandler)
    {
        self.titleMessage = title
        self.positiveBtnTitle = positiveBtnTitle
        self.negativeBtnTitle = negativeBtnTitle
        self.placeHolder = placeHolder
        self.textAlignment = textAlignment
        self.isCapitalTextRequired = isCapitalTextRequired
        self.isDropDownRequired = isDropDownRequired
        self.dropDownReasonList = dropDownReasons
        self.viewController = viewController
        self.completionHandler = handler
        self.existedMessage = existingMessage
    }
    
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        self.titleLabel.textAlignment = self.textAlignment!
        titleLabel.text = titleMessage
        positiveActnBtn.setTitle(positiveBtnTitle, for: UIControl.State.normal)
        negativeActnBtn.setTitle(negativeBtnTitle, for: UIControl.State.normal)

        handleBrandingChangesBasedOnTarget()
        NotificationCenter.default.addObserver(self, selector: #selector(BaseTextViewCustomAlertController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BaseTextViewCustomAlertController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if negativeBtnTitle == nil || (negativeBtnTitle?.isEmpty)!
        {
            negativeActnBtn.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CustomExtensionUtility.changeBtnColor(sender: self.positiveActnBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        CustomExtensionUtility.changeBtnColor(sender: self.negativeActnBtn, color1: UIColor.white, color2: UIColor.white)
        negativeActnBtn.addShadow()
    }
    
    func handleBrandingChangesBasedOnTarget()
    {
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: alertDialogueView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)

        ViewCustomizationUtils.addCornerRadiusToView(view: positiveActnBtn, cornerRadius: 20)
        positiveActnBtn.backgroundColor = Colors.mainButtonColor
    }
    
  @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }

        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
            alertDialogueViewBtmHeightConstraint.constant = keyBoardSize.height + 10
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        alertDialogueViewBtmHeightConstraint.constant = 30
    }


    @IBAction func negativeActnBtnTapped(_ sender: Any) {
        self.view?.removeFromSuperview()
        self.removeFromParent()
    }
    
}
