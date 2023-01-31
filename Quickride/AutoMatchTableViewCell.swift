//
//  AutoMatchTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 29/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol AutoMatchTableViewCellDelegate: class {
    func updateAndSaveAutoMatchPreference(status: Bool,preference: RidePreferences)
    func autoMatchSettingTapped()
}

class AutoMatchTableViewCell: UITableViewCell {
  
   //MARK: Outlets
    @IBOutlet weak var autoMatchDescriptionLabel: UILabel!
    @IBOutlet weak var autoMatchSwitch: UISwitch!
    @IBOutlet weak var seperatorView: UIView!
    private var ridePreference : RidePreferences?
    weak var delegate: AutoMatchTableViewCellDelegate?
    
    func setUpUI(rideType: String? = nil) {
        ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if rideType == Ride.PASSENGER_RIDE{
            if let preference = ridePreference {
                autoMatchDescriptionLabel.text = preference.autoconfirm + " with " + String(format: Strings.route_match_for_autoConfirm, arguments: [String(preference.autoConfirmRideMatchPercentageAsPassenger) + "%"]) + " and ± " + String(format: Strings.mins_of_sch_time, arguments: [String(preference.autoConfirmRideMatchTimeThreshold)])
            }else{
                autoMatchDescriptionLabel.text = ""
            }
        }else if rideType == Ride.RIDER_RIDE{
            autoMatchDescriptionLabel.text = String(format: Strings.route_match_for_autoConfirm, arguments: [String(clientConfiguration.autoConfirmDefaultRideMatchPercentageAsRider) + "%"]) + " and ± " + String(format: Strings.mins_of_sch_time, arguments: [String(clientConfiguration.autoConfirmDefaultRideMatchTimeThreshold)])
        }else{
            autoMatchDescriptionLabel.text =
            "It allows users to get instant ride confirmation with Verified Users having 95% route match and + 15 minutes of scheduled time"
        }
        autoMatchSwitch.setOn(ridePreference?.autoConfirmEnabled ?? false, animated: false)
    }
    
    @IBAction func autoMatchSettingsButtonTapped(_ sender: UIButton) {
        delegate?.autoMatchSettingTapped()
    }
    
    @IBAction func autoMatchSwitchChanged(_ sender: UISwitch) {
        guard let preference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() else {
            autoMatchSwitch.setOn(ridePreference?.autoConfirmEnabled ?? false, animated: false)
            return
        }
        delegate?.updateAndSaveAutoMatchPreference(status: sender.isOn, preference: preference)
    }
}
