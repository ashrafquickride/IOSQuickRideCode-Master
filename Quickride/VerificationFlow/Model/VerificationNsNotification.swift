//
//  VerificationNsNotification.swift
//  Quickride
//
//  Created by Vinutha on 08/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension NSNotification.Name {
    static let getEndorsementVerificationDataSucceded = NSNotification.Name("getEndorsementVerificationDataSucceded")
    static let reloadEndoserTableView = NSNotification.Name("reloadEndoserTableView")
    static let endoserRequestTapped = NSNotification.Name("endoserRequestTapped")
    static let endoserRequestSucceded = NSNotification.Name("endoserRequestSucceded")
    static let endorsementRequestAccepted = NSNotification.Name("endorsementRequestAccepted")
    static let endorsementRequestRejected = NSNotification.Name("endorsementRequestRejected")
    static let personalIdDetailStored = NSNotification.Name("personalIdDetailStored")
    static let personalIdDetailStoringFailed = NSNotification.Name("personalIdDetailStoringFailed")
    static let organisationIdImageSavingSucceded = NSNotification.Name("organisationIdImageSavingSucceded")
    static let organisationIdImageSavingFailed = NSNotification.Name("organisationIdImageSavingFailed")
    static let organisationIdVerificationInitiated = NSNotification.Name("organisationIdVerificationInitiated")
}
