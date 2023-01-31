//
//  TaxiEmergencyConfirmationViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 29/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias taxiEmergencyConfirmationHandler = (_ isEmergencyStarted: Bool) -> Void

class TaxiEmergencyConfirmationViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var secondLabel: UILabel!
    
    private var timer: Timer?
    private var timeLeft = 2
    private var handler: taxiEmergencyConfirmationHandler?
    
    func initialiseEmergencyConfirmation(handler: @escaping taxiEmergencyConfirmationHandler){
        self.handler = handler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        setUpUi()
    }
    
    private func setUpUi(){
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func startTimer(){
        if timeLeft != 0{
            secondLabel.text = String(timeLeft)
            timeLeft -= 1
        }else{
            timer?.invalidate()
            handler?(true)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    @IBAction func cancelAlertButtonTapped(_ sender: Any) {
        timer?.invalidate()
        handler?(false)
        closeView()
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        timer?.invalidate()
        handler?(false)
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
