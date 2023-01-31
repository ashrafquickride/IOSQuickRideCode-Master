//
//  RouteTravelledPathDetector.swift
//  Quickride
//
//  Created by Vinutha on 21/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
import Polyline

protocol TravelledRideRouteReceiver {
    func receiveTravelledRideRoute(newRoute: RideRoute?)
}

class RouteTravelledPathDetector {

    var riderRide: RiderRide?
    var travelledPathLatlngs: [CLLocationCoordinate2D]?
    var rideRouteReceiver: TravelledRideRouteReceiver?

    init(riderRide: RiderRide, travelledPath: String, rideRouteReceiver: TravelledRideRouteReceiver) {
        self.riderRide = riderRide
        self.travelledPathLatlngs = Polyline(encodedPolyline: travelledPath).coordinates
        self.rideRouteReceiver = rideRouteReceiver

    }

    func getTravelledRoute(){
        if riderRide == nil || travelledPathLatlngs == nil || travelledPathLatlngs!.count <= 0 {
            rideRouteReceiver?.receiveTravelledRideRoute(newRoute: nil)
            return
        }
        let deviatedPoints = getDeviatedLatLngsFromActualRoute()
        if deviatedPoints.isEmpty {
            rideRouteReceiver?.receiveTravelledRideRoute(newRoute: nil)
            return
        }
        getRouteFromGoogle(deviatedPoints: deviatedPoints)
    }

    private func getRouteFromGoogle(deviatedPoints: [Location]) {
        MyRoutesCache.getInstance()?.getUserRoute(useCase: "IOS.App.RiderRide.CustomRoute.RouteTravelledView", rideId: riderRide!.rideId, startLatitude: riderRide!.startLatitude, startLongitude: riderRide!.startLongitude, endLatitude: riderRide!.endLatitude ?? 0, endLongitude: riderRide?.endLongitude ?? 0, wayPoints: deviatedPoints.toJSONString(), routeReceiver: self,saveCustomRoute: true)

    }

    private func getDeviatedLatLngsFromActualRoute() -> [Location] {
        var deviatedLatLngs = [Location]()
        for latlng in travelledPathLatlngs! {
            let nearest = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: latlng, routePath: riderRide!.routePathPolyline).1
            let distance = LocationClientUtils.getDistance(fromLatitude: latlng.latitude, fromLongitude: latlng.longitude, toLatitude: nearest.latitude, toLongitude: nearest.longitude)
            if distance > 200 {
                deviatedLatLngs.append(Location(latitude: latlng.latitude, longitude: latlng.longitude, shortAddress: nil))
            }
        }
        if deviatedLatLngs.count <= 10 {
            return deviatedLatLngs
        }
        var subset = [Location]()
        var multiplier = deviatedLatLngs.count/10
        if deviatedLatLngs.count%10 > 5 {
            multiplier = multiplier+1
        }
        for i in 0..<deviatedLatLngs.count {
            if i%multiplier == 0 {
                subset.append(deviatedLatLngs[0])
            }
            if subset.count == 10 {
                return subset
            }
        }
        return subset
    }

}
extension RouteTravelledPathDetector: RouteReceiver {
    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
        if rideRoute.isEmpty {
            rideRouteReceiver?.receiveTravelledRideRoute(newRoute: nil)
        } else {
            rideRouteReceiver?.receiveTravelledRideRoute(newRoute: rideRoute[0])
        }
    }
    
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {
        rideRouteReceiver?.receiveTravelledRideRoute(newRoute: nil)
    }
    
    
}
