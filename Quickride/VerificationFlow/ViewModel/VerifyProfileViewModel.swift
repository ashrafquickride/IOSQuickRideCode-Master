//
//  VerifyProfileViewModel.swift
//  Quickride
//
//  Created by Vinutha on 08/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class VerifyProfileViewModel {

    //MARK: Properties
    var endorsementVerificationInfo = [EndorsementVerificationInfo]()
    var endorsementVerifiedUser = [EndorsementVerificationInfo]()
    
    //MARK: Methods
    func filterOnlyEndorsementVerifiedUser(endorsementVerificationInfo: [EndorsementVerificationInfo]) {
        endorsementVerifiedUser.removeAll()
        for endorsementVerification in endorsementVerificationInfo {
            if endorsementVerification.endorsedBy != nil &&  endorsementVerification.endorsementStatus == EndorsableUser.STATUS_VERIFIED {
                endorsementVerifiedUser.append(endorsementVerification)
            } else {
                continue
            }
        }
    }
}
