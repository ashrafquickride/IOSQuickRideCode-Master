//
//  AppStoreRatingViewModel.swift
//  Quickride
//
//  Created by Ashutos on 30/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AppStoreRatingViewModel {
    
    var viewShowingStatus: Int?
    static let DAYS_AFTER_APPSTORE_POPUP_SHOULD_SHOW = 24*60*90
    
    func setPopShowingDate() {
        SharedPreferenceHelper.setLikingTheAppPopupShownDate(time: NSDate())
    }
    
    func getAppStoreRatingShownDateStatus() -> Bool {
        let lastDisplayedDate = SharedPreferenceHelper.getRatingPopUpShownDate()
        if lastDisplayedDate == nil || DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastDisplayedDate!) > AppStoreRatingViewModel.DAYS_AFTER_APPSTORE_POPUP_SHOULD_SHOW {
            return true// show the App store ratingView after 90 days
        }
        return false
    }
    
    func setAppStoreRatingShownDate() {
        SharedPreferenceHelper.setRatingPopUpShownDate(time: NSDate())
    }
    
    func setSkipDate() {
        SharedPreferenceHelper.setSkipRatingDate(time: NSDate())
    }
}
