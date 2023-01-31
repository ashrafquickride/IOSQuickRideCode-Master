//
//  OnBoardingViewController.swift
//  Quickride
//
//  Created by Admin on 06/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    
    @IBOutlet weak var separatorView1: UIView!
    @IBOutlet weak var separatorView2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI(){
        separatorView1.addDashedView(color: UIColor.darkGray.cgColor)
        separatorView2.addDashedView(color: UIColor.darkGray.cgColor)
    }
    

}
