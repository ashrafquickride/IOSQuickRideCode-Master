//
//  ModelLessDialogue.swift
//  Quickride
//
//  Created by QuickRideMac on 10/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class ModelLessDialogue: UIView {
  
  @IBOutlet weak var modelLessDialogueBackgroundViewHeight: NSLayoutConstraint!
  @IBOutlet weak var modelLessDialogueBackgroundView: UIView!
  @IBOutlet weak var messageText: UILabel!
  
  @IBOutlet weak var messageTextWidthConstraint: NSLayoutConstraint!
  
    @IBOutlet weak var messageTextHeightConstraint: NSLayoutConstraint!
    //Branding Outlets
  @IBOutlet weak var hyperLinkText: UILabel!
    
    func initializeViews(message :String, actionText : String){
    AppDelegate.getAppDelegate().log.debug("initializeViews()")
    
    hyperLinkText.textColor = Colors.hyperLinkTextColor
    
    modelLessDialogueBackgroundView.layer.cornerRadius = 20.0
    messageText.text = message
    
    if Int(messageText.text!.count) == 15
    {
      messageTextWidthConstraint.constant = 60
    }
    
    if Int(messageText.text!.count) > 35
    {
        resizeHeightToFit(message : message, constraint: messageTextHeightConstraint)
    }
    else if Int(actionText.count) > 50{
        resizeHeightToFit(message: actionText, constraint: messageTextHeightConstraint)
    }
    let actionNSString = actionText as NSString
        let underLine = [NSAttributedString.Key.underlineStyle: 1]
    let attributedString = NSMutableAttributedString(string: actionText as String)
    attributedString.addAttributes(underLine, range: actionNSString.range(of: actionText))
    hyperLinkText.attributedText = attributedString
  }
    func resizeHeightToFit(message : String, constraint: NSLayoutConstraint) {
        
        modelLessDialogueBackgroundViewHeight.constant = modelLessDialogueBackgroundViewHeight.constant - constraint.constant
        let lines = CGFloat(message.count * ViewCustomizationUtils.LABEL_TEXT_SIZE)/(messageTextWidthConstraint.constant)
        let height = lines * CGFloat(ViewCustomizationUtils.LABEL_LINE_HEIGHT)
        constraint.constant = height
        modelLessDialogueBackgroundViewHeight.constant = modelLessDialogueBackgroundViewHeight.constant + constraint.constant
    }
    
}
extension UIView {
  class func loadFromNibNamed(nibNamed: String, bundle : Bundle? = nil) -> UIView? {
    AppDelegate.getAppDelegate().log.debug("loadFromNibNamed()")
    return UINib(
      nibName: nibNamed,
      bundle: bundle
      ).instantiate(withOwner: nil, options: nil)[0] as? UIView
  }
}
