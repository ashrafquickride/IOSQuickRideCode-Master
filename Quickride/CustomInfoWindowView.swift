//
//  CustomInfoWindowView.swift
//  Quickride
//
//  Created by iDisha on 04/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CustomInfoWindowView: UIView
{
    
    @IBOutlet var labelTitle: UILabel!
    
    func initializeView(title: String){
        labelTitle.text = title
    }
}

