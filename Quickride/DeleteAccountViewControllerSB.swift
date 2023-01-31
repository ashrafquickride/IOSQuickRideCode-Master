//
//  DeleteAccountViewControllerSB.swift
//  Quickride
//
//  Created by Quickride on 23/11/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import BottomPopup
import UIKit
import ObjectMapper

enum DeleteAction {
    case suspend
    case delete
}

class DeleteAccountViewControllerSB: BottomPopupViewController {
    
    var handler: (DeleteAction) -> Void = {
        (action: DeleteAction) -> Void in
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var suspendButton: UIButton!
    @IBOutlet weak var deleteAccount: UIButton!
    @IBOutlet weak var suspendView: UIView!
    @IBOutlet weak var deleteView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePopupHeight(to: 320)
        suspendButton.isUserInteractionEnabled = true
        suspendButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DeleteAccountViewControllerSB.suspendAction(_:))))
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: contentView, cornerRadius: 20, corner1: .topRight, corner2: .topLeft)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.suspendView, cornerRadius: 25)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.suspendButton, cornerRadius: 25)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.deleteAccount, cornerRadius: 25)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.deleteView, cornerRadius: 25)
        suspendView.addShadow()
        deleteView.addShadow()
        
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        let warningViewController = UIStoryboard(name: "DeleteAccountSB", bundle: nil).instantiateViewController(withIdentifier: "WarningViewController") as! WarningViewController
        warningViewController.initializeView() { completed in
            if completed {
                self.handler(.delete)
            }
        }
        ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: warningViewController, animated: false, completion: nil)
    }
    
    @objc func suspendAction(_ sender: UITapGestureRecognizer)  {
            dismiss(animated: false)
            handler(.suspend)
        }
}
