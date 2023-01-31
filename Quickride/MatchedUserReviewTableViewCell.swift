//
//  MatchedUserReviewTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 10/06/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MatchedUserReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var firstSubLabel: UILabel!
    
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var secondSubLabel: UILabel!
    
    @IBOutlet weak var seperatorView: UIView!
    
    func initialiseData(rating: Double,noOfReviews: Int,userOnTimeComplianceRating: String?,requiredSeats: Int?){
        firstLabel.text = StringUtils.getPointsInDecimal(points: rating)
        firstSubLabel.text = "( " + String(noOfReviews) + " )"
        
        if let userOnTimeComplianceRating = userOnTimeComplianceRating {
            secondImageView.image = UIImage(named: "icon_ontime")
            secondLabel.text =  userOnTimeComplianceRating + "%"
            secondSubLabel.text = Strings.onTime
        }else if let requiredSeats = requiredSeats {
            secondImageView.image = UIImage(named: "seats")
            secondLabel.text = String(requiredSeats)
            secondSubLabel.text = ""
        }else {
            secondImageView.isHidden = true
            secondLabel.isHidden = true
            secondSubLabel.isHidden = true
            seperatorView.isHidden = true
        }
    }
    
}
