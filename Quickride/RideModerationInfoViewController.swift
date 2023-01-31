//
//  RideModerationInfoViewController.swift
//  Quickride
//
//  Created by Vinutha on 30/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideModerationInfoViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rideModerationEnabledSwitch: UISwitch!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var rideModerationLabel: UILabel!
    
    //MARK: Properties
    var rideModerationInfoViewModel: RideModerationInfoViewModel?
    
    //MARK: Initializer
    func initialiseView(titleMessage: String, subTitle: String?, infoImages: [UIImage], infoTitles: [String], infoSubTitles: [String], ridePreferenceReceiver: SaveRidePreferencesReceiver?) {
        rideModerationInfoViewModel = RideModerationInfoViewModel(titleMessage: titleMessage, subTitle: subTitle, infoImages: infoImages, infoTitles: infoTitles, infoSubTitles: infoSubTitles, ridePreferenceReceiver: ridePreferenceReceiver)
    }
    
    //MARK: Viewlifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewHeightConstraint.constant = tableView.contentSize.height //modify to content height
    }
    
    //MARK: Methods
    private func setupUI(){
        titleLabel.text = rideModerationInfoViewModel!.titleMessage!
        if let subTitle = self.rideModerationInfoViewModel?.subTitle {
            subTitleLabel.isHidden = false
            subTitleLabel.text = subTitle
        } else{
            subTitleLabel.isHidden = true
        }
        if let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() {
            rideModerationEnabledSwitch.setOn(ridePreference.rideModerationEnabled, animated: false)
        }
        changeTextBasedOnSwitchState()
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped(_:))))
    }
    
    private func changeTextBasedOnSwitchState() {
        if rideModerationEnabledSwitch.isOn {
            rideModerationLabel.text = Strings.ride_moderation_on
        } else {
            rideModerationLabel.text = Strings.ride_moderation_off
        }
    }
    @objc private func backgroundViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    //MARK: Actions
    @IBAction func rideModerationEnabledSwitchTapped(_ sender: UISwitch) {
        if let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() {
            ridePreference.rideModerationEnabled = sender.isOn
            SaveRidePreferencesTask.init(ridePreferences: ridePreference, viewController: self, receiver: rideModerationInfoViewModel?.ridePreferenceReceiver).saveRidePreferences()
        }
        changeTextBasedOnSwitchState()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

//MARK: TableViewDataSouce
extension RideModerationInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideModerationInfoViewModel!.infoTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideModerationInfoTableViewCell", for: indexPath) as! RideModerationInfoTableViewCell
        if rideModerationInfoViewModel!.infoImages.endIndex <= indexPath.row || rideModerationInfoViewModel!.infoTitles.endIndex <= indexPath.row || rideModerationInfoViewModel!.infoSubTitles.endIndex <= indexPath.row{
            return cell
        }
        cell.initaialiseView(infoImage: rideModerationInfoViewModel!.infoImages[indexPath.row], infoTitle: rideModerationInfoViewModel!.infoTitles[indexPath.row], infoSubTitle: rideModerationInfoViewModel!.infoSubTitles[indexPath.row])
        return cell
    }
}

//MARK: RidePreferenceUpdateDelegate
extension RideModerationInfoViewController: SaveRidePreferencesReceiver {
    func ridePreferencesSavingFailed() {}
    
    func ridePreferencesSaved() {}
}
