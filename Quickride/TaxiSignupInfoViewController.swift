//
//  TaxiSignupInfoViewController.swift
//  Quickride
//
//  Created by Rajesab on 24/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiSignupInfoViewController: UIViewController {

    @IBOutlet weak var taxiSignupflowImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func letsStartButtonTapped(_ sender: Any) {
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_TAXI_ONBORDING_DETAILS, value: true)
        RideManagementUtils.moveToRecentTabBar()
        closeView()
    }
}
