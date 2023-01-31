//
//  ProfileVerificationCategory.swift
//  Quickride
//
//  Created by Vinutha on 03/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ProfileVerificationCategory {
    
    var type: String?
    var imageName: String?
    var status: Bool?
    var name: String?
    
    init(type: String?, imageName: String?, status: Bool?, name: String?) {
        self.type = type
        self.imageName = imageName
        self.status = status
        self.name = name
    }
}
