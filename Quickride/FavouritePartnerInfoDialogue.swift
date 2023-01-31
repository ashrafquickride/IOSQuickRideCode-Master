//
//  FavouritePartnerInfoDialogue.swift
//  Quickride
//
//  Created by rakesh on 3/17/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class FavouritePartnerInfoDialogue : UIViewController{
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    override func viewDidLoad() {
        ViewCustomizationUtils.addBorderToView(view: doneButton, borderWidth: 1, colorCode: 0x0091EA)
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FavouritePartnerInfoDialogue.backGroundViewTapped(_:))))
    }
    
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
}
