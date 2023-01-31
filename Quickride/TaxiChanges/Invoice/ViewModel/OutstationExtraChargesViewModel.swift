//
//  OutstationExtraChargesViewModel.swift
//  Quickride
//
//  Created by HK on 28/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class OutstationExtraChargesViewModel{
    
    var outstationTaxiFareDetails: PassengerFareBreakUp?
    var showDriverAddedChanges = false
    
    init(outstationTaxiFareDetails: PassengerFareBreakUp,showDriverAddedChanges: Bool) {
        self.outstationTaxiFareDetails = outstationTaxiFareDetails
        self.showDriverAddedChanges = showDriverAddedChanges
    }
    init() {}
}
