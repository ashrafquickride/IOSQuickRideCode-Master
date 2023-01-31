//
//  TaxiRideDetailsForInViteViewModel.swift
//  Quickride
//
//  Created by Ashutos on 9/15/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class TaxiRideDetailsForInViteViewModel {
    var selectedIndex = 0
    var matchedPassengerRide = [MatchedPassenger]()
    var taxiShareRide: TaxiShareRide?
    var ride: Ride?
    var allInvitedUsers: [TaxiInviteEntity]?
    var pickupZoomState = ZOOMED_OUT
    var dropZoomState = ZOOMED_OUT
    var isOverlappingRouteDrawn = false
    var pickUpOrDropNavigation: String?
    let MIN_TIME_DIFF_CURRENT_LOCATION = 10
    
    static let ZOOMED_IN = "ZOOMIN"
    static let ZOOMED_OUT = "ZOOMOUT"
    
    init(selectedIndex: Int,matchedPassengerRide: [MatchedPassenger],taxiShareRide: TaxiShareRide,ride: Ride? ,allInvitedUsers: [TaxiInviteEntity]?) {
        self.selectedIndex = selectedIndex
        self.matchedPassengerRide = matchedPassengerRide
        self.taxiShareRide = taxiShareRide
        self.ride = ride
        self.allInvitedUsers = allInvitedUsers
    }
    
    func getInvitedList(completionHandler: @escaping(_ result: Bool)->()) {
        TaxiPoolInvitationCache.getInstance().getAllInvitesForRide(rideId: ride?.rideId ?? 0.0) {[weak self] (data, error) in
            if data != [] {
                self?.allInvitedUsers = data
                completionHandler(true)
            }
        }
    }
}
