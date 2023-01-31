//
//  CallToJoinConfirmationViewController.swift
//  Quickride
//
//  Created by Vinutha on 14/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CallToJoinConfirmationViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK:Propertise
    private var rideStatus: String?
    private var completionHandler: clickActionCompletionHandler?
    
    //MARK: Initializer
    func initializeViews(rideStatus: String?, completionHandler: clickActionCompletionHandler?) {
        self.rideStatus = rideStatus
        self.completionHandler = completionHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        if rideStatus == Ride.RIDE_STATUS_STARTED {
            titleLabel.text = "Rider is already Started"
        } else {
            titleLabel.text = "Rider is about to Start"
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                   animations: { [weak self] in
                    guard let self = `self` else {return}
                    self.popUpView.center.y -= self.popUpView.bounds.height
        }, completion: nil)
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        completionHandler?(nil)
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.popUpView.center.y += self.popUpView.bounds.height
            self.popUpView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    @IBAction func callToJoinButtonClicked(_ sender: UIButton) {
        completionHandler?(Strings.call_to_join)
        removeView()
    }
    
    @IBAction func continueToInviteButtonCicked(_ sender: UIButton) {
        completionHandler?(Strings.continue_to_invite)
        removeView()
    }
}

