//
//  ResumeRecurringRidesViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 15/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ResumeRecurringRidesViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backGroungView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var suspendedRidesTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var resumeRecurringRidesViewModel =  ResumeRecurringRidesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        prepareUi()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    private func prepareUi(){
        suspendedRidesTableView.register(UINib(nibName: "SuspendedRecurringRideTableViewCell", bundle: nil), forCellReuseIdentifier: "SuspendedRecurringRideTableViewCell")
        resumeRecurringRidesViewModel.getSuspendedRecurringRides()
        suspendedRidesTableView.reloadData()
        tableViewHeightConstraint.constant = CGFloat(resumeRecurringRidesViewModel.recurringRides.count*115)
        if tableViewHeightConstraint.constant > 270{
            tableViewHeightConstraint.constant = 270
        }
        NotificationCenter.default.addObserver(self, selector: #selector(rideStatusChanged(_:)), name: .rideStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeRideTime(_:)), name: .changeRideTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpinner(_:)), name: .stopSpinner, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRides(_:)), name: .refreshRides, object: nil)
        backGroungView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        userNameLabel.text = "Hey " + (UserDataCache.getInstance()?.userProfile?.userName ?? "")
    }
    
    @objc func rideStatusChanged(_ notification:Notification) {
        guard let index = notification.userInfo?["index"] as? Int,let status =  notification.userInfo?["switchStatus"] as? Bool else { return }
        if status{
            resumeRecurringRidesViewModel.selcetedRides.append(resumeRecurringRidesViewModel.recurringRides[index])
        }else{
            let regularRide = resumeRecurringRidesViewModel.recurringRides[index]
            resumeRecurringRidesViewModel.selcetedRides = resumeRecurringRidesViewModel.selcetedRides.filter(){$0 != regularRide}
        }
    }
    
    @objc func changeRideTime(_ notification:Notification) {
        guard let index = notification.userInfo?["index"] as? Int else { return }
        if !resumeRecurringRidesViewModel.recurringRides.isEmpty{
            changeTimeTapped(regularRide: resumeRecurringRidesViewModel.recurringRides[index])
        }
    }
    @objc func stopSpinner(_ notification:Notification) {
        QuickRideProgressSpinner.stopSpinner()
        closeView()
    }
    
    @objc func refreshRides(_ notification:Notification) {
        resumeRecurringRidesViewModel.getSuspendedRecurringRides()
        if resumeRecurringRidesViewModel.selcetedRides.isEmpty{
            closeView()
        }else{
            suspendedRidesTableView.reloadData()
            tableViewHeightConstraint.constant = CGFloat(resumeRecurringRidesViewModel.recurringRides.count*115)
            if tableViewHeightConstraint.constant > 270{
                tableViewHeightConstraint.constant = 270
            }
        }
    }
    private func changeTimeTapped(regularRide: RegularRide){
        var regularRide = regularRide
        resumeRecurringRidesViewModel.fillTimeForDayInWeek(regularRide: regularRide)
        let recurringRideSettingsViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RecurringRideSettingsViewController") as! RecurringRideSettingsViewController
        recurringRideSettingsViewController.initailizeRecurringRideSettingView(ride: regularRide, dayType: Ride.ALL_DAYS, weekdays: resumeRecurringRidesViewModel.weekdays, editWeekDaysTimeCompletionHandler: { (weekdays,dayType,startTime) in
            if let rideStartTime = startTime{
                regularRide.startTime = rideStartTime
            }
            regularRide.dayType = dayType
            regularRide = RecurringRideUtils().fillTimeForEachDayInWeek(regularRide: regularRide, weekdays: self.resumeRecurringRidesViewModel.weekdays)
            self.resumeRecurringRidesViewModel.updateRide(regularRide: regularRide)
            self.suspendedRidesTableView.reloadData()
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: recurringRideSettingsViewController)
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        if resumeRecurringRidesViewModel.selcetedRides.isEmpty{
            closeView()
        }else{
            QuickRideProgressSpinner.startSpinner()
            resumeRecurringRidesViewModel.resumeSelectedRecurringRides()
        }
    }
}

//UITableViewDataSource
extension ResumeRecurringRidesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resumeRecurringRidesViewModel.recurringRides.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuspendedRecurringRideTableViewCell", for: indexPath) as! SuspendedRecurringRideTableViewCell
        if resumeRecurringRidesViewModel.recurringRides.endIndex <= indexPath.row{
            return cell
        }
        cell.initialiseRecurringRide(regularRide: resumeRecurringRidesViewModel.recurringRides[indexPath.row])
        cell.rideSwitch.tag = indexPath.row
        return cell
    }
}

//UITableViewDelegate
extension ResumeRecurringRidesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recurringRideViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.recurringRideViewController) as! RecurringRideViewController
        recurringRideViewController.initializeDataBeforePresentingView(ride: resumeRecurringRidesViewModel.recurringRides[indexPath.row], isFromRecurringRideCreation: false)
        self.navigationController?.pushViewController(recurringRideViewController, animated: false)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
