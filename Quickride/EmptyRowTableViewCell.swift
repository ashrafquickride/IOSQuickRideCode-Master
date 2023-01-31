//
//  EmptyRowTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 4/3/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EmptyRowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var percentageSymbolShowinglabel: UILabel!
    @IBOutlet weak var pointTopView: UIView!
    @IBOutlet weak var routeMatchShowingLabel: UILabel!
    @IBOutlet weak var offerOrRequestButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpUI(matchedUsertype: String) {
        if Ride.RIDER_RIDE == matchedUsertype {
            percentageSymbolShowinglabel.isHidden = false
            pointTopView.isHidden = true
            routeMatchShowingLabel.text = Strings.route_match
            offerOrRequestButton.setTitle(Strings.OFFER_RIDE_CAPS, for: .normal)
        } else {
            percentageSymbolShowinglabel.isHidden = true
            pointTopView.isHidden = false
            routeMatchShowingLabel.text = Strings.points_new
            offerOrRequestButton.setTitle(Strings.request_caps, for: .normal)
        }
    }
}
