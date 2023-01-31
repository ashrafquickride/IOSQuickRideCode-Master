//
//  RideSortByViewModel.swift
//  Quickride
//
//  Created by Bandish Kumar on 04/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideSortByViewModel {
    
    //MARK:Variable
    var rideType : String?
    var sortOptions = [String]()
    var selectedIndex = 0
    
    func initailizeSortOptionsAvailableSortOption(status: [String : String]){
        if rideType == Ride.RIDER_RIDE{
            sortOptions = Strings.sort_matching_list_titles_rider
        }else{
            sortOptions = Strings.sort_matching_list_titles
        }
        setUpSelectedSortOption(status: status)
    }
    
    private func setUpSelectedSortOption(status: [String : String]){
        if rideType == Ride.RIDER_RIDE{
            switch status[DynamicFiltersCache.SORT_CRITERIA] {
            case DynamicFiltersCache.SORT_ROUTE_PERCENTAGE_DESCENDING:
                selectedIndex = 1
            case DynamicFiltersCache.SORT_POINTS_DESCENDING:
                selectedIndex = 2
            case DynamicFiltersCache.SORT_BASED_ON_LAST_RESPONSE:
                selectedIndex = 3
            case DynamicFiltersCache.SORT_PICK_UP_TIME_IN_ASCENDING:
                selectedIndex = 4
            default:
                selectedIndex = 0
            }
        }else{
            switch status[DynamicFiltersCache.SORT_CRITERIA] {
            case DynamicFiltersCache.SORT_ROUTE_PERCENTAGE_DESCENDING:
                selectedIndex = 1
            case DynamicFiltersCache.SORT_POINTS_ASCENDING:
                selectedIndex = 2
            case DynamicFiltersCache.SORT_BASED_ON_LAST_RESPONSE:
                selectedIndex = 3
            case DynamicFiltersCache.SORT_BASED_ON_PICKUP_POINT_DISTANCE:
                selectedIndex = 4
            case DynamicFiltersCache.SORT_PICK_UP_TIME_IN_ASCENDING:
                selectedIndex = 5
            default:
                selectedIndex = 0
            }
        }
    }
    
    func assignNewSelectedSortOption(index: Int) -> String?{
        if rideType == Ride.RIDER_RIDE{
            switch index {
            case 1:
                return DynamicFiltersCache.SORT_ROUTE_PERCENTAGE_DESCENDING
            case 2:
                return DynamicFiltersCache.SORT_POINTS_DESCENDING
            case 3:
                return DynamicFiltersCache.SORT_BASED_ON_LAST_RESPONSE
            case 4:
                return DynamicFiltersCache.SORT_PICK_UP_TIME_IN_ASCENDING
            default:
                return nil
            }
        }else{
            switch index{
            case 1:
                return DynamicFiltersCache.SORT_ROUTE_PERCENTAGE_DESCENDING
            case 2:
                return DynamicFiltersCache.SORT_POINTS_ASCENDING
            case 3:
                return DynamicFiltersCache.SORT_BASED_ON_LAST_RESPONSE
            case 4:
                return DynamicFiltersCache.SORT_BASED_ON_PICKUP_POINT_DISTANCE
            case 5:
                return DynamicFiltersCache.SORT_PICK_UP_TIME_IN_ASCENDING
            default:
                return nil
            }
        }
    }
}
