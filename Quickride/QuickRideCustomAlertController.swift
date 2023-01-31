//
//  QuickRideCustomAlertController.swift
//  Quickride
//
//  Created by Quickrid on 30/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
public typealias alertControllerActionHandler = (_ result : String) -> Void
public typealias alertControllerActionHandlerWithDontShowStatus = (_ result : String,_ dontShow : Bool) -> Void
class QuickRideCustomAlertController : ModelViewController {
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var alertDialogView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleLabelTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabelBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstMsgLblText: UILabel!

    @IBOutlet weak var secondMsgLblText: UILabel!
    
    @IBOutlet weak var secondMsgTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var positiveActnBtn: UIButton!
    
    @IBOutlet weak var negativeActnBtn: UIButton!
    
    @IBOutlet weak var positiveActionBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var positiveBtnLeadingSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeBtn: UIButton!

    @IBOutlet weak var closeBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeBtnBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linksButton: UIButton!
    
    @IBOutlet weak var linksButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var linkButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var gotItBtn: UIButton!
    
    @IBOutlet weak var gotItBtnWidthConstraint: NSLayoutConstraint!
    
    var titleMessage : String?
    var isDismissViewRequired = false
    var firstMessage : String?
    var secondMessage : String?
    var positiveBtnTitle : String?
    var negativeBtnTitle : String?
    var completionHandler : alertControllerActionHandler?
    var linkButtonText : String?
    var msgWithLinkText: String?
    var isActionButtonRequired = true
    
    func initializeDataBeforePresentingView(title : String?, isDismissViewRequired : Bool, message1 : String?, message2 : String?, positiveActnTitle : String?,negativeActionTitle : String?,linkButtonText : String?,msgWithLinkText: String?, isActionButtonRequired: Bool, handler: alertControllerActionHandler?)
    {
        self.titleMessage = title
        self.isDismissViewRequired = isDismissViewRequired
        self.firstMessage = message1
        self.secondMessage = message2
        self.positiveBtnTitle = positiveActnTitle
        self.negativeBtnTitle = negativeActionTitle
        self.completionHandler = handler
        self.linkButtonText = linkButtonText
        self.msgWithLinkText = msgWithLinkText
        self.isActionButtonRequired = isActionButtonRequired
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: alertDialogView, cornerRadius: 10.0)
        setTitleFirstMsgAndSecondMsg()
        handleBrandingChangesBasedOnTarget()
        positiveActnBtn.setTitle(positiveBtnTitle, for: UIControl.State.normal)
        negativeActnBtn.setTitle(negativeBtnTitle, for: UIControl.State.normal)
        if isDismissViewRequired{
            dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(QuickRideCustomAlertController.dismissViewTapped(_:))))
        }
    }
    override func viewDidLayoutSubviews(){
        CustomExtensionUtility.changeBtnColor(sender: self.positiveActnBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        ViewCustomizationUtils.addBorderToView(view: gotItBtn, borderWidth: 1, color: UIColor(netHex: 0x0091EA))
        CustomExtensionUtility.changeBtnColor(sender: self.negativeActnBtn, color1: UIColor.white, color2: UIColor.white)
        ViewCustomizationUtils.addCornerRadiusToView(view: positiveActnBtn, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: negativeActnBtn, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: gotItBtn, cornerRadius: 5.0)
        negativeActnBtn.addShadow()
    }
    func setTitleFirstMsgAndSecondMsg(){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.4
        if titleMessage != nil{
            titleLabel.isHidden = false
            titleLabelBottomSpaceConstraint.constant = 5
            titleLabel.text = titleMessage
        }else{
            titleLabel.isHidden = true
            titleLabelBottomSpaceConstraint.constant = 0
        }
        if firstMessage != nil{
            firstMsgLblText.isHidden = false
            let attributedString2 = NSMutableAttributedString(string: firstMessage!)
            attributedString2.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString2.length))
            attributedString2.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x000000), textSize: 14.0), range: NSMakeRange(0, attributedString2.length))
            firstMsgLblText.attributedText = attributedString2
        }else{
            firstMsgLblText.isHidden = true
        }
        if secondMessage != nil{
            secondMsgLblText.isHidden = false
            secondMsgTopSpaceConstraint.constant =  10
            let attributedString3 = NSMutableAttributedString(string: secondMessage!)
            attributedString3.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString3.length))
            attributedString3.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x000000), textSize: 14.0), range: NSMakeRange(0, attributedString3.length))
            secondMsgLblText.attributedText = attributedString3
        }else{
            secondMsgTopSpaceConstraint.constant =  0
            secondMsgLblText.isHidden = true
        }
    }
    func handleBrandingChangesBasedOnTarget()
    {
        if negativeBtnTitle == nil || negativeBtnTitle!.isEmpty{
            positiveActnBtn.isHidden = true
            negativeActnBtn.isHidden = true
            gotItBtn.isHidden = false
        }else{
            positiveActnBtn.isHidden = false
            negativeActnBtn.isHidden = false
            gotItBtn.isHidden = true
        }
        if positiveBtnTitle == nil || positiveBtnTitle!.isEmpty{
            gotItBtn.setTitle(Strings.ok_caps, for: UIControl.State.normal)
        }else{
            gotItBtn.setTitle(positiveBtnTitle, for: UIControl.State.normal)
        }
        if Int(gotItBtn.title(for: .normal)!.count) <= 10
        {
            gotItBtnWidthConstraint.constant = 90
        }
        else{
            gotItBtnWidthConstraint.constant = 150
        }
        if !isActionButtonRequired {
            positiveActnBtn.isHidden = true
            negativeActnBtn.isHidden = true
            gotItBtn.isHidden = true
            positiveActionBtnHeightConstraint.constant = 0
            gotItBtnWidthConstraint.constant = 0
        }
        if linkButtonText == nil{
            linksButton.isHidden = true
            linksButtonHeight.constant = 0
            linkButtonTopConstraint.constant = 0
        }else{
            linksButton.isHidden = false
            linksButtonHeight.constant = 20
            linkButtonTopConstraint.constant = 10
            linksButton.setTitle(linkButtonText, for: UIControl.State.normal)
        }
    }

    @IBAction func linksButtonTapped(_ sender: Any) {
        completionHandler?(Strings.click_here_for_more_details)
    }
    
    @IBAction func positveActionClicked(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("positveActionClicked()")
        self.view.removeFromSuperview()
        self.removeFromParent()
        completionHandler?(positiveActnBtn.titleLabel!.text!)
    }
    
    @IBAction func negativeActionClicked(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        completionHandler?(negativeActnBtn.titleLabel!.text!)
    }
    
    @objc func dismissViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        completionHandler?(Strings.cancel_caps)
    }
    
    @IBAction func neutralActionBtnClicked(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        completionHandler?(gotItBtn.titleLabel!.text!)
    }
}
