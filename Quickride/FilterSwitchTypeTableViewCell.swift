//
//  FilterSwitchTypeTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 03/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol FilterSwitchTypeTableViewCellDelegate: class {
    func setFilterToggle(status: Bool,index: Int)
}

class FilterSwitchTypeTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var filterTypeLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    
    //MARK: Variables
    private weak var delegate: FilterSwitchTypeTableViewCellDelegate?
    private weak var viewController: UIViewController?
    private var isAlertRequire = false
    private var filterType: String?
    
    func initializeSwitch(filterType: String,status: Bool,tag: Int,changesFromSettings: Bool,viewController: UIViewController, delegate: FilterSwitchTypeTableViewCellDelegate){
        filterTypeLabel.text = filterType
        filterSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        filterSwitch.setOn(status, animated: false)
        self.delegate = delegate
        filterSwitch.tag = tag
        self.viewController = viewController
        isAlertRequire = changesFromSettings
        self.filterType = filterType
    }
    
    //MARK: Action
    @IBAction func filterToggleTapped(_ sender: UISwitch) {
        if isAlertRequire{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.change_settings, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: viewController, handler: { (result) in
                if Strings.yes_caps == result{
                    self.delegate?.setFilterToggle(status: sender.isOn,index:sender.tag)
                    let securityPreferences = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().copy() as? SecurityPreferences
                    guard let securityPref = securityPreferences,let vc = self.viewController else { return }
                    if self.filterType == Strings.verified_users_only{
                        securityPreferences?.shareRidesWithUnVeririfiedUsers = true
                        SecurityPreferencesUpdateTask(viewController: vc, securityPreferences: securityPref, securityPreferencesUpdateReceiver: nil).updateSecurityPreferences()
                        self.delegate?.setFilterToggle(status: sender.isOn,index:sender.tag)
                    }else if self.filterType == Strings.same_gender_only{
                        securityPreferences?.shareRidesWithSameGenderUsersOnly = true
                        SecurityPreferencesUpdateTask(viewController: vc, securityPreferences: securityPref, securityPreferencesUpdateReceiver: nil).updateSecurityPreferences()
                        self.delegate?.setFilterToggle(status: sender.isOn,index:sender.tag)
                    }
                }else{
                    self.filterSwitch.setOn(true, animated: false)
                }
            })
        }else{
            delegate?.setFilterToggle(status: sender.isOn,index:sender.tag)
        }
    }
}

