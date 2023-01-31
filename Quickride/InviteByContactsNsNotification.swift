//
//  InviteByContactsNsNotification.swift
//  Quickride
//
//  Created by Vinutha on 03/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension NSNotification.Name{
    static let bestMatchAlertTapped = NSNotification.Name("bestMatchAlertTapped")
    static let inviteRidePartnerContactTapped = NSNotification.Name("inviteRidePartnerContactTapped")
    static let contactInviteResponse = NSNotification.Name("contactInviteResponse")
    
    //contcts
    static let contactInviteTapped = NSNotification.Name("contactInviteTapped")
    static let contactPermission = NSNotification.Name("contactPermission")
    static let contactsFetchingFailed = NSNotification.Name("contactsFetchingFailed")
    static let noContactsToDisplay = NSNotification.Name("noContactsToDisplay")
    static let contactsLoaded = NSNotification.Name("contactsLoaded")
    static let inviteContactSuccess = NSNotification.Name("inviteContactSuccess")
    static let inviteContactfailed = NSNotification.Name("inviteContactfailed")
}
