//
//  CustomExtensionUtility.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 06/11/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Lottie

class CustomExtensionUtility {
    
    static func transitionEffectWhilePushingView() -> CATransition{
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromRight
        return transition
    }
    static func transitionEffectWhilePopingView() -> CATransition{
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromLeft
        return transition
    }
    
    static func changeBtnColor(sender: UIButton, color1: UIColor, color2: UIColor){
//        if sender.layer.sublayers != nil && sender.layer.sublayers!.count > 1{
//            for _ in 0 ..< sender.layer.sublayers!.count - 1{
//                sender.layer.sublayers![0].removeFromSuperlayer()
//            }
//            sender.applyGradientForButton(colours: [color1, color2])
//        }else{
//            sender.applyGradientForButton(colours: [color1, color2])
//        }
        sender.backgroundColor = color1
    }
}
extension UIButton {
    
    func applyGradientForButton(colours: [UIColor]) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.masksToBounds = false
        gradient.startPoint = CGPoint.init(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint.init(x: 0.5, y: 1.0)
        gradient.colors = colours.map { $0.cgColor }
        gradient.cornerRadius = layer.cornerRadius
        self.layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.3
        self.layer.insertSublayer(gradient, at: 0)
    }
    
}

extension UIView{
    func applyGradient(colours: [UIColor]) -> Void {
        
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = self.bounds
//        gradient.masksToBounds = true
//        gradient.startPoint = CGPoint.init(x: 0.0, y: 0.5)
//        gradient.endPoint = CGPoint.init(x: 0.5, y: 1.0)
//        gradient.colors = colours.map { $0.cgColor }
//        gradient.cornerRadius = layer.cornerRadius
//        self.layer.insertSublayer(gradient, at: 0)
        self.backgroundColor = colours[0]
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}


extension UIPageControl {
    
    func customPageControl(dotFillColor:UIColor, dotBorderColor:UIColor, dotBorderWidth:CGFloat) {
        for (pageIndex, dotView) in self.subviews.enumerated() {
            if self.currentPage == pageIndex {
                dotView.backgroundColor = dotFillColor
                dotView.layer.cornerRadius = dotView.frame.size.height / 2
            }else{
                dotView.backgroundColor = .clear
                dotView.layer.cornerRadius = dotView.frame.size.height / 2
                dotView.layer.borderColor = dotBorderColor.cgColor
                dotView.layer.borderWidth = dotBorderWidth
            }
        }
    }
    
}

