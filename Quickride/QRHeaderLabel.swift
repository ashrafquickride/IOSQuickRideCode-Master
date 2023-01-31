//
//  QRHeaderLabel.swift
//  Quickride
//
//  Created by Ashutos on 4/8/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
@IBDesignable

class QRHeaderLabel: UILabel {
    
    @IBInspectable var textHeaderFont: CGFloat = 18 {
        didSet {
            self.font = UIFont(name: "Roboto-Medium", size: textHeaderFont)
        }
    }
    
    @IBInspectable var colorOfHeaderText: UIColor = .black {
        didSet {
            self.textColor = colorOfHeaderText
        }
    }
    
    override init(frame: CGRect) {
        print("init(frame:)")
        super.init(frame: frame);
        
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("init?(coder:)")
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        print("prepareForInterfaceBuilder()")
        sharedInit()
    }
    
    func sharedInit() {
        self.textColor = .black
        self.font = UIFont(name: "Roboto-Medium", size: 18.0)
    }
}
