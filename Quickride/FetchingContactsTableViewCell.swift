//
//  FetchingContactsTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 04/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class FetchingContactsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var loadingView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadingView.animation = Animation.named("loading_otp")
        loadingView.play()
        loadingView.loopMode = .loop
    }
}
