//
//  TravelledRouteSavingViewModel.swift
//  Quickride
//
//  Created by Vinutha on 21/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class TravelledRouteSavingViewModel {
    
    //MARK: Properties
    var riderRide: RiderRide?
    var newRoute: RideRoute?
    
    //MARK: Initialiser
    func initialiseData(riderRide: RiderRide, newRoute: RideRoute) {
        self.riderRide = riderRide
        self.newRoute = newRoute
    }
    
    //MARK: Methods
    func extractViaPoints(wayPoints: String) -> [Location]? {
        return Mapper<Location>().mapArray(JSONString: wayPoints)
    }
}
