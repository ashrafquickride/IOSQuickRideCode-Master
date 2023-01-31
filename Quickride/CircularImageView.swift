//
//  CircularImageView.swift
//  Quickride
//
//  Created by Admin on 08/02/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CircularImageView: UIImageView{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
