//
//  DriverCancelledTripInfoView.swift
//  Quickride
//
//  Created by HK on 25/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class DriverCancelledTripInfoView: UIView {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dismissAnimationView: UIView!
    @IBOutlet weak var animationViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var dismissButtonTimer: Timer!
    private var timeLeft = 10
    
    func showDriverCancelledView(viewController: UIViewController){
        if ViewCustomizationUtils.hasTopNotch{
            self.frame = CGRect(x: 0, y: 25, width: UIScreen.main.bounds.size.width, height: 105)
        }else{
            self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 105)
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlUp],
                       animations: {
                        self.contentView.frame.origin.x = 0
                        self.contentView.frame.origin.y += self.contentView.bounds.width
        }, completion: nil)
        self.contentView.isHidden = false
        viewController.view.addSubview(self)
        addAnimationForDismissButton()
    }
    
    private func addAnimationForDismissButton() {
        dismissButtonTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dismissButtonTimerAction), userInfo: nil, repeats: true)
    }
    
    @objc func dismissButtonTimerAction() {
        if timeLeft != 0 {
            dismissAnimationView.isHidden = false
            timeLeft -= 1
            animationViewWidthConstraint.constant += dismissButton.bounds.size.width/10
        } else {
            stopTimer()
        }
    }
    
    private func stopTimer() {
        dismissAnimationView.isHidden = true
        dismissButtonTimer.invalidate()
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: {
                        self.contentView.frame.origin.y -= self.contentView.bounds.width
        }, completion: {(_ completed: Bool) -> Void in
            self.contentView.isHidden = true
            self.removeFromSuperview()
        })
    }
    
    @IBAction func gotItButtonTapped(_ sender: UIButton) {
        dismissButtonTimer.invalidate()
        removeView()
    }
}
