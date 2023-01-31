//
//  CommutePassActivatedAlertController.swift
//  Quickride
//
//  Created by apple on 3/1/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Lottie

typealias animationCompletionHandler = () -> Void

class AnimationAlertController : UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var activatedTxt: UILabel!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var animationView: AnimationView!
    
    @IBOutlet weak var congratsLabel: UILabel!
    
    private var activatedMessage : String?
    private var handler : animationCompletionHandler?
    private var timer : Timer?
    private let TIMER_TIME_PERIOD : Double = 3
    private var isFromLinkedWallet = false
    
    
    func initializeDataBeforePresenting(activatedMessage : String?, isFromLinkedWallet: Bool, handler : animationCompletionHandler?){
        self.activatedMessage = activatedMessage
        self.handler = handler
        self.isFromLinkedWallet = isFromLinkedWallet
    }
    override func viewDidLoad() {
        activatedTxt.text = activatedMessage
        if isFromLinkedWallet{
            congratsLabel.isHidden = true
        }
        addAnimatedView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: alertView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
    }
    
    private func addAnimatedView(){
        animationView.animation = Animation.named("signup_congrats")
        animationView!.contentMode = .scaleAspectFit
        animationView!.play()
        animationView!.loopMode = .loop
        timer = Timer.scheduledTimer(timeInterval: TIMER_TIME_PERIOD, target: self, selector: #selector(AnimationAlertController.dismissAlertView), userInfo: nil, repeats: true)
    }
    
    @objc func dismissAlertView(){
        timer?.invalidate()
        timer = nil
        animationView?.stop()
        
        self.view.removeFromSuperview()
        self.removeFromParent()
        handler?()
    }
}
