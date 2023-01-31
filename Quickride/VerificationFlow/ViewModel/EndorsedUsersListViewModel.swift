//
//  EndorsedUsersListViewModel.swift
//  Quickride
//
//  Created by Vinutha on 14/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EndorsedUsersListViewModel {

    //MARK: Properties
    var endorsedUserInfo = [EndorsementVerificationInfo]()

    //MARK: Initialiser
    func initialiseData(endorsedUserInfo: [EndorsementVerificationInfo]) {
        self.endorsedUserInfo = endorsedUserInfo
    }
}
