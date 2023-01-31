//
//  RideModeratorCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class RideModeratorCardTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var rideModeratorImageView: UIImageView!
    @IBOutlet weak var rideModeratorView: UIView!
    @IBOutlet weak var rideModeratorSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var rideType : String?
    //MARK: Initializer
    func initializeData(rideType : String){
        self.rideType = rideType
        setUpUI()
    }
    
    //MARK: Methods
    private func setUpUI(){
        rideModeratorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moderatorViewTapped(_:))))
        if let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() {
            rideModeratorSwitch.setOn(ridePreference.rideModerationEnabled, animated: false)
            if ridePreference.rideModerationEnabled {
                rideModeratorImageView.image = UIImage(named: "icon_ride_anchor_enable")
            } else {
                rideModeratorImageView.image = UIImage(named: "icon_ride_anchor_disable")
            }
        }
        if rideType == Ride.RIDER_RIDE {
            titleLabel.text = Strings.enable_ride_moderation_title_for_rider
            subTitleLabel.text = Strings.enable_ride_moderation_subtitle_for_rider
        } else {
            titleLabel.text = Strings.enable_ride_moderation_title_for_ridetaker
            subTitleLabel.text = Strings.enable_ride_moderation_subtitle_for_ridetaker
        }
    }
    
    @objc func moderatorViewTapped(_ sender: UITapGestureRecognizer)  {
        moveToModerationInfoView()
    }
    
    private func moveToModerationInfoView() {
        let rideModerationInfoVC = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideModerationInfoViewController") as! RideModerationInfoViewController
        
        var message: String?
        var subTitle: String?
        var titles: [String]?
        var subTitles: [String]?
        var infoImages: [UIImage]?
        if rideType == Ride.RIDER_RIDE {
            message = Strings.ride_moderation_title_for_rider
            titles = Strings.ride_moderation_info_titles_for_rider
            subTitles = Strings.ride_moderation_info_sub_titles_for_rider
            infoImages = Strings.ride_moderation_info_images_for_rider
            subTitle = Strings.ride_moderation_sub_title_for_rider
        } else {
            message = Strings.ride_moderation_title_for_ride_taker
            titles = Strings.ride_moderation_info_titles_for_ride_taker
            subTitles = Strings.ride_moderation_info_sub_titles_for_ride_taker
            infoImages = Strings.ride_moderation_info_images_ride_takers
            subTitle = Strings.ride_moderation_sub_title_for_ride_taker
        }
        rideModerationInfoVC.initialiseView(titleMessage: message!, subTitle: subTitle, infoImages: infoImages!, infoTitles: titles!, infoSubTitles: subTitles!, ridePreferenceReceiver: self)
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideModerationInfoVC)
    }
    
    //MARK: Actions
    @IBAction func rideModerationEnabledSwitchTapped(_ sender: UISwitch) {
        if let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() {
            ridePreference.rideModerationEnabled = sender.isOn
            SaveRidePreferencesTask.init(ridePreferences: ridePreference, viewController: parentViewController, receiver: self).saveRidePreferences()
        }
    }
}
extension RideModeratorCardTableViewCell : SaveRidePreferencesReceiver {
    func ridePreferencesSaved(){
        initializeData(rideType: self.rideType!)
        NotificationCenter.default.post(name: .rideModerationStatusChanged, object: nil)
    }
    func ridePreferencesSavingFailed(){
        initializeData(rideType: self.rideType!)
    }
}

