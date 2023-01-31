//
//  File.swift
//  Quickride
//
//  Created by QR Mac 1 on 17/03/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Lottie
  
class AnimatedprofileViewController:  UIViewController {
    
    

    @IBOutlet weak var profileView: AnimatedControl!
    
    @IBOutlet weak var createProfile: UIButton!
    
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        showAnimation()
    }
        
    func showAnimation() {
        profileView.animationView.animation = Animation.named("show_imgofperson")
        profileView.animationView.play()
        profileView.animationView.loopMode = .loop
    }
         
    func stopAnimation(){
        profileView.animationView.stop()
        self.navigationController?.popToRootViewController(animated: false)
    }
}
