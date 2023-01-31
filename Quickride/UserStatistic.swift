//
//  UserStatistic.swift
//  Quickride
//
//  Created by Vinutha on 24/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserStatistic {
    
    var imageName: String?
    var title: String?
    var value1: String?
    var value2: String?
    
    init(imageName: String, title: String, value1: String, value2: String?) {
        self.imageName = imageName
        self.title = title
        self.value1 = value1
        self.value2 = value2
    }
}
