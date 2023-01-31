//
//  RelayRideNsNotification.swift
//  Quickride
//
//  Created by Vinutha on 18/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension Notification.Name{
    static let firstRideCreated = NSNotification.Name("firstRideCreated")
    static let firstRideCreationFailed = NSNotification.Name("firstRideCreationFailed")
    static let secondRideCreated = NSNotification.Name("secondRideCreated")
    static let secondRideCreationFailed = NSNotification.Name("secondRideCreationFailed")
    static let firstInviteSent = NSNotification.Name("firstInviteSent")
    static let firstInviteFailed = NSNotification.Name("firstInviteFailed")
    static let secondInviteSent = NSNotification.Name("secondInviteSent")
    static let secondInviteFailed = NSNotification.Name("secondInviteFailed")
}
