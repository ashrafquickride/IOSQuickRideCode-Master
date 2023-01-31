//
//  LastResponseAlertView.swift
//  Quickride
//
//  Created by Admin on 30/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class LastResponseAlertView : UIViewController{
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var gotItBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: gotItBtn, borderWidth: 1.0, color: UIColor(netHex: 0x0091EA))
        ViewCustomizationUtils.addCornerRadiusToView(view: gotItBtn, cornerRadius: 5.0)
       backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LastResponseAlertView.backgroundViewTapped(_:))))
    }
    
    @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func gotItBtnClicked(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
    
    
    
    
    
    
    
}
