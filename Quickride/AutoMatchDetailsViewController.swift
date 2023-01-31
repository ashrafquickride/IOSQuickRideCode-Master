//
//  AutoMatchDetailsViewController.swift
//  Quickride
//
//  Created by Ashutos on 27/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias autoMatchStatusChanged = (_ changed : Bool) -> Void

class AutoMatchDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var viewPreferenceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var verificationImageView: UIImageView!
    @IBOutlet weak var typeOfUserLabel: UILabel!
    @IBOutlet weak var scheduleTimeMatchLabel: UILabel!
    @IBOutlet weak var preferenceDetailsView: UIView!
    @IBOutlet weak var routeMatchDetailsLabel: UILabel!
    @IBOutlet weak var routeMatchPercentageLabel: UILabel!
    @IBOutlet weak var autoMatchStatusLabel: UILabel!
    @IBOutlet weak var autoConfirmSwitch: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    
    //MARK:Propertise
    private var isPreferenceShown = true
    private var ridePreference: RidePreferences?
    private var autoMatchType = Ride.PASSENGER_RIDE
    private var autoMatchStatusChanged: autoMatchStatusChanged?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setDataToView()
        // Do any additional setup after loading the view.
    }
    
    func initializeData(rideType: String,autoMatchStatusChanged: autoMatchStatusChanged?) {
        autoMatchType = rideType
        self.autoMatchStatusChanged = autoMatchStatusChanged
    }
    
    
    private func setUpUI() {
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: popUpView, cornerRadius: 20)
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.popUpView.center.y -= self.popUpView.bounds.height
            }, completion: nil)
        preferenceDetailsView.isHidden = false
        viewPreferenceHeightConstraint.constant = 130
    }
    
    private func setDataToView() {
        guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() else { return }
        ridePreference = ridePreferences
        checkAutoMatch(autoConfirmMatchType: ridePreferences.autoconfirm)
        if ridePreferences.autoConfirmEnabled{
            autoConfirmSwitch.setOn(true, animated: true)
            infoLabel.text = Strings.autoConfirm_onState_info
        }else{
            autoConfirmSwitch.setOn(false, animated: true)
            infoLabel.text = Strings.autoConfirm_offState_info
        }
        if autoMatchType == Ride.PASSENGER_RIDE {
            routeMatchPercentageLabel.text = "\(ridePreferences.autoConfirmRideMatchPercentageAsPassenger)%"
            routeMatchDetailsLabel.text = Strings.find_ride_match_auto_details
        }else{
            routeMatchPercentageLabel.text = "\(ridePreferences.autoConfirmRideMatchPercentageAsRider)%"
            routeMatchDetailsLabel.text = Strings.offer_ride_match_auto_details
        }
        scheduleTimeMatchLabel.text = "±\(ridePreferences.autoConfirmRideMatchTimeThreshold)"
    }
    
    private func checkAutoMatch(autoConfirmMatchType: String) {
        switch autoConfirmMatchType {
        case RidePreferences.AUTO_CONFIRM_VERIFIED:
            typeOfUserLabel.text = Strings.verified_users
            verificationImageView.image =  UIImage(named: "verified")
        case RidePreferences.AUTO_CONFIRM_FAVORITE_PARTNERS:
            typeOfUserLabel.text = Strings.favourite_partners
            ImageUtils.setTintedIcon(origImage: UIImage(named: "fav_active")!, imageView: verificationImageView, color: UIColor(netHex: 0x51B261))
        default :
            typeOfUserLabel.text = Strings.all_users
            ImageUtils.setTintedIcon(origImage: UIImage(named: "blue_group")!, imageView: verificationImageView, color: UIColor(netHex: 0x51B261))
        }
    }
    
    @IBAction func viewPreferenceBtnPressed(_ sender: UIButton) {
        if isPreferenceShown {
            isPreferenceShown = false
            viewPreferenceHeightConstraint.constant = 130
            preferenceDetailsView.isHidden = false
        } else {
            isPreferenceShown = true
            viewPreferenceHeightConstraint.constant = 0
            preferenceDetailsView.isHidden = true
        }
    }
    @IBAction func editPreferenceBtnPressed(_ sender: UIButton) {
        removeView()
        guard let ridePreference = ridePreference else{ return }
        goToSettings(ridePreference: ridePreference)
    }
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.popUpView.center.y += self.popUpView.bounds.height
            self.popUpView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func goToSettings(ridePreference: RidePreferences) {
        let rideAutoConfirmationSettingViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAutoConfirmationSettingViewController") as! RideAutoConfirmationSettingViewController
        rideAutoConfirmationSettingViewController.initializeViews(ridePreferences: ridePreference)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: rideAutoConfirmationSettingViewController, animated: false)
    }
    
    @IBAction func switchTapped(_ sender: Any) {
        guard let ridePref = ridePreference else { return }
        if autoConfirmSwitch.isOn{
            ridePref.autoConfirmEnabled = true
        }else{
            ridePref.autoConfirmEnabled = false
        }
        SaveRidePreferencesTask(ridePreferences: ridePref, viewController: self, receiver: self).saveRidePreferences()
        autoMatchStatusChanged?(true)
    }
}

//MARK: SaveRidePreferencesReceiver
extension AutoMatchDetailsViewController: SaveRidePreferencesReceiver{
    func ridePreferencesSaved() {
        autoMatchStatusChanged?(true)
        removeView()
    }

    func ridePreferencesSavingFailed() { }
}
