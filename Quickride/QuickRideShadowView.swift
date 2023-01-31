//
//  QuickRideShadowView.swift
//  Quickride
//
//  Created by QuickRideMac on 8/14/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

import Foundation
import UIKit
import QuartzCore

class QuickRideShadowView: UIView {
    
    override func draw(_ rect: CGRect) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }
}
