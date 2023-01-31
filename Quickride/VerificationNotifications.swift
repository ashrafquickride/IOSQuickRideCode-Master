//
//  VerificationNotifications.swift
//  Quickride
//
//  Created by Halesh on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension Notification.Name{
    static let companyDomainStatusReceived = NSNotification.Name("companyDomainStatusReceived")
    static let companyDomainStatusFailed = NSNotification.Name("companyDomainStatusFailed")
    static let userProfileUpatedWithOrgEmail = NSNotification.Name("userProfileUpatedWithOrgEmail")
    static let userProfileUpatedFailed = NSNotification.Name("userProfileUpatedFailed")
}
