//
//  UserStatisticsCollectionViewCell.swift
//  Quickride
//
//  Created by Vinutha on 24/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UserStatisticsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func initialiseData(userStatistic: UserStatistic) {
        imageView.image = UIImage(named: userStatistic.imageName!)
        titleLabel.text = userStatistic.title
        if userStatistic.title == Strings.ratings {
            let title = userStatistic.value1! + userStatistic.value2!
            let attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x222222), textSize: 11), range: (title as NSString).range(of: userStatistic.value2!))
            valueLabel.attributedText = attributedString
        } else {
            valueLabel.text = userStatistic.value1
        }
    }
}
