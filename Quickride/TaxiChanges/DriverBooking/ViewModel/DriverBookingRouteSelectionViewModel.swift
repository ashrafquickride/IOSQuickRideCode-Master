//
//  DriverBookingRouteSelectionViewModel.swift
//  Quickride
//
//  Created by HK on 01/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class DriverBookingRouteSelectionViewModel {
    
    var startLocation: Location?
    var endLocation: Location?
    var carType = Strings.hatchBack
    var selectedRouteId = -1.0
    var distance = 0.0
    var MAP_ZOOM : Float = 15
    var isRoundTrip = false
    var startTime = NSDate().getTimeStamp()
    var rideTypes = [CommuteSubSegment(name: Strings.one_way,type: TaxiPoolConstants.JOURNEY_TYPE_ONE_WAY), CommuteSubSegment(name: Strings.round_trip,type: TaxiPoolConstants.JOURNEY_TYPE_ROUND_TRIP)]
}
