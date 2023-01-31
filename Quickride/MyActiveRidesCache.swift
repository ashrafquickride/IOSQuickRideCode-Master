//
//  MyActiveRidesCache.swift
//  Quickride
//
//  Created by KNM Rao on 12/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
import GoogleMaps
import Alamofire
import ObjectMapper
import Reachability

protocol TaxiPoolDetailsUpdateDelegate {
    func fetchNewRideDetailInfoTaxiPool()
}
typealias RideDetilInfoHandler = (_ rideDetailInfo : RideDetailInfo?,_ responseError : ResponseError?,_ error : NSError?) -> Void

public typealias ActiveRidesReceiverHandler = (_ activeRiderRides : [Double : RiderRide],_ activePassengerRides :  [Double : PassengerRide])->Void

public class MyActiveRidesCache {
    
    
    
    static let LiveRideMapViewController_key = "LiveRideMapViewController"
    static let MyRidesDetailViewController_key = "MyRidesDetailViewController"
    var activeRiderRides : [Double : RiderRide]? = [Double : RiderRide]()
    var activePassengerRides : [Double : PassengerRide]? = [Double : PassengerRide]()
    var riderRideDetailInfo : [Double : RideDetailInfo]? = [Double : RideDetailInfo]()
    //Can be made as Array after finding solution for multiple view controller pushing for same ride issue
    
    var rideUpdateListeners = [String :RideUpdateListener]()
    var rideLocationListeners = [String :RideParticipantLocationListener]()
    var riderRidesLastSyncTimes = [Double:NSDate]()
    var passengerRidesLastSyncTimes = [Double : NSDate]()
    var userId : String?
    var isRideObjectUpdateGoingOn : Bool?
    var pendingStatusUpdates : [RideStatus]? = [RideStatus]()
    var isInitializedSuccessfully = false
    var pendingRideDetailInfoToBeRetrieved = [Double : RideDetailInfo]()
    var pendingPassengerRidesGettingStatusUpdates = [Double : RideStatus]()
    var pendingRideParticipantsToBeRetrieved = [Double : RideStatus]()
    var rideParticipants = [Double: [RideParticipant]]()
    
    var delegateForTaxiPool: TaxiPoolDetailsUpdateDelegate?


    var reachability : Reachability?
  
  static var singleCacheInstance : MyActiveRidesCache?
  static let THRESHOLD_TIME_TO_CREATE_RIDE_ON_SAME_ROUTE = 60 //MINS
  static let THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES :Double = 500 //Metres
  static let THRESHOLD_DISTANCE_FOR_ACTUAL_RIDE_DISTANCE_IN_METRES :Double = 1000 //Metres
  static let THRESHOLD_TIME_BETWEEN_TWO_POINTS_FOR_DAY_IN_MINS = 2*60
  static var RECURRING_RIDES_CREATED = false
    var timer : Timer?
    
    private init(userId : String?){
        self.userId = userId?.components(separatedBy: ".")[0]
    }
    
    private func removeCacheInstance(){
        AppDelegate.getAppDelegate().log.debug("")
        self.activeRiderRides?.removeAll()
        self.activePassengerRides?.removeAll()
        self.riderRideDetailInfo?.removeAll()
        self.riderRideDetailInfo?.removeAll()
        self.rideLocationListeners.removeAll()
        self.userId = nil
    }
    
    public static func getInstance(userId : String?) -> MyActiveRidesCache? {
        AppDelegate.getAppDelegate().log.debug("")
        
        if self.singleCacheInstance == nil {
            self.singleCacheInstance = MyActiveRidesCache(userId: userId)
        }
        return self.singleCacheInstance
    }
    public static func newUserSession(userId : String){
        AppDelegate.getAppDelegate().log.debug("userId : \(userId)")
        self.singleCacheInstance = MyActiveRidesCache(userId: userId)
    }
    
    static func reInitialiseUserSession(userId : String, targetViewController : UIViewController?, activeRidesCacheListener : ActiveRidesCacheInitializationStatusListener?) {
        
        AppDelegate.getAppDelegate().log.debug("")
        MyActiveRidesCache.clearUserSession()
        MyActiveRidesCache.singleCacheInstance = MyActiveRidesCache(userId: userId)
        MyActiveRidesCache.singleCacheInstance?.initialiseRidesFromServer(userId: userId, targetViewController: targetViewController, activeRidesCacheListener: activeRidesCacheListener)
        
    }
    
    func initialiseRidesFromServer(userId : String, targetViewController : UIViewController?, activeRidesCacheListener : ActiveRidesCacheInitializationStatusListener?){
        RideServicesClient.getAllActiveRidesOfUser(userId: userId, completionHandler: { (responseObject, error) -> Void in
            if(responseObject == nil){
                self.isInitializedSuccessfully = false
                activeRidesCacheListener?.initializationCompleted()
            }
            else{
                if responseObject!["result"]! as! String == "SUCCESS"{
                    let userRides : UserRides = Mapper<UserRides>().map(JSONObject: responseObject!["resultData"])!
                    AppDelegate.getAppDelegate().log.debug("initializeRidesFromServer")
                    for riderRide in userRides.riderRides{
                        AppDelegate.getAppDelegate().log.debug("Rider Ride : \(riderRide.rideId)")
                    }
                    for passengerRide in userRides.passengerRides{
                        AppDelegate.getAppDelegate().log.debug("Passenger Ride: \(passengerRide.rideId)")
                    }
                    MyActiveRidesCache.singleCacheInstance?.initializeActiveRides(passengerRideList: userRides.passengerRides, riderRideList: userRides.riderRides)
                    MyRegularRidesCache.getInstance().receiveRegularRides(regularRiderRides: userRides.regularRiderRides,regularPassengerRides: userRides.regularPassenerRides)
                    MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.riderRideTable)
                    MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.passengerRideTable)
                    MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.regularRiderRideTable)
                    MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.regularPassengerRideTable)
                    
                    MyRidesPersistenceHelper.storeRiderRidesInBulk(riderRides: userRides.riderRides)
                    MyRidesPersistenceHelper.storePassengerRidesInBulk(passengerRides: userRides.passengerRides)
                    MyRidesPersistenceHelper.storeRegularRiderRidesInBulk(regularRiderRides: userRides.regularRiderRides)
                    MyRidesPersistenceHelper.storeRegularPassengerRidesInBulk(regularPassengerRides: userRides.regularPassenerRides)
                    if let rideUpdateListener = self.rideUpdateListeners[MyActiveRidesCache.LiveRideMapViewController_key]{
                        rideUpdateListener.refreshRideView()
                    }
                    self.isInitializedSuccessfully = true
                    activeRidesCacheListener?.initializationCompleted()
                }
                else if responseObject!["result"]! as! String == "FAILURE" {
                    let errorResponse = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    AppDelegate.getAppDelegate().log.debug("Error while loading active rides \(String(describing: errorResponse))")
                    self.isInitializedSuccessfully = false
                    activeRidesCacheListener?.initializationFailed(error: errorResponse)
                }
            }
        })
    }
    
    
    
    
    func initializeRidesFromPersistence(){
        
        let riderRides = MyRidesPersistenceHelper.getRiderRides()
        let passengerRides = MyRidesPersistenceHelper.getPassengerRides()
        AppDelegate.getAppDelegate().log.debug("initializeRidesFromPersistence")
        for riderRide in riderRides{
            AppDelegate.getAppDelegate().log.debug("Rider Ride : \(riderRide.rideId)")
        }
        for passengerRide in passengerRides{
            AppDelegate.getAppDelegate().log.debug("Passenger Ride: \(passengerRide.rideId)")
        }
        let regularRiderRides = MyRidesPersistenceHelper.getRegularRiderRides()
        let regularPassengerRides = MyRidesPersistenceHelper.getRegularPassengerRides()
        self.isInitializedSuccessfully = true
        MyActiveRidesCache.singleCacheInstance!.initializeActiveRides(passengerRideList: passengerRides, riderRideList: riderRides)
        MyRegularRidesCache.getInstance().receiveRegularRides(regularRiderRides: regularRiderRides,regularPassengerRides: regularPassengerRides)
    }
    
    func getActiveRidesFromServer(listener : MyRidesCacheListener){
        self.getActiveRidesAndUpdateInCache { (activeRiderRides, activePassengerRides) in
            
            listener.receivedActiveRides(activeRiderRides: activeRiderRides, activePassengerRides: activePassengerRides)
        }
        
    }
    
    func getActiveRidesAndUpdateInCache(handler: @escaping ActiveRidesReceiverHandler){
        RideServicesClient.getAllActiveRidesOfUser(userId: userId!, completionHandler: { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"]! as! String == "SUCCESS"{
                let userRides : UserRides = Mapper<UserRides>().map(JSONObject: responseObject!["resultData"])!
                
                self.initializeActiveRides(passengerRideList: userRides.passengerRides, riderRideList: userRides.riderRides)
                MyRegularRidesCache.getInstance().receiveRegularRides(regularRiderRides: userRides.regularRiderRides,regularPassengerRides: userRides.regularPassenerRides)
                self.isInitializedSuccessfully = true
            }
            handler(self.activeRiderRides!, self.activePassengerRides!)
        })
    }
    func updateRiderRideLastSyncedTime(rideId : Double,lastSyncedTime : NSDate){
        
        
        riderRidesLastSyncTimes[rideId] = lastSyncedTime
    }
    
    func updatePassengerRideLastSyncedTime(rideId : Double, lastSyncedTime : NSDate){
        
        
        passengerRidesLastSyncTimes[rideId] = lastSyncedTime
    }
    
    public static func resumeUserSession(userId : String){
        AppDelegate.getAppDelegate().log.debug("")
        
        singleCacheInstance = MyActiveRidesCache(userId: userId)
        singleCacheInstance?.initializeRidesFromPersistence()
        singleCacheInstance?.initialiseRidesFromServer(userId: userId, targetViewController: nil, activeRidesCacheListener: nil)
    }
    
    public static func clearUserSession(){
        AppDelegate.getAppDelegate().log.debug("")
        
        if MyActiveRidesCache.singleCacheInstance != nil{
            MyActiveRidesCache.singleCacheInstance!.removeCacheInstance()
            MyActiveRidesCache.singleCacheInstance = nil
            MyActiveRidesCache.clearPersistenceHelper()
        }
        if MyRegularRidesCache.singleInstance != nil{
            MyRegularRidesCache.getInstance().removeCacheInstance()
        }
    }
    
    public static func clearPersistenceHelper(){
        
    }
    
    public static func getRidesCacheInstance() -> MyActiveRidesCache?{
        AppDelegate.getAppDelegate().log.debug("")
        if MyActiveRidesCache.singleCacheInstance != nil{
            return MyActiveRidesCache.singleCacheInstance!
        }
        return nil
    }
    
    
    public func initializeActiveRides(passengerRideList:Array<PassengerRide>?,riderRideList : Array<RiderRide>?){
        AppDelegate.getAppDelegate().log.debug("\(String(describing: riderRideList))")
        
        activePassengerRides?.removeAll()
        activeRiderRides?.removeAll()
        AppDelegate.getAppDelegate().log.debug("initializeRidesAfterSync")
        if passengerRideList != nil{
            for passengerRide in passengerRideList!{
                activePassengerRides![passengerRide.rideId] = passengerRide
                AppDelegate.getAppDelegate().log.debug("Passenger Ride : \(passengerRide.rideId)")
            }
        }
        if riderRideList != nil{
            for riderRide in riderRideList!{
                activeRiderRides![riderRide.rideId] = riderRide
                 AppDelegate.getAppDelegate().log.debug("Rider Ride : \(riderRide.rideId)")
            }
        }
    }
    
    func getActiveRides(listener : MyRidesCacheListener) {
        AppDelegate.getAppDelegate().log.debug("")
        if isInitializedSuccessfully{
            listener.receivedActiveRides(activeRiderRides: activeRiderRides!, activePassengerRides: activePassengerRides!)
        }else{
            listener.receivedActiveRides(activeRiderRides: activeRiderRides!, activePassengerRides: activePassengerRides!)
            getActiveRidesFromServer(listener: listener)
        }
    }
    
    func getPassengerRide(passengerRideId : Double) -> PassengerRide?{
        AppDelegate.getAppDelegate().log.debug("passengerRideId : \(passengerRideId)")
        return self.activePassengerRides![passengerRideId]
    }
    
    public func addNewRide(ride : Ride){
        AppDelegate.getAppDelegate().log.debug("\(ride.rideId)")
        if ride.status == Ride.RIDE_STATUS_COMPLETED || ride.status == Ride.RIDE_STATUS_CANCELLED{
            return
        }
        if isRiderRide(ride: ride){
            
            if let riderRide = ride as? RiderRide{
                self.activeRiderRides![ride.rideId] = riderRide
                MyRidesPersistenceHelper.storeRiderRide(riderRide: riderRide)
            }
            RideManagementMqttProxy.getInstance().riderRideCreated(riderRideId: ride.rideId)
        }else {
            if let passengerRide = ride as? PassengerRide{
                self.activePassengerRides![ride.rideId] = passengerRide
                MyRidesPersistenceHelper.storePassengerRide(passengerRide: passengerRide)
            }
            
        }
        LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
        
        notifyRideStatusChangeToListener(rideStatus: RideStatus(ride :ride))
    }
    
    public func updateExistingRide(ride : Ride){
        
        AppDelegate.getAppDelegate().log.debug("\(ride.rideId)")
        if ride.rideType == Ride.PASSENGER_RIDE{
            if let passengerRide = ride as? PassengerRide{
                activePassengerRides![ride.rideId] = passengerRide
                MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide)
                
                var rideDetailInfo: RideDetailInfo?
                
                if passengerRide.taxiRideId == nil || passengerRide.taxiRideId == 0 {
                    rideDetailInfo = riderRideDetailInfo?[passengerRide.riderRideId] ?? nil
                }else{
                    rideDetailInfo = riderRideDetailInfo?[passengerRide.taxiRideId!] ?? nil
                }
                if rideDetailInfo != nil{
                    rideDetailInfo!.currentUserRide = ride
                    riderRideDetailInfo![passengerRide.riderRideId] = rideDetailInfo
                    self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                }
           }
        }else{
            if let riderRide = ride as? RiderRide{
                activeRiderRides![ride.rideId] = riderRide
                MyRidesPersistenceHelper.storeRiderRide(riderRide: riderRide)
                let rideDetailInfo = riderRideDetailInfo?[ride.rideId]
                if rideDetailInfo != nil{
                    rideDetailInfo!.currentUserRide = ride
                    rideDetailInfo!.riderRide = riderRide
                    riderRideDetailInfo![ride.rideId] = rideDetailInfo
                    self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                }
            }
        }
        
    }

    func getRideParicipantForUserId(riderRideId : Double, userId: Double) -> RideParticipant? {
        let rideDetailInfo = SharedPreferenceHelper.getRideDetailInfo(riderRideId: StringUtils.getPointsInDecimal(points: riderRideId))
        var allRideParticipants = [RideParticipant]()
        if rideDetailInfo != nil && rideDetailInfo!.rideParticipants != nil && !rideDetailInfo!.rideParticipants!.isEmpty {
            allRideParticipants = rideDetailInfo!.rideParticipants!
        } else if rideParticipants[riderRideId] != nil && !rideParticipants[riderRideId]!.isEmpty{
            allRideParticipants = rideParticipants[riderRideId]!
        }
        for rideParticipant in allRideParticipants {
            if rideParticipant.userId == userId {
                 return rideParticipant
            }
        }
        return nil
    }
    
    func getTaxiShareRideData(taxiRideId : Double, userId: Double, myRidesCacheListener: MyRidesCacheListener?) -> TaxiShareRide? {
        
         let rideDetailInfo = SharedPreferenceHelper.getRideDetailInfo(riderRideId: StringUtils.getPointsInDecimal(points: taxiRideId))
            return rideDetailInfo?.taxiShareRide
    }

    func getRideParicipants(riderRideId : Double, rideParticipantsListener : RideParticipantsListener){
        AppDelegate.getAppDelegate().log.debug("riderRideId: \(riderRideId)")
        let rideDetailInfo = SharedPreferenceHelper.getRideDetailInfo(riderRideId: StringUtils.getPointsInDecimal(points: riderRideId))
        if rideDetailInfo != nil && rideDetailInfo!.rideParticipants != nil && rideDetailInfo!.rideParticipants!.isEmpty == false{
            rideParticipantsListener.getRideParticipants(rideParticipants: rideDetailInfo!.rideParticipants!)
        }else{
            if rideParticipants[riderRideId] != nil && !rideParticipants[riderRideId]!.isEmpty{
                rideParticipantsListener.getRideParticipants(rideParticipants: rideParticipants[riderRideId]!)
                return
            }
            var userId: String?
            var pickupLat: Double?
            var pickupLng: Double?
            var dropLat: Double?
            var dropLng: Double?
            if let passengerRide = getPassengerRide(rideId: riderRideId) {
                userId = QRSessionManager.getInstance()?.getUserId()
                pickupLat = passengerRide.pickupLatitude
                pickupLng = passengerRide.pickupLongitude
                dropLat = passengerRide.dropLatitude
                dropLng = passengerRide.dropLongitude
            }
            RiderRideRestClient.getAllParticipantRides(rideId: riderRideId, userId: userId, pickupLat: pickupLat, pickupLng: pickupLng, dropLat: dropLat, dropLng: dropLng, targetViewController: nil) { (responseObject, error) -> Void in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"
                {
                    let rideParticipants = Mapper<RideParticipant>().mapArray(JSONObject:responseObject!["resultData"])!
                    self.rideParticipants[riderRideId] = rideParticipants
                    self.checkCurrentUserVerifiedStatusAndHandleChatAndCall(rideParticipants: rideParticipants)
                    rideParticipantsListener.getRideParticipants(rideParticipants: rideParticipants)
                }else{
                    rideParticipantsListener.onFailure(responseObject: responseObject, error: error)
                }
            }
        }
    }
    func updateRideRoute(rideRoute : RideRoute, rideId : Double, rideType : String){
        AppDelegate.getAppDelegate().log.debug("routeId :\(String(describing: rideRoute.routeId)) rideId: \(rideId) rideType :\(rideType)")
        if Ride.PASSENGER_RIDE == rideType{
            let passengerRide = getPassengerRide(passengerRideId: rideId)
            if passengerRide == nil{
                return
            }
            passengerRide?.routePathPolyline = rideRoute.overviewPolyline!
            passengerRide?.waypoints = rideRoute.waypoints
            passengerRide?.routeId = rideRoute.routeId
            passengerRide?.distance = rideRoute.distance
            passengerRide?.expectedEndTime = DateUtils.addMinutesToTimeStamp(time: passengerRide!.startTime, minutesToAdd: Int(rideRoute.duration!))
            MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide!)
        }
        else if Ride.RIDER_RIDE == rideType
        {
            let riderRide = getRiderRide(rideId: rideId)
            if riderRide == nil{
                return
            }
            riderRide?.routePathPolyline = rideRoute.overviewPolyline!
            riderRide?.waypoints = rideRoute.waypoints
            riderRide?.routeId = rideRoute.routeId
            riderRide?.distance = rideRoute.distance
            riderRide?.expectedEndTime = DateUtils.addMinutesToTimeStamp(time: riderRide!.startTime,minutesToAdd: Int(rideRoute.duration!))
            MyRidesPersistenceHelper.updateRiderRide(riderRide: riderRide!)
        }
    }
    public func getRideParicipants(riderRideId : Double) -> [RideParticipant] {
        AppDelegate.getAppDelegate().log.debug("riderRideId :\(riderRideId)")
        let rideDetailInfo : RideDetailInfo? = riderRideDetailInfo![riderRideId]
        if rideDetailInfo != nil && rideDetailInfo!.rideParticipants != nil {
            checkCurrentUserVerifiedStatusAndHandleChatAndCall(rideParticipants: rideDetailInfo!.rideParticipants)
            return rideDetailInfo!.rideParticipants!
        }
        return [RideParticipant]()
    }
    
    

    func getRideDetailInfo(riderRideId : Double,currentuserRide : Ride, myRidesCacheListener: MyRidesCacheListener?){
        AppDelegate.getAppDelegate().log.debug("riderRideId :\(riderRideId)")
        AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(riderRideId) : : rideDetailInfoStarted")
        if riderRideDetailInfo![riderRideId] != nil {
            let rideDetailInfo : RideDetailInfo? = riderRideDetailInfo![riderRideId]
            myRidesCacheListener?.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo!)
            return
        }

        if let rideDetailInfo = SharedPreferenceHelper.getRideDetailInfo(riderRideId: StringUtils.getStringFromDouble(decimalNumber: riderRideId)){
            if let rideId = rideDetailInfo.currentUserRide?.rideId, let rideType = rideDetailInfo.currentUserRide?.rideType{
                if rideType == Ride.RIDER_RIDE,let riderRide = getRiderRide(rideId: rideId) {
                    rideDetailInfo.currentUserRide = riderRide
                } else if let passengerRide = getPassengerRide(passengerRideId: rideId){
                    rideDetailInfo.currentUserRide = passengerRide
                }
            }
            riderRideDetailInfo![riderRideId] = rideDetailInfo
            myRidesCacheListener?.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo)
        }
//        if let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoInOffline(riderRideId: riderRideId){
//            myRidesCacheListener?.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo)
//        }
        if !QRReachability.isConnectedToNetwork(){
            if let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoInOffline(riderRideId: riderRideId){
                self.pendingRideDetailInfoToBeRetrieved[riderRideId] = rideDetailInfo
            }
            self.registerRetryListeberForFailure(QuickRideErrors.NetworkConnectionNotAvailableError)
            return
        }
        self.getRideDetailInfoFromServer(currentUserRide: currentuserRide, myRidesCacheListener: myRidesCacheListener)

    }
    
    
    func getTaxiDetailInfo(taxiRideId: Double, passengerRideId: Double , myRidesCacheListener: MyRidesCacheListener?) {
        AppDelegate.getAppDelegate().log.debug("taxiRideId :\(taxiRideId)")
        AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(taxiRideId) : : rideDetailInfoStarted")
        if riderRideDetailInfo![taxiRideId] != nil {
            let rideDetailInfo : RideDetailInfo? = riderRideDetailInfo![taxiRideId]
            myRidesCacheListener?.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo!)
            return
        }
        if !QRReachability.isConnectedToNetwork(){
            let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoInOffline(riderRideId: taxiRideId)
            if rideDetailInfo == nil{
                return
            }
            myRidesCacheListener?.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo!)
            self.registerRetryListeberForFailure(QuickRideErrors.NetworkConnectionNotAvailableError)
        }else{
            taxiPoolRideDetailInfoFromServer(taxiRideId: taxiRideId, passengerRideId: passengerRideId , myRidesCacheListener: myRidesCacheListener)
        }
    }
    
func taxiPoolRideDetailInfoFromServer(taxiRideId: Double, passengerRideId: Double , myRidesCacheListener: MyRidesCacheListener?) {
          let taxiID = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
          let userId = QRSessionManager.sharedInstance?.getUserId() ?? "0"
          let passengerRideID = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
          
          TaxiPoolRestClient.rideTaxiDetailInfo(id: taxiID, userId: userId, passengerRideId: passengerRideID) { (responseObject, error) in
              if error != nil {
              } else if responseObject!["result"] as! String == "SUCCESS"{
                let data = responseObject!["resultData"] as! [String: Any]
                let rideDetailInfo =  Mapper<RideDetailInfo>().map(JSONObject: data["rideDetailInfo"])
                rideDetailInfo?.currentUserRide = MyRidesPersistenceHelper.getPassengerRide(rideid: passengerRideId)
                

                  self.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo, myRidesCacheListener: myRidesCacheListener, handler: nil)
              }
          }
      }

    func getRideDetailInfoInOffline(riderRideId : Double) -> RideDetailInfo
    {
        AppDelegate.getAppDelegate().log.debug("riderRideId :\(riderRideId)")
        let rideDetailInfo = SharedPreferenceHelper.getRideDetailInfo(riderRideId: StringUtils.getStringFromDouble(decimalNumber: riderRideId))
        if rideDetailInfo != nil{
            rideDetailInfo!.offlineData = true
            var currentParticipantRide : Ride? = getRiderRide(rideId: riderRideId)
            if currentParticipantRide == nil{
                currentParticipantRide = getPassengerRideByRiderRideId(riderRideId: riderRideId)
            }
            else{
                if let riderRide = currentParticipantRide as? RiderRide{
                    rideDetailInfo!.riderRide = riderRide
                }
            }
            rideDetailInfo!.currentUserRide = currentParticipantRide
            return rideDetailInfo!
        }
        else{
        let rideDetailInfo =  RideDetailInfo(riderRideId: riderRideId)
        rideDetailInfo.offlineData = true
        var riderRide : RiderRide? = nil
        var currentParticipantRide : Ride? = getRiderRide(rideId: riderRideId)
        if currentParticipantRide == nil{
            let passengerRide = getPassengerRideByRiderRideId(riderRideId: riderRideId)
            if passengerRide != nil{
                let passengerInfo = RideParticipant(rideId : passengerRide!.rideId, participantId : passengerRide!.userId, participantName : passengerRide!.userName!, gender : User.USER_GENDER_UNKNOWN,isDriver :false, pickupLocation : passengerRide!.pickupAddress, dropLocation : passengerRide!.dropAddress, imageURI: nil, status: passengerRide!.status, startPoint : LatLng(lat: passengerRide!.pickupLatitude,long: passengerRide!.pickupLongitude),endPoint :LatLng(lat :passengerRide!.dropLatitude,long :passengerRide!.dropLongitude),callSupport : "1", noOfSeats: passengerRide!.noOfSeats)
                rideDetailInfo.addNewParticipant(rideParticipant: passengerInfo)
                
                let riderInfo = RideParticipant(rideId : passengerRide!.riderRideId, participantId : passengerRide!.riderId, participantName : passengerRide!.riderName, gender : User.USER_GENDER_UNKNOWN,isDriver :true, pickupLocation : nil, dropLocation : nil, imageURI: nil, status: Ride.RIDE_STATUS_SCHEDULED, startPoint : nil,endPoint : nil,  callSupport : "1", noOfSeats: passengerRide!.noOfSeats)
                rideDetailInfo.addNewParticipant(rideParticipant: riderInfo)
                
                currentParticipantRide = passengerRide
            }
            
        }
        else
        {
            riderRide = currentParticipantRide as? RiderRide
            let riderInfo =  RideParticipant(rideId : riderRide!.rideId, participantId : riderRide!.userId, participantName : riderRide!.userName!, gender : User.USER_GENDER_UNKNOWN,isDriver :true, pickupLocation : riderRide!.startAddress, dropLocation : riderRide!.endAddress, imageURI: nil, status: riderRide!.status, startPoint : LatLng(lat: riderRide!.startLatitude,long: riderRide!.startLongitude), endPoint : LatLng(lat : riderRide!.endLatitude!, long : riderRide!.endLongitude!), callSupport : "1", noOfSeats: riderRide!.noOfPassengers)
            rideDetailInfo.addNewParticipant(rideParticipant: riderInfo)
            
        }
        rideDetailInfo.currentUserRide = currentParticipantRide
        if riderRide != nil{
            rideDetailInfo.riderRide = riderRide
        }
        return rideDetailInfo
        }
    }
    func getRideDetailInfoFromServer(currentUserRide: Ride, myRidesCacheListener: MyRidesCacheListener?){
        retrieveRideDetailInfoFromServer(currentUserRide: currentUserRide, myRidesCacheListener: myRidesCacheListener, handler: nil)
    }
    
    func getRideDetailInfoFromServerByHandler(currentUserRide: Ride,handler : RideDetilInfoHandler?){
        retrieveRideDetailInfoFromServer(currentUserRide: currentUserRide, myRidesCacheListener: nil, handler: handler)
    }
    func handleRideDetailInfoRetrievalFailure(riderRideId : Double,myRidesCacheListener: MyRidesCacheListener?,handler : RideDetilInfoHandler?,error : NSError?,responseError : ResponseError?){
        if error != nil{
            pendingRideDetailInfoToBeRetrieved[riderRideId] = RideDetailInfo(riderRideId: riderRideId)
            registerRetryListeberForFailure(error)
        }
        
        if myRidesCacheListener != nil{
            myRidesCacheListener!.onRetrievalFailure(responseError: responseError,error: error)
        }
        if handler != nil{
            handler!(nil, responseError, error)
        }
        
    }
    
    func retrieveRideDetailInfoFromServer(currentUserRide: Ride, myRidesCacheListener: MyRidesCacheListener?,handler : RideDetilInfoHandler?){
        
        var riderRideId : Double
        if let passengerRide = currentUserRide as? PassengerRide {
            riderRideId = passengerRide.riderRideId
        }else {
            riderRideId = currentUserRide.rideId
        }
        
        RideServicesClient.getRideDetailInfo(riderRideId: riderRideId, currentUserRideId: currentUserRide.rideId, userId: currentUserRide.userId) { (responseObject, error) in
            let result = RestResponseParser<RideViewDetails>().parse(responseObject: responseObject, error: error)
            if let rideViewUtils = result.0 {
                let rideDetailInfo = rideViewUtils.rideDetailInfo
                if currentUserRide is PassengerRide {
                    rideDetailInfo?.currentUserRide = rideViewUtils.currentUserPsgrRide
                }else {
                    rideDetailInfo?.currentUserRide = rideViewUtils.currentUserRiderRide
                }
                self.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo, myRidesCacheListener: myRidesCacheListener, handler: handler)
            }else {
                self.handleRideDetailInfoRetrievalFailure(riderRideId: riderRideId, myRidesCacheListener: myRidesCacheListener, handler: handler, error: result.2, responseError: result.1)
            }
        }
    }
    
    private func assignDistanceFromRiderStartToPickUp(currentRide: Ride, rideParticipant: RideParticipant) {
        rideParticipant.distanceFromRiderStartToPickUp = LocationClientUtils.getDistanceBetweenTwoPointOnRoute(startLat: currentRide.startLatitude, startLng: currentRide.startLongitude, endLat: rideParticipant.startPoint?.latitude ?? 0, endLng: rideParticipant.startPoint?.longitude ?? 0, routePolyLine: currentRide.routePathPolyline)
    }
    func checkCurrentUserVerifiedStatusAndHandleChatAndCall(rideParticipants : [RideParticipant]?){
        if rideParticipants == nil{return}
        for rideParticipant in rideParticipants!{
            if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus != 0 && !rideParticipant.enableChatAndCall{
                rideParticipant.enableChatAndCall = true
            }
        }
    }
    
    func receiveRideDetailInfo(rideDetailInfo : RideDetailInfo?,myRidesCacheListener: MyRidesCacheListener?,handler : RideDetilInfoHandler?){
        AppDelegate.getAppDelegate().log.debug("rideDetailInfo :\(String(describing: rideDetailInfo))")
        if rideDetailInfo?.taxiShareRide == nil {
        if rideDetailInfo == nil || rideDetailInfo?.isLoaded() == false{
            return
        }
        }
        AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(String(describing:rideDetailInfo!.riderRideId))  : rideDetailInfo completed")
        AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(String(describing: rideDetailInfo!.riderRideId)) : : cache synchronisation started")
        for rideParticipant in rideDetailInfo!.rideParticipants! {
            if rideDetailInfo?.riderRide != nil{
            self.assignDistanceFromRiderStartToPickUp(currentRide: rideDetailInfo!.riderRide!, rideParticipant: rideParticipant)
            }else{
                
                rideParticipant.distanceFromRiderStartToPickUp = LocationClientUtils.getDistanceBetweenTwoPointOnRoute(startLat: rideDetailInfo?.taxiShareRide?.startLatitude ?? 0, startLng: rideDetailInfo?.taxiShareRide?.startLongitude ?? 0, endLat: rideParticipant.startPoint?.latitude ?? 0, endLng: rideParticipant.startPoint?.longitude ?? 0, routePolyLine: rideDetailInfo?.taxiShareRide?.routePathPolyline ?? "")
            }
        }
        let updatedRideDetailInfo = updateRideParticipantLocations(rideDetailInfo: rideDetailInfo!)
        if let existing = SharedPreferenceHelper.getRideDetailInfo(riderRideId: StringUtils.getStringFromDouble(decimalNumber: updatedRideDetailInfo.riderRideId)),let route = existing.riderRideRoutePathData{
            updatedRideDetailInfo.riderRideRoutePathData = route
        }
        riderRideDetailInfo![(rideDetailInfo?.riderRideId)!] = updatedRideDetailInfo
        syncRideData(rideDetailInfo: rideDetailInfo!)
        pendingRideDetailInfoToBeRetrieved.removeValue(forKey: rideDetailInfo!.riderRideId!)
        if myRidesCacheListener != nil {
            AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(String(describing: rideDetailInfo!.riderRideId)) : : UI Refresh started")
            myRidesCacheListener?.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo!)
            AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(String(describing: rideDetailInfo!.riderRideId)) : : UI Refresh completed")
        }else if handler != nil {
            handler!(rideDetailInfo!, nil, nil)
        }else{
            notifyRideDetailInfoToListener(rideDetailInfo: rideDetailInfo!)
        }
        if updatedRideDetailInfo.rideParticipantLocations == nil || updatedRideDetailInfo.rideParticipantLocations!.isEmpty{
            let existingRideDetailInfo = self.getRideDetailInfoInOffline(riderRideId: rideDetailInfo!.riderRideId!)
            updatedRideDetailInfo.rideParticipantLocations = existingRideDetailInfo.rideParticipantLocations
        }
        self.updateRideDetailInfo(rideDetailInfo: updatedRideDetailInfo)
        AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(String(describing: rideDetailInfo!.riderRideId)) : : cache synchronisation completed")
    }
    func updateRideParticipantLocations( rideDetailInfo : RideDetailInfo) -> RideDetailInfo {
        
        let existingRideDetailInfo = riderRideDetailInfo![rideDetailInfo.riderRideId!]
        if existingRideDetailInfo == nil{
            return rideDetailInfo
        }else{
            
            if rideDetailInfo.rideParticipantLocations == nil || rideDetailInfo.rideParticipantLocations!.isEmpty {
                rideDetailInfo.rideParticipantLocations = existingRideDetailInfo!.rideParticipantLocations
            }else {
                var currentRideParticipantLocations = RideViewUtils.getRideParticipantMapFromList(rideParticipantLocations: existingRideDetailInfo?.rideParticipantLocations)
                for  location in
                    rideDetailInfo.rideParticipantLocations! {
                        let existingLocation = currentRideParticipantLocations[location.userId!]
                        if existingLocation == nil {
                            currentRideParticipantLocations[location.userId!] = location
                        } else if (existingLocation!.lastUpdateTime != nil && location.lastUpdateTime! > existingLocation!.lastUpdateTime!) {
                            currentRideParticipantLocations[location.userId!] = location
                        }
                }
                rideDetailInfo.rideParticipantLocations?.removeAll()
                for  location in
                    currentRideParticipantLocations {
                        rideDetailInfo.rideParticipantLocations?.append(location.1)
                }
            }
        }
        return rideDetailInfo
    }
    
    func syncRideData(rideDetailInfo : RideDetailInfo){
        AppDelegate.getAppDelegate().log.debug("\(String(describing: rideDetailInfo.currentUserRide?.rideId))")
        let currentParticipantRide : Ride? = rideDetailInfo.currentUserRide
        if currentParticipantRide == nil{return}
        if isRiderRide(ride: currentParticipantRide!){
            syncRiderRide(rideDetailInfo: rideDetailInfo, currentParticipantRide: currentParticipantRide!)
        }else{
            syncPassengerRide(rideDetailInfo: rideDetailInfo, currentParticipantRide: currentParticipantRide!)
        }
    }
    
    func syncPassengerRide(rideDetailInfo : RideDetailInfo, currentParticipantRide : Ride){
        AppDelegate.getAppDelegate().log.debug("\(currentParticipantRide.rideId)")
        var passengerRide : PassengerRide? = activePassengerRides![currentParticipantRide.rideId]
        if passengerRide == nil {return}
        rideDetailInfo.currentUserRide = passengerRide
        var rideParticipant : RideParticipant? = rideDetailInfo.getScheduledRideParticipant(rideParticipantId: currentParticipantRide.userId)
        
        if rideParticipant == nil{
            rideParticipant = rideDetailInfo.getRideParticipant(rideParticipantId: currentParticipantRide.userId)
        }
        if rideParticipant == nil{
            PassengerRideServiceClient.getPassengerRide(rideId: passengerRide!.rideId, targetViewController: nil) { (responseObject, error) -> Void in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let ride = Mapper<PassengerRide>().map(JSONObject: responseObject!["resultData"])
                    if ride != nil && ride!.status == Ride.RIDE_STATUS_REQUESTED {
                        self.activePassengerRides![passengerRide!.rideId] = ride
                    	MyRidesPersistenceHelper.updatePassengerRide(passengerRide: ride!)
                        let rideStatus : RideStatus = RideStatus(rideId: ride!.rideId,userId: ride!.userId,status: ride!.status,rideType: ride!.rideType!,joinedRideId: ride!.riderRideId,joinedRideStatus: nil)
                        self.notifyRideStatusChangeToListener(rideStatus: rideStatus)
                    }
                    else{
                        passengerRide?.status = Ride.RIDE_STATUS_CANCELLED
                        self.checkStatusForMovingFromActiveToClosure(ride: passengerRide!)
                    }
                    
                }
                else{
                    passengerRide?.status = Ride.RIDE_STATUS_CANCELLED
                    self.checkStatusForMovingFromActiveToClosure(ride: passengerRide!)
                }
            }
            
        }
        else{
            let status : String? = rideParticipant?.status
            passengerRide?.status = status!
            if isRideClosed(status: status!){
                checkStatusForMovingFromActiveToClosure(ride: passengerRide!)
            }
            if isRideRequested(status: status!){
                passengerRide = unJoinPassengerFromRiderRide(ride: passengerRide!)
            }
            activePassengerRides![passengerRide!.rideId] = passengerRide
            MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide!)
        }
    }
    
    private func isRideRequested(status : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("status :\(status)")
        
        return Ride.RIDE_STATUS_REQUESTED == status
    }
    func updateRideParticipantStatusAndNotify(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        let rideDetailInfo = riderRideDetailInfo![rideStatus.joinedRideId]
        if rideDetailInfo == nil{
            return
        }
        updateRideDetailInfoForParticipantStatusUpdate(rideDetailInfo: rideDetailInfo!, rideStatus: rideStatus)
        notifyRideStatusChangeToListener(rideStatus: rideStatus)
    }
    
    private func syncRiderRide(rideDetailInfo : RideDetailInfo, currentParticipantRide : Ride){
        AppDelegate.getAppDelegate().log.debug("\(currentParticipantRide.rideId)")
        
        let riderRide : RiderRide? = activeRiderRides![currentParticipantRide.rideId]
        if riderRide == nil {return}
        rideDetailInfo.currentUserRide = riderRide
        var rideParticipant : RideParticipant? = rideDetailInfo.getScheduledRideParticipant(rideParticipantId: currentParticipantRide.userId)
        
        if rideParticipant == nil{
            rideParticipant = rideDetailInfo.getRideParticipant(rideParticipantId: currentParticipantRide.userId)
        }
        if rideParticipant == nil {
            return
        }
        riderRide?.status = rideParticipant!.status
        if isRideClosed(status: (riderRide?.status)!){
            checkStatusForMovingFromActiveToClosure(ride: riderRide!)
        }
        
        let capacity : Int = Int((riderRide?.availableSeats)!) + Int((riderRide?.noOfPassengers)!)
        let numberOfPassengers : Int = (rideDetailInfo.rideParticipants?.count)! - 1
        let availableSeats : Int = capacity - numberOfPassengers
        riderRide?.noOfPassengers = numberOfPassengers
        riderRide?.availableSeats = availableSeats
        activeRiderRides![riderRide!.rideId] = riderRide
        MyRidesPersistenceHelper.updateRiderRide(riderRide: riderRide!)
        
    }
    
    private func isRideClosed(status : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("status :\(status)")
        return Ride.RIDE_STATUS_CANCELLED == status || Ride.RIDE_STATUS_COMPLETED == status
    }
    
    public func rideDetailInfoRetrievalFailed(){
        
    }
    
    public func checkStatusForMovingFromActiveToClosure(ride : Ride){
        AppDelegate.getAppDelegate().log.debug("\(ride.rideId)")
        if ride.status == Ride.RIDE_STATUS_CANCELLED || ride.status == Ride.RIDE_STATUS_COMPLETED{
            if ride.status == Ride.RIDE_STATUS_COMPLETED{
                ride.actualEndtime = NSDate().timeIntervalSince1970*1000
            }
            let rideType : String = ride.rideType!
            
            if Ride.RIDER_RIDE == rideType{
                deleteRiderRideAndSubscriptions(ride: ride as! RiderRide)
                if ride.status == Ride.RIDE_STATUS_CANCELLED {
                    removeRideDetailInformationForRiderRide(riderRideId: ride.rideId)
                }
                
            }else if Ride.PASSENGER_RIDE == rideType{
                if ride.status == Ride.RIDE_STATUS_CANCELLED {
                    removeRideDetailInformationForRiderRide(riderRideId: (ride as! PassengerRide).riderRideId)
                }
                deletePassengerRideAndSubscriptions(ride: ride as! PassengerRide)
            }
            SharedPreferenceHelper.clearIgnoredRideIds(rideId: ride.rideId)
            LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
            MyClosedRidesCache.getClosedRidesCacheInstance().addRideToClosedRides(ride: ride)
        }
    }
    
    private func deletePassengerRideAndSubscriptions(ride : PassengerRide){
        AppDelegate.getAppDelegate().log.debug("\(ride.rideId)")
        RideManagementMqttProxy.getInstance().userUnJoinedRiderRide(riderRideId: ride.rideId,passengerRideId: ride.riderRideId)
        NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupValue: StringUtils.getStringFromDouble(decimalNumber: ride.rideId))
        MyRidesPersistenceHelper.deletePassengerRide(rideid: ride.rideId)
        activePassengerRides?.removeValue(forKey: ride.rideId)
    }
    
    func deleteRiderRideAndSubscriptions(ride : RiderRide)
    {
        AppDelegate.getAppDelegate().log.debug("rideId :\(ride.rideId)")
        RideManagementMqttProxy.getInstance().riderRideClosed(riderRideId: ride.rideId)
        MyRidesPersistenceHelper.deleteRiderRide(rideid: ride.rideId)
        activeRiderRides?.removeValue(forKey: ride.rideId)
    }
    
    
    func updateRideStatus(newRideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(newRideStatus.rideId) joinedRideId :\(newRideStatus.joinedRideId)")
        if newRideStatus.joinedRideType == "TaxiShare" {
            delegateForTaxiPool?.fetchNewRideDetailInfoTaxiPool()
            
        }else{
            
            if self.userId! == StringUtils.getStringFromDouble(decimalNumber: newRideStatus.userId){
                if isStatusUpdateRedundant(newRideStatus: newRideStatus){
                    return
                }
                if newRideStatus.rideType == Ride.RIDER_RIDE {
                    let ride :RiderRide? = activeRiderRides![newRideStatus.rideId]
                    if ride == nil{
                        return
                    }
                    let rideStatus = ride!.prepareRideStatusObject()
                    if !rideStatus.isValidStatusChange(newStatus: newRideStatus.status!){
                        return
                    }
                    updateRiderRideStatusForCurrentUser(rideStatus: newRideStatus)
                }else{
                    let ride :PassengerRide? = activePassengerRides![newRideStatus.rideId]
                    if ride == nil{
                        return
                    }

                    let rideStatus = ride!.prepareRideStatusObject()
                    if !rideStatus.isValidStatusChange(newStatus: newRideStatus.status!){
                        return
                    }
                    updatePassengerRideStatusForCurrentUser(rideStatus: newRideStatus)
                }
            }else {
                if newRideStatus.rideType == Ride.RIDER_RIDE {
                    handleUpdateForCurrentUserConnectedRiderRideStatusChange(rideStatus: newRideStatus)
                }else{
                    handleUpdateForCurrentUserRiderRideOtherParticipantStatusChange(rideStatus: newRideStatus)
                }
            }
            if(isRideObjectUpdateGoingOn == true){
                pendingStatusUpdates?.append(newRideStatus)
                
            }else{
                notifyRideStatusChangeToListener(rideStatus: newRideStatus)
            }
        }
    }
    
    static func updateRideStatusInPersistence(newRideStatus : RideStatus){
        if let userId = SharedPreferenceHelper.getLoggedInUserId(){
            if newRideStatus.userId == Double(userId){
                if newRideStatus.rideType == Ride.RIDER_RIDE {
                    let ride :RiderRide? = MyRidesPersistenceHelper.getRiderRide(rideid: newRideStatus.rideId)
                    if ride == nil{
                        return
                    }
                    if !newRideStatus.isValidStatusChange(newStatus: newRideStatus.status!){
                        return
                    }
                    updateRiderRideStatusForCurrentUserInPersistence(rideStatus: newRideStatus,riderRide : ride!)
                }else{
                    let ride :PassengerRide? = MyRidesPersistenceHelper.getPassengerRide(rideid: newRideStatus.rideId)
                    if ride == nil{
                        return
                    }
                    if !newRideStatus.isValidStatusChange(newStatus: newRideStatus.status!){
                        return
                    }
                    updatePassengerRideStatusForCurrentUserInPersistence(rideStatus : newRideStatus, passengerRide: ride!)
                }
            }else {
                if newRideStatus.rideType == Ride.RIDER_RIDE {
                    handleUpdateForCurrentUserConnectedRiderRideStatusChangeInPersistence(rideStatus: newRideStatus)
                }else{
                    handleUpdateForCurrentUserRiderRideOtherParticipantStatusChangeInPersistence(rideStatus: newRideStatus)
                }
            }
        }
    }
    
    static func updateRiderRideStatusForCurrentUserInPersistence(rideStatus : RideStatus,riderRide : RiderRide){
        let status : String? = rideStatus.status
        
        riderRide.status = status!
        
        if(status == Ride.RIDE_STATUS_STARTED){
            riderRide.actualStartTime = NSDate().timeIntervalSince1970*1000
        }
        if Ride.RIDE_STATUS_CANCELLED == rideStatus.status || Ride.RIDE_STATUS_COMPLETED == rideStatus.status{
            MyRidesPersistenceHelper.deleteRiderRide(rideid: riderRide.rideId)
        }else{
            MyRidesPersistenceHelper.updateRiderRide(riderRide: riderRide)
        }
    }
    
    static func updatePassengerRideStatusForCurrentUserInPersistence(rideStatus : RideStatus,passengerRide : PassengerRide){
        let status : String? = rideStatus.status
        if Ride.RIDE_STATUS_REQUESTED == status{
            updatePassengerRideParamsForUnjoinAndSaveInPersistence(ride: passengerRide)
        }else if(status == Ride.RIDE_STATUS_STARTED){
            passengerRide.actualStartTime = NSDate().timeIntervalSince1970*1000
            passengerRide.status = status!
            MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide)
        }else if Ride.RIDE_STATUS_SCHEDULED == status{
            passengerRide.status = status!
            passengerRide.riderRideId = rideStatus.joinedRideId
            MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide)
        }else{
            MyRidesPersistenceHelper.deletePassengerRide(rideid: passengerRide.rideId)
        }
        
    }
    
    
    private func isStatusUpdateRedundant(newRideStatus : RideStatus) -> Bool{
        AppDelegate.getAppDelegate().log.debug("rideId :\(newRideStatus.rideId) joinedRideId :\(newRideStatus.joinedRideId)")
        var isReduntant : Bool = false
        let rideId : Double = newRideStatus.rideId
        var existingRide : Ride?
        if newRideStatus.rideType == Ride.RIDER_RIDE{
            existingRide = activeRiderRides![rideId]
            
        }else{
            existingRide = activePassengerRides![rideId]
        }
        
        if existingRide == nil{
            isReduntant = true
        }else if existingRide?.status == newRideStatus.status {
            isReduntant = true
        }
        return isReduntant
    }
    
    
    
    private func updateRiderRideStatusForCurrentUser(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        let status : String? = rideStatus.status
        let ride : RiderRide? = self.activeRiderRides![rideStatus.rideId]
        
        if ride == nil {return}
        ride?.status = status!
        
        if(status == Ride.RIDE_STATUS_STARTED){
            ride?.actualStartTime = NSDate().timeIntervalSince1970*1000
        }
        if isRideClosed(status: status!){
            checkStatusForMovingFromActiveToClosure(ride: ride!)
        }else{
            let rideDetailsInfo : RideDetailInfo? = getRideDetailInfoIfExist(riderRideId: ride?.rideId)
            if rideDetailsInfo != nil {
                rideDetailsInfo?.updateRiderRideStatus(status: status!)
                self.updateRideDetailInfo(rideDetailInfo: rideDetailsInfo)
            }
            MyRidesPersistenceHelper.updateRiderRide(riderRide: ride!)
        }
    }
    
    private func updatePassengerRideStatusForCurrentUser(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        let status : String? = rideStatus.status
        let rideId : Double = rideStatus.rideId
        let passengerRide : PassengerRide? = activePassengerRides![rideId]
        if passengerRide == nil{
            return
        }
        if Ride.RIDE_STATUS_REQUESTED == status{
            unJoinPassengerFromRiderRide(ride: passengerRide!)
            RideManagementMqttProxy.getInstance().userUnJoinedRiderRide(riderRideId: rideStatus.joinedRideId, passengerRideId: rideStatus.rideId)
            LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
            NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupValue: String(rideStatus.rideId))
            passengerRide?.status = rideStatus.status!
            activePassengerRides![passengerRide!.rideId] = passengerRide
            
        }else if(status == Ride.RIDE_STATUS_STARTED){
            passengerRide?.actualStartTime = NSDate().timeIntervalSince1970*1000
            passengerRide?.status = status!
            activePassengerRides![passengerRide!.rideId] = passengerRide
            let rideDetailInfo : RideDetailInfo? = getRideDetailInfoIfExist(riderRideId: rideStatus.joinedRideId)
            if rideDetailInfo != nil {
                rideDetailInfo?.updateRideParticipantStatus(participantId: rideStatus.userId, status: rideStatus.status!)
                self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                //reloadPassengerRideDetails(rideStatus: rideStatus)
            }
        }else if Ride.RIDE_STATUS_SCHEDULED == status{
            passengerRide?.status = status!
            passengerRide?.riderRideId = rideStatus.joinedRideId
            activePassengerRides![passengerRide!.rideId] = passengerRide
            reloadPassengerRideDetails(rideStatus: rideStatus)
            
        }
        else if Ride.RIDE_STATUS_COMPLETED == status{
            passengerRide!.status = rideStatus.status!
            activePassengerRides![passengerRide!.rideId] = passengerRide
            RideManagementUtils.completePassengerRide(riderRideId: passengerRide!.riderRideId, passengerRideId: passengerRide!.rideId, userId: passengerRide!.userId, targetViewController: nil, rideCompletionActionDelegate: nil)
            checkStatusForMovingFromActiveToClosure(ride: passengerRide!)
            removeNotificationForPassengerCancellationOrCompletingRide(rideStatus: rideStatus)
        }else{
            
            passengerRide!.status = rideStatus.status!
            activePassengerRides![passengerRide!.rideId] = passengerRide
            let rideDetailInfo = getRideDetailInfoIfExist(riderRideId: rideStatus.joinedRideId)
            if  rideDetailInfo != nil {
                rideDetailInfo!.updateRideParticipantStatus(participantId: rideStatus.userId,status : rideStatus.status!)
                self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
            }
            checkStatusForMovingFromActiveToClosure(ride: passengerRide!)
            removeNotificationForPassengerCancellationOrCompletingRide(rideStatus: rideStatus)
        }
        MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide!)
    }
    func removeNotificationForPassengerCancellationOrCompletingRide( rideStatus :RideStatus)
    {
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        if Ride.RIDE_STATUS_COMPLETED == rideStatus.status || Ride.RIDE_STATUS_CANCELLED == rideStatus.status{
            let store = NotificationStore.getInstanceIfExists()
            if store != nil{
                store?.removeInvitationWithGroupNameAndGroupValue(groupName: UserNotification.NOT_GRP_PASSENGER_RIDE, groupValue: String(rideStatus.rideId))
                store?.removeOldNotificationOfSameGroupValue(groupName: UserNotification.NOT_GRP_PASSENGER_RIDE, groupValue: String(rideStatus.rideId))
                store?.removeOldNotificationOfSameGroupValue(groupValue: String(rideStatus.rideId))
            }
        }
    }
    func validateAndDisplayRideConfimrationDialogue(_ ride: PassengerRide?,_ rideStatus : RideStatus) {
        if(Ride.RIDE_STATUS_SCHEDULED == rideStatus.status)
        {
            let rideDetailInfo = self.getRideDetailInfoIfExist(riderRideId: rideStatus.joinedRideId)
            
            var riderVehicle : Vehicle?
            if rideDetailInfo != nil{
                let rider = RideViewUtils.getRideParticipantObjForParticipantId(participantId: ride!.riderId, rideParticipants: rideDetailInfo?.rideParticipants)
                let currentUser = RideViewUtils.getRideParticipantObjForParticipantId(participantId: ride!.userId, rideParticipants: rideDetailInfo?.rideParticipants)
                if rider == nil{
                    return
                }
                if rider!.pickUpTime == nil{
                    rider!.pickUpTime = ride!.pickupTime
                }
                if ride!.newFare != -1{
                    rider!.points = ride!.newFare
                }else{
                    rider!.points = ride!.points
                }
                
                riderVehicle = Vehicle(ownerId: rideDetailInfo!.riderRide!.userId, vehicleModel: rideDetailInfo!.riderRide!.vehicleModel, vehicleType: rideDetailInfo!.riderRide!.vehicleType, registrationNumber: rideDetailInfo!.riderRide!.vehicleNumber, capacity: rideDetailInfo!.riderRide!.capacity, fare: rideDetailInfo!.riderRide!.farePerKm, makeAndCategory: rideDetailInfo!.riderRide!.makeAndCategory, additionalFacilities: nil, riderHasHelmet: false)
                self.displayJoinedDialog(currentRide: rideDetailInfo!.currentUserRide, rideId: ride!.riderRideId, currentRideType: Ride.PASSENGER_RIDE, joinedUserId: ride!.userId, currentUser: currentUser, rideParticipant: rider!, riderVehicle: riderVehicle, riderRide: rideDetailInfo!.riderRide!)
            }else{
                self.getRideDetailInfoFromServerByHandler(currentUserRide: ride!, handler: { (rideDetailInfo,responseError,error) in
                    if rideDetailInfo != nil{
                        let rider = RideViewUtils.getRideParticipantObjForParticipantId(participantId: ride!.riderId, rideParticipants: rideDetailInfo!.rideParticipants)
                        let currentUser = RideViewUtils.getRideParticipantObjForParticipantId(participantId: ride!.userId, rideParticipants: rideDetailInfo?.rideParticipants)
                        if rider == nil{
                            return
                        }
                        if rider!.pickUpTime == nil{
                            rider!.pickUpTime = ride!.pickupTime
                        }
                        if ride!.newFare != -1{
                            rider!.points = ride!.newFare
                        }else{
                            rider!.points = ride!.points
                        }
                        
                        riderVehicle = Vehicle(ownerId: rideDetailInfo!.riderRide!.userId, vehicleModel: rideDetailInfo!.riderRide!.vehicleModel, vehicleType: rideDetailInfo!.riderRide!.vehicleType, registrationNumber: rideDetailInfo!.riderRide!.vehicleNumber, capacity: rideDetailInfo!.riderRide!.capacity, fare: rideDetailInfo!.riderRide!.farePerKm, makeAndCategory: rideDetailInfo!.riderRide!.makeAndCategory, additionalFacilities: nil, riderHasHelmet: false)
                        self.displayJoinedDialog(currentRide: rideDetailInfo!.currentUserRide, rideId: ride!.riderRideId, currentRideType: Ride.PASSENGER_RIDE, joinedUserId: ride!.userId, currentUser: currentUser, rideParticipant: rider!, riderVehicle: riderVehicle, riderRide: rideDetailInfo!.riderRide!)
                    }
                    
                })
            }
            
            
        }
    }
    
    private func reloadPassengerRideDetails(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        
        isRideObjectUpdateGoingOn = true
        
        PassengerRideServiceClient.getPassengerRide(rideId: rideStatus.rideId, targetViewController: nil) { (responseObject, error) -> Void in
            if responseObject != nil{
                if responseObject!["result"] as! String == "SUCCESS"{
                    let ride = Mapper<PassengerRide>().map(JSONObject: responseObject!["resultData"])
                    RideManagementMqttProxy.getInstance().userJoinedRiderRide(riderRideId: (ride?.riderRideId)! , passengerRideId: (ride?.rideId)!)
                    self.updateExistingRide(ride: ride!)
                    LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
                    self.pendingStatusUpdates?.append(rideStatus)
                    self.pendingPassengerRidesGettingStatusUpdates.removeValue(forKey: rideStatus.rideId)
                    
                    self.processPeningRideStatusUpdates()
                    
                    self.validateAndDisplayRideConfimrationDialogue(ride,rideStatus)
                    self.isRideObjectUpdateGoingOn = false
                }else if responseObject!["result"] as! String == "FAILURE"{
                    self.processPeningRideStatusUpdates()
                    self.isRideObjectUpdateGoingOn = false
                }
            }else{
                self.isRideObjectUpdateGoingOn = false
                self.pendingPassengerRidesGettingStatusUpdates[rideStatus.rideId] = rideStatus
                self.registerRetryListeberForFailure(error)
            }
        }
    }

    func displayJoinedDialog(currentRide: Ride?, rideId : Double, currentRideType : String,joinedUserId : Double,currentUser : RideParticipant?,rideParticipant : RideParticipant,riderVehicle : Vehicle?, riderRide: RiderRide)
    {
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideId) joinedUserId :\(joinedUserId)")
        if UIApplication.shared
            .keyWindow != nil && UIApplication.shared.keyWindow!.subviews.last != nil && UIApplication.shared.keyWindow!.subviews.last!.isKind(of: TipsView.classForCoder()){
            UIApplication.shared.keyWindow!.subviews.last!.removeFromSuperview()
        }
        moveToRideJoinView(currentRide: currentRide, rideId: rideId, currentRideType: currentRideType, currentUser: currentUser, joinedUserId: joinedUserId, rideParticipant: rideParticipant, riderVehicle: riderVehicle, riderRide: riderRide)
    }
    
    func moveToRideJoinView(currentRide: Ride?, rideId : Double, currentRideType : String,currentUser : RideParticipant?,joinedUserId : Double,rideParticipant : RideParticipant,riderVehicle : Vehicle?, riderRide: RiderRide){
    
        if currentRideType == Ride.PASSENGER_RIDE {
            if let rideInvitation = RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: rideId, passengerRideId: currentRide?.rideId ?? 0, rideType: currentRideType, userId: rideParticipant.userId), rideInvitation.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED {
                let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
                mainContentVC.initializeData(ride: currentRide!, matchedUserList: [MatchedRider(riderRide: riderRide, rideParticipant: rideParticipant, currentRideParticipant: currentUser)], viewType: DetailViewType.RideConfirmView, selectedIndex: 0, startAndEndChangeRequired: false, selectedUserDelegate: nil)
                ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: mainContentVC, animated: true)
            } else {
                moveToRideConfirmationPage(rideId : rideId, currentRideType : currentRideType,currentUser : currentUser,joinedUserId : joinedUserId,rideParticipant : rideParticipant,riderVehicle : riderVehicle)
            }
        } else if currentRideType == Ride.RIDER_RIDE {
            moveToRideConfirmationPage(rideId : rideId, currentRideType : currentRideType,currentUser : currentUser,joinedUserId : joinedUserId,rideParticipant : rideParticipant,riderVehicle : riderVehicle)
        }
    }
    
    func moveToRideConfirmationPage(rideId : Double, currentRideType : String,currentUser : RideParticipant?,joinedUserId : Double,rideParticipant : RideParticipant,riderVehicle : Vehicle?) {
        
        if RideJoinConfirmationViewController.rideConfirmationDialogue == nil {
            showPresentRideConfirmationAlert(rideId: rideId, currentRideType: currentRideType, currentUser: currentUser, joinedUserId: joinedUserId, rideParticipant: rideParticipant, riderVehicle: riderVehicle)
        } else if RideJoinConfirmationViewController.rideConfirmationDialogue!.rideId == rideId {
            RideJoinConfirmationViewController.rideConfirmationDialogue!.appendNewParticipant(rideParticipant: rideParticipant)
        } else {
            RideJoinConfirmationViewController.rideConfirmationDialogue?.view.removeFromSuperview()
            RideJoinConfirmationViewController.rideConfirmationDialogue = nil
            showPresentRideConfirmationAlert(rideId: rideId, currentRideType: currentRideType, currentUser: currentUser, joinedUserId: joinedUserId, rideParticipant: rideParticipant, riderVehicle: riderVehicle)
        }
    }
    
    func showPresentRideConfirmationAlert(rideId : Double, currentRideType : String,currentUser : RideParticipant?,joinedUserId : Double,rideParticipant : RideParticipant,riderVehicle : Vehicle?) {
        
        let rideJoinConfirmationViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideJoinConfirmationViewController") as! RideJoinConfirmationViewController
        rideJoinConfirmationViewController.initializeDataBeforePresenting(rideId: rideId, rideType: currentRideType, currentUser: currentUser, joinedParticipant: rideParticipant, riderVehicle: riderVehicle, viewController: ViewControllerUtils.getCenterViewController())
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideJoinConfirmationViewController)
    }
    private func processPeningRideStatusUpdates(){
        AppDelegate.getAppDelegate().log.debug("")
        for pendingRideStatus in pendingStatusUpdates!{
            notifyRideStatusChangeToListener(rideStatus: pendingRideStatus)
        }
        pendingStatusUpdates?.removeAll()
    }
    
    public func removeRideDetailInformationForRiderRide(riderRideId : Double){
        AppDelegate.getAppDelegate().log.debug("riderRideId :\(riderRideId)")
        riderRideDetailInfo?.removeValue(forKey: riderRideId)
        SharedPreferenceHelper.clearRideDetailInfo(riderRideId: StringUtils.getStringFromDouble(decimalNumber: riderRideId))
    }
    
    private func handleUpdateForCurrentUserConnectedRiderRideStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        let currentUserPassengerRide : PassengerRide? = getPassengerRideByRiderRideId(riderRideId: rideStatus.rideId)
        if currentUserPassengerRide == nil {return}
        
        
        let rideDetailInfo : RideDetailInfo? = getRideDetailInfoIfExist(riderRideId: rideStatus.rideId)
        if rideDetailInfo != nil {
            let participant = rideDetailInfo?.getRideParticipant(rideParticipantId: rideStatus.userId)
            if participant != nil{
                let participantStatus = participant!.getRideStatus()
                if participantStatus.isValidStatusChange(newStatus: rideStatus.status!){
                    rideDetailInfo?.updateRiderRideStatus(status: rideStatus.status!)
                    self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                }
            }
        }
        if Ride.RIDE_STATUS_CANCELLED == rideStatus.status{
            unJoinPassengerFromRiderRide(ride: currentUserPassengerRide!)
            RideManagementMqttProxy.getInstance().userUnJoinedRiderRide(riderRideId: rideStatus.joinedRideId, passengerRideId: rideStatus.rideId)
            NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupValue: StringUtils.getStringFromDouble(decimalNumber: currentUserPassengerRide?.rideId))
        }else if Ride.RIDE_STATUS_COMPLETED == rideStatus.status{
            if currentUserPassengerRide?.status == Ride.RIDE_STATUS_SCHEDULED{
                unJoinPassengerFromRiderRide(ride: currentUserPassengerRide!)
                RideManagementMqttProxy.getInstance().userUnJoinedRiderRide(riderRideId: rideStatus.joinedRideId, passengerRideId: rideStatus.rideId)
                NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupValue: StringUtils.getStringFromDouble(decimalNumber: currentUserPassengerRide?.rideId))
            }else if currentUserPassengerRide?.status == Ride.RIDE_STATUS_STARTED{
                RideManagementMqttProxy.getInstance().userUnJoinedRiderRide(riderRideId: rideStatus.joinedRideId, passengerRideId: rideStatus.rideId)
                checkStatusForMovingFromActiveToClosure(ride: currentUserPassengerRide!)
            }
        }
        
    }
    
    static func handleUpdateForCurrentUserConnectedRiderRideStatusChangeInPersistence(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        let currentUserPassengerRide : PassengerRide? = MyRidesPersistenceHelper.getPassengerRide(rideid: rideStatus.rideId)
        if currentUserPassengerRide == nil {return}
        
        if Ride.RIDE_STATUS_CANCELLED == rideStatus.status || Ride.RIDE_STATUS_REQUESTED == rideStatus.status{
            updatePassengerRideParamsForUnjoinAndSaveInPersistence(ride: currentUserPassengerRide!)
        }else if Ride.RIDE_STATUS_COMPLETED == rideStatus.status{
            if currentUserPassengerRide?.status == Ride.RIDE_STATUS_SCHEDULED{
                updatePassengerRideParamsForUnjoinAndSaveInPersistence(ride: currentUserPassengerRide!)
            }else if currentUserPassengerRide?.status == Ride.RIDE_STATUS_STARTED{
                MyRidesPersistenceHelper.deletePassengerRide(rideid: currentUserPassengerRide!.rideId )
            }
        }
        
    }

    
    private func handleUpdateForCurrentUserRiderRideOtherParticipantStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        adjustNoOfPsgrsAndAvailableSeats(rideStatus: rideStatus)
        let rideDetailInfo : RideDetailInfo? = getRideDetailInfoIfExist(riderRideId: rideStatus.joinedRideId)
        if Ride.RIDE_STATUS_SCHEDULED == rideStatus.status && rideStatus.joinedRideId > 0
        {
            RideInviteCache.getInstance().updateRiderRideInvitesStatus(rideId: rideStatus.joinedRideId, passengerId: rideStatus.userId, status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED)
            
        }
        let passengerRide = activePassengerRides![rideStatus.rideId]
        if passengerRide != nil{
            passengerRide!.status = rideStatus.status!
            activePassengerRides![passengerRide!.rideId] = passengerRide
        }
        if rideDetailInfo != nil{
            updateRideDetailInfoForParticipantStatusUpdate(rideDetailInfo: rideDetailInfo!, rideStatus: rideStatus)
        }
        
    }
    
    static func handleUpdateForCurrentUserRiderRideOtherParticipantStatusChangeInPersistence(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideStatus.rideId) joinedRideId :\(rideStatus.joinedRideId)")
        adjustNoOfPsgrsAndAvailableSeatsInPersistence(rideStatus: rideStatus)
        let passengerRide = MyRidesPersistenceHelper.getPassengerRide(rideid: rideStatus.rideId)
        if passengerRide != nil{
            passengerRide!.status = rideStatus.status!
            MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide!)
        }
    }
    
    private func adjustNoOfPsgrsAndAvailableSeats(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("\(rideStatus.noOfSeats)")
        let ride : RiderRide? = activeRiderRides![rideStatus.joinedRideId]
        if ride == nil {return}
        
        if isParticipantRideCancelledOrRequested(rideStatus: rideStatus.status!)
        {
            var noOfPassengers = ride!.noOfPassengers - 1
            if noOfPassengers < 0{
                noOfPassengers = 0
            }
            else if noOfPassengers > ride!.capacity{
                noOfPassengers = ride!.capacity
            }
            
            ride!.noOfPassengers = noOfPassengers
            var  availableSeats : Int =  ride!.availableSeats+rideStatus.noOfSeats
            if availableSeats < 0{
                availableSeats = 0
            }else if availableSeats > ride!.capacity{
                availableSeats =  ride!.capacity
            }
            ride!.availableSeats =  availableSeats
            
            var cumulativeDistance = ride!.cumulativeOverlapDistance - rideStatus.distanceJoined
            if cumulativeDistance < 0{
                cumulativeDistance = 0
            }
            ride?.cumulativeOverlapDistance = cumulativeDistance
            
        }
        else if isParticipantNewlyAdded(status: rideStatus.status!)
        {
            var noOfPassengers = ride!.noOfPassengers + 1
            if noOfPassengers > ride!.capacity{
                noOfPassengers = ride!.capacity
            }
            ride!.noOfPassengers = noOfPassengers
            var  availableSeats : Int =  ride!.availableSeats-rideStatus.noOfSeats
            if availableSeats < 0{
                availableSeats = 0
            }else if availableSeats > ride!.capacity{
                availableSeats =  ride!.capacity
            }
            ride!.availableSeats =  availableSeats
            var cumulativeDistance = (ride?.cumulativeOverlapDistance)! + (Double(rideStatus.noOfSeats)*rideStatus.distanceJoined)
            if cumulativeDistance < 0{
                cumulativeDistance = 0
            }
            ride?.cumulativeOverlapDistance = cumulativeDistance
            MyRidesPersistenceHelper.updateRiderRide(riderRide: ride!)
        }
    }
    
    static func adjustNoOfPsgrsAndAvailableSeatsInPersistence(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("\(rideStatus.noOfSeats)")
        let ride : RiderRide? = MyRidesPersistenceHelper.getRiderRide(rideid: rideStatus.joinedRideId)
        if ride == nil {return}
        
        if Ride.RIDE_STATUS_CANCELLED == rideStatus.status || Ride.RIDE_STATUS_REQUESTED == rideStatus.status
        {
            var noOfPassengers = ride!.noOfPassengers - 1
            if noOfPassengers < 0{
                noOfPassengers = 0
            }
            else if noOfPassengers > ride!.capacity{
                noOfPassengers = ride!.capacity
            }
            
            ride!.noOfPassengers = noOfPassengers
            var  availableSeats : Int =  ride!.availableSeats+rideStatus.noOfSeats
            if availableSeats < 0{
                availableSeats = 0
            }else if availableSeats > ride!.capacity{
                availableSeats =  ride!.capacity
            }
            ride!.availableSeats =  availableSeats
            
            var cumulativeDistance = ride!.cumulativeOverlapDistance - rideStatus.distanceJoined
            if cumulativeDistance < 0{
                cumulativeDistance = 0
            }
            ride?.cumulativeOverlapDistance = cumulativeDistance
            
        }
        else if Ride.RIDE_STATUS_SCHEDULED == rideStatus.status
        {
            var noOfPassengers = ride!.noOfPassengers + 1
            if noOfPassengers > ride!.capacity{
                noOfPassengers = ride!.capacity
            }
            ride!.noOfPassengers = noOfPassengers
            var  availableSeats : Int =  ride!.availableSeats-rideStatus.noOfSeats
            if availableSeats < 0{
                availableSeats = 0
            }else if availableSeats > ride!.capacity{
                availableSeats =  ride!.capacity
            }
            ride!.availableSeats =  availableSeats
            var cumulativeDistance = (ride?.cumulativeOverlapDistance)! + (Double(rideStatus.noOfSeats)*rideStatus.distanceJoined)
            if cumulativeDistance < 0{
                cumulativeDistance = 0
            }
            ride?.cumulativeOverlapDistance = cumulativeDistance
        }
        MyRidesPersistenceHelper.updateRiderRide(riderRide: ride!)
    }
    
    private func updateRideDetailInfoForParticipantStatusUpdate(rideDetailInfo : RideDetailInfo, rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("\(rideDetailInfo) \(rideStatus.joinedRideId)")
        let rideParticipant = rideDetailInfo.getRideParticipant(rideParticipantId: rideStatus.userId)
        if isParticipantNewlyAdded(status: rideStatus.status!){
            if rideParticipant != nil{
                return
            }
            addNewRideParticipantToRideDetailInfo(rideDetailInfo: rideDetailInfo, rideStatus: rideStatus)
        }else{
            if rideParticipant == nil{
                return
            }
            let particiapantStatus = rideParticipant!.getRideStatus()
            if particiapantStatus.isValidStatusChange(newStatus: rideStatus.status!){
                rideDetailInfo.updateRideParticipantStatus(participantId: rideStatus.userId, status: rideStatus.status!)
                self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                if (Ride.RIDE_STATUS_CANCELLED == rideStatus.status!||Ride.RIDE_STATUS_REQUESTED == rideStatus.status! || Ride.RIDE_STATUS_STARTED == rideStatus.status!) && rideStatus.rideId != 0{
                    NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupValue: StringUtils.getStringFromDouble(decimalNumber: rideStatus.rideId))
                }
            }
            
        }
    }
    
    private func isParticipantRideCancelledOrRequested(rideStatus : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("\(rideStatus)")
        return Ride.RIDE_STATUS_CANCELLED == rideStatus || Ride.RIDE_STATUS_REQUESTED == rideStatus
    }
    func isParticipantRideCompleted(status : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("\(status)")
        return Ride.RIDE_STATUS_COMPLETED == status
    }
    
    private func isParticipantNewlyAdded(status : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("\(status)")
        return Ride.RIDE_STATUS_SCHEDULED == status
    }
    
    
    
    func addNewRideParticipantToRideDetailInfo(rideDetailInfo : RideDetailInfo, rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("\(rideDetailInfo) \(rideStatus.joinedRideId)")
        RiderRideRestClient.getRideParticipant(rideId: StringUtils.getStringFromDouble(decimalNumber: rideStatus.joinedRideId), userId: StringUtils.getStringFromDouble(decimalNumber: rideStatus.userId), targetViewController: nil) { (responseObject, error) -> Void in
            if responseObject != nil{
                if responseObject!["result"] as! String == "SUCCESS" {
                    self.pendingRideParticipantsToBeRetrieved.removeValue(forKey: rideStatus.rideId)
                    let rideParticipant : RideParticipant? = Mapper<RideParticipant>().map(JSONObject: responseObject!["resultData"])
                    if rideParticipant == nil {return}
                    RideViewUtils.checkCurrentUserVerificationStatusAndHandleChatAndCall(rideParticipant: rideParticipant)
                    self.assignDistanceFromRiderStartToPickUp(currentRide: rideDetailInfo.riderRide!, rideParticipant: rideParticipant!)
                    rideDetailInfo.addNewParticipant(rideParticipant: rideParticipant!)
                    self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                    self.notifyRideStatusChangeToListener(rideStatus: rideStatus)
                    if rideStatus.joinedRideId > 0 && QRSessionManager.getInstance()!.getUserId() == (StringUtils.getStringFromDouble(decimalNumber: rideDetailInfo.riderRide?.userId))
                    {
                        let riderVehicle = Vehicle(ownerId: rideDetailInfo.riderRide!.userId, vehicleModel: rideDetailInfo.riderRide!.vehicleModel, vehicleType: rideDetailInfo.riderRide!.vehicleType, registrationNumber: rideDetailInfo.riderRide!.vehicleNumber, capacity: rideDetailInfo.riderRide!.capacity, fare: 0, makeAndCategory: rideDetailInfo.riderRide!.makeAndCategory, additionalFacilities: nil, riderHasHelmet: false)
                        let currentUser = RideViewUtils.getRideParticipantObjForParticipantId(participantId: rideDetailInfo.riderRide!.userId, rideParticipants: rideDetailInfo.rideParticipants)
                        self.displayJoinedDialog(currentRide: rideDetailInfo.currentUserRide, rideId: rideStatus.joinedRideId, currentRideType: Ride.RIDER_RIDE, joinedUserId: rideStatus.userId, currentUser: currentUser, rideParticipant: rideParticipant!, riderVehicle: riderVehicle, riderRide: rideDetailInfo.riderRide!)
                    }
                }
            }else{
                self.pendingRideParticipantsToBeRetrieved[rideStatus.rideId] = rideStatus
                self.registerRetryListeberForFailure(error)
            }
        }
    }
    
    private func unJoinPassengerFromRiderRide(ride : PassengerRide) -> PassengerRide{
        AppDelegate.getAppDelegate().log.debug("\(ride.rideId) \(ride.riderRideId)")
        removeRideDetailInformationForRiderRide(riderRideId: ride.riderRideId)
        return MyActiveRidesCache.updatePassengerRideParamsForUnjoinAndSaveInPersistence(ride : ride)
    }
    
    static func updatePassengerRideParamsForUnjoinAndSaveInPersistence(ride : PassengerRide) -> PassengerRide{
        ride.status = Ride.RIDE_STATUS_REQUESTED
        ride.riderId = 0
        ride.riderName = ""
        ride.points = 0
        ride.pickupAddress = ""
        ride.pickupLatitude = 0
        ride.pickupLongitude = 0
        ride.pickupTime = 0.0
        ride.dropAddress = ""
        ride.dropLatitude = 0
        ride.dropLongitude = 0
        ride.dropTime = 0
        ride.pickupAndDropRoutePolyline = ""
        ride.overLappingDistance = 0
        ride.riderRideId = 0
        MyRidesPersistenceHelper.updatePassengerRide(passengerRide: ride)
        return ride
    }
    
    func getRideDetailInfoIfExist(riderRideId : Double?) -> RideDetailInfo?{
        AppDelegate.getAppDelegate().log.debug("riderRideId :\(String(describing: riderRideId))")
        if riderRideId == nil {
            return nil
        }
        if (riderRideDetailInfo == nil || riderRideDetailInfo?.isEmpty == true){
            return nil
        }else{
            return riderRideDetailInfo![riderRideId!]
        }
    }
    
    public func getPassengerRideByRiderRideId(riderRideId : Double) -> PassengerRide?{
        AppDelegate.getAppDelegate().log.debug("riderRideId :\(riderRideId)")
        if riderRideId == 0 {
            return nil
        }
        
        for ride in (activePassengerRides?.values)!{
            if ride.riderRideId == riderRideId{
                return ride
            }
        }
        return nil
    }
    
    func addRideUpdateListener(listener : RideUpdateListener?,key : String){
        AppDelegate.getAppDelegate().log.debug("key :\(key)")
        if listener == nil{
            return
        }
        rideUpdateListeners[key] = listener
    }
    
    func removeRideUpdateListener(key : String){
        AppDelegate.getAppDelegate().log.debug("key :\(key)")
        rideUpdateListeners.removeValue(forKey: key)
        
    }
    
    func notifyRideStatusChangeToListener(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("\(rideStatus.rideId) \(String(describing: rideStatus.status))")
        if self.rideUpdateListeners.isEmpty == true {return}
        DispatchQueue.main.async {
            for rideUpdateListener in self.rideUpdateListeners.values{
                rideUpdateListener.participantStatusUpdated(rideStatus: rideStatus)
            }
        }
    }
    func notifyRideDetailInfoToListener(rideDetailInfo : RideDetailInfo){
        AppDelegate.getAppDelegate().log.debug("\(rideDetailInfo.riderRideId)")
        if self.rideUpdateListeners.isEmpty == true {return}
        DispatchQueue.main.async {
            for rideUpdateListener in self.rideUpdateListeners.values{
                AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(rideDetailInfo.riderRideId) : : UI Refresh started")
                rideUpdateListener.receiveRideDetailInfo(rideDetailInfo: rideDetailInfo)
                AppDelegate.getAppDelegate().log.debug("RideDetailInfoREtrieve \(rideDetailInfo.riderRideId) : : UI Refresh completed")
            }
        }
    }

    public func getPassengerRide(rideId : Double) -> PassengerRide?{
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideId)")
        if let passengerRides = activePassengerRides,!passengerRides.isEmpty, passengerRides[rideId] != nil {
            return activePassengerRides![rideId]!
        }else{
            return nil
        }
    }

    public func getRiderRide(rideId : Double) -> RiderRide?{
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideId)")
        return activeRiderRides![rideId]
    }
    
    public func getRiderRideFromRideDetailInfo(rideId : Double) -> RiderRide?{
        AppDelegate.getAppDelegate().log.debug("rideId :\(rideId)")
        if let riderRide = riderRideDetailInfo?[rideId]?.riderRide {
            return riderRide
        }
        return nil
    }
    
    public func updateRiderRideNotes(rideId : Double, statusMessage : String)
    {
        let riderRide = getRiderRide(rideId: rideId)
        if riderRide == nil{return}
        riderRide!.rideNotes = statusMessage
        MyRidesPersistenceHelper.updateRiderRide(riderRide: riderRide!)
    }
    
    public func updatePassengerRideNotes(rideId : Double, statusMessage : String)
    { let passengerRide = getPassengerRide(passengerRideId: rideId)
        if passengerRide == nil{
            return
        }
        passengerRide!.rideNotes = statusMessage
        MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide!)
    }
    
    public func updateRiderRideFreezeRide(rideId : Double,freezeRide : Bool)
    {
        let riderRide = getRiderRide(rideId: rideId)
        if riderRide == nil{return}
        riderRide!.freezeRide = freezeRide
        MyRidesPersistenceHelper.updateRiderRide(riderRide: riderRide!)
    }
    public func getRideRideNotes(rideId : Double) -> String?
    {
        return  getRiderRide(rideId: rideId)?.rideNotes
    }
    
    public func getPassengerRideNotes(rideId : Double) -> String?
    {
        return  getPassengerRide(passengerRideId: rideId)?.rideNotes
    }

    public func updateCurrentUserLocationChange(rideParticipantLocations : [RideParticipantLocation]){
        AppDelegate.getAppDelegate().log.debug("updateCurrentUserLocationChange: \(String(describing: riderRideDetailInfo?.values.count))")
        for rideParticipantLocation in rideParticipantLocations {
            if let rideDetailInfo = getRideDetailInfoIfExist(riderRideId: rideParticipantLocation.rideId){
               let updatedRideParticipantLocation =  rideDetailInfo.updateRideParticipantLocation(rideParticipantLocation: rideParticipantLocation)
                self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                notifyRideLocationChangeListeners(rideParticipateLocation: updatedRideParticipantLocation)
            }
        }
    }
    
    public func updateRideParticipantLocation(rideParticipantLocation : RideParticipantLocation?){
        AppDelegate.getAppDelegate().log.debug("")
        if rideParticipantLocation == nil{
            return
        }
        var participantLocation = rideParticipantLocation
        if participantLocation!.userId == Double(self.userId!){
            return
        }
        let rideDetailInfo : RideDetailInfo? = riderRideDetailInfo![participantLocation!.rideId!]
        
        if rideDetailInfo == nil{
            return
        }
        let existingRideParticipantLocation = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: participantLocation!.userId,rideParticipantLocations: rideDetailInfo!.rideParticipantLocations)
        
        if existingRideParticipantLocation != nil && existingRideParticipantLocation?.sequenceNo != 0 && participantLocation!.sequenceNo != 0 && participantLocation!.sequenceNo < existingRideParticipantLocation!.sequenceNo {
            AppDelegate.getAppDelegate().log.debug("Ignoring as sequence order is wrong")

            return
        }
        if participantLocation!.lastUpdateTime == nil || participantLocation!.lastUpdateTime! == 0{
            participantLocation?.lastUpdateTime = NSDate().timeIntervalSince1970*1000
        }
        participantLocation = rideDetailInfo!.updateRideParticipantLocation(rideParticipantLocation: participantLocation!)
        self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
        notifyRideLocationChangeListeners(rideParticipateLocation: participantLocation!)
        
    }
    
    func updateRideParticipantLocations(rideId : Double ,rideParticipantLocations : [RideParticipantLocation]){
        
        let rideDetailInfo = riderRideDetailInfo![rideId]
        if rideDetailInfo == nil{
            return
        }
        rideDetailInfo!.rideParticipantLocations = rideParticipantLocations
        riderRideDetailInfo![rideId] = rideDetailInfo
        self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
    }
    func rescheduleRide( rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("\(rideStatus.rideId) \(rideStatus.joinedRideId)")
        
        if Ride.PASSENGER_RIDE == rideStatus.rideType{
            let passengerRide = getPassengerRide(passengerRideId: rideStatus.rideId)
            if passengerRide == nil{
                return
            }
            if passengerRide!.riderRideId != 0{
                passengerRide?.status = Ride.RIDE_STATUS_SCHEDULED
            }else{
                passengerRide?.status = Ride.RIDE_STATUS_REQUESTED
            }
            let rideDuration = DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: passengerRide?.expectedEndTime, time2: passengerRide?.startTime)
            passengerRide?.startTime = rideStatus.rescheduleTime!
            
            passengerRide?.expectedEndTime = DateUtils.addMinutesToTimeStamp(time: rideStatus.rescheduleTime!, minutesToAdd: rideDuration)
            activePassengerRides![passengerRide!.rideId] = passengerRide
            MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide!)
            
        }else if Ride.RIDER_RIDE == rideStatus.rideType{
            if rideStatus.userId == Double(userId!){
                let riderRide = getRiderRide(rideId: rideStatus.rideId)
                if riderRide == nil{
                    return
                }
                riderRide!.status = Ride.RIDE_STATUS_SCHEDULED
                let rideDuration = DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: riderRide?.expectedEndTime, time2: riderRide?.startTime)
                riderRide!.startTime = rideStatus.rescheduleTime!
                riderRide!.expectedEndTime = NSDate(timeIntervalSince1970: riderRide!.startTime/1000).addMinutes(minutesToAdd: rideDuration).getTimeStamp()
                activeRiderRides![riderRide!.rideId] = riderRide
                MyRidesPersistenceHelper.updateRiderRide(riderRide: riderRide!)
            }else{
                let passengerRide = getPassengerRideByRiderRideId(riderRideId: rideStatus.rideId)
                if passengerRide == nil{
                    return
                }
                passengerRide?.status = Ride.RIDE_STATUS_SCHEDULED
                passengerRide?.pickupTime = rideStatus.pickupTime!
                
                passengerRide?.dropTime = rideStatus.dropTime!
                
                activePassengerRides![passengerRide!.rideId] = passengerRide
                MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passengerRide!)
                let rideDetailInfo = riderRideDetailInfo![rideStatus.rideId]
                if rideDetailInfo != nil{
                    rideDetailInfo?.riderRide?.startTime = rideStatus.rescheduleTime!
                    self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                }
            }
            let rideDetailInfo = riderRideDetailInfo![rideStatus.rideId]
            if rideDetailInfo != nil{
                let rideParticipants = rideDetailInfo?.rideParticipants
                for rideParticipant in rideParticipants!{
                    rideParticipant.status = Ride.RIDE_STATUS_SCHEDULED
                }
            }
        }
        notifyRideRescheduleToListener(rideStatus: rideStatus);
    }
    func notifyRideRescheduleToListener(rideStatus: RideStatus){
        AppDelegate.getAppDelegate().log.debug("\(rideStatus.rideId)")
        DispatchQueue.main.async {
            for listener in self.rideUpdateListeners.values{
                listener.participantRideRescheduled(rideStatus: rideStatus)
            }
        }
    }
    
    func addRideLocationChangeListener(rideParticipantLocationListener : RideParticipantLocationListener,key : String){
        AppDelegate.getAppDelegate().log.debug("")
        self.rideLocationListeners[key] = rideParticipantLocationListener
        
    }
    
    func removeRideLocationChangeListener(rideParticipantLocationListener : RideParticipantLocationListener){
        AppDelegate.getAppDelegate().log.debug("")
        self.rideLocationListeners.removeAll()
    }
    
    public func notifyRideLocationChangeListeners(rideParticipateLocation : RideParticipantLocation){
        AppDelegate.getAppDelegate().log.debug("")
        
        DispatchQueue.main.async {
            for ridelocationListener in self.rideLocationListeners.values {
                ridelocationListener.receiveRideParticipantLocation(rideParticipantLocation: rideParticipateLocation)
            }
            
            
        }
    }
    
    private func isRiderRide(ride :  Ride) -> Bool{
        AppDelegate.getAppDelegate().log.debug("")
        return ride.rideType == Ride.RIDER_RIDE
    }
    
    public func checkEarliestRideStartingTimeForConfirmedRide() -> Double?{
        AppDelegate.getAppDelegate().log.debug("")
        let activeRiderRide : Ride? = getActiveRiderRide()
        let activePassengerRide : Ride? = getActivePassengerRide()
        if activeRiderRide == nil {
            if activePassengerRide == nil || (Ride.RIDE_STATUS_SCHEDULED  != activePassengerRide?.status && Ride.RIDE_STATUS_DELAYED  != activePassengerRide?.status){
                return nil
            }else{
                return activePassengerRide?.startTime
            }
        }else{
            if activePassengerRide == nil || (Ride.RIDE_STATUS_SCHEDULED  != activePassengerRide?.status && Ride.RIDE_STATUS_DELAYED  != activePassengerRide?.status){
                if activeRiderRide?.status == Ride.RIDE_STATUS_STARTED{
                    return NSDate().getTimeStamp()
                }else{
                     return activeRiderRide?.startTime
                }
               
            }else{
                if activeRiderRide?.status == Ride.RIDE_STATUS_STARTED{
                   return NSDate().getTimeStamp()
                }
                else if activePassengerRide!.startTime < activeRiderRide!.startTime{
                    return activePassengerRide?.startTime
                }else{
                    return activeRiderRide?.startTime
                }
            }
        }
    }
    public func getOnGoingPassengerRide() -> PassengerRide?{
        AppDelegate.getAppDelegate().log.debug("")
        let activePassengerRide = getActivePassengerRide()
        if activePassengerRide != nil && Ride.RIDE_STATUS_STARTED == activePassengerRide?.status{
            return activePassengerRide as? PassengerRide
        }
        return nil
    }
  
    
    public func getNextRecentRideOfUser() -> Ride? {
        AppDelegate.getAppDelegate().log.debug("")
        let earliestRiderRide : Ride? = getActiveRiderRide()
        let earliestPassengerRide : Ride? = getActivePassengerRide()
        
        if earliestRiderRide == nil {
            if earliestPassengerRide == nil {
                return nil
            } else {
                return earliestPassengerRide
            }
        }else{
            if earliestPassengerRide == nil {
                return earliestRiderRide
            }else{
                
                if earliestRiderRide!.startTime < earliestPassengerRide!.startTime{
                    return earliestRiderRide
                }else{
                    return earliestPassengerRide
                }
            }
        }
    }
   
    
    func getActivePassengerRide() -> Ride? {
        AppDelegate.getAppDelegate().log.debug("")
        var earliestRide : Ride?
        for ride in (activePassengerRides?.values)!{
            if !ride.checkIfRideIsValid() || ride.status == Ride.RIDE_STATUS_COMPLETED || ride.status == Ride.RIDE_STATUS_CANCELLED || ride.status ==  TaxiShareRide.RIDE_STATUS_PENDING_TAXI_JOIN {
                continue
            }
            if earliestRide == nil || (earliestRide?.startTime)! > ride.startTime {
                earliestRide = ride
            }
        }
        return earliestRide
    }
    func getActivePassengerRide(taxiRideId: Double) -> PassengerRide? {
        AppDelegate.getAppDelegate().log.debug("")
        var found : PassengerRide?
        for ride in (activePassengerRides?.values)!{
            if ride.tempTaxiRideId == taxiRideId {
                found = ride
                break
            }
        }
        return found
    }
    
    private func getActiveRiderRide() -> Ride? {
        AppDelegate.getAppDelegate().log.debug("")
        var earliestRide : Ride?
        for ride in (activeRiderRides?.values)! {
            if !ride.checkIfRideIsValid() || ride.status == Ride.RIDE_STATUS_COMPLETED || ride.status == Ride.RIDE_STATUS_CANCELLED{
                continue
            }
            if earliestRide == nil || (earliestRide?.startTime)! > ride.startTime {
                earliestRide = ride
            }
        }
        return earliestRide
    }
    
  func checkForRedundancyOfRide(ride : Ride) -> Ride?{
    AppDelegate.getAppDelegate().log.debug("\(ride.rideId)")
    if Ride.RIDER_RIDE == ride.rideType{
      for riderRide in (activeRiderRides?.values)! {
        if checkForRedundancy(ride: ride, existingRide: riderRide){
          return riderRide
        }
      }
      return nil
    }else {
        for passengerRide in (activePassengerRides?.values)! {
            if checkForRedundancy(ride: ride, existingRide: passengerRide){
                if passengerRide.status != TaxiShareRide.RIDE_STATUS_PENDING_TAXI_JOIN {
                    return passengerRide
                }
            }
        }
      return nil
    }
  }
  func getRedundantRide(ride : Ride) -> Ride?{
    AppDelegate.getAppDelegate().log.debug("\(ride.rideId)")
    if Ride.RIDER_RIDE == ride.rideType{
      for riderRide in activeRiderRides!.values {
        if checkForRedundancy(ride: ride, existingRide: riderRide){
          return riderRide
        }
        
      }
      return nil
    }else {
      for passengerRide in (activePassengerRides?.values)! {
        if checkForRedundancy(ride: ride, existingRide: passengerRide){
          return passengerRide
        }
      }
      return nil
    }
  }
    public func checkForRedundancy(ride : Ride , existingRide : Ride) -> Bool{
        AppDelegate.getAppDelegate().log.debug("\(ride.rideId) \(existingRide.rideId)")
        let newRideStartPoint = CLLocation(latitude: ride.startLatitude, longitude: ride.startLongitude)
        let existingRideStartPoint = CLLocation(latitude: existingRide.startLatitude, longitude: existingRide.startLongitude)
        let newRideEndPoint = CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
        let existingRideEndPoint = CLLocation(latitude: existingRide.endLatitude!, longitude: existingRide.endLongitude!)
        
        return newRideStartPoint.distance(from: existingRideStartPoint) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES &&
            newRideEndPoint.distance(from: existingRideEndPoint) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES &&
            DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride.startTime, time2: existingRide.startTime) < MyActiveRidesCache.THRESHOLD_TIME_TO_CREATE_RIDE_ON_SAME_ROUTE && ride.rideId != existingRide.rideId
    }
    
    public func getCurrentUserParticipatingActiveRiderRideIds() -> [Double]{
        AppDelegate.getAppDelegate().log.debug("")
        var rideList : [Double] = [Double]()
        let thresholdDate : Double = Double(AppConfiguration.advancedTimeLocationUpdateInMinutes) + Double(NSDate().timeIntervalSince1970)*1000
        for ride in (self.activeRiderRides?.values)! {
            
            if ride.startTime < thresholdDate{
                rideList.append(ride.rideId)
            }
        }
        
        for ride in (activePassengerRides?.values)!{
            
            if ride.startTime < thresholdDate && ride.riderRideId != 0{
                rideList.append(ride.riderRideId)
            }
        }
        return rideList
    }
    
    public func getActiveRiderRides() -> [Double : RiderRide]{
        AppDelegate.getAppDelegate().log.debug("")
        return activeRiderRides!
    }
    
    public  func getActivePassengerRides() -> [Double : PassengerRide]{
        AppDelegate.getAppDelegate().log.debug("")
        return activePassengerRides!
    }
    func  getRiderRideLastSyncedTime(rideId : Double) -> NSDate?{
        return riderRidesLastSyncTimes[rideId]
    }
    
    func getPassengerRideLastSyncedTime(rideId : Double) -> NSDate?{
        return passengerRidesLastSyncTimes[rideId]
    }
    
    public func clearLocalMemoryOnSessionInitializationFailure(){
        AppDelegate.getAppDelegate().log.debug("")
        removeCacheInstance()
        if MyRegularRidesCache.singleInstance != nil{
            MyRegularRidesCache.getInstance().removeCacheInstance()
        }
    }
    func checkForDuplicateRideOnSameDay(ride : Ride) -> Ride?{
        for riderRide in activeRiderRides!.values{
            if validateRideRedundancyOnSameDay(ride: ride, existingRide: riderRide){
                return riderRide
            }
        }
        for passengerRide in activePassengerRides!.values{
            if validateRideRedundancyOnSameDay(ride: ride, existingRide: passengerRide){
                if passengerRide.status != TaxiShareRide.RIDE_STATUS_PENDING_TAXI_JOIN {
                    return passengerRide
                }
            }
        }
        return nil
    }
    public func validateRideRedundancyOnSameDay(ride : Ride , existingRide : Ride) -> Bool{
        AppDelegate.getAppDelegate().log.debug("\(ride.rideId)")
        let newRideStartPoint = CLLocation(latitude: ride.startLatitude, longitude: ride.startLongitude)
        let existingRideStartPoint = CLLocation(latitude: existingRide.startLatitude, longitude: existingRide.startLongitude)
        let newRideEndPoint = CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
        let existingRideEndPoint = CLLocation(latitude: existingRide.endLatitude!, longitude: existingRide.endLongitude!)
        let diffStartTimes =  DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride.startTime, time2: existingRide.startTime)
        
        return newRideStartPoint.distance(from: existingRideStartPoint) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES &&
            newRideEndPoint.distance(from: existingRideEndPoint) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES &&
            diffStartTimes < MyActiveRidesCache.THRESHOLD_TIME_BETWEEN_TWO_POINTS_FOR_DAY_IN_MINS && ride.rideId != existingRide.rideId
    }
    public func getPassengerToPickUp(riderRideId : Double) -> [RideParticipant]{
        var passengersToPickupDict = [Double : RideParticipant]()
        
        let rideParticipants = getRideParicipants(riderRideId: riderRideId)
        for rideParticipant in rideParticipants{
            if rideParticipant.rider == false && (rideParticipant.status == Ride.RIDE_STATUS_DELAYED || rideParticipant.status == Ride.RIDE_STATUS_SCHEDULED){
                passengersToPickupDict[rideParticipant.userId] = rideParticipant
            }
        }
        var passengersToPickup = [RideParticipant]()
        
        for passenger in passengersToPickupDict{
            passengersToPickup.append(passenger.1)
        }
        return passengersToPickup
    }
    public func getUsersActiveRidesCount() -> Int?
    {
        return activePassengerRides!.count + activeRiderRides!.count
    }
    public func updateRiderVehicleDetails(rideVehicle: RideVehicle)
    {
        let rideDetailInfo : RideDetailInfo? = riderRideDetailInfo![rideVehicle.rideId]
        let riderRide = rideDetailInfo?.riderRide
        if riderRide != nil
        {
            riderRide?.farePerKm = rideVehicle.fare
            riderRide?.vehicleNumber = rideVehicle.registrationNumber
            riderRide?.vehicleType = rideVehicle.vehicleType
            riderRide?.vehicleModel = rideVehicle.model!
            riderRide?.additionalFacilities = rideVehicle.additionalFacilities
            riderRide?.makeAndCategory = rideVehicle.makeAndCategory
            riderRide?.capacity = rideVehicle.capacity
            riderRide?.vehicleImageURI = rideVehicle.imageURI
            riderRide?.vehicleId = rideVehicle.vehicleId
            rideDetailInfo?.riderRide = riderRide
            riderRideDetailInfo![rideVehicle.rideId] = rideDetailInfo
            self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
        }
        
    }
    
    func updateRideParticipantDetails(rideParticipant : RideParticipant) {
        AppDelegate.getAppDelegate().log.debug("\(rideParticipant.rideId) \(rideParticipant.riderRideId)")
        let rideDetailInfo = riderRideDetailInfo![rideParticipant.riderRideId]
        if rideDetailInfo != nil{
            rideDetailInfo?.removeParticipant(participantId: rideParticipant.userId)
            self.assignDistanceFromRiderStartToPickUp(currentRide: rideDetailInfo!.riderRide!, rideParticipant: rideParticipant)
            rideDetailInfo?.addNewParticipant(rideParticipant: rideParticipant)
            riderRideDetailInfo![rideParticipant.rideId] = rideDetailInfo
            self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
            notifyRideParticipantChangeToListener(rideParticipant: rideParticipant)
        }
    }
    func notifyRideParticipantChangeToListener(rideParticipant : RideParticipant){
        AppDelegate.getAppDelegate().log.debug("\(rideParticipant.rideId) \(rideParticipant.riderRideId)")
        DispatchQueue.main.async {
            for rideUpdateListener in self.rideUpdateListeners.values{
                rideUpdateListener.participantUpdated(rideParticipant: rideParticipant)
            }
        }
    }
    @objc func retrievePendingDataFromServer(){
        
        AppDelegate.getAppDelegate().log.debug("fetching any pending data -> RideDetailInfo:\(self.pendingRideDetailInfoToBeRetrieved.keys)& PassengerRides: \(self.pendingPassengerRidesGettingStatusUpdates)")
        stopReachabilityNotifier()
        cancelTimer()
        for  riderRideId in  pendingRideDetailInfoToBeRetrieved.keys {
            if let riderRide = activeRiderRides?[riderRideId] {
                getRideDetailInfo(riderRideId: riderRideId, currentuserRide: riderRide, myRidesCacheListener: nil)
            }else if let passegerRide = getPassengerRideByRiderRideId(riderRideId: riderRideId){
               getRideDetailInfo(riderRideId: riderRideId, currentuserRide: passegerRide, myRidesCacheListener: nil)
            }
            
        }
        for  key in pendingPassengerRidesGettingStatusUpdates.keys {
            let value = pendingPassengerRidesGettingStatusUpdates[key]
            if value != nil{
                reloadPassengerRideDetails(rideStatus: value!)
            }
        }
        
        
        for passengerRideId in pendingRideParticipantsToBeRetrieved.keys {
            let rideStatus =
                pendingRideParticipantsToBeRetrieved[passengerRideId]
            let rideDetailInfo =
                getRideDetailInfoIfExist(riderRideId: rideStatus!.joinedRideId)
            if rideDetailInfo == nil
            {
                pendingRideParticipantsToBeRetrieved.removeValue(forKey: passengerRideId)
                continue
            }
            addNewRideParticipantToRideDetailInfo(rideDetailInfo : rideDetailInfo!, rideStatus : rideStatus!)
        }
    }
    func registerRetryListeberForFailure(_ error: NSError?) {
        if error == QuickRideErrors.NetworkConnectionNotAvailableError{
            self.registerListenerTOGetPendingDataAfterNetworkReestablished()
        }else if error == QuickRideErrors.RequestTimedOutError{
            self.registerTimerToGetPendingDataAfterServerReachable()
        }
    }
    func registerListenerTOGetPendingDataAfterNetworkReestablished(){
        
        if reachability != nil{
            return
        }
        reachability = Reachability()!
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability!.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    func stopReachabilityNotifier() {
        if reachability != nil{
            reachability!.stopNotifier()
            NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
            reachability = nil
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachabilityNotification = note.object as! Reachability
        
        switch reachabilityNotification.connection {
        case .wifi:
            QRReachability.isInternetAvailable { (status) in
                if status {
                    self.retrievePendingDataFromServer()
                    self.stopReachabilityNotifier()
                }
            }
        case .cellular:
            retrievePendingDataFromServer()
            stopReachabilityNotifier()
        case .none:
            AppDelegate.getAppDelegate().log.error("Network not reachable")
        }
    }
    func registerTimerToGetPendingDataAfterServerReachable(){
        startTimer()
    }
    func startTimer(){
        if timer != nil{
            return
        }
        cancelTimer()
        
        self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(MyActiveRidesCache.retrievePendingDataFromServer), userInfo: nil, repeats: true)
    }
    func cancelTimer(){
        timer?.invalidate()
        timer = nil
    }
    func getActiveStatedRiderRide() -> RiderRide?{
        let riderRides = MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides()
        if riderRides != nil || riderRides?.isEmpty == false{
            for riderRide in riderRides!.values{
                if riderRide.status == Ride.RIDE_STATUS_STARTED{
                    return riderRide
                }
            }
        }
        return nil
    }
    func handleFreezeRide(freezeRideStatusObj : FreezeRideStatus){
        activeRiderRides?[freezeRideStatusObj.rideId!]?.freezeRide = freezeRideStatusObj.freezeRideStatus
        if let riderRide = MyRidesPersistenceHelper.getRiderRide(rideid: freezeRideStatusObj.rideId!){
            riderRide.freezeRide = freezeRideStatusObj.freezeRideStatus
            MyRidesPersistenceHelper.updateRiderRide(riderRide: riderRide)
        }
        updateFreezeRideStatusToListeners()
    }
    
    func updateFreezeRideStatusToListeners(){
            DispatchQueue.main.async {
                for listener in self.rideUpdateListeners{
                    listener.value.handleUnfreezeRide()
                }
            }
        
    }
    func addRoutepathDataToRideDetailInfo(routePathData : RoutePathData,riderRideId : Double){
        
        var rideDetailInfo = riderRideDetailInfo?[riderRideId]
        if rideDetailInfo == nil{
            rideDetailInfo = SharedPreferenceHelper.getRideDetailInfo(riderRideId:  StringUtils.getStringFromDouble(decimalNumber: riderRideId))
        }
        if rideDetailInfo != nil{
            rideDetailInfo?.riderRideRoutePathData = routePathData
            riderRideDetailInfo?[riderRideId] = rideDetailInfo
            self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
        }
    }
    
    func getRideParticipantLocationAndRefresh(riderRideId : Double, handler : @escaping (_ participantLocations: [RideParticipantLocation]?) -> Void) {
        LiveRideClient.getRideParticipantLocations(riderRideId: StringUtils.getStringFromDouble(decimalNumber: riderRideId), targetViewController: nil) { (responseObject, error) -> Void in
            var rideParticipantLocations : [RideParticipantLocation]?
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                rideParticipantLocations = Mapper<RideParticipantLocation>().mapArray(JSONObject: responseObject!["resultData"])
                let rideDetailInfo = self.riderRideDetailInfo?[riderRideId]
                if rideParticipantLocations != nil && !rideParticipantLocations!.isEmpty && rideDetailInfo != nil{
                    rideDetailInfo!.rideParticipantLocations = rideParticipantLocations
                    self.riderRideDetailInfo![riderRideId] = rideDetailInfo
                    self.updateRideDetailInfo(rideDetailInfo: rideDetailInfo)
                }
                else{
                    rideParticipantLocations = rideDetailInfo?.rideParticipantLocations
                }
            }
            handler(rideParticipantLocations)
        }
    }
    
    func isRidesPostedOnVaction(userVacation: UserVacation) -> (Bool,[RiderRide],[PassengerRide]){
        let riderRides = MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides()
        let passengerRides = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRides()
        var riderRidesDuringVacation =  [RiderRide]()
        var passengerRidesDuringVacation =  [PassengerRide]()
        if riderRides != nil && !riderRides!.isEmpty{
            for riderRide in riderRides!{
                if riderRide.value.startTime >= userVacation.fromDate! && riderRide.value.startTime <= userVacation.toDate!{
                    riderRidesDuringVacation.append(riderRide.value)
                }
            }
        }
        if passengerRides != nil && !passengerRides!.isEmpty{
            for passengerRide in passengerRides!{
                if passengerRide.value.startTime >= userVacation.fromDate! && passengerRide.value.startTime <= userVacation.toDate!{
                    passengerRidesDuringVacation.append(passengerRide.value)
                }
            }
        }
        if riderRidesDuringVacation.isEmpty && passengerRidesDuringVacation.isEmpty {
            return (false,[],[])
        }
        else{
            return (true,riderRidesDuringVacation,passengerRidesDuringVacation)
        }
    }
    
    func updateRideDetailInfo(rideDetailInfo: RideDetailInfo?){
        SharedPreferenceHelper.storeRideDetailInfo(rideDetailInfo: rideDetailInfo)
    }
    func getCurrentUserParticipatingActiveRiderRides() -> [RiderRide]{
        var riderRides = [RiderRide]()

        let thresholdDate : Double = Double(AppConfiguration.advancedTimeLocationUpdateInMinutes) + Double(NSDate().timeIntervalSince1970)*1000
        for ride in (self.activeRiderRides?.values)! {

            if ride.startTime < thresholdDate{
                riderRides.append(ride)
            }
        }
        return riderRides
    }
    func getCurrentUserParticipatingActivePassengerRides() -> [PassengerRide]{
        var passengerRides = [PassengerRide]()
        let thresholdDate : Double = Double(AppConfiguration.advancedTimeLocationUpdateInMinutes) + Double(NSDate().timeIntervalSince1970)*1000

        for ride in (self.activePassengerRides?.values)! {

            if ride.status != Ride.RIDE_STATUS_REQUESTED && ride.startTime < thresholdDate{
                passengerRides.append(ride)
            }
        }
        return passengerRides;
    }
    
    func updateAndNotifyRideModeratorStatus(rideModeratorStatus: RideModeratorStatus?) {
        if let riderDetailInfo = riderRideDetailInfo, let moderatorStatus = rideModeratorStatus {
            for rideDetailInfo in riderDetailInfo {
                for rideParticipant in rideDetailInfo.value.rideParticipants ?? [RideParticipant]() {
                    if rideParticipant.userId == moderatorStatus.userId, let moderationEnabled = moderatorStatus.moderationEnabled {
                        rideParticipant.rideModerationEnabled = moderationEnabled
                        updateRideDetailInfo(rideDetailInfo: rideDetailInfo.value)
                        self.notifyRideParticipantChangeToListener(rideParticipant: rideParticipant)
                        break
                    }
                }
            }
        }
    }
    func updateRiderRide(riderRide : RiderRide){
        guard let _ = activeRiderRides![riderRide.rideId] else {
            return
        }
        activeRiderRides![riderRide.rideId] = riderRide
        MyRidesPersistenceHelper.updateRiderRide(riderRide: riderRide)
    }
    func getOtherChildRelayRide(ride: PassengerRide?) -> PassengerRide?{
        let passengerRides = getActivePassengerRides().values
        for passengerRide in passengerRides{
            if passengerRide.parentId == ride?.parentId && passengerRide.rideId != ride?.rideId{
                return passengerRide
            }
        }
        return nil
    }
    
    func rideRouteUpdate(rideUpdate: RideUpdate) {
        if let rideId = rideUpdate.rideId, let rideIdInDouble = Double(String(rideId)), let riderRideDetail = riderRideDetailInfo?[rideIdInDouble], let ride = riderRideDetail.currentUserRide {
            getRideDetailInfoFromServer(currentUserRide: ride, myRidesCacheListener: nil)
        }
    }
    
    func getRequestedPassengerRides() -> [PassengerRide]{
        return activePassengerRides?.values.filter({$0.status == Ride.RIDE_STATUS_REQUESTED}) ?? [PassengerRide]()
    }
}
