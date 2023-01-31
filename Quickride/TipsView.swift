//
//  TipsView.swift
//  Quickride
//
//  Created by QuickRideMac on 1/28/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class TipsView : UIView
{
  
  @IBOutlet weak var tipDisplayView: UIView!
  
  @IBOutlet weak var tipInfoLbl: UILabel!
  
  @IBOutlet weak var nextTipLbl: UILabel!
  
  @IBOutlet weak var closeBtn: UIButton!
  
  @IBOutlet weak var nextTipView: UIView!
  
  @IBOutlet weak var tipDisplayViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var tipInfoLblHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var nextViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet var tipViewWidth: NSLayoutConstraint!
  
  var viewController : UIViewController?
  var presentTipPosition : Int?
  var tips : [String]?
  var context : String?
  
  
  func displayTipDialog(context : String?, viewController : UIViewController,tips : [String], tipPosition : Int) {
    self.context = context
    self.viewController = viewController
    self.tipInfoLbl.text = tips[tipPosition]
    self.tips = tips
    presentTipPosition = tipPosition
    
    ViewCustomizationUtils.addCornerRadiusToView(view: self.tipDisplayView, cornerRadius: 5.0)
    nextTipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TipsView.displayNextTip(_:))))
    if tips.count - 1 == tipPosition
    {
        nextTipView.isHidden = true
    }
    adjustViewBasedOnTips(message: tips[tipPosition])
    UIApplication.shared.keyWindow?.addSubview(self)
    
    self.center = CGPoint(x: UIApplication.shared.keyWindow!.frame.size.width  / 2,
                          y: UIApplication.shared.keyWindow!.frame.size.height / 2)
    if context != nil{
        TipsFactory.getInstance().storeTipStatus(context: context!,value: presentTipPosition!)
    }
    
    tipViewWidth.constant = UIApplication.shared.keyWindow!.frame.width-40
  }
  
  func adjustViewBasedOnTips(message : String)
  {
    let lines = CGFloat(message.count * ViewCustomizationUtils.LABEL_TEXT_SIZE)/(UIApplication.shared.keyWindow!.frame.width-60)
    let height = lines * CGFloat(ViewCustomizationUtils.LABEL_LINE_HEIGHT)
    tipInfoLblHeightConstraint.constant = height + CGFloat(ViewCustomizationUtils.ALERT_DIALOGUE_LABEL_TEXT_SIZE)
    if nextTipView.isHidden == true
    {
      tipDisplayViewHeightConstraint.constant = tipInfoLblHeightConstraint.constant + nextViewHeightConstraint.constant
    }
    else{
      tipDisplayViewHeightConstraint.constant = tipInfoLblHeightConstraint.constant + nextViewHeightConstraint.constant
    }
  }
    @objc func displayNextTip(_ sender: UITapGestureRecognizer) {
    presentTipPosition = presentTipPosition! + 1
    tipInfoLbl.text = self.tips![presentTipPosition!]
    
    if tips!.count - 1 == presentTipPosition
    {
        nextTipView.isHidden = true
    }
    adjustViewBasedOnTips(message: tips![presentTipPosition!])
    if context != nil{
        TipsFactory.getInstance().storeTipStatus(context: context!,value: presentTipPosition!)
    }
    
  }
  
  @IBAction func closeBtnTapped(_ sender: Any) {
    self.removeFromSuperview()
  }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    AppDelegate.getAppDelegate().log.debug("hitTest()")
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha == 0 {
      return nil
    }
    var hitView: UIView? = self
        if !self.point(inside: point, with: event) {
      if self.clipsToBounds {
        return nil
      } else {
        hitView = nil
      }
    }
        for subview in self.subviews.reversed() {
            let insideSubview = self.convert(point, to: subview)
            if let sview = subview.hitTest(insideSubview, with: event) {
        return sview
      }
    }
    if hitView == nil
    {
      self.removeFromSuperview()
    }
    return hitView
  }
  
}

