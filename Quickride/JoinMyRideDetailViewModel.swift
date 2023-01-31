//
//  JoinMyRideDetailViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import Polyline

class JoinMyRideDetailViewModel {
    
    var ride: Ride?
    var matchedUser: MatchedUser?
    var pickupZoomState = RideDetailMapViewModel.ZOOMED_OUT
    var dropZoomState = RideDetailMapViewModel.ZOOMED_OUT
    
    init() {}
    init(ride: Ride, matchedUser: MatchedUser) {
        self.ride = ride
        self.matchedUser = matchedUser
    }
    func getNearestPicupPointForPassenger(){
        let polyLine = Polyline(encodedPolyline: matchedUser?.routePolyline ?? "")
        guard let rideObj = ride, let rideRoute = polyLine.coordinates else { return }
        let pickUpLatLngIndex = LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: CLLocationCoordinate2D(latitude: rideObj.startLatitude, longitude: rideObj.startLongitude), route: rideRoute)
        let pickupPoint:CLLocationCoordinate2D = rideRoute[pickUpLatLngIndex]
        QuickRideProgressSpinner.startSpinner()
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.pickup.JoinMyRideLocationSelectionView", coordinate: pickupPoint, handler: { (location,error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if error != nil{
                var userInfo = [String: Any]()
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }else if location == nil{
                UIApplication.shared.keyWindow?.makeToast(Strings.location_not_found)
            }else{
                self.matchedUser?.pickupLocationLatitude = location?.latitude
                self.matchedUser?.pickupLocationLongitude = location?.longitude
                self.matchedUser?.pickupLocationAddress = location?.shortAddress
                self.getRouteMatricsForOtherLoaction()
            }
        })
    }
    
    func getNearestDropPointForPassenger(){
        let polyLine = Polyline(encodedPolyline: matchedUser?.routePolyline ?? "")
        guard let rideObj = ride, let rideRoute = polyLine.coordinates else { return }
        let dropLatLngIndex = LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: CLLocationCoordinate2D(latitude: rideObj.endLatitude!, longitude: rideObj.endLongitude!), route: rideRoute)
        let dropPoint:CLLocationCoordinate2D = rideRoute[dropLatLngIndex]
        QuickRideProgressSpinner.startSpinner()
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.drop.JoinMyRideLocationSelectionView", coordinate: dropPoint, handler: { (location,error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if error != nil{
                var userInfo = [String: Any]()
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }else if location == nil{
                UIApplication.shared.keyWindow?.makeToast(Strings.location_not_found)
            }else{
                self.matchedUser?.dropLocationLatitude = location?.latitude
                self.matchedUser?.dropLocationLongitude = location?.longitude
                self.matchedUser?.dropLocationAddress = location?.shortAddress
                self.getRouteMatricsForOtherLoaction()
            }
        })
    }
    
    func getRouteMatricsForOtherLoaction(){
        guard let rideObj = ride, let matchedUser = matchedUser  else { return }
        QuickRideProgressSpinner.startSpinner()
        let rideMatchMetricsForNewPickupDropTask = RideMatchMetricsForNewPickupDropTask(riderRideId: matchedUser.rideid ?? 0, passengerRideId: rideObj.rideId,riderId: matchedUser.userid ?? 0,passengerId: rideObj.userId, pickupLat: rideObj.startLatitude, pickupLng: rideObj.startLongitude, dropLat: rideObj.endLatitude!, dropLng: rideObj.endLongitude!, noOfSeats: 1, viewController: ViewControllerUtils.getCenterViewController())
        rideMatchMetricsForNewPickupDropTask.getRideMatchMetricsForNewPickupDrop { (rideMatchMetrics,responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if let rideMetrics = rideMatchMetrics{
                matchedUser.distance = rideMetrics.distanceOnRiderRoute
                matchedUser.matchPercentage = rideMetrics.matchPercentOnPassengerRoute
                matchedUser.matchPercentageOnMatchingUserRoute = rideMetrics.matchPercentOnRiderRoute
                if matchedUser.ridePassId == 0{
                    matchedUser.points = rideMetrics.points
                }
                matchedUser.pickupTime = rideMetrics.pickUpTime
                matchedUser.dropTime = rideMetrics.dropTime
                NotificationCenter.default.post(name: .receivedRouteMatrics, object: nil)
            }else{
                var userInfo = [String: Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func createRideAndJoin(){
        let rideInvitation = RideInvitation()
        rideInvitation.startTime = NSDate().timeIntervalSince1970*1000
        rideInvitation.pickupLatitude = matchedUser?.pickupLocationLatitude ?? 0
        rideInvitation.pickupLongitude = matchedUser?.pickupLocationLongitude ?? 0
        rideInvitation.dropLatitude = matchedUser?.dropLocationLatitude ?? 0
        rideInvitation.dropLongitude = matchedUser?.dropLocationLongitude ?? 0
        rideInvitation.pickupAddress = matchedUser?.pickupLocationAddress
        rideInvitation.dropAddress = matchedUser?.dropLocationAddress
        rideInvitation.pickupTime = matchedUser?.pickupTime ?? 0
        rideInvitation.points = matchedUser?.points ?? 0
        rideInvitation.dropTime = matchedUser?.dropTime ?? 0
        rideInvitation.rideType = Ride.PASSENGER_RIDE
        rideInvitation.invitingUserName = matchedUser?.name
        rideInvitation.invitingUserId = matchedUser?.userid ?? 0
        if matchedUser?.matchPercentage != nil{
            rideInvitation.matchPercentageOnPassengerRoute = matchedUser?.matchPercentage ?? 0
            rideInvitation.matchPercentageOnRiderRoute = matchedUser?.matchPercentageOnMatchingUserRoute ?? 0
        }
        let passengerRide = PassengerRide(ride : ride!)
        passengerRide.noOfSeats = (ride as? PassengerRide)?.noOfSeats ?? 1
        QuickRideProgressSpinner.startSpinner()
        CreatePassengerRideHandler(ride: passengerRide, rideRoute: nil, isFromInviteByContact: true, targetViewController: ViewControllerUtils.getCenterViewController(),parentRideId: nil,relayLegSeq: nil).createPassengerRide(handler: { (passengerRide, error) in
            QuickRideProgressSpinner.stopSpinner()
            if error != nil{
                var userInfo = [String: Any]()
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }else{
                rideInvitation.passenegerRideId = passengerRide!.rideId
                rideInvitation.passengerId = passengerRide!.userId
                self.joinPassengerToInvitedRiderRide(rideInvitation: rideInvitation)
            }
        })
    }
    
    func joinPassengerToInvitedRiderRide(rideInvitation : RideInvitation) {
        var riderHasHelmet = false
        guard let matchedUser = self.matchedUser else { return }
        if (matchedUser as? MatchedRider)?.riderHasHelmet == true{
            riderHasHelmet = true
        }
        let joinPassengerToRideHandler = JoinPassengerToRideHandler(viewController: ViewControllerUtils.getCenterViewController(), riderRideId: matchedUser.rideid!, riderId: matchedUser.userid!, passengerRideId: rideInvitation.passenegerRideId, passengerId: rideInvitation.passengerId, rideType: rideInvitation.rideType, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude!, pickupLongitude: matchedUser.pickupLocationLongitude!, pickupTime: rideInvitation.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude!, dropLongitude: matchedUser.dropLocationLongitude!, dropTime: rideInvitation.dropTime, matchingDistance: matchedUser.distance!, points: matchedUser.points!,newFare:  matchedUser.newFare, noOfSeats: rideInvitation.noOfSeats, rideInvitationId: 0.0,invitingUserName :rideInvitation.invitingUserName!,invitingUserId : rideInvitation.invitingUserId,displayPointsConfirmationAlert: true, riderHasHelmet: riderHasHelmet, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: rideInvitation.matchPercentageOnPassengerRoute, riderRouteMatchPercentage: rideInvitation.matchPercentageOnRiderRoute, moderatorId: nil ,listener: nil)
        joinPassengerToRideHandler.joinPassengerToRide(invitation: rideInvitation)
    }
}

extension NSNotification.Name{
    static let receivedRouteMatrics = Notification.Name("receivedRouteMatrics")
}
