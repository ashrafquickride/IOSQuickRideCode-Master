//
//  RideParticipantMarkerView.swift
//  Quickride
//
//  Created by Vinutha on 17/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideParticipantMarkerView: UIView {
    
    @IBOutlet var labelName: UILabel!
    
    @IBOutlet var viewBackGround: UIView!
    
    func initializeView(name: String, colorCode: UIColor){
        labelName.text = "\(name.prefix(1).capitalized)"
        viewBackGround.backgroundColor = colorCode
    }
}
