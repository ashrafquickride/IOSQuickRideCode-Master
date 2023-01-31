//
//  QRSubTitleLabel.swift
//  Quickride
//
//  Created by Ashutos on 4/8/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
@IBDesignable

class QRSubTitleLabel: UILabel {
    
    @IBInspectable var textFont: CGFloat = 12 {
        didSet {
            self.font = UIFont(name: "Roboto-Regular", size: textFont)
        }
    }
    
    @IBInspectable var textOfColor: UIColor = UIColor.black.withAlphaComponent(0.4) {
        didSet {
            self.textColor = textOfColor
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
        self.textColor = UIColor.black.withAlphaComponent(0.4)
        self.font = UIFont(name: "Roboto-Regular", size: 12.0)
    }
}

