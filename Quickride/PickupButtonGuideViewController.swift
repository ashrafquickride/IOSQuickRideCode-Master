//
//  PickupButtonGuideViewController.swift
//  Quickride
//
//  Created by Vinutha on 06/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PickupButtonGuideViewController: UIViewController {
        
    @IBOutlet weak var backGroundView: UIView!
    
    override func viewDidLoad(){
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView(_:))))
    }
    
    @objc func dismissView(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
        
    }
    
    @IBAction func gotItButtonTapped(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        
    }
}
