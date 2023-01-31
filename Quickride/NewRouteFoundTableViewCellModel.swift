//
//  NewRouteFoundTableViewCellModel.swift
//  Quickride
//
//  Created by Vinutha on 22/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class NewRouteFoundTableViewCellModel {
    
    //MARK: Properties
    var newRoute: RideRoute?
    var riderRide: RiderRide?
    
    //MARK: Initialiser
    func initialiseData(newRoute: RideRoute?, riderRide: RiderRide?) {
        self.newRoute = newRoute
        self.riderRide = riderRide
    }
}
