//
//  StepProgressTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 12/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class StepProgressTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var slider: CustomSlider!
    
    func initialiseStepProgress(step: Int){
        stepLabel.text = String(format: Strings.step, arguments: [String(step)])
        slider.minimumTrackTintColor = UIColor(netHex: 0x9CDEBC)
        slider.maximumTrackTintColor = UIColor(netHex: 0xF2F2F2)
        slider.trackRect(forBounds: CGRect(x: 0, y: 0, width: 25, height: 25))
        slider.setValue(Float(step), animated: false)
    }
}
