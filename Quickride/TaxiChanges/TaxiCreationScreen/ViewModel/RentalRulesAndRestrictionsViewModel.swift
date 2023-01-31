//
//  RentalRulesAndRestrictionsViewModel.swift
//  Quickride
//
//  Created by Rajesab on 01/03/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RentalRulesAndRestrictionsViewModel {
    var rentalPackageConfig: [RentalPackageConfig]?
    
    init(rentalPackageConfig: [RentalPackageConfig]?){
        self.rentalPackageConfig = rentalPackageConfig
    }
    init(){
        
    }
}
