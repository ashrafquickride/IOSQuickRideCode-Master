//
//  NSNotificationName+UserDetailForRiderAndPassengerCard.swift
//  Quickride
//
//  Created by Quick Ride on 7/14/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
extension NSNotification.Name
{
    static let matchedUsersToInviteResult = NSNotification.Name("matchedUsersToInviteResult")
    static let rideMatchesUpdated = NSNotification.Name("rideMatchesUpdated")
    static let selectedPassengerChanged = NSNotification.Name("selectedPassengerChanged")
    static let passengerChangedPickup = NSNotification.Name("passengerChangedPickup")
    static let rideUpdated = NSNotification.Name("rideUpdated")
    static let linkedWalletAdded = NSNotification.Name("linkedWalletAdded")
    static let freezeRideUpdated = NSNotification.Name("freezeRideUpdated")
    static let rideModerationStatusChanged = NSNotification.Name("rideModerationStatusChanged")
    static let taxiInvitationReceived = Notification.Name("taxiInvitationReceived")
    static let passengerPickedUp = Notification.Name("passengerPickedUp")
    static let passengerPickedUpRideStartedStatus = Notification.Name("passengerPickedUpRideStartedStatus")
    static let outStationViewTaxiDetail = Notification.Name("outStationViewTaxiDetail")
    static let receivedPassengerETAInfo = Notification.Name("receivedPassengerETAInfo")
    static let updateUiWithNewData = Notification.Name("updateUiWithNewData")
}
