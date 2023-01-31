//
//  AutoConfirmPopUpViewController.swift
//  Quickride
//
//  Created by Ashutos on 29/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AutoConfirmPopUpViewController: UIViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var autoConfirmSwitch: UISwitch!
    
    @IBOutlet weak var PopUpView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var autoConfirmDefaultTypeLabel: UILabel!
    
    @IBOutlet weak var routeMatchPercentageLabel: UILabel!
    
    @IBOutlet weak var routeMatchTimeLabel: UILabel!
    
    private var ridePreference : RidePreferences?
    var rideType : String?
    
    func initializeView(rideType: String?){
        self.rideType = rideType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.PopUpView.center.y -= self.PopUpView.bounds.height
        }, completion: nil)
        showDefaultValues()
        guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences else { return }
        ridePreference = ridePreferences
        autoConfirmSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backGroundViewTapped(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ViewCustomizationUtils.addCornerRadiusToView(view: confirmButton, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: PopUpView, cornerRadius: 20.0, corner1: .topLeft, corner2: .topRight)
    }

    func showDefaultValues(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if clientConfiguration.autoConfirmDefaultValue == RidePreferences.AUTO_CONFIRM_VERIFIED{
            autoConfirmDefaultTypeLabel.text = Strings.verified_users
        }else if clientConfiguration.autoConfirmDefaultValue == RidePreferences.AUTO_CONFIRM_FAVORITE_PARTNERS{
            autoConfirmDefaultTypeLabel.text = Strings.favourite_partners
        }
        routeMatchTimeLabel.text = String(format: Strings.mins_of_sch_time, arguments: [String(clientConfiguration.autoConfirmDefaultRideMatchTimeThreshold)])
        if rideType == Ride.RIDER_RIDE{
            routeMatchPercentageLabel.text = String(format: Strings.route_match_for_autoConfirm, arguments: [String(clientConfiguration.autoConfirmDefaultRideMatchPercentageAsRider)])
        }else{
           routeMatchPercentageLabel.text = String(format: Strings.route_match_for_autoConfirm, arguments: [String(clientConfiguration.autoConfirmDefaultRideMatchPercentageAsPassenger)])
        }
    }
    
    @IBAction func switchDidChanged(_ sender: UISwitch) {
        SharedPreferenceHelper.setAutoConfirmCount(count: 4)
        if sender.isOn{
            sender.backgroundColor = .green
        }else{
            sender.backgroundColor = .lightGray
            sender.layer.cornerRadius = 15
        }
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
        removeView()
        goToSettings()
        
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        if autoConfirmSwitch.isOn{
            ridePreference?.autoConfirmEnabled = true
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            ridePreference?.autoconfirm = clientConfiguration.autoConfirmDefaultValue
            ridePreference?.autoConfirmRideMatchTimeThreshold = clientConfiguration.autoConfirmDefaultRideMatchTimeThreshold
            ridePreference?.rideMatchPercentageAsRider = clientConfiguration.autoConfirmDefaultRideMatchPercentageAsRider
            ridePreference?.rideMatchPercentageAsPassenger = clientConfiguration.autoConfirmDefaultRideMatchPercentageAsPassenger
        } else {
            ridePreference?.autoConfirmEnabled = false
            SharedPreferenceHelper.setAutoConfirmCount(count: 4)
        }
        QuickRideProgressSpinner.startSpinner()
        SaveRidePreferencesTask(ridePreferences: ridePreference!, viewController: self, receiver: self).saveRidePreferences()
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.PopUpView.center.y += self.PopUpView.bounds.height
            self.PopUpView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func goToSettings() {
        SharedPreferenceHelper.setAutoConfirmCount(count: 4)
        let rideAutoConfirmationSettingViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAutoConfirmationSettingViewController") as! RideAutoConfirmationSettingViewController
        rideAutoConfirmationSettingViewController.initializeViews(ridePreferences: ridePreference!)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: rideAutoConfirmationSettingViewController, animated: false)
    }
}
//MARK: SaveRidePreferencesReceiver Delegate
extension AutoConfirmPopUpViewController: SaveRidePreferencesReceiver {
    func ridePreferencesSaved() {
        QuickRideProgressSpinner.stopSpinner()
        removeView()
    }

    func ridePreferencesSavingFailed() {
        QuickRideProgressSpinner.stopSpinner()
    }
}

