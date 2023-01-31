//
//  ReferalPointsUsageViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 15/09/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReferalPointsUsageViewController: UIViewController {
 @IBOutlet weak var gotItBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: gotItBtn, cornerRadius: 8)
        ViewCustomizationUtils.addBorderToView(view: gotItBtn, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
    }
    
    override func viewWillAppear(_ animated: Bool) {
     self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func gotItTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    

}
