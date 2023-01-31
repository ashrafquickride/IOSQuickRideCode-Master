//
//  CustomUIButton.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 05/04/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CustomUIButton: UIButton{
    func changeBackgroundColorBasedOnSelection(){
        self.addTarget(self, action:#selector(CustomUIButton.HoldButton(_:)), for: UIControl.Event.touchDown)
        self.addTarget(self, action:#selector(CustomUIButton.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
    }
    @objc func HoldButton(_ sender: UIButton){
        sender.backgroundColor = Colors.lightGrey
    }
    
    @objc func HoldRelease(_ sender: UIButton){
        sender.backgroundColor = UIColor.white
    }
}
extension UIButton {
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 5
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
        
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
}

