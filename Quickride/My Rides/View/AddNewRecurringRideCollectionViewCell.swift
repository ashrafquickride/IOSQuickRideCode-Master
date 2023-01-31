//
//  AddNewRecurringRideCollectionViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 07/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddNewRecurringRideCollectionViewCell: UICollectionViewCell {
    //MARK: Outlets
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var officeIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    //MARK: Methods
    func configureViewBasedOnAddress(isShowOffice: Bool) {
        if isShowOffice {
            fromAddressLabel.text = Strings.office
            homeIcon.image = UIImage(named: "office_location_new")
            toAddressLabel.text = Strings.home
            officeIcon.image = UIImage(named: "home_location_new")
        } else {
            fromAddressLabel.text = Strings.home
            homeIcon.image = UIImage(named: "home_location_new")
            toAddressLabel.text = Strings.office
            officeIcon.image = UIImage(named: "office_location_new")
        }
    }
}
