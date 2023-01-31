//
//  UITextFieldBordered.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 6/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UITextFieldBordered: UITextField {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    func setKeybrdType(type:UIKeyboardType) {
      AppDelegate.getAppDelegate().log.debug("setKeybrdType()")
        self.keyboardType = type
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect
    {
      AppDelegate.getAppDelegate().log.debug("textRectForBounds()")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 5.0
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y + 10, width: bounds.size.width - 10*2, height: bounds.size.height - 10*2)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect
    {
      AppDelegate.getAppDelegate().log.debug("editingRectForBounds()")
        return self.textRect(forBounds: bounds)
    }
    
    func enableField(){
      AppDelegate.getAppDelegate().log.debug("enableField()")
        self.isEnabled = true
        self.backgroundColor = UIColor.white
    }
    
    func disableField(){
      AppDelegate.getAppDelegate().log.debug("disableField()")
        self.isEnabled = false
        self.backgroundColor = UIColor.lightGray
        self.text = ""
    }
    
    func removeBorderColor ()
    {
      AppDelegate.getAppDelegate().log.debug("removeBorderColor()")
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 0.0
    }
    
    func addBorderColor ()
    {
      AppDelegate.getAppDelegate().log.debug("addBorderColor()")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 5.0
    }
}
