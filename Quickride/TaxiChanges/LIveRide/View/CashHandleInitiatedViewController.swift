//
//  CashHandleInitiatedViewController.swift
//  Quickride
//
//  Created by Rajesab on 16/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CashHandleInitiatedViewController: UIViewController {

    @IBOutlet weak var refreshButton: UIButton!
    
    private var actionComplitionHandler: actionComplitionHandler?
    
    func initializeData(actionComplitionHandler: @escaping actionComplitionHandler){
        self.actionComplitionHandler = actionComplitionHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(removeView), name: .cashHandleRejectedByDriver ,object: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        closeView()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        if let actionComplitionHandler = actionComplitionHandler {
            actionComplitionHandler(true)
        }
    }
    
    @objc func removeView(_ notification: Notification){
        if let actionComplitionHandler = actionComplitionHandler {
            actionComplitionHandler(false)
        }
    }
    
    func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
extension Notification.Name{
    static let cashHandleRejectedByDriver = NSNotification.Name("cashHandleRejectedByDriver")
    static let taxiPaymentStatusUpdated = NSNotification.Name("taxiPaymentStatusUpdated")
    static let taxiDriverAllocationStatusChanged = NSNotification.Name("taxiDriverAllocationStatusChanged")
}
