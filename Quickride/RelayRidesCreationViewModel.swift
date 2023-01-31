//
//  RelayRidesCreationViewModel.swift
//  Quickride
//
//  Created by Vinutha on 18/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RelayRidesCreationViewModel {
    
    var parentRide: Ride?
    var firstRide: PassengerRide?
    var secondRide: PassengerRide?
    var relayRideMatch: RelayRideMatch?
    var rideCreationFailed: String?
    
    static let CREATING_FIRST_RIDE = "CREATING_FIRST_RIDE"
    static let FIRST_RIDE_CREATED = "FIRST_RIDE_CREATED"
    static let SENDING_FIRST_INVITATION = "SENDING_FIRST_INVITATION"
    static let FIRST_INVITATION_SENT = "FIRST_INVITATION_SENT"
    static let CREATING_SECOND_RIDE = "CREATING_SECOND_RIDE"
    static let SECOND_RIDE_CREATED = "SECOND_RIDE_CREATED"
    static let SENDING_SECOND_INVITATION = "SENDING_SECOND_INVITATION"
    static let SECOND_INVITATION_SENT = "SECOND_INVITATION_SENT"
    static let FIRST_RIDE_CREATION_FAILED = "FIRST_RIDE_CREATION_FAILED"
    static let SECOND_RIDE_CREATION_FAILED = "SECOND_RIDE_CREATION_FAILED"
    
    init(parentRide: Ride,relayRideMatch: RelayRideMatch) {
        self.parentRide = parentRide
        self.relayRideMatch = relayRideMatch
    }
    
    init() {
        
    }
    
    func createFirstRide(viewController: UIViewController){
        AppDelegate.getAppDelegate().log.debug("createFirstPassengerRide")
        let matchedRider = relayRideMatch?.firstLegMatch
        let ride = Ride(userId: Double(QRSessionManager.getInstance()?.getUserId() ?? "") ?? 0, rideType: Ride.PASSENGER_RIDE, startAddress: parentRide?.startAddress ?? "", startLatitude: parentRide?.startLatitude ?? 0, startLongitude: parentRide?.startLongitude ?? 0, endAddress: matchedRider?.dropLocationAddress ?? "", endLatitude: matchedRider?.dropLocationLatitude ?? 0, endLongitude: matchedRider?.dropLocationLongitude ?? 0, startTime: parentRide?.startTime ?? 0)
        let passengerRide = PassengerRide(ride: ride)
        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: matchedRider?.dropTime, time2: parentRide?.startTime)
        let rideRoute = RideRoute(routeId: matchedRider?.routeId ?? 0,overviewPolyline : matchedRider?.routePolyline ?? "",distance :matchedRider?.distance ?? 0,duration : Double(duration), waypoints : nil)
        
        passengerRide.noOfSeats = (ride as? PassengerRide)?.noOfSeats ?? 1
        let createPassengerRideHandler = CreatePassengerRideHandler(ride: passengerRide,rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: viewController, parentRideId: parentRide?.rideId,relayLegSeq: 1)
        createPassengerRideHandler.createPassengerRide(handler: { (passengerRide, error) -> Void in
            if passengerRide != nil{
                self.firstRide = passengerRide
                NotificationCenter.default.post(name: .firstRideCreated, object: self)
            }else{
                self.rideCreationFailed = RelayRidesCreationViewModel.FIRST_RIDE_CREATION_FAILED
                NotificationCenter.default.post(name: .firstRideCreationFailed, object: self)
            }
        })
    }
    
    func createSecondRide(viewController: UIViewController){
        AppDelegate.getAppDelegate().log.debug("createSecondPassengerRide")
        let matchedRider = relayRideMatch?.secondLegMatch
        let ride = Ride(userId: Double(QRSessionManager.getInstance()?.getUserId() ?? "") ?? 0, rideType: Ride.PASSENGER_RIDE, startAddress: matchedRider?.pickupLocationAddress ?? "", startLatitude: matchedRider?.pickupLocationLatitude ?? 0, startLongitude: matchedRider?.pickupLocationLongitude ?? 0, endAddress: parentRide?.endAddress ?? "", endLatitude: parentRide?.endLatitude ?? 0, endLongitude: parentRide?.endLongitude ?? 0, startTime: matchedRider?.pickupTime ?? 0)
        let passengerRide = PassengerRide(ride: ride)
        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: parentRide?.actualEndtime, time2: matchedRider?.pickupTime)
        let rideRoute = RideRoute(routeId: matchedRider?.routeId ?? 0,overviewPolyline : matchedRider?.routePolyline ?? "",distance :matchedRider?.distance ?? 0,duration : Double(duration), waypoints : nil)
        
        passengerRide.noOfSeats = (ride as? PassengerRide)?.noOfSeats ?? 1
        let createPassengerRideHandler = CreatePassengerRideHandler(ride: passengerRide,rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: viewController, parentRideId: parentRide?.rideId,relayLegSeq: 2)
        createPassengerRideHandler.createPassengerRide(handler: { (passengerRide, error) -> Void in
            if passengerRide != nil{
                self.secondRide = passengerRide
                NotificationCenter.default.post(name: .secondRideCreated, object: self)
            }else{
                self.rideCreationFailed = RelayRidesCreationViewModel.SECOND_RIDE_CREATION_FAILED
                NotificationCenter.default.post(name: .secondRideCreationFailed, object: self)
            }
        })
    }
    
    func sendInvitationToFistRider(viewController: UIViewController){
        guard let matchedRider = relayRideMatch?.firstLegMatch, let passengerRide = firstRide else { return }
        var matchedRiders = [MatchedRider]()
        matchedRiders.append(matchedRider)
        let inviteRiderHandler = InviteRiderHandler(passengerRide: passengerRide, selectedRiders: matchedRiders, displaySpinner: false, selectedIndex: nil, viewController: viewController)
        inviteRiderHandler.inviteSelectedRiders(inviteHandler: { (error,nserror) -> Void in
            self.handleFirstInviteResponse(error: error, nsError: nserror, viewController: viewController)
        })
    }
    private func handleFirstInviteResponse(error : ResponseError?,nsError : NSError?,viewController: UIViewController){
        if error != nil{
            RideValidationUtils.handleRiderInvitationFailedException(error: error!, viewController: viewController, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                self.sendInvitationToFistRider(viewController: viewController)
            })
        }else if error == nil && nsError == nil{
            NotificationCenter.default.post(name: .firstInviteSent, object: self)
        }
    }
    func sendInvitationToSecondRider(viewController: UIViewController){
        guard let matchedRider = relayRideMatch?.secondLegMatch, let passengerRide = secondRide else { return }
        var matchedRiders = [MatchedRider]()
        matchedRiders.append(matchedRider)
        let inviteRiderHandler = InviteRiderHandler(passengerRide: passengerRide, selectedRiders: matchedRiders, displaySpinner: false, selectedIndex: nil, viewController: viewController)
        inviteRiderHandler.inviteSelectedRiders(inviteHandler: { (error,nserror) -> Void in
            self.handleSecondInviteResponse(error: error, nsError: nserror, viewController: viewController)
        })
    }
    
    private func handleSecondInviteResponse(error : ResponseError?,nsError : NSError?,viewController: UIViewController){
        if error != nil{
            RideValidationUtils.handleRiderInvitationFailedException(error: error!, viewController: viewController, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                self.sendInvitationToSecondRider(viewController: viewController)
            })
        }else if error == nil && nsError == nil{
            NotificationCenter.default.post(name: .secondInviteSent, object: self)
        }
    }
}
