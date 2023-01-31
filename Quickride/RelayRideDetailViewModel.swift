//
//  RelayRideDetailViewModel.swift
//  Quickride
//
//  Created by Vinutha on 17/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation


class RelayRideDetailViewModel{
    
    var stopOverZoomState = RideDetailMapViewModel.ZOOMED_OUT
    
  //MARK: Variables
    var ride = Ride()
    var relayRideMatchs = [RelayRideMatch]()
    var numberOfSeatsImageArray = [UIImageView]()
    var secondRiderSeatsImageArray = [UIImageView]()
    var selectedIndex = 0
    
    init(ride: Ride,relayRideMatchs: [RelayRideMatch],selectedIndex: Int) {
        self.ride = ride
        self.relayRideMatchs = relayRideMatchs
        self.selectedIndex = selectedIndex
    }
    
    init() {
        
    }
    
    func getDistanceString( distance: Double) -> String {
        if distance > 1000{
            var convertDistance = (distance/1000)
            let roundTodecimalTwoPoints = convertDistance.roundToPlaces(places: 1)
            return "\(roundTodecimalTwoPoints) \(Strings.KM)"
        } else {
            let roundTodecimalTwoPoints = Int(distance)
            return "\(roundTodecimalTwoPoints) \(Strings.meter)"
        }
    }
}




