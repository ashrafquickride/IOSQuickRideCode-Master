//
//  RidesProtocol.swift
//  Quickride
//
//  Created by KNM Rao on 11/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

 protocol ActiveRidesCacheInitializationStatusListener {
  func initializationCompleted()
  func initializationFailed(error : ResponseError?)
}

 protocol MyRidesCacheListener {
  func receivedActiveRides(activeRiderRides : [Double : RiderRide], activePassengerRides :  [Double : PassengerRide])
  func receiveClosedRides(closedRiderRides : [Double : RiderRide], closedPassengerRides :  [Double : PassengerRide])
   func receiveActiveRegularRides(regularRiderRides : [Double : RegularRiderRide], regularPassengerRides :  [Double : RegularPassengerRide] )
  func receiveRideDetailInfo(rideDetailInfo : RideDetailInfo)
    func onRetrievalFailure(responseError : ResponseError?, error :NSError?)
}

 protocol RideParticipantsListener {
  func getRideParticipants(rideParticipants : [RideParticipant])
  func onFailure(responseObject: NSDictionary?, error: NSError?)
}

 protocol RidesInformationReceiver {
  func receiveRideDetailInfo()
  func rideDetailInfoRetrievalFailed()
}

 protocol RideParticipantLocationListener : class{
  func receiveRideParticipantLocation(rideParticipantLocation : RideParticipantLocation)
}

 protocol RideUpdateListener : class {
  func participantStatusUpdated(rideStatus : RideStatus)
  func participantRideRescheduled(rideStatus : RideStatus)
  func participantUpdated(rideParticipant : RideParticipant)
  func receiveRideDetailInfo(rideDetailInfo : RideDetailInfo)
  func refreshRideView()
  func handleUnfreezeRide()
}
