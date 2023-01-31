//
//  CreateRecurringRideTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 29/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CreateRecurringRideTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var officeIcon: UIImageView!
    
    //MARK: Methods
    private var isRecurringRideRequiredFrom: String?
    
    func showCreatingRecurringRideView(isRecurringRideRequiredFrom: String?) {
        self.isRecurringRideRequiredFrom = isRecurringRideRequiredFrom
        if isRecurringRideRequiredFrom == RegularRideCreationViewController.HOME_TO_OFFICE{
            fromAddressLabel.text = Strings.home
            homeIcon.image = UIImage(named: "home_location_new")
            toAddressLabel.text = Strings.office
            officeIcon.image = UIImage(named: "office_location_new")
        } else if isRecurringRideRequiredFrom == RegularRideCreationViewController.OFFICE_TO_HOME{
            fromAddressLabel.text = Strings.office
            homeIcon.image = UIImage(named: "office_location_new")
            toAddressLabel.text = Strings.home
            officeIcon.image = UIImage(named: "home_location_new")
        }
    }
    @IBAction func whatsRecurringRideTapped(_ sender: Any) {
        MessageDisplay.displayInfoViewAlert(title: Strings.recurring_ride_info_title, titleColor: nil, message: Strings.recurring_ride_info, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
        }
    }
    
    @IBAction func setNowTapped(_ sender: Any) {
        if let userCache = UserDataCache.getInstance(), let _ = userCache.getHomeLocation(), let _ = userCache.getOfficeLocation() {
            let regularRideCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.regularRideCreationViewController) as! RegularRideCreationViewController
            regularRideCreationViewController.isRecurringRideRequiredFrom = isRecurringRideRequiredFrom
            regularRideCreationViewController.initializeView(createRideAsRecuringRide: false, ride: nil)
            parentViewController?.navigationController?.pushViewController(regularRideCreationViewController, animated: false)
        }else{
            let destViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCreateViewController") as! RideCreateViewController
            destViewController.initializeView(myRideDeleagte: self)
            ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: destViewController, animated: true)
        }
    }
}
//MARK: HomeOfficeSavingDelegate
extension CreateRecurringRideTableViewCell: HomeOfficeLocationSavingDelegate {
    func navigateToRegularRideCreation() {
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.regularRideCreationViewController) as! RegularRideCreationViewController
        destViewController.isRecurringRideRequiredFrom = isRecurringRideRequiredFrom
        destViewController.initializeView(createRideAsRecuringRide: false, ride: nil)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: destViewController, animated: true)
    }
}
