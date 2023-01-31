//
//  RideFilterViewController.swift
//  Quickride
//
//  Created by Bandish Kumar on 04/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideFilterViewController: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var rideFilterTableView: UITableView!
    
    //MARK: Variables
    weak var topViewController: RideFilterBaseViewController?
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        rideFilterTableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "RatingTableViewCell")
    }
}
//MARK: UITableViewDataSource
extension RideFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if topViewController?.rideType == Ride.RIDER_RIDE{
            return 7
        }else{
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let securityPreferences = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().copy() as? SecurityPreferences
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeRangeTableViewCell", for: indexPath) as! TimeRangeTableViewCell
            cell.delegate = self
            let timeRange = getTimeRange()
            cell.prepareTimeRangeList(selectedTimeRange: timeRange)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RouteMatchTableViewCell", for: indexPath) as! RouteMatchTableViewCell
            cell.delegate = self
            cell.iniatializeRouteMatch(percentage: topViewController?.status[DynamicFiltersCache.ROUTE_MATCH_CRITERIA], routeMatchPoint: topViewController?.status[DynamicFiltersCache.ROUTE_POINT_CRITERIA], rideType: topViewController?.rideType,view: self.view)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchTypeTableViewCell", for: indexPath) as! FilterSwitchTypeTableViewCell
            var verifiedUsers = false
            var isChangesFromSettings = false
            if topViewController?.status[DynamicFiltersCache.USERS_CRITERIA] == DynamicFiltersCache.PREFERRED_USERS_VERIFIED{
                verifiedUsers = true
            }else if let shareRidesWithUnVeririfiedUsers = securityPreferences?.shareRidesWithUnVeririfiedUsers,!shareRidesWithUnVeririfiedUsers{
                verifiedUsers = true
                isChangesFromSettings = true
            }
            cell.initializeSwitch(filterType: Strings.verified_users_only, status: verifiedUsers,tag: indexPath.row, changesFromSettings: isChangesFromSettings, viewController: self,delegate: self)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchTypeTableViewCell", for: indexPath) as! FilterSwitchTypeTableViewCell
            var activeUsersOnly = false
            if topViewController?.status[DynamicFiltersCache.EXISTANCE_CRITERIA] == DynamicFiltersCache.ACTIVE_USERS{
                activeUsersOnly = true
            }
            cell.initializeSwitch(filterType: Strings.active_users_last_1_business_day, status: activeUsersOnly,tag: indexPath.row, changesFromSettings: false, viewController: self, delegate: self)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchTypeTableViewCell", for: indexPath) as! FilterSwitchTypeTableViewCell
            var favouritePartners = false
            if topViewController?.status[DynamicFiltersCache.PARTNERS_CRITERIA] == DynamicFiltersCache.FAVOURITE_PARTNERS{
                favouritePartners = true
            }
            cell.initializeSwitch(filterType: Strings.favourites_users_only, status: favouritePartners, tag: indexPath.row, changesFromSettings: false, viewController: self,delegate: self)
            return cell
        case 5:
            if topViewController?.rideType == Ride.RIDER_RIDE{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingTableViewCell
                cell.delegate = self
                cell.setupRatingView(selectedRating: Int(topViewController?.status[DynamicFiltersCache.MINIMUM_RATING_CRITERIA] ?? "") ?? -1)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleFilterTableViewCell", for: indexPath) as! VehicleFilterTableViewCell
                cell.delegate = self
                cell.initializeVehicleFilterOption(vehicleCriteria: topViewController?.status[DynamicFiltersCache.VEHICLE_CRITERIA])
                return cell
            }
        case 6:
            if topViewController?.rideType == Ride.RIDER_RIDE{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchTypeTableViewCell", for: indexPath) as! FilterSwitchTypeTableViewCell
                var isGenderFilterApplyed = false
                var isChangesFromSettings = false
                if topViewController?.status[DynamicFiltersCache.GENDER_CRITERIA] == UserDataCache.getInstance()?.getCurrentUserGender(){
                    isGenderFilterApplyed = true
                }else if let shareRidesWithSameGenderUsersOnly = securityPreferences?.shareRidesWithSameGenderUsersOnly,shareRidesWithSameGenderUsersOnly{
                    isGenderFilterApplyed = true
                    isChangesFromSettings = true
                }
                cell.initializeSwitch(filterType: Strings.same_gender_only, status: isGenderFilterApplyed, tag: indexPath.row, changesFromSettings: isChangesFromSettings, viewController: self, delegate: self)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingTableViewCell
                cell.delegate = self
                cell.setupRatingView(selectedRating: Int(topViewController?.status[DynamicFiltersCache.MINIMUM_RATING_CRITERIA] ?? "") ?? -1)
                return cell
            }
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchTypeTableViewCell", for: indexPath) as! FilterSwitchTypeTableViewCell
            var isGenderFilterApplyed = false
            var isChangesFromSettings = false
            if topViewController?.status[DynamicFiltersCache.GENDER_CRITERIA] == UserDataCache.getInstance()?.getCurrentUserGender(){
                isGenderFilterApplyed = true
            }else if let shareRidesWithSameGenderUsersOnly = securityPreferences?.shareRidesWithSameGenderUsersOnly,shareRidesWithSameGenderUsersOnly{
                isGenderFilterApplyed = true
                isChangesFromSettings = true
            }
            cell.initializeSwitch(filterType: Strings.same_gender_only, status: isGenderFilterApplyed, tag: indexPath.row, changesFromSettings: isChangesFromSettings, viewController: self,delegate: self)
            return cell
        default: break
        }
        return UITableViewCell()
    }
    private func getTimeRange() -> String{
        if let timeRange = topViewController?.status[DynamicFiltersCache.TIME_RANGE_CRITERIA]{
            return timeRange
        }else{
            guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()else { return DynamicFiltersCache.timeRangeList[0] }
            let timeRange = ridePreferences.rideMatchTimeThreshold
            if timeRange > 0 && timeRange <= 15{
                return DynamicFiltersCache.timeRangeList[0]
            }else if timeRange > 15 && timeRange <= 30{
                return DynamicFiltersCache.timeRangeList[1]
            }else if timeRange > 30 && timeRange <= 45{
                return DynamicFiltersCache.timeRangeList[2]
            }else if timeRange > 45 && timeRange <= 60{
                return DynamicFiltersCache.timeRangeList[3]
            }else if timeRange > 60 && timeRange <= 90{
                return DynamicFiltersCache.timeRangeList[4]
            }else if timeRange > 90 && timeRange <= 120{
                return DynamicFiltersCache.timeRangeList[5]
            }else{
                return DynamicFiltersCache.timeRangeList[0]
            }
        }
    }
}

//MARK: UITableViewDelegate
extension RideFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: TimeRangeTableViewCellDelagate
extension RideFilterViewController: TimeRangeTableViewCellDelagate{
    func timeRangeSelected(time: String) {
        topViewController?.status[DynamicFiltersCache.TIME_RANGE_CRITERIA] = time
    }
}

//MARK: FilterSwitchTypeTableViewCellDelegate
extension RideFilterViewController: FilterSwitchTypeTableViewCellDelegate {
    func setFilterToggle(status: Bool, index: Int) {
        switch index {
        case 2:
            if status{
                topViewController?.status[DynamicFiltersCache.USERS_CRITERIA] = DynamicFiltersCache.PREFERRED_USERS_VERIFIED
            }else{
                topViewController?.status[DynamicFiltersCache.USERS_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
            }
        case 3:
            if status{
                topViewController?.status[DynamicFiltersCache.EXISTANCE_CRITERIA] = DynamicFiltersCache.ACTIVE_USERS
            }else{
                topViewController?.status[DynamicFiltersCache.EXISTANCE_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
            }
        case 4:
            if status{
                topViewController?.status[DynamicFiltersCache.PARTNERS_CRITERIA] = DynamicFiltersCache.FAVOURITE_PARTNERS
            }else{
                topViewController?.status[DynamicFiltersCache.PARTNERS_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
            }
        case 6,7:
            if status{
                topViewController?.status[DynamicFiltersCache.GENDER_CRITERIA] = UserDataCache.getInstance()?.getCurrentUserGender()
            }else{
                topViewController?.status[DynamicFiltersCache.GENDER_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
            }
        default: break
        }
        topViewController?.showClearFilterButtonIfFilterApplied()
    }
    
}

//MARK: TimeRangeTableViewCellDelagate
extension RideFilterViewController: RatingTableViewCellDelegate{
    func ratingButtonTapped(rating: Int) {
        topViewController?.status[DynamicFiltersCache.MINIMUM_RATING_CRITERIA] = String(rating)
        topViewController?.showClearFilterButtonIfFilterApplied()
    }
}

//MARK: VehicleFilterTableViewCellDelegate
extension RideFilterViewController: VehicleFilterTableViewCellDelegate{
    func selectedVehicleOption(vehicleType: String) {
        topViewController?.status[DynamicFiltersCache.VEHICLE_CRITERIA] = vehicleType
        topViewController?.showClearFilterButtonIfFilterApplied()
    }
}

//MARK: RouteMatchTableViewCellDelegate
extension RideFilterViewController: RouteMatchTableViewCellDelegate {
    func selectedRouteMatchPercentage(precentage: String) {
        topViewController?.status[DynamicFiltersCache.ROUTE_MATCH_CRITERIA] = precentage
    }
    
    func routeMatchViaPoint(routeMatchPoint: String?) {
        topViewController?.status[DynamicFiltersCache.ROUTE_POINT_CRITERIA] = routeMatchPoint
    }
}
