//
//  CallChargealertViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 16/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Foundation

enum CallChargeAction {
    case call
    case chat
}

class CallChageViewController : UIViewController {
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var cornerView: UIView!
    
    @IBOutlet weak var textField: UILabel!
    var userId: String?
    
    
    var handler: (CallChargeAction) -> Void = {
        (action: CallChargeAction) -> Void in
    }
    override func viewDidLoad(){
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: cornerView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundTapped(_:))))
    }
    func initializeData(userId: String, handler: @escaping (_ action: CallChargeAction) -> Void) {
        self.userId = userId;
        self.handler = handler
    }
    
    @IBAction func callButtn(_ sender: Any) {
        dismiss(animated: false)
        handler(.call)
    }
    
    @IBAction func startChatAction(_ sender: Any) {
        dismiss(animated: false)
        handler(.chat)
    }
    @objc func backGroundTapped(_ gesture: UITapGestureRecognizer){
        dismiss(animated: false)
    }
}


