//
//  UserLocationUpdateToServerTask.swift
//  Quickride
//
//  Created by QuickRide on 05/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import ObjectMapper

class UserLocationUpdateToServerTask {
    
    var serverUpdatedLastLoc : CLLocation? = nil
    var isTaskExecutionRequired : Bool = true
    var  userId : Double = Double(QRSessionManager.getInstance()!.getUserId())!
    var previousLocationUpdateTime :NSDate?
    var previousLocationUpdateTimeToEventServer :NSDate?
    var rideInvitesTrackingForCurrentLocationAsyncTask : RideInvitesTrackingForCurrentLocationAsyncTask?
    
    func setLatestLocation( newLocation : CLLocation,rideParticipantLocations : [RideParticipantLocation]){
        
        let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()
        var locationAccuracyUpdateToServer : Int?
        
        if ridePreferences?.locationUpdateAccuracy == 2{
            locationAccuracyUpdateToServer = AppConfiguration.MIN_DISTANCE_CHANGE_FOR_SERVER_UPDATE_HIGH
        } else {
            locationAccuracyUpdateToServer = AppConfiguration.MIN_DISTANCE_CHANGE_FOR_SERVER_UPDATE_MEDIUM
        }
        
        if serverUpdatedLastLoc != nil &&
            newLocation.distance(from: serverUpdatedLastLoc!)
            < Double(locationAccuracyUpdateToServer!) && (previousLocationUpdateTime != nil && DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2:  previousLocationUpdateTime!) < Int(AppConfiguration.LOCATION_REFRESH_TIME_THRESHOLD_IN_SECS)){
            return
        }
        for rideParticipantLocation in rideParticipantLocations {
            if rideParticipantLocation.bearing == nil || rideParticipantLocation.bearing == 0{
                rideParticipantLocation.bearing = newLocation.getDirection(prevLat: serverUpdatedLastLoc?.coordinate.latitude, prevLng: serverUpdatedLastLoc?.coordinate.longitude)
            }
            rideParticipantLocation.sequenceNo = SharedPreferenceHelper.getSequenceNoForRide(rideId: rideParticipantLocation.rideId!)
            rideParticipantLocation.lastUpdateTime = NSDate().getTimeStamp()
            LocationUpdationServiceClient.updateRideParticipantLocation(rideParticipantLocation: rideParticipantLocation, targetViewController: nil) { (responseObject, error) in
                
            }
        }
        
        
        serverUpdatedLastLoc = newLocation
        previousLocationUpdateTime = NSDate()
        let rideInvitesTrackingForCurrentLocationAsyncTask = RideInvitesTrackingForCurrentLocationAsyncTask(location: LatLng(lat: newLocation.coordinate.latitude, long: newLocation.coordinate.longitude))
        rideInvitesTrackingForCurrentLocationAsyncTask.updateNotificationStatusForRides()
    }
}
