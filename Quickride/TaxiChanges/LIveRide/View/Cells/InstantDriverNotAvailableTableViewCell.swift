//
//  InstantDriverNotAvailableTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class InstantDriverNotAvailableTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var animatingView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animatingView.animation = Animation.named("lnstant_booking")
        animatingView.play()
        animatingView.loopMode = .loop
        animatingView.contentMode = .scaleAspectFill
    }
    
    @IBAction func cancelRideTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .cancelInstantTrip, object: nil)
    }
    
    @IBAction func scheduleLaterTapped(_ sender: Any) {
       NotificationCenter.default.post(name: .scheduleInstantRideLater, object: nil)
    }
}
