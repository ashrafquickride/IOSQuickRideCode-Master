//
//  RideCompletedViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias actionComplitionHandler = (_ completed : Bool) -> Void 

class RideCompletedViewController: UIViewController {

    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var carImage: UIImageView!
    
    private var actionComplitionHandler: actionComplitionHandler?
    
    func initializeView(actionComplitionHandler: @escaping actionComplitionHandler){
        self.actionComplitionHandler = actionComplitionHandler
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        actionComplitionHandler!(true)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
