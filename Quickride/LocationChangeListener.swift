 //
 //  LocationChangeListener.swift
 //  Quickride
 //
 //  Created by QuickRideMac on 05/02/16.
 //  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
 //
 
 import Foundation
 import GoogleMaps
// import AVFoundation
 
 enum LocationStatus {
    case LocationEnabled
    case LocationDenied
    case BatteryCriticallyLow
    case BatteryLow
    case BatteryOk
 }
 
 class LocationChangeListener : NSObject,CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    
    var previousLocationUpdate : CLLocation? = nil
    var previousInvalidLocUpdate = [CLLocation]()
    var previousLocationUpdateTime : Double? = nil
    var currentLocStatus : Bool = false
    var timer : Timer?
    var locationUpdateToServerTask : UserLocationUpdateToServerTask? = nil
    static var singleInstance : LocationChangeListener? = nil
    var isOverSpeedAlertNotifiedDate : NSDate?
    var userLocationTracker :  UserLocationTracker?
    var currentLocationUpdateStatus: LocationStatus?

    let THRESHOLD_TIME_BETWEEN_START_RIDE_ALERT_TO_USER_IN_MIN = 5
    var  lastStartRideAlertTime :  NSDate?
    
    static func getInstance()  -> LocationChangeListener{
        if singleInstance == nil  {
            singleInstance =  LocationChangeListener()
            
        }
        return singleInstance!
    }

    static func removeInstance(){
        if singleInstance != nil {
            singleInstance!.stopLocationListener()
            singleInstance!.timer?.invalidate()
            singleInstance!.timer = nil
            singleInstance!.previousInvalidLocUpdate.removeAll()
            singleInstance = nil
        }
    }
    func refreshLocationUpdateRequirementStatus(){
        
        let locationUpdateRequired = isLocationUpdateRequired()
        handleLocationUpdateRequirementStatus(latestReqstatus: locationUpdateRequired)
    }
    
    func  isLocationUpdateRequired() -> Bool{
        AppDelegate.getAppDelegate().log.debug("")
        let earliestRideStartingTime : Double? = MyActiveRidesCache.getRidesCacheInstance()?.checkEarliestRideStartingTimeForConfirmedRide()
        if earliestRideStartingTime == nil{
            return false
        }
        let thresholdDate  = NSDate().timeIntervalSince1970+Double(AppConfiguration.ADVANCE_TIME_LOCATION_UPDATE_IN_MINUTES*60)
        return earliestRideStartingTime!/1000 < thresholdDate
    }
    
    func handleLocationUpdateRequirementStatus( latestReqstatus : Bool){
        AppDelegate.getAppDelegate().log.debug("CURRENT STATUS :  \( self.currentLocStatus) and LATEST STATUS : \(latestReqstatus)")
        

        if !currentLocStatus && latestReqstatus{
            startLocationListener()
        }else if currentLocStatus && !latestReqstatus{
            stopLocationListener()
            checkPassengerStatusAndStartTimerToMonitorAndUpdateLocation()
        }else if !latestReqstatus{
            checkPassengerStatusAndStartTimerToMonitorAndUpdateLocation()
        }
    }
    func checkPassengerStatusAndStartTimerToMonitorAndUpdateLocation(){
        if self.timer != nil{
            return
        }
        let onGoingPassengeRide = MyActiveRidesCache.getRidesCacheInstance()?.getOnGoingPassengerRide()
        if onGoingPassengeRide == nil{
            timer?.invalidate()
            timer = nil
            return
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 60*10, repeats: true) { (timer) in
            
            LocationUpdationServiceClient.getPassegnerLocationUpdateIfRequired(riderRideId: onGoingPassengeRide!.riderRideId, passengerId: onGoingPassengeRide!.userId) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let status = responseObject!["resultData"] as? Bool
                    if status != nil && status!{
                        if !self.currentLocStatus{
                            self.startLocationListener()
                        }
                    }else{
                        self.stopLocationListener()
                        
                    }
                }
            }
        }
        self.timer?.fire()
    }
    
    func startLocationListener(){
        AppDelegate.getAppDelegate().log.debug("startLocationListener()")
        addObserverToLocationChangeListner()
        let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()
        if ridePreferences?.locationUpdateAccuracy == 0{
            return
        }
        let batteryStatus = UIDevice.current.batteryState
        let batteryLevel = UIDevice.current.batteryLevel
        var desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        var allowBackGroundLocation = true
        var activityType = CLActivityType.automotiveNavigation
        if batteryStatus != .charging &&  batteryLevel <= 0.08{
            AppDelegate.getAppDelegate().log.debug("Battery level is less so not starting location updates")
            return
        }else if batteryStatus != .charging &&  batteryLevel <= 0.15 && batteryLevel > 0.08{
            desiredAccuracy = kCLLocationAccuracyHundredMeters
            allowBackGroundLocation = false
            activityType = CLActivityType.other
        }
        
        self.locationManager  = CLLocationManager()
        locationManager!.requestWhenInUseAuthorization()
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager!.allowsBackgroundLocationUpdates = true
        self.locationManager!.pausesLocationUpdatesAutomatically = false
        self.locationManager!.activityType = CLActivityType.automotiveNavigation
        self.locationManager!.delegate = self
        self.locationManager!.startUpdatingLocation()

        locationUpdateToServerTask = UserLocationUpdateToServerTask()
        if locationManager?.location != nil{
            processLocationUpdate(location: (locationManager?.location)!)
        }


        currentLocStatus = true
    }

    func stopLocationListener(){
        AppDelegate.getAppDelegate().log.debug("stopLocationListener()")
        if locationManager != nil{
            self.locationManager!.delegate = nil
            self.locationManager!.allowsBackgroundLocationUpdates = false
            self.locationManager!.stopUpdatingLocation()


        }

        if ( locationUpdateToServerTask != nil ) {
            self.locationUpdateToServerTask = nil
        }
        currentLocStatus = false
    }
    func restartLcoationManager(){
        AppDelegate.getAppDelegate().log.debug("")
        if locationManager != nil{
            locationManager?.startUpdatingLocation()
        }
    }
    
    // MARK: CLLocationManagerDelegate method implementation
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppDelegate.getAppDelegate().log.error("\(error)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        LocationCache.getCacheInstance().putRecentLocationOfUser(location: locations.last)
        let location = locations.last
        if(SessionManagerController.sharedInstance.isSessionManagerInitialized()) {
            self.processLocationUpdate(location: location!)
        }
        else {
            // Resume session and then handle notification
            let appStartupHandler = AppStartupHandler(targetViewController: nil,  notificationActionIdentifier : nil,isbackGroundStartUp: true, completionHandler: {(sessionStart, sessionStop,sessionRestart) in
                
            })
            appStartupHandler.resumeUserSessionAndNavigateToAppropriateInitialView()
        }
    }
    
    
    func processLocationUpdate( location : CLLocation){
        
        AppDelegate.getAppDelegate().log.debug("\(location)")
        var distanceMoved : Double = 0.0
        if previousLocationUpdate != nil{
            distanceMoved = previousLocationUpdate!.distance(from: location)
        }
        let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()
        var thresholdDistance = 0
        if ridePreferences?.locationUpdateAccuracy == 0{
            return
        }else if ridePreferences?.locationUpdateAccuracy == 1{
            thresholdDistance = AppConfiguration.MIN_DISTANCE_CHANGE_FOR_UPDATES_MEDIUM
        }else if ridePreferences?.locationUpdateAccuracy == 2{
            thresholdDistance = AppConfiguration.MIN_DISTANCE_CHANGE_FOR_UPDATES_HIGH
        }
        var locationExpired = true
        if previousLocationUpdateTime != nil && DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: NSDate(timeIntervalSince1970: previousLocationUpdateTime!/1000)) < Int(AppConfiguration.LOCATION_REFRESH_TIME_THRESHOLD_IN_SECS){
            locationExpired = false
        }
        if !locationExpired && previousLocationUpdate != nil && distanceMoved <= Double(thresholdDistance){
            return
        }
        for prevInvalidLocUpdate in previousInvalidLocUpdate{
            if !locationExpired && prevInvalidLocUpdate.distance(from: location) <= Double(thresholdDistance){
                return
            }
        }
       
        let currentTime : Double = NSDate().timeIntervalSince1970*1000
        var travelledSpeed = 0.0
        if(previousLocationUpdateTime != nil){
            
            let timeDiff : Double = currentTime - previousLocationUpdateTime!
            //in Millis
            //Multiplication with 60 to calcualte the speed in KMpH distance is in Km,time in minutes
            //So to convert time to hours we need to devide with 60,But we are multiplying distance with 60 as travelled speed is very small in hours, always 0.
            travelledSpeed  = (distanceMoved*60*60)/timeDiff
            if travelledSpeed < Double(AppConfiguration.MAX_SPEED_ALLOWED){
                processValidLocUpdate(location: location,travelledSpeed: travelledSpeed)
            }else{
                for prevInvalidLocUpdate in previousInvalidLocUpdate{
                    distanceMoved = prevInvalidLocUpdate.distance(from: location)
                    travelledSpeed  = (distanceMoved*60*60)/timeDiff
                    if travelledSpeed < Double(AppConfiguration.MAX_SPEED_ALLOWED){
                        processValidLocUpdate(location: location, travelledSpeed: travelledSpeed)
                        return
                    }
                }
                previousInvalidLocUpdate.append(location)
            }
        }else{
            processValidLocUpdate(location: location,travelledSpeed : travelledSpeed)
        }
    }
    
    func processValidLocUpdate(location : CLLocation, travelledSpeed : Double){
        let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()
        if ridePreferences != nil && ridePreferences!.alertOnOverSpeed == true
            && (isOverSpeedAlertNotifiedDate == nil || DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: isOverSpeedAlertNotifiedDate!) >= 5) && (location.speed > AppConfiguration.OVER_SPEED_LIMIT_MPS || travelledSpeed > AppConfiguration.OVER_SPEED_LIMIT){
            AppDelegate.getAppDelegate().log.debug("play speed alert")
            let riderRides = MyActiveRidesCache.getRidesCacheInstance()?.activeRiderRides
            if riderRides != nil{
                for riderRide in riderRides!{
                    if Ride.RIDE_STATUS_STARTED == riderRide.1.status{
//                        let speechSynthesizer = AVSpeechSynthesizer()
//                        let speechUtterance = AVSpeechUtterance(string: Strings.over_speed_alert)
//                        speechUtterance.rate = 0.1
//
//                        speechSynthesizer.speak(speechUtterance)
                        isOverSpeedAlertNotifiedDate = NSDate()
                        break
                    }
                }
            }
        }
        var rideParticipantLocations = [RideParticipantLocation]()
        if let riderRides = MyActiveRidesCache.getRidesCacheInstance()?.getCurrentUserParticipatingActiveRiderRides(){
            for riderRide in riderRides {
                let rideParticipantLocation = RideParticipantLocation(rideId: riderRide.rideId, userId: riderRide.userId, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, bearing: location.course, participantETAInfos: nil)
                rideParticipantLocation.lastUpdateTime = NSDate().getTimeStamp()
                rideParticipantLocations.append(rideParticipantLocation)
            }
        }
        if let passengerRides = MyActiveRidesCache.getRidesCacheInstance()?.getCurrentUserParticipatingActivePassengerRides(){
            for passengerRide in passengerRides{
                let rideParticipantLocation = RideParticipantLocation(rideId: passengerRide.riderRideId, userId: passengerRide.userId,latitude:location.coordinate.latitude,longitude: location.coordinate.longitude,bearing: location.course,participantETAInfos: nil)
                rideParticipantLocations.append(rideParticipantLocation)
            }
        }

        if self.locationUpdateToServerTask == nil{
            self.locationUpdateToServerTask = UserLocationUpdateToServerTask()
        }
        self.locationUpdateToServerTask?.setLatestLocation(newLocation: location, rideParticipantLocations: rideParticipantLocations)
        let myActiveRidesCache =  MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache != nil {
            myActiveRidesCache!.updateCurrentUserLocationChange(rideParticipantLocations: rideParticipantLocations)
        }
            
        previousLocationUpdate = location
        previousLocationUpdateTime = NSDate().getTimeStamp()

    }
    func trackUserLocationForStartAlert( location : CLLocation) {
        AppDelegate.getAppDelegate().log.debug("trackUserLocationForStartAlert()")
        if userLocationTracker == nil{
            userLocationTracker = UserLocationTracker()
        }
        userLocationTracker!.addUserLocation(location: location)
        if userLocationTracker!.isUserMoving() == false{
            return
        }
        let currentTime = NSDate()
        if lastStartRideAlertTime != nil && (lastStartRideAlertTime?.addMinutes(minutesToAdd: THRESHOLD_TIME_BETWEEN_START_RIDE_ALERT_TO_USER_IN_MIN).timeIntervalSince1970)! > currentTime.timeIntervalSince1970{
            return
        }
        let startRideAnalyzer = StartRideAnalyzer()
        startRideAnalyzer.analyzeRides();
        lastStartRideAlertTime = currentTime;
    }
    deinit{
        locationManager?.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    func pushCurrentLocationToTopic(rideId : Double) {
        if locationManager == nil{
            self.locationManager  = CLLocationManager()
        }
        if let location = locationManager?.location{
            ParticipantETAInfoCalculator().prepareParticipantETAInfo(riderCurrentLocation: location, riderPrevLocation: previousLocationUpdate, riderRides: MyActiveRidesCache.getRidesCacheInstance()?.getCurrentUserParticipatingActiveRiderRides()) { (rideParticipantLocationsForRiderRides) in
                var rideParticipantLocations  = rideParticipantLocationsForRiderRides
                if let passengerRides = MyActiveRidesCache.getRidesCacheInstance()?.getCurrentUserParticipatingActivePassengerRides(){
                    for passengerRide in passengerRides{
                        let rideParticipantLocation = RideParticipantLocation(rideId: passengerRide.rideId, userId: passengerRide.userId,latitude:location.coordinate.latitude,longitude: location.coordinate.longitude,bearing: location.course,participantETAInfos: nil)
                        rideParticipantLocations.append(rideParticipantLocation)
                    }
                }
                let myActiveRidesCache =  MyActiveRidesCache.getRidesCacheInstance()
                if myActiveRidesCache != nil {
                    myActiveRidesCache!.updateCurrentUserLocationChange(rideParticipantLocations: rideParticipantLocations)
                }
                if self.locationUpdateToServerTask == nil{
                    self.locationUpdateToServerTask = UserLocationUpdateToServerTask()
                }
                self.locationUpdateToServerTask?.setLatestLocation(newLocation: location, rideParticipantLocations: rideParticipantLocations)
            }
        }
    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        AppDelegate.getAppDelegate().log.debug("Battery level Changed")
        if UIDevice.current.batteryLevel == -1 {
            return
        }
        if UIDevice.current.batteryState == .charging || UIDevice.current.batteryLevel > 0.15{
            AppDelegate.getAppDelegate().log.debug("Battery level OK, No need to stop location updates")
            refreshLocationUpdateRequirementStatus()
        }
        else{
            stopLocationListener()
        }
        checkAndPostLocationUpdateStatus(locationUpdateStatus: LocationUpdateStatus(batteryLevel: Double(UIDevice.current.batteryLevel), batteryState: UIDevice.current.batteryState, locationPermission: CLLocationManager.authorizationStatus()))
    }
    @objc func batteryStateDidChange(_ notification: Notification) {
        AppDelegate.getAppDelegate().log.debug("Battery state Changed :- \(UIDevice.current.batteryState)")
        if UIDevice.current.batteryLevel == -1 {
            return
        }
        if UIDevice.current.batteryState == .charging ||  UIDevice.current.batteryLevel > 0.15{
            AppDelegate.getAppDelegate().log.debug("Battery level OK, No need to stop location updates")
            AppDelegate.getAppDelegate().log.debug("Mobile charge connected :- \(UIDevice.current.batteryState)")
            refreshLocationUpdateRequirementStatus()
        }else{
            stopLocationListener()
        }
        checkAndPostLocationUpdateStatus(locationUpdateStatus: LocationUpdateStatus(batteryLevel: Double(UIDevice.current.batteryLevel), batteryState: UIDevice.current.batteryState, locationPermission: CLLocationManager.authorizationStatus()))
    }
    
    private func addObserverToLocationChangeListner() {
        NotificationCenter.default.addObserver(self, selector: #selector(LocationChangeListener.batteryLevelDidChange(_:)) , name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationChangeListener.batteryStateDidChange(_:)), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        UIDevice.current.isBatteryMonitoringEnabled = true
          NotificationCenter.default.addObserver(self, selector: #selector(checkNotificationStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                self.currentLocationUpdateStatus = LocationStatus.LocationDenied
            } else {
                self.currentLocationUpdateStatus = LocationStatus.LocationEnabled
            }
            self.checkAndPostLocationUpdateStatus(locationUpdateStatus: LocationUpdateStatus(batteryLevel: Double(UIDevice.current.batteryLevel), batteryState: UIDevice.current.batteryState, locationPermission: CLLocationManager.authorizationStatus()))
        }
    }
    
    private func checkAndPostLocationUpdateStatus(locationUpdateStatus: LocationUpdateStatus) {
        if currentLocationUpdateStatus != LocationStatus.LocationDenied {
            let batteryStatus = locationUpdateStatus.batteryState
            if batteryStatus == .charging || batteryStatus == .full {
                currentLocationUpdateStatus = LocationStatus.BatteryOk
            } else {
                let batteryLevel = locationUpdateStatus.batteryLevel
                if batteryLevel > -1 && batteryLevel <= 0.10 {
                    currentLocationUpdateStatus = LocationStatus.BatteryCriticallyLow
                } else if batteryLevel > 0.10,batteryLevel < 0.30 {
                    currentLocationUpdateStatus = LocationStatus.BatteryLow
                } else {
                    currentLocationUpdateStatus = LocationStatus.BatteryOk
                }
            }
        }
        NotificationCenter.default.post(name: .locationUpdateSatatus, object: nil)
    }
 }
