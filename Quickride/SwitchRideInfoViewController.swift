//
//  SwitchRideInfoView.swift
//  Quickride
//
//  Created by rakesh on 2/12/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class SwitchRideInfoViewController : UIViewController{
    
    @IBOutlet weak var switchRideBtn: UIButton!
    
    @IBOutlet weak var gotItButton: UIButton!
    
    @IBOutlet var backGroundView: UIView!
    
    
    override func viewDidLoad(){
        handleBrandingChanges()
        ViewCustomizationUtils.addCornerRadiusToView(view: switchRideBtn, cornerRadius: 5.0)
     
        ViewCustomizationUtils.addCornerRadiusToView(view: gotItButton, cornerRadius: 5.0)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SwitchRideInfoViewController.dismissView(_:))))
    }
    
    func handleBrandingChanges()
    {
        gotItButton.backgroundColor = Colors.gotItBtnBackGroundColor
        
    }
    @objc func dismissView(_ gesture : UITapGestureRecognizer){
        SharedPreferenceHelper.setDisplaySwitchRideInfoGuideLineView(status: true)
        self.view.removeFromSuperview()
        self.removeFromParent()
 
    }

    @IBAction func gotItButtonTapped(_ sender: Any) {
        SharedPreferenceHelper.setDisplaySwitchRideInfoGuideLineView(status: true)
        self.view.removeFromSuperview()
        self.removeFromParent()
   
    }
    
}
