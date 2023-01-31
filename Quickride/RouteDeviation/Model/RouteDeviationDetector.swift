//
//  RouteDeviationDetector.swift
//  Quickride
//
//  Created by Vinutha on 16/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation

protocol RouteDeviationDetectorDelegate {
    func routeDeviated(_ deviated: Bool)
}
class RouteDeviationDetector {

    static let ROUTE_DEVIATION_DISTANCE_THRESHOLD: Double = 500 //M
    static let DISTANCE_BETWEEN_PICKUPS: Double = 20 // M
    static let CONFIRMED = "CONFIRMED"
    static let CANCELLED = "CANCELLED"
    static let FAILED = "FAILED"
    
    private var delegate: RouteDeviationDetectorDelegate?
    private var riderRide: RiderRide?
    private var rideParticipantLocation: RideParticipantLocation?
    private var ride: Ride?
    
    init() {}
    
    init(ride: Ride?, riderRide: RiderRide?, rideParticipantLocation: RideParticipantLocation?, delegate: RouteDeviationDetectorDelegate) {
        self.ride = ride
        self.delegate = delegate
        self.riderRide = riderRide
        self.rideParticipantLocation = rideParticipantLocation
    }
    func isRouteDeviated() {
        if riderRide == nil || rideParticipantLocation == nil || ride?.rideType == Ride.PASSENGER_RIDE {
            delegate?.routeDeviated(false)
            return
        }
        if riderRide!.userId != UserDataCache.getInstance()?.getLoggedInUserProfile()?.userId {
            delegate?.routeDeviated(false)
            return
        }
        if riderRide!.status != Ride.RIDE_STATUS_STARTED {
            delegate?.routeDeviated(false)
            return
        }
        if let status = SharedPreferenceHelper.getRouteDeviationStatus(id: riderRide!.rideId) {
            if status == RouteDeviationDetector.CONFIRMED {
                delegate?.routeDeviated(false)
                return
            } else if status == RouteDeviationDetector.CANCELLED {
                delegate?.routeDeviated(false)
                return
            }else if status ==  RouteDeviationDetector.FAILED{ // Route deviated and route upadting failed
                delegate?.routeDeviated(true)
            }
        } else {
            let currentLocationLatlng = CLLocationCoordinate2D(latitude: rideParticipantLocation!.latitude!, longitude: rideParticipantLocation!.longitude!)
            let nearestLatLng = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: currentLocationLatlng, routePath: riderRide!.routePathPolyline).1
            let deviatedDistance = LocationClientUtils.getDistance(fromLatitude: currentLocationLatlng.latitude, fromLongitude: currentLocationLatlng.longitude, toLatitude: nearestLatLng.latitude, toLongitude: nearestLatLng.longitude)
            
            if deviatedDistance <= RouteDeviationDetector.ROUTE_DEVIATION_DISTANCE_THRESHOLD {
                delegate?.routeDeviated(false)
                return
            }
            delegate?.routeDeviated(true)
        }
    }
    
    func getMissingPickups(riderRide: RiderRide, newRoute: RideRoute) -> [RideParticipant] {
        var missingPickups = [RideParticipant]()
        if let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: riderRide.rideId) {
            let passengersYetToPickupInOrder = RideViewUtils.getPassengersYetToPickupInOrder(rideParticipants: rideDetailInfo.rideParticipants)
            if passengersYetToPickupInOrder.isEmpty {
                return missingPickups
            }
            for passengerInfo in passengersYetToPickupInOrder {
                let pickup = CLLocationCoordinate2D(latitude: passengerInfo.startPoint!.latitude, longitude: passengerInfo.startPoint!.longitude)
                let nearestPickup = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: pickup, routePath: newRoute.overviewPolyline!).1
                let distanceBetweenPickups = LocationClientUtils.getDistance(fromLatitude: pickup.latitude, fromLongitude: pickup.longitude, toLatitude: nearestPickup.latitude, toLongitude: nearestPickup.longitude)
                if distanceBetweenPickups > RouteDeviationDetector.DISTANCE_BETWEEN_PICKUPS {
                    missingPickups.append(passengerInfo)
                }
            }
        }
        return missingPickups
    }
    
    func getMissingRideInvites(riderRide: RiderRide, newRoute: RideRoute) -> [RideInvitation]{
        var missingInvites = [RideInvitation]()
        let rideInvites = RideInviteCache.getInstance().getPendingInvitesOfRide(rideId: riderRide.rideId)
        if rideInvites.isEmpty {
            return missingInvites
        }
        for invite in rideInvites {
            let pickup = CLLocationCoordinate2D(latitude: invite.pickupLatitude, longitude: invite.pickupLongitude)
            let nearestPickup = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: pickup, routePath: newRoute.overviewPolyline!).1
            let distanceBetweenPickups = LocationClientUtils.getDistance(fromLatitude: pickup.latitude, fromLongitude: pickup.longitude, toLatitude: nearestPickup.latitude, toLongitude: nearestPickup.longitude)
            if distanceBetweenPickups > RouteDeviationDetector.DISTANCE_BETWEEN_PICKUPS {
                missingInvites.append(invite)
            }
        }
        return missingInvites
    }
    
}
extension RouteDeviationDetector: RouteReceiver {
    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
        if !rideRoute.isEmpty && !getMissingPickups(riderRide: riderRide!, newRoute: rideRoute[0]).isEmpty {
            delegate?.routeDeviated(false)
        } else {
            delegate?.routeDeviated(true)
        }
    }
    
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {
        delegate?.routeDeviated(true)
    }
    
}
