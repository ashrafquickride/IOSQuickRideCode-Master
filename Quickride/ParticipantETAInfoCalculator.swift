import Foundation
import CoreLocation
import ObjectMapper


class ParticipantETAInfoCalculator {
    
    static var etaInProgress = false
    
    public func prepareParticipantETAInfo( riderCurrentLocation : CLLocation, riderPrevLocation : CLLocation?,  riderRides : [RiderRide]?, handler : @escaping  ( _ participantLocations :[RideParticipantLocation]) -> Void) {
        if ParticipantETAInfoCalculator.etaInProgress{
            return
        }
        var rideParticipantLocations = [RideParticipantLocation]()
        guard riderRides != nil && !riderRides!.isEmpty else {
            return handler(rideParticipantLocations)
        }
        let dispatchQueue = DispatchQueue.main
        var dispatchGroup :DispatchGroup? = DispatchGroup()
        for riderRide in riderRides! {
            dispatchGroup?.enter()
            dispatchQueue.async(group: dispatchGroup) {
                
                self.getRideDetailInfo(riderRide: riderRide) { (rideDetailInfo) in
                    if let rideDetailInfo = rideDetailInfo,let rideParticipants = rideDetailInfo.rideParticipants{
                        var endPoints = [LatLng]()
                        for rideParticipant in rideParticipants{
                            if rideParticipant.rider {
//                                endPoints.append(LatLng(lat: rideParticipant.endPoint?.latitude ?? 0, long: rideParticipant.endPoint?.longitude ?? 0))
                                continue // For rider we are not calculating eta now
                            } else {
                                if Ride.RIDE_STATUS_SCHEDULED == rideParticipant.status || Ride.RIDE_STATUS_DELAYED == rideParticipant.status{
                                    endPoints.append(LatLng(lat: rideParticipant.startPoint?.latitude ?? 0, long: rideParticipant.startPoint?.longitude ?? 0))
                                }
                            }
                        }
                        if endPoints.isEmpty{
                           let rideParticipantLocation = RideParticipantLocation(rideId: riderRide.rideId, userId: riderRide.userId, latitude: riderCurrentLocation.coordinate.latitude, longitude: riderCurrentLocation.coordinate.longitude, bearing: riderCurrentLocation.course, participantETAInfos: nil)
                           rideParticipantLocation.lastUpdateTime = NSDate().getTimeStamp()
                           rideParticipantLocations.append(rideParticipantLocation)
                           dispatchGroup?.leave()
                            return
                        }
                        ParticipantETAInfoCalculator.etaInProgress = true
                        RoutePathServiceClient.getETAForMultiPoint(routeId: rideDetailInfo.riderRide?.routeId ?? 0, startTime: rideDetailInfo.riderRide?.startTime ?? 0, startLatLngList: [LatLng(lat: riderCurrentLocation.coordinate.latitude, long: riderCurrentLocation.coordinate.longitude)], endLatLngList: endPoints, vehicleType: rideDetailInfo.riderRide?.vehicleType ?? "",rideId: riderRide.rideId, useCase: "iOS.App.Rider.Eta.ETACalculator.Rider", snapToRoute: true,routeStartLatitude: rideDetailInfo.riderRide?.startLatitude ?? 0, routeStartLongitude: rideDetailInfo.riderRide?.startLongitude ?? 0, routeEndLatitude: rideDetailInfo.riderRide?.endLongitude ?? 0, routeEndLongitude: rideDetailInfo.riderRide?.endLongitude ?? 0, routeWaypoints: rideDetailInfo.riderRide?.waypoints, routeOverviewPolyline: rideDetailInfo.riderRide?.routePathPolyline){ (responseObject, error) in
                            ParticipantETAInfoCalculator.etaInProgress = false
                            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                                let etaResponseList = Mapper<ETAResponse>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ETAResponse]()
                                var participantETAInfos = [ParticipantETAInfo]()
                                for rideParticipant in
                                    rideParticipants{
                                        for etaResponse in
                                            etaResponseList {
                                                if rideParticipant.rider && rideParticipant.endPoint!.latitude == etaResponse.destination?.latitude && rideParticipant.endPoint!.longitude == etaResponse.destination?.longitude {
                                                    participantETAInfos.append(ParticipantETAInfo(participantId: rideParticipant.userId, destinationLatitude: rideParticipant.endPoint!.latitude, destinationLongitude: rideParticipant.endPoint!.longitude,routeDistance : etaResponse.distanceInKM*1000, durationInTraffic: etaResponse.timeTakenInSec/60, duration: etaResponse.timeTakenInSec/60, error: etaResponse.error))
                                                } else if rideParticipant.startPoint!.latitude == etaResponse.destination?.latitude && rideParticipant.startPoint!.longitude == etaResponse.destination?.longitude{
                                                    participantETAInfos.append(ParticipantETAInfo(participantId: rideParticipant.userId, destinationLatitude: rideParticipant.startPoint!.latitude, destinationLongitude: rideParticipant.startPoint!.longitude,routeDistance : etaResponse.distanceInKM*1000, durationInTraffic: etaResponse.timeTakenInSec/60, duration: etaResponse.timeTakenInSec/60, error: etaResponse.error))
                                                }
                                        }
                                }
                                let rideParticipantLocation = RideParticipantLocation(rideId: rideDetailInfo.riderRide!.rideId, userId: rideDetailInfo.riderRide!.userId, latitude: riderCurrentLocation.coordinate.latitude, longitude: riderCurrentLocation.coordinate.longitude, bearing: riderCurrentLocation.course, participantETAInfos: participantETAInfos)
                                rideParticipantLocation.lastUpdateTime = NSDate().getTimeStamp()
                                rideParticipantLocations.append(rideParticipantLocation)
                                dispatchGroup?.leave()
                            }
                        }
                    }else{
                        let rideParticipantLocation = RideParticipantLocation(rideId: riderRide.rideId, userId: riderRide.userId, latitude: riderCurrentLocation.coordinate.latitude, longitude: riderCurrentLocation.coordinate.longitude, bearing: riderCurrentLocation.course, participantETAInfos: nil)
                        rideParticipantLocation.lastUpdateTime = NSDate().getTimeStamp()
                        rideParticipantLocations.append(rideParticipantLocation)
                        dispatchGroup?.leave()
                    }
                }
            }
        }
        dispatchGroup?.notify(queue: dispatchQueue) {
            dispatchGroup = nil
            handler(rideParticipantLocations)
        }
    }
    fileprivate func getRideDetailInfo(riderRide :RiderRide, handler : @escaping (_ rideDetailInfo : RideDetailInfo?)->Void){
        var rideDetailInfo = MyActiveRidesCache.singleCacheInstance?.getRideDetailInfoIfExist(riderRideId: riderRide.rideId)
        if rideDetailInfo == nil{
            rideDetailInfo = SharedPreferenceHelper.getRideDetailInfo(riderRideId:  StringUtils.getStringFromDouble(decimalNumber: riderRide.rideId))
        }
        if rideDetailInfo == nil {
            MyActiveRidesCache.singleCacheInstance?.getRideDetailInfoFromServerByHandler(currentUserRide: riderRide, handler: {
                (rideDetailInfo,responseError,error) in
                
                handler(rideDetailInfo)
            }
            )
        }else{
            handler(rideDetailInfo)
        }
    }
    func getEtaTextBasedOnRouteMetrics(routeMetrics: RouteMetrics) -> String {
        if let etaError = routeMetrics.error, etaError.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR {
            return Strings.rider_crossed_pickup
        }
        let timeDifferenceInSeconds = DateUtils.getDifferenceBetweenTwoDatesInSecs(time1: DateUtils.getCurrentTimeInMillis(), time2: routeMetrics.creationTime)
        var eta: String?
        if timeDifferenceInSeconds <= 30 {
            let durationInTrafficMinutes = routeMetrics.journeyDurationInTraffic
            if durationInTrafficMinutes <= 59 {
                eta = "\(durationInTrafficMinutes) min away"
            } else {
                eta = "\(durationInTrafficMinutes/60) hour away"
            }
        }else{
            let timeDifference: String?
            if timeDifferenceInSeconds <= 59 {
                timeDifference = "\(timeDifferenceInSeconds) sec ago"
            } else{
                timeDifference = "\(timeDifferenceInSeconds/60) min ago"
            }
            let distanceInMeters = routeMetrics.routeDistance
            if distanceInMeters > 1000 {
                let distanceInKm = distanceInMeters / 1000
                eta = timeDifference! + ", " + StringUtils.getStringFromDouble(decimalNumber: distanceInKm) + " km away"
            } else if distanceInMeters > 900 {
                eta = timeDifference! + ", " +  "1 km away"
            } else if distanceInMeters > 1 {
                eta = timeDifference! + ", " +  StringUtils.getStringFromDouble(decimalNumber: distanceInMeters) + " m away"
            } else {
                eta = timeDifference! + ", " +  "1 m away"
            }
        }
        return eta!.uppercased()
    }
}
