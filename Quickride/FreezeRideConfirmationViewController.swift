//
//  FreezeRideConfirmationViewController.swift
//  Quickride
//
//  Created by HK on 06/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import BottomPopup
typealias freezeRideConfirmationComplitionHandler = (_ isConfirmed: Bool) -> Void

class FreezeRideConfirmationViewController: BottomPopupViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    private var handler: freezeRideConfirmationComplitionHandler?
    func initialiseFreezeRideConfirmation(handler: @escaping freezeRideConfirmationComplitionHandler){
        self.handler = handler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePopupHeight(to: 350)
    }
    
    @IBAction func freezeRideButtonTapped(_ sender: Any) {
        self.dismiss(animated: false)
        handler?(true)
    }
}
