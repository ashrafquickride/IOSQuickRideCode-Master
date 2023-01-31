//
//  UIButtonBordered.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 6/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import QuartzCore

class UIButtonBordered: UIButton {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    override func awakeFromNib() {
      AppDelegate.getAppDelegate().log.debug("awakeFromNib()")
        self.resignFirstResponder()
        
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        AppDelegate.getAppDelegate().log.debug("beginTrackingWithTouch()")
        super.resignFirstResponder()
        return true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        //        self.backgroundColor = UIColor.clearColor()
        //self.backgroundColor = UIColor.whiteColor()
        //        self.layer.borderWidth = 1.0
        //        self.layer.borderColor = UIColor(red: 5.0/255.0, green: 130.0/255.0, blue: 38.0/255.0, alpha: 1.0).CGColor
        //        self.backgroundColor = UIColor(red: 5.0/255.0, green: 130.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        self.layer.cornerRadius = 5.0
        //        self.tintColor = UIColor.whiteColor()
        self.resignFirstResponder()
    }
    
    func enableField(){
      AppDelegate.getAppDelegate().log.debug("enableField()")
        self.isEnabled = true
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.white
    }
    
    func disableField(){
      AppDelegate.getAppDelegate().log.debug("disableField()")
        self.isEnabled = false
        self.isUserInteractionEnabled = false
    }
}
