//
//  RideCancellationFeeViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 22/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol RideCancellationFeeViewModelDelegate {
    func handleSuccessResponse()
}

class RideCancellationFeeViewModel{
    
    var compensations = [Compensation]()
    var rideType: String?
    var isFromCancelRide = true
    var ride: Ride?
    var reason = ""
    var completionHandler : rideCancellationCompletionHandler?
    
    //Unjoin
    var riderRideId : Double?
    var unjoiningUserRideId : Double?
    var unjoiningUserId : Double?
    var unjoiningUserRideType : String?
    
    //fee applicable data
    var noOfSeatCancellation = 0
    var noOfFreeCancellation = 0
    var cancellationAmount = 0
    var isUserSelectWaiveOff = false
    var oppositeUserRideType = ""
    var validityOfFreeCancellations = 0
    
    func initialiseData(ride: Ride?, rideType: String,isFromCancelRide: Bool,compensation: [Compensation], reason: String, riderRideId : Double?,unjoiningUserRideId : Double?,unjoiningUserId : Double?, unjoiningUserRideType : String?,completionHandler : rideCancellationCompletionHandler?){
        self.compensations = compensation
        self.rideType = rideType
        self.isFromCancelRide = isFromCancelRide
        self.ride = ride
        self.reason = reason
        self.completionHandler = completionHandler
        self.riderRideId = riderRideId
        self.unjoiningUserRideId = unjoiningUserRideId
        self.unjoiningUserId = unjoiningUserId
        self.unjoiningUserRideType = unjoiningUserRideType
    }
    
    func assignOppositeUserRideType(){
        if rideType == Ride.RIDER_RIDE{
            oppositeUserRideType = "ride taker"
        }else{
            oppositeUserRideType = "ride giver"
        }
    }
    func preapreApplicableFeeData(){
        noOfSeatCancellation = compensations.count
        for compension in compensations{
            if compension.freeCancellationsAvailable > noOfFreeCancellation{
                noOfFreeCancellation = compension.freeCancellationsAvailable
            }
            validityOfFreeCancellations = compension.validityOfFreeCancellations
            cancellationAmount = Int(compension.compensationAmount)
        }
        cancellationAmount = cancellationAmount * (noOfSeatCancellation - noOfFreeCancellation)
    }
    
    func cancelRide(viewController : UIViewController, delegate: RideCancellationFeeViewModelDelegate){
        guard let rideObj = ride else { return }
        RideCancelActionProxy.cancelRide(ride: rideObj, cancelReason: reason, isWaveOff: isUserSelectWaiveOff,viewController: viewController, handler: {
            delegate.handleSuccessResponse()
        })
    }
    
    
    func unJoinRide(viewController : UIViewController,delegate: RideCancellationFeeViewModelDelegate){
        RideCancelActionProxy.unjoinParticipant(riderRideId: riderRideId ?? 0, passengerRIdeId: unjoiningUserRideId ?? 0, passengerUserId: unjoiningUserId ?? 0, rideType: unjoiningUserRideType ?? "", cancelReason : reason, isWaveOff: isUserSelectWaiveOff,viewController: viewController, completionHandler: {_,_ in
            delegate.handleSuccessResponse()
        })
    }
}
