//
//  MyClosedRidesCache.swift
//  Quickride
//
//  Created by KNM Rao on 17/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MyClosedRidesCache{
    
    var closedRiderRides : [Double : RiderRide]? = [Double : RiderRide]()
    var closedPassengerRides : [Double : PassengerRide]? = [Double : PassengerRide]()
    
    var initializationStatus =  ClosedRidesCacheInitializationStatus.Uninitialized
    var closedRidesListenerWaiting : [MyRidesCacheListener]?
    
    static var sharedInstance : MyClosedRidesCache?
    var userId : String?
    
    init(userId : String?) {
        self.userId = userId
        self.initializationStatus =  ClosedRidesCacheInitializationStatus.Uninitialized
    }
    
    static func clearUserSession() {
        AppDelegate.getAppDelegate().log.debug("clearUserSession()")
        if sharedInstance == nil {
            return
        }
        
        sharedInstance?.clearClosedRidesFromPersistence()
        sharedInstance?.removeCacheInstance()
    }
    
    func removeCacheInstance() {
        AppDelegate.getAppDelegate().log.debug("removeCacheInstance()")
        MyClosedRidesCache.sharedInstance?.initializationStatus = .Uninitialized
        MyClosedRidesCache.sharedInstance?.closedRiderRides?.removeAll()
        MyClosedRidesCache.sharedInstance?.closedPassengerRides?.removeAll()
        MyClosedRidesCache.sharedInstance = nil
        self.userId = nil
    }
    
    func clearClosedRidesFromPersistence() {
        AppDelegate.getAppDelegate().log.debug("clearClosedRidesFromPersistence()")
        MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.closedRiderRideTable)
        MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.closedPassengerRideTable)
    }
    
    static func getClosedRidesCacheInstance() -> MyClosedRidesCache{
        AppDelegate.getAppDelegate().log.debug("getClosedRidesCacheInstance()")
        if sharedInstance == nil {
            sharedInstance = MyClosedRidesCache(userId: QRSessionManager.sharedInstance!.getUserId())
        }
        return sharedInstance!
    }
    
    static func getClosedRidesCacheInstanceIfExists() -> MyClosedRidesCache?{
        AppDelegate.getAppDelegate().log.debug("getClosedRidesCacheInstanceIfExists()")
        if self.sharedInstance != nil {
            return sharedInstance!
        }
        return nil
    }
    
    static func newUserSession() {
        AppDelegate.getAppDelegate().log.debug("newUserSession()")
        getClosedRidesCacheInstance()
        sharedInstance!.initializationStatus = .InitializationComplete
    }
    
    static func reinitializeUserSession() {
        AppDelegate.getAppDelegate().log.debug("reinitializeUserSession()")
        getClosedRidesCacheInstance()
        sharedInstance!.getClosedRides(myRidesCacheListener: nil)
    }
    
    static func resumeUserSession() {
        AppDelegate.getAppDelegate().log.debug("resumeUserSession()")
        getClosedRidesCacheInstance()
        sharedInstance!.reloadClosedRidesFromPersistence()
        sharedInstance!.getClosedRidesFromServer()
       
    }
    
    private func reloadClosedRidesFromPersistence() {
        AppDelegate.getAppDelegate().log.debug("reloadClosedRidesFromPersistence()")
        let closedRiderRides = MyRidesPersistenceHelper.getClosedRiderRides()
        
        for closedRiderRide in closedRiderRides{
            MyClosedRidesCache.sharedInstance?.closedRiderRides![closedRiderRide.rideId] = closedRiderRide
        }

        
        let closedPassengerRides = MyRidesPersistenceHelper.getClosedPassengerRides()
        for closedPassengerRide in closedPassengerRides{
            MyClosedRidesCache.sharedInstance?.closedPassengerRides![closedPassengerRide.rideId] = closedPassengerRide
        }
        
        initializationStatus = .InitializationComplete
    }
    
    private func receiveClosedRidesInfoOnSuccess(userRides : UserRides){
        AppDelegate.getAppDelegate().log.debug("receiveClosedRidesInfoOnSuccess()")
        initializeClosedRides(userRides: userRides)
        initializationStatus = .InitializationComplete
        
        notifyListeners()
        addClosedRidesToPersistence(userRides: userRides)
    }
    
    func notifyListeners() {
        AppDelegate.getAppDelegate().log.debug("notifyListeners()")
        if closedRidesListenerWaiting == nil || closedRidesListenerWaiting?.isEmpty == true {
            return
        }
        
        for listener in closedRidesListenerWaiting! {
            listener.receiveClosedRides(closedRiderRides: self.closedRiderRides!, closedPassengerRides: self.closedPassengerRides!)
        }
        self.closedRidesListenerWaiting = nil
    }
    
    func addClosedRidesToPersistence(userRides : UserRides) {
        AppDelegate.getAppDelegate().log.debug("addClosedRidesToPersistence()")
        MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.closedRiderRideTable)
        MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.closedPassengerRideTable)
        MyRidesPersistenceHelper.storeClosedRiderRidesInBulk(riderRides: userRides.riderRides)
        MyRidesPersistenceHelper.storeClosedPassengerRidesInBulk(passengerRides: userRides.passengerRides)
    }
    
     func getClosedRides(myRidesCacheListener : MyRidesCacheListener?) {
        AppDelegate.getAppDelegate().log.debug("getClosedRides()")
        if initializationStatus == .InitializationComplete {
            if (myRidesCacheListener != nil) {
                myRidesCacheListener!.receiveClosedRides(closedRiderRides: closedRiderRides!, closedPassengerRides: closedPassengerRides!)
            }
            
        }else{
            if (myRidesCacheListener != nil) {
                myRidesCacheListener!.receiveClosedRides(closedRiderRides: closedRiderRides!, closedPassengerRides: closedPassengerRides!)
            }
            if QRReachability.isConnectedToNetwork() == false {
                if (myRidesCacheListener != nil) {
                    myRidesCacheListener!.onRetrievalFailure(responseError: nil, error: QuickRideErrors.NetworkConnectionNotAvailableError)
                }
                return
            }
            
            if closedRidesListenerWaiting == nil {
                closedRidesListenerWaiting = [MyRidesCacheListener]()
            }
            if (myRidesCacheListener != nil) {
                closedRidesListenerWaiting?.append(myRidesCacheListener!)
                
            }
            if initializationStatus == .InitializationStarted {
                return
            }
            
            initializationStatus = .InitializationStarted
            getClosedRidesFromServer()
        }
    }
    
    func getClosedRidesFromServer(){
        RideServicesClient.getAllClosedRidesOfUser(userId : QRSessionManager.getInstance()!.getUserId(), completionHandler: { (responseObject, error) -> Void in
            if(responseObject == nil){
                self.ridesRetrievalFailed(businessError: nil, serviceError: error);
            }else{
                if responseObject!["result"]! as! String == "SUCCESS"{
                    let userRides : UserRides = Mapper<UserRides>().map(JSONObject: responseObject!["resultData"])!
                    self.receiveClosedRidesInfoOnSuccess(userRides: userRides)
                    if MyActiveRidesCache.getRidesCacheInstance() != nil && MyActiveRidesCache.getRidesCacheInstance()!.rideUpdateListeners != nil && !MyActiveRidesCache.getRidesCacheInstance()!.rideUpdateListeners.isEmpty{
                        if let rideUpdateListener = MyActiveRidesCache.getRidesCacheInstance()!.rideUpdateListeners[MyActiveRidesCache.LiveRideMapViewController_key]{
                            rideUpdateListener.refreshRideView()
                        }
                    }
                }
                else if responseObject!["result"]! as! String == "FAILURE" {
                    let businessError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])!
                    self.ridesRetrievalFailed(businessError: businessError, serviceError: nil)
                }
            }
        })
    }
    func getPassengerRide(rideId : Double) -> PassengerRide?{
        AppDelegate.getAppDelegate().log.debug("getPassengerRide() \(rideId)")
        return closedPassengerRides![rideId]
    }
    func getRiderRide(rideId : Double) -> RiderRide?{
        AppDelegate.getAppDelegate().log.debug("getRiderRide() \(rideId)")
        return closedRiderRides![rideId]
    }
    func deleteRiderRide(rideId : Double){
        AppDelegate.getAppDelegate().log.debug("deleteRiderRide() \(rideId)")
        closedRiderRides?.removeValue(forKey: rideId)
        MyRidesPersistenceHelper.deleteClosedRiderRide(rideid: rideId)
    }
    func deletePassengerRide(rideId : Double){
        AppDelegate.getAppDelegate().log.debug("deletePassengerRide() \(rideId)")
        closedPassengerRides?.removeValue(forKey: rideId)
        MyRidesPersistenceHelper.deleteClosedRiderRide(rideid: rideId)
    }
    private func ridesRetrievalFailed(businessError : ResponseError?, serviceError : NSError?){
        AppDelegate.getAppDelegate().log.debug("ridesRetrievalFailed()")
        
     
          self.initializationStatus = .InitializationFailure
       
        if (self.closedRidesListenerWaiting != nil && self.closedRidesListenerWaiting!.isEmpty == false){
            for myRidesCacheListener in self.closedRidesListenerWaiting!{
                myRidesCacheListener.onRetrievalFailure(responseError: businessError,error: serviceError)
            }
            self.closedRidesListenerWaiting = nil
        }
    }
    
    private func initializeClosedRides(userRides : UserRides){
        AppDelegate.getAppDelegate().log.debug("initializeClosedRides()")
        for riderRide in userRides.riderRides{
            self.closedRiderRides![riderRide.rideId] = riderRide
        }
        for passengerRide in userRides.passengerRides{
            self.closedPassengerRides![passengerRide.rideId] = passengerRide
        }
    }
    
    func addRideToClosedRides(ride : Ride){
        AppDelegate.getAppDelegate().log.debug("addRideToClosedRides()")
        if initializationStatus == .InitializationFailure || initializationStatus == .Uninitialized {
            return
        }
        self.addRideToCacheBasedOnRideType(ride: ride)
        self.addRideToPersistence(ride: ride)
    }
    
    private func addRideToCacheBasedOnRideType(ride : Ride){
        AppDelegate.getAppDelegate().log.debug("addRideToCacheBasedOnRideType()")
        if ride.rideType == Ride.RIDER_RIDE{
            closedRiderRides![ride.rideId] = ride as? RiderRide
        }else{
            closedPassengerRides![ride.rideId] = ride as? PassengerRide
        }
    }
    
    private func addRideToPersistence(ride : Ride) {
        AppDelegate.getAppDelegate().log.debug("addRideToPersistence()")
        if ride.isKind(of: RiderRide.self){
            MyRidesPersistenceHelper.saveClosedRiderRide(riderRide: ride as! RiderRide)
        }else if ride.isKind(of: PassengerRide.self){
            MyRidesPersistenceHelper.saveClosedPassengerRide(passengerRide: ride as! PassengerRide)
        }
    }
    
    static func clearLocalMemoryOnSessionInitializationFailure(){
        AppDelegate.getAppDelegate().log.debug("")
        sharedInstance?.removeCacheInstance()
    }
    
    func clearArchiveRides(date : NSDate?){
        if date == nil{
            closedPassengerRides?.removeAll()
            closedRiderRides?.removeAll()
            MyClosedRidesCache.getClosedRidesCacheInstance().clearClosedRidesFromPersistence()
        }else{
            for passengerRide in closedPassengerRides!.values {
                if passengerRide.startTime < date!.getTimeStamp() {
                    closedPassengerRides?.removeValue(forKey: passengerRide.rideId)
                    MyRidesPersistenceHelper.deleteClosedPassengerRide(rideid: passengerRide.rideId)
                }
            }
            for riderRide in closedRiderRides!.values {
                if riderRide.startTime < date!.getTimeStamp() {
                    closedRiderRides?.removeValue(forKey: riderRide.rideId)
                    MyRidesPersistenceHelper.deleteClosedRiderRide(rideid: riderRide.rideId)
                }
            }
        }
        
    }
    func getClosedRiderRides() -> [Double : RiderRide]?{
       return closedRiderRides
    }
    func getClosedPasssengerRides() -> [Double : PassengerRide]?{
       return closedPassengerRides
    }
}

enum ClosedRidesCacheInitializationStatus {
    case Uninitialized
    case InitializationComplete
    case InitializationFailure
    case InitializationStarted
}
