//
//  GreetingDisplayView.swift
//  Quickride
//
//  Created by iDisha on 25/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class GreetingDisplayView: UIView {
    
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var greetingViewWidthConstriant: NSLayoutConstraint!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissAnimationView: UIView!
    @IBOutlet weak var animationViewWidthConstraint: NSLayoutConstraint!
    
    weak var viewController: UIViewController?
    private var greetingDetails : GreetingDetails?
    private var handler: actionCompletionHandler?
    private var dismissButtonTimer: Timer!
    private var timeLeft = 180
    
    func initializeViews(greetingDetails : GreetingDetails, image: UIImage?, x: CGFloat, y: CGFloat, viewController: UIViewController, handler: actionCompletionHandler?){
        let attributedString = NSMutableAttributedString(string: greetingDetails.message ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.messageLabel.attributedText = attributedString
        self.viewController = viewController
        self.handler = handler
        self.gifImageView.image = image
        greetingViewWidthConstriant.constant = viewController.view.frame.size.width
        if ViewCustomizationUtils.hasTopNotch{
            self.frame = CGRect(x: x, y: y, width: greetingViewWidthConstriant.constant, height: greetingView.frame.size.height + 50)
        }else{
            self.frame = CGRect(x: x, y: y, width: greetingViewWidthConstriant.constant, height: greetingView.frame.size.height + 50)
        }
        self.loadView()
    }
    
    func loadView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlUp],
                       animations: {
                        self.greetingView.frame.origin.x = 0
                        self.greetingView.frame.origin.y += self.greetingView.bounds.width
        }, completion: nil)
        self.greetingView.isHidden = false
        viewController?.view.addSubview(self)
        addAnimationForDismissButton()
    }
    
    private func addAnimationForDismissButton() {
        dismissButtonTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dismissButtonTimerAction), userInfo: nil, repeats: true)
    }
    
    @objc func dismissButtonTimerAction() {
        if timeLeft != 0 {
            dismissAnimationView.isHidden = false
            timeLeft -= 1
            animationViewWidthConstraint.constant += dismissButton.bounds.size.width/180
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
                        self.greetingView.frame.origin.y -= self.greetingView.bounds.width
        }, completion: {(_ completed: Bool) -> Void in
            self.handler?()
            self.greetingView.isHidden = true
            self.removeFromSuperview()
        })
    }
    
    @IBAction func gotItButtonTapped(_ sender: UIButton) {
        removeView()
    }
    
    
}
