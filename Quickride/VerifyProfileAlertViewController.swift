//
//  VerifyProfileAlertViewController.swift
//  Quickride
//
//  Created by iDisha on 23/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias verifyProfileCompletionHandler = (_ action : String?) -> Void

class VerifyProfileAlertViewController: ModelViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var buttonGotoProfile: UIButton!
    
    @IBOutlet weak var buttonDontWantFreeRide: UIButton!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    var handler : verifyProfileCompletionHandler?
    var titleString: String?
    var actionText: String?
    
    func initializeView(titleString: String, actionText: String, handler: @escaping verifyProfileCompletionHandler){
        self.handler = handler
        self.titleString = titleString
        self.actionText = actionText
    }
    
    override func viewDidLoad() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(VerifyProfileAlertViewController.backGroundViewTapped(_:))))
        buttonDontWantFreeRide.setTitle(self.actionText, for: .normal)
        
    }
    
    @IBAction func verifyNowTapped(_ sender: Any?){
        handler?(buttonGotoProfile.titleLabel?.text)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func iDontWantFreeRideTapped(_ sender: Any?){
        handler?(buttonDontWantFreeRide.titleLabel?.text)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @objc func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        handler?(Strings.cancel_caps)
        self.view.removeFromSuperview()
        self.removeFromParent()
        
    }
}
