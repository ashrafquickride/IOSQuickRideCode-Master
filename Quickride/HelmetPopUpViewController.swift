//
//  HelmetPopUpViewController.swift
//  Quickride
//
//  Created by Ashutos on 3/30/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias helmetOptionChoosen = (_ completed : Bool) -> Void

class HelmetPopUpViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    private var handler: helmetOptionChoosen?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func initialiseData(handler: callOptionChoosen?) {
        self.handler = handler
    }
    
    
    private func setUpUI() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.popUpView.center.y -= self.popUpView.bounds.height
            }, completion: nil)
        
        self.popUpView.clipsToBounds = true
        self.popUpView.layer.cornerRadius = 15
        if #available(iOS 11.0, *) {
            self.popUpView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
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
    
    @IBAction func ihaveAHelmetBtnPressed(_ sender: UIButton) {
        removeView()
        handler?(true)
    }
    
    @IBAction func dontHaveHelmetBtnPressed(_ sender: UIButton) {
         removeView()
         handler?(false)
    }
}
