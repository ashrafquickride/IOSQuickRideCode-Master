//
//  MatchingOptionNsNotifications.swift
//  Quickride
//
//  Created by Vinutha on 11/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension NSNotification.Name{
    static let bestMatchAlertCreated = NSNotification.Name("bestMatchAlertCreated")
    static let bestMatchAlertCreationFailed = NSNotification.Name("bestMatchAlertCreationFailed")
    static let cancelRideInvitationSuccess = NSNotification.Name("cancelRideInvitationSuccess")
    static let cancelRideInvitationFailed = NSNotification.Name("cancelRideInvitationFailed")
    static let receivedRidePresentLocation = NSNotification.Name("receivedRidePresentLocation")
    static let clearFilters = NSNotification.Name("clearFilters")
    static let receivedRelayRides = NSNotification.Name("receivedRelayRides")
    static let loadMore = NSNotification.Name("loadMore")
}
