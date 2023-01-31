//
//  BazaarySignupInfoViewController.swift
//  Quickride
//
//  Created by Rajesab on 25/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class BazaarySignupInfoViewController: UIViewController {
    
    private var actionComplitionHandler: actionComplitionHandler?
    
    func initializeData(actionComplitionHandler: @escaping actionComplitionHandler){
        self.actionComplitionHandler = actionComplitionHandler
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_BAZAARY_ONBORDING_DETAILS, value: true)
        RideManagementUtils.moveToRecentTabBar()
        closeView()
        if let complitionHandler = actionComplitionHandler {
            complitionHandler(true)
        }
    }
}
