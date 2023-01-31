//
//  NetworkErrorDialogue.swift
//  Quickride
//
//  Created by QuickRideMac on 27/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
class NetworkErrorDialogue: UIView {
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var iconView: UIView!
  
    @IBOutlet weak var backgroundView: UIView!
  
    @IBOutlet weak var backgroundHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundWidth: NSLayoutConstraint!
    var handler: alertControllerActionHandler?
    static var currentDisplayingDialogue : NetworkErrorDialogue?
    
    func initializeDataBeforePresenting(message : String?,actionName : String?,viewController : UIViewController ,handler: alertControllerActionHandler?){
      AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting() \(String(describing: message)) \(String(describing: actionName))")
        self.handler = handler
        if message != nil{
            self.message.text = message
        }
        if actionName != nil{
            actionButton.setTitle(actionName, for: UIControl.State.normal)
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: iconView, cornerRadius: 5.0, corner1: UIRectCorner.topLeft, corner2: .topRight)
        if NetworkErrorDialogue.currentDisplayingDialogue != nil{
            NetworkErrorDialogue.currentDisplayingDialogue?.removeFromSuperview()
        }
        if viewController.navigationController != nil{
            backgroundWidth.constant = viewController.navigationController!.view.frame.size.width
            backgroundHeight.constant = viewController.navigationController!.view.frame.size.height
            viewController.navigationController!.view.addSubview(self)
        }else{
            backgroundWidth.constant = viewController.view.frame.size.width
            backgroundHeight.constant = viewController.view.frame.size.height
            viewController.view.addSubview(self)
        }
        NetworkErrorDialogue.currentDisplayingDialogue = self
        
    }
    
    
    @IBAction func actionClicked(_ sender: UIButton) {
      AppDelegate.getAppDelegate().log.debug("actionClciked()")
        self.removeFromSuperview()
        NetworkErrorDialogue.currentDisplayingDialogue = nil
        if handler != nil{
            handler!(sender.titleLabel!.text!)
        }
    }
}
