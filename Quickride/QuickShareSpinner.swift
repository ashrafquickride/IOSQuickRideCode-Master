//
//  QuickShareSpinner.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Lottie

class QuickShareSpinner: UIViewController {
    
    @IBOutlet weak var spinnerAnimationView: AnimationView!
    
    static var spinner : QuickShareSpinner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        spinnerAnimationView.animation = Animation.named("loading_otp")
        spinnerAnimationView.play()
        spinnerAnimationView.loopMode = .loop
    }
    override func viewWillDisappear(_ animated: Bool) {
        spinnerAnimationView.stop()
    }
    
    static func start(){
        DispatchQueue.main.async() {
            if spinner != nil{
                return
            }
            spinner = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickShareSpinner") as? QuickShareSpinner
            UIApplication.shared.keyWindow?.addSubview(spinner!.view)
        }
    }
    static func stop(){
        DispatchQueue.main.async() {
            if spinner != nil{
                spinner!.view.removeFromSuperview()
                spinner = nil
            }
        }
    }
}
