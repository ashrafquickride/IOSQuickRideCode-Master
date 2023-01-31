//
//  RentalPackageEstimate.swift
//  Quickride
//
//  Created by Rajesab on 22/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RentalPackageEstimate {
    var packageDistance: Int
    var packageDuration: Int
    var rentalPackageConfigList: [RentalPackageConfig]
    
    init(packageDistance: Int, packageDuration: Int ) {
        self.packageDistance = packageDistance
        self.packageDuration = packageDuration
        self.rentalPackageConfigList = []
    }
}
