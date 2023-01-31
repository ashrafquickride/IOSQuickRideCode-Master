//
//  LogOutViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 07/04/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import BottomPopup

class LogOutViewController: BottomPopupViewController {
    
    
    @IBOutlet weak var mainLogView: UIView!
    @IBOutlet weak var noButton: QRCustomButton!
    
    @IBOutlet weak var yesButton: QRCustomButton!
    
var completionHandler : alertControllerActionHandler?
    
func initializeButton(handler: alertControllerActionHandler?){
        self.completionHandler = handler
    }
    
func closeView(){
    self.view.removeFromSuperview()
    self.removeFromParent()
}
    
override func viewDidLoad() {
    super.viewDidLoad()
    
    ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: mainLogView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
    updatePopupHeight(to: 210)
   
}
    
    @IBAction func cancelActionTapped(_ sender: Any) {
        completionHandler?(noButton.titleLabel!.text!)
        dismiss(animated: false)
    }

    
    @IBAction func okActionTapped(_ sender: Any) {
        completionHandler?(yesButton.titleLabel!.text!)
        dismiss(animated: false)
    }
    
}
