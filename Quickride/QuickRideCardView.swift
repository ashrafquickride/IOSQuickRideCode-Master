//
//  QuickRideCardView.swift
//  Quickride
//
//  Created by QuickRideMac on 8/14/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
@IBDesignable

class QuickRideCardView: UIView {
    
     @IBInspectable var borderWidth: CGFloat = 0.0 {
           didSet {
               self.layer.borderWidth = borderWidth
           }
       }
       
       @IBInspectable var borderColor: UIColor = UIColor.clear {
           didSet {
               self.layer.borderColor = borderColor.cgColor
           }
       }
       
       @IBInspectable var cornerRadius: CGFloat = 0.0 {
           didSet {
               self.layer.cornerRadius = cornerRadius
           }
       }
       
       @IBInspectable var shadowColor: UIColor = UIColor.clear {
           didSet {
               self.layer.shadowColor = shadowColor.cgColor
           }
       }
       
       @IBInspectable var shadowOffset: CGSize {
           get {
               return self.layer.shadowOffset
           }
           set {
               self.layer.shadowOffset = newValue
           }
       }
       
       /// The opacity of the shadow. Defaults to 0. Specifying a value outside the [0,1] range will give undefined results. Animatable.
       @IBInspectable var shadowOpacity: Float {
           get {
               return self.layer.shadowOpacity
           }
           set {
               self.layer.shadowOpacity = newValue
           }
       }
       
       @IBInspectable var shadowRadius: Double {
           get {
               return Double(self.layer.shadowRadius)
           }
           set {
               self.layer.shadowRadius = CGFloat(newValue)
           }
       }
       
       override func prepareForInterfaceBuilder() {
           super.prepareForInterfaceBuilder()
       }
}
