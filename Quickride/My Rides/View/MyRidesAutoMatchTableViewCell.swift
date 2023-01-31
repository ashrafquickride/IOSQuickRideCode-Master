//
//  MyRidesAutoMatchTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 29/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol MyRidesAutoMatchTableViewCellDelegate: class {
    func getStatusOfAutoMatch(status: Bool)
    func autoMatchSettingTapped()
}

class MyRidesAutoMatchTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var autoMatchSwitch: UISwitch!
    @IBOutlet weak var autoMatchRideImageView: UIImageView!
    @IBOutlet weak var autoMatchRiderTypeLabel: UILabel!
    @IBOutlet weak var minimumOfferRideMatchValueLabel: UILabel!
    @IBOutlet weak var minimumFindRideMatchValueLabel: UILabel!
    @IBOutlet weak var minimumRideTimeRangeValueLabel: UILabel!
    
    //MARK: Property
    weak var delegate: MyRidesAutoMatchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Methods
    func setupAutoConfirmToggleUI(ridePreferences: RidePreferences?) {
        if let preference = ridePreferences {
            checkAutoMatch(userType: preference.autoconfirm)
            minimumOfferRideMatchValueLabel.text = "\(preference.autoConfirmRideMatchPercentageAsRider)%"
            minimumFindRideMatchValueLabel.text = "\(preference.autoConfirmRideMatchPercentageAsPassenger)%"
            minimumRideTimeRangeValueLabel.text = "± \(preference.autoConfirmRideMatchTimeThreshold)"
            autoMatchSwitch.setOn(preference.autoConfirmEnabled, animated: false)
        }
    }
    
    func checkAutoMatch(userType: String) {
        switch userType {
        case RidePreferences.AUTO_CONFIRM_VERIFIED:
            autoMatchRiderTypeLabel.text = Strings.verified_users
            autoMatchRideImageView.image =  UIImage(named: "verified")
        case RidePreferences.AUTO_CONFIRM_FAVORITE_PARTNERS:
            autoMatchRiderTypeLabel.text = Strings.favourite_partners
            ImageUtils.setTintedIcon(origImage: UIImage(named: "fav_active")!, imageView: autoMatchRideImageView, color: UIColor(netHex: 0x51B261))
        default :
            autoMatchRiderTypeLabel.text = Strings.all_users
            ImageUtils.setTintedIcon(origImage: UIImage(named: "blue_group")!, imageView: autoMatchRideImageView, color: UIColor(netHex: 0x51B261))
        }
    }
    
    //MARK: Actions
    @IBAction func autoMatchSettingsButtonTapped(_ sender: UIButton) {
        delegate?.autoMatchSettingTapped()
    }
    
    @IBAction func autoMatchSwitchChanged(_ sender: UISwitch) {
        delegate?.getStatusOfAutoMatch(status: sender.isOn)
    }
}
