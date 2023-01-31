//
//  RideSortByViewController.swift
//  Quickride
//
//  Created by Bandish Kumar on 04/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideSortByViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var sortByTableView: UITableView!
    
    //Mark: Properties
    lazy var rideSortByViewModel: RideSortByViewModel = {
        return RideSortByViewModel()
    }()
    weak var topViewController: RideFilterBaseViewController?
    
    override func viewDidLoad() {
        getSortAndFilterStatus()
        rideSortByViewModel.rideType = topViewController?.rideType
        rideSortByViewModel.initailizeSortOptionsAvailableSortOption(status: topViewController!.status)
    }
    private func getSortAndFilterStatus(){
        if let rideId = topViewController?.rideId,let rideType = topViewController?.rideType, let statusFromCache = DynamicFiltersCache.getInstance().getDynamicFiltersStatusForRide(rideId: rideId, rideType: rideType){
            topViewController?.status = statusFromCache
        }
    }
}

//MARK: UITableViewDataSource
extension RideSortByViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideSortByViewModel.sortOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SortRideMatchTableViewCell
        if rideSortByViewModel.sortOptions.endIndex <= indexPath.row{
            return cell
        }
        var isimageSelected = false
        if rideSortByViewModel.selectedIndex == indexPath.row{
            isimageSelected = true
        }
        cell.initializeViews(optionTitle: rideSortByViewModel.sortOptions[indexPath.row], imageSelected: isimageSelected)
        return cell
    }
}

//MARK: UITableViewDelegate
extension RideSortByViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedIndex = tableView.cellForRow(at: indexPath) as? SortRideMatchTableViewCell{
            selectedIndex.selectionImage.image = UIImage(named: "ic_radio_button_checked")
            selectedIndex.sortOptionTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            selectedIndex.sortOptionTitle.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            topViewController?.status[DynamicFiltersCache.SORT_CRITERIA] = rideSortByViewModel.assignNewSelectedSortOption(index: indexPath.row)
        }
        if let prevSelectedIndex = tableView.cellForRow(at: IndexPath(item: rideSortByViewModel.selectedIndex, section: 0)) as? SortRideMatchTableViewCell{
            if rideSortByViewModel.selectedIndex != indexPath.row{
                prevSelectedIndex.selectionImage.image = UIImage(named: "radio_button_1")
                prevSelectedIndex.sortOptionTitle.font = UIFont(name: "HelveticaNeue", size: 14)
                prevSelectedIndex.sortOptionTitle.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
            }
        }
        rideSortByViewModel.selectedIndex = indexPath.row
        topViewController?.showClearFilterButtonIfFilterApplied()
    }
}
