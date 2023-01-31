//
//  RecurringRideNsNotifications.swift
//  Quickride
//
//  Created by Vinutha on 29/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension NSNotification.Name{
    static let editDaysAndTime = NSNotification.Name("editDaysAndTime")
    static let rideStatusChanged = NSNotification.Name("rideStatusChanged")
    static let deleteRideTapped = NSNotification.Name("deleteRideTapped")
    static let recurringRideStatusUpdated = NSNotification.Name("recurringRideStatusUpdated")
    static let recurringRideStatusUpdateFailed = NSNotification.Name("recurringRideStatusUpdateFailed")
    static let unjoiningSucess = NSNotification.Name("unjoiningSucess")
    static let changeRideTime = NSNotification.Name("changeRideTime")
    static let refreshRides = NSNotification.Name("refreshRides")
}
