//
//  QuickRideCustomView.swift
//  Quickride
//
//  Created by Quick Ride on 11/22/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickRideCustomView: UIView {
    var width = 1.0
    
    override open var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: width, height: 1.0)
        }
    }
}

