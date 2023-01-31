//
//  InviteTaxiPoolViewModel.swift
//  Quickride
//
//  Created by Ashutos on 8/7/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class InviteTaxiPoolViewModel {
    var matchedPassengerList: [MatchedPassenger]?
    var taxiShareRide: TaxiShareRide?
    var ride: Ride?
    var allInvitedUsers: [TaxiInviteEntity]? = []
    init(taxiShareRide: TaxiShareRide?,ride: Ride?) {
        self.taxiShareRide = taxiShareRide
        self.ride = ride
    }
    
    func getMatchingList(completionHandler: @escaping(_ result: Bool)->()) {
        guard let ride = ride else {return}
        MatchedPassengerTaxiCache.getInstance().getAllMatchedPassengers(ride: ride) { [weak self] (data, error) in
            if data != nil && data != [] {
                self?.matchedPassengerList = data
                completionHandler(true)
            }else {
               completionHandler(false)
            }
        }
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
