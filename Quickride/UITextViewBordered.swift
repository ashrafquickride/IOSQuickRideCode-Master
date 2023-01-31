//
//  UITextViewBordered.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 6/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UITextViewBordered: UITextView {
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 5.0
        self.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func enableField(){
      AppDelegate.getAppDelegate().log.debug("enableField()")
        //self.enabled = true
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func disableField(){
      AppDelegate.getAppDelegate().log.debug("disableField()")
        //self.enabled = false
        self.backgroundColor = UIColor.lightGray
        self.isUserInteractionEnabled = false
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
}
