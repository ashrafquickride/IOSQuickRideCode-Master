//
//  ConfirmCarpoolPickupOrDropPointViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ConfirmCarpoolPickupOrDropPointViewModel {
    
    var riderRoutePolyline: String?
    var matchedUser: MatchedUser?
    var passengerRideId: Double?
    var riderRideId: Double?
    var passengerId: Double?
    var riderId: Double?
    var noOfSeats = 1
    var delegate: PickUpAndDropSelectionDelegate?
    
    init(matchedUser: MatchedUser,riderRoutePolyline : String,delegate : PickUpAndDropSelectionDelegate, passengerRideId :Double?,riderRideId : Double?,passengerId :Double?,riderId : Double?,noOfSeats : Int){
        self.matchedUser = matchedUser
        self.passengerRideId = passengerRideId
        self.riderRideId = riderRideId
        self.passengerId = passengerId
        self.riderId = riderId
        self.delegate = delegate
        self.noOfSeats = noOfSeats
        self.riderRoutePolyline = riderRoutePolyline
    }
    
    init() {}
    
    func getRideMatchMetricsForNewPickupDrop(preferredPickupDrop: UserPreferredPickupDrop?, viewController: UIViewController) {
        QuickRideProgressSpinner.startSpinner()
        let rideMatchMetricsForNewPickupDropTask = RideMatchMetricsForNewPickupDropTask(riderRideId: riderRideId!, passengerRideId: passengerRideId!,riderId: riderId!,passengerId: passengerId!, pickupLat: matchedUser!.pickupLocationLatitude!, pickupLng: matchedUser!.pickupLocationLongitude!, dropLat: matchedUser!.dropLocationLatitude!, dropLng: matchedUser!.dropLocationLongitude!, noOfSeats: noOfSeats, viewController: viewController)
        rideMatchMetricsForNewPickupDropTask.getRideMatchMetricsForNewPickupDrop { (rideMatchMetrics,responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if rideMatchMetrics != nil{
                
                self.matchedUser!.distance = rideMatchMetrics!.distanceOnRiderRoute
                if(self.matchedUser!.userRole == MatchedUser.PASSENGER) {
                    self.matchedUser!.matchPercentage = rideMatchMetrics!.matchPercentOnRiderRoute
                    self.matchedUser!.matchPercentageOnMatchingUserRoute = rideMatchMetrics!.matchPercentOnPassengerRoute
                    
                }else if self.matchedUser!.userRole == MatchedUser.RIDER {
                    self.matchedUser!.matchPercentage = rideMatchMetrics!.matchPercentOnPassengerRoute
                    self.matchedUser!.matchPercentageOnMatchingUserRoute = rideMatchMetrics!.matchPercentOnRiderRoute
                    
                }else {
                    self.matchedUser!.matchPercentage = rideMatchMetrics!.matchPercentOnRiderRoute
                    
                }
                if self.matchedUser!.ridePassId == 0 {
                    self.matchedUser!.points = rideMatchMetrics!.points
                }
                self.matchedUser!.pickupTime = rideMatchMetrics!.pickUpTime
                self.matchedUser!.dropTime = rideMatchMetrics!.dropTime
            }
            self.delegate?.pickUpAndDropChanged(matchedUser: self.matchedUser!, userPreferredPickupDrop: preferredPickupDrop)
            viewController.navigationController?.popViewController(animated: false)
        }
    }
}
