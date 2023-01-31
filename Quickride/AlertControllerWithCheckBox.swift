//
//  AlertControllerWithCheckBox.swift
//  Quickride
//
//  Created by QuickRideMac on 10/2/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AlertControllerWithCheckBox: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var checkBoxTitle: UIButton!
    
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    @IBOutlet weak var positiveButton: UIButton!
    
    @IBOutlet weak var negativeButton: UIButton!
    
    @IBOutlet weak var alertDialogueWidth: NSLayoutConstraint!
    
    @IBOutlet weak var alertDialogue: UIView!
    
    
    var checkBoxValue = false
    var handler : alertControllerActionHandlerWithDontShowStatus?
    var alertTitle : String?
    var checkBoxText : String?
    
    func initializeDataBeforePresenting(alertTitle : String?,checkBoxText : String,handler: @escaping alertControllerActionHandlerWithDontShowStatus) {
        self.handler = handler
        self.alertTitle = alertTitle
        self.checkBoxText = checkBoxText
    }
    
    override func viewDidLoad() {
        ViewCustomizationUtils.addCornerRadiusToView(view: positiveButton, cornerRadius: 3.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: negativeButton, cornerRadius: 3.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: alertDialogue, cornerRadius: 5.0)
        alertDialogueWidth.constant = UIApplication.shared.keyWindow!.frame.width*0.8
         self.message.text = alertTitle
         self.checkBoxTitle.setTitle(checkBoxText, for: UIControl.State.normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        CustomExtensionUtility.changeBtnColor(sender: self.positiveButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        CustomExtensionUtility.changeBtnColor(sender: self.negativeButton, color1: UIColor.white, color2: UIColor.white)
        self.negativeButton.addShadow()
    }
    @IBAction func positiveButtonAction(_ sender: UIButton) {
        
        self.view.removeFromSuperview()
        self.navigationController?.removeFromParent()
        handler?(sender.titleLabel!.text!,checkBoxValue)
    }
    
    @IBAction func negativeButtonAction(_ sender: UIButton) {
    
        self.view.removeFromSuperview()
        self.navigationController?.removeFromParent()
        handler?(sender.titleLabel!.text!,checkBoxValue)
    }
    
    @IBAction func checkBoxClicked(_ sender: Any) {
        if checkBoxValue == false{
            checkBoxValue = true
            checkBoxBtn.setImage(UIImage(named: "group_tick_icon"), for: .normal)
        }else{
            checkBoxValue = false
            checkBoxBtn.setImage(UIImage(named: "tick_icon"), for: .normal)
        }
    }
}
