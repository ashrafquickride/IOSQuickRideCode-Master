//
//  WarningViewController.swift
//  Quickride
//
//  Created by Quickride on 23/11/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import BottomPopup
import UIKit
import Foundation

class WarningViewController: BottomPopupViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var deleteView: UIView!
    
    private var actionComplitionHandler: actionComplitionHandler?
    
    func initializeView(actionComplitionHandler: @escaping actionComplitionHandler){
        self.actionComplitionHandler = actionComplitionHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePopupHeight(to: 320)
        cancelView.addShadow()
        deleteView.addShadow()
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: contentView, cornerRadius: 20, corner1: .topRight, corner2: .topLeft)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.cancelView, cornerRadius: 20)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.cancelBtn, cornerRadius: 20)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.deleteBtn, cornerRadius: 20)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.deleteView, cornerRadius: 20)   
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if let actionComplitionHandler = actionComplitionHandler {
            actionComplitionHandler(true)
        }
        dismiss(animated: false)
        
    }
}
