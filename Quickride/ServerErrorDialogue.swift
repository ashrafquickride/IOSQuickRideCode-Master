//
//  ServerErrorDialogue.swift
//  Quickride
//
//  Created by QuickRideMac on 27/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class ServerErrorDialogue: UIView{
    
    var handler : alertControllerActionHandler?
    

    @IBOutlet weak var alertView: UIView!
    
   @IBOutlet weak var backgroundWidth: NSLayoutConstraint!
  
  @IBOutlet weak var backgroundHeight: NSLayoutConstraint!
  
    @IBOutlet weak var okBtn: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    func initializeDataBeforePresenting(viewController : UIViewController,handler: alertControllerActionHandler?){
      AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting()")
        self.handler = handler
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: okBtn, borderWidth: 1.0, color: UIColor(netHex: 0x0091EA))
        ViewCustomizationUtils.addCornerRadiusToView(view: okBtn, cornerRadius: 5.0)
        if viewController.navigationController != nil{
            backgroundWidth.constant = viewController.navigationController!.view.frame.size.width
            backgroundHeight.constant = viewController.navigationController!.view.frame.size.height
            viewController.navigationController!.view.addSubview(self)
        }else{
            backgroundWidth.constant = viewController.view.frame.size.width
            backgroundHeight.constant = viewController.view.frame.size.height
            viewController.view.addSubview(self)
        }
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ServerErrorDialogue.backgroundViewTapped(_:))))
    }
    
    @IBAction func actionClciked(_ sender: Any) {
      AppDelegate.getAppDelegate().log.debug("actionClciked()")
        self.removeFromSuperview()
        if handler != nil{
            handler!(Strings.ok)
        }
    }
    
    @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.removeFromSuperview()
        if handler != nil{
            handler!(Strings.ok)
        }
    }
    
}
