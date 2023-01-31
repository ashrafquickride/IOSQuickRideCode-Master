//
//  PayByCashConfirmationViewController.swift
//  Quickride
//
//  Created by Rajesab on 16/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PayByCashConfirmationViewController: UIViewController {
    
    @IBOutlet weak var payOnlineButton: QRCustomButton!
    @IBOutlet weak var confirmcashPaymentButton: QRCustomButton!
    
    private var actionComplitionHandler: actionComplitionHandler?
    private var amount: Double?
    
    func initializeData(amount: Double?, actionComplitionHandler: @escaping actionComplitionHandler){
        self.actionComplitionHandler = actionComplitionHandler
        self.amount = amount
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let amount = amount {
            confirmcashPaymentButton.setTitle(String(format: Strings.confirm_cash_payment, arguments: [String(Int(amount))]), for: .normal)
        }
    }
    
    @IBAction func payOnlineButtonTapped(_ sender: Any) {
        if let actionComplitionHandler = actionComplitionHandler {
            actionComplitionHandler(false)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        closeView()
    }
    
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func confirmCashPaymentButtonTapped(_ sender: Any) {
        if let actionComplitionHandler = actionComplitionHandler {
            actionComplitionHandler(true)
        }
    }
}
