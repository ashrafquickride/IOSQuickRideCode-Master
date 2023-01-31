//
//  MyActiveTaxiRideCache.swift
//  Quickride
//
//  Created by Ashutos on 30/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import GoogleMaps

protocol MyActiveTaxiRideCacheDelegate {
    func getActiveRides(activeRides: [TaxiRidePassenger])
    func failedToFetch(error : NSError?)
}

protocol ClosedTaxiRidesDelegate {
    func getClosedTaxiRides(closedRides: [TaxiRidePassenger])
    func failedToFetchClosedRide(error : NSError?)
}

class MyActiveTaxiRideCache {
    
    static var singleInstance: MyActiveTaxiRideCache?
    private var activeTaxiRides = [TaxiRidePassenger]()
    private var closedTaxiRides = [TaxiRidePassenger]()
    private var taxipoolInvites = [TaxiPoolInvite]()

    private var carpoolPassengerMatches = [Double: MatchedCarpoolPassengerHolder]()
    static let QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS = 45
    
    private init() {}
    
    static func getInstance() -> MyActiveTaxiRideCache {
        AppDelegate.getAppDelegate().log.debug("getInstance()")
        if singleInstance == nil {
            singleInstance = MyActiveTaxiRideCache()
        }
        return singleInstance!
    }
    
    func initializeCache() {
        activeTaxiRides = MyTaxiRidesPersistenceHelper.getAllActiveTaxiTrips()
        closedTaxiRides = MyTaxiRidesPersistenceHelper.getClosedTaxiTrips()
        getTaxiDetailsFromServer(dataReceiver: nil)
        getClosedTaxiDetailsFromServer(closedDataReceiver: nil)
        getInvitesFromServer()
    }
    
    static func clearUserSession(){
        if singleInstance == nil {
            return
        }
        singleInstance?.removeCacheInstance()
        singleInstance?.clearPersitanceHelper()
    }
    
    func removeCacheInstance(){
        if MyActiveTaxiRideCache.singleInstance != nil{
            activeTaxiRides.removeAll()
            closedTaxiRides.removeAll()
            MyActiveTaxiRideCache.singleInstance = nil
        }
    }
    
    func clearPersitanceHelper(){
        MyTaxiRidesPersistenceHelper.clearTableForEntity(entityName: MyTaxiRidesPersistenceHelper.taxiRidePassengerTable)
        MyTaxiRidesPersistenceHelper.clearTableForEntity(entityName: MyTaxiRidesPersistenceHelper.closedTaxiRidePassengerTable)
    }
    
    func clearLocalMemoryOnSessionInitializationFailure(){
        AppDelegate.getAppDelegate().log.debug("")
        removeCacheInstance()
    }
    
    static func getClosedTaxiRidesCacheInstanceIfExists() -> MyActiveTaxiRideCache?{
        AppDelegate.getAppDelegate().log.debug("getClosedRidesCacheInstanceIfExists()")
        if singleInstance != nil {
            return singleInstance!
        }
        return nil
    }
    
    func getActiveTaxiRides() -> [TaxiRidePassenger] {
        return activeTaxiRides
    }
    
    func updateTaxiPassengerRideInList(taxiId: Double,taxiRidePassenger:TaxiRidePassenger){
        if let i = activeTaxiRides.firstIndex(where: { $0.id == taxiId}) {
            activeTaxiRides[i] = taxiRidePassenger
            MyTaxiRidesPersistenceHelper.updateTaxiTrip(taxiRide: taxiRidePassenger)
        }
    }
    
    private func getTaxiDetailsFromServer(dataReceiver: MyActiveTaxiRideCacheDelegate?) {
        TaxiPoolRestClient.getActiveTaxiRides { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self?.activeTaxiRides = Mapper<TaxiRidePassenger>().mapArray(JSONObject:responseObject!["resultData"])!
                MyTaxiRidesPersistenceHelper.storeAllActiveTrips(taxiRides: self?.activeTaxiRides ?? [TaxiRidePassenger]())
                if !(self?.activeTaxiRides.isEmpty ?? false) {
                    dataReceiver?.getActiveRides(activeRides: self?.activeTaxiRides ?? [])
                }
            }else{
                dataReceiver?.failedToFetch(error: error)
            }
        }
    }
    
    func removeRideFromActiveTaxiCache(taxiId: Double){
        var index: Int?
        for i in 0..<activeTaxiRides.count {
            if taxiId == activeTaxiRides[i].id {
               index = i
                break
            }
        }
        
        if let index = index {
            activeTaxiRides.remove(at: index)
            MyTaxiRidesPersistenceHelper.deleteTaxiRide(taxiRideid: taxiId)
        }
    }
    
    func addNewRideToCache(taxiRidePassenger: TaxiRidePassenger) {
        if let index = activeTaxiRides.firstIndex (where: { passenger in
            return taxiRidePassenger.id == passenger.id
        }), index >= 0 {
            activeTaxiRides.insert(taxiRidePassenger, at: index)
            MyTaxiRidesPersistenceHelper.updateTaxiTrip(taxiRide: taxiRidePassenger)
        }else{
            activeTaxiRides.insert(taxiRidePassenger, at: 0)
            MyTaxiRidesPersistenceHelper.saveActiveTrip(taxiRide: taxiRidePassenger)
        }
    }
    func getClosedTaxiRidesFromCache() -> [TaxiRidePassenger]{
        return closedTaxiRides
    }
    
    private func getClosedTaxiDetailsFromServer(closedDataReceiver: ClosedTaxiRidesDelegate?) {
        TaxiPoolRestClient.getClosedTaxiRides { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self?.closedTaxiRides = Mapper<TaxiRidePassenger>().mapArray(JSONObject:responseObject!["resultData"])!
                self?.checkAnyTaxiRideHasPendingBillAndShow()
                MyTaxiRidesPersistenceHelper.storeAllClosedTaxiRides(taxiRides: self?.closedTaxiRides ?? [TaxiRidePassenger]())
                if !(self?.closedTaxiRides.isEmpty ?? false) {
                    closedDataReceiver?.getClosedTaxiRides(closedRides: self?.closedTaxiRides ?? [])
                }
            }else{
                closedDataReceiver?.failedToFetchClosedRide(error: error)
            }
        }
    }
    func checkAnyTaxiRideHasPendingBillAndShow(){
        var pendingBillRide: TaxiRidePassenger?
        for closedRide in closedTaxiRides{
            if closedRide.status == TaxiRidePassenger.STATUS_COMPLETED && closedRide.pendingAmount != 0.0{
                pendingBillRide = closedRide
                break
            }
        }
        if pendingBillRide != nil{
            TaxiPoolRestClient.getTaxiPendingBill(id: pendingBillRide?.id ?? 0) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let taxiPendingBill = Mapper<TaxiPendingBill>().map(JSONObject: responseObject!["resultData"]),taxiPendingBill.amountPending != 0.0{
                        let payTaxiPendingBillViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pending_due_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PayTaxiPendingBillViewController") as! PayTaxiPendingBillViewController
                        payTaxiPendingBillViewController.initialisePendingBill(taxiRideId: pendingBillRide?.id ?? 0,taxiPendingBill: taxiPendingBill,taxiRideInvoice: nil,paymentMode: nil, taxiGroupId: pendingBillRide?.taxiGroupId, isRequiredToInitiatePayment: nil) { (isBillCleared) in
                            if isBillCleared{
                                pendingBillRide?.pendingAmount = 0
                            }
                        }
                        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: payTaxiPendingBillViewController, animated: false)
                    }
                }
            }
        }
    }
    
    func getTaxiRidePassenger(taxiRideId : Double) -> TaxiRidePassenger?{
        for taxiRidePassenger in activeTaxiRides {
            if taxiRidePassenger.id == taxiRideId {return taxiRidePassenger}
        }
        return nil
    }
    
    func addNewClosedTaxiRides(taxiRidePassenger: TaxiRidePassenger) {
        closedTaxiRides.insert(taxiRidePassenger, at: 0)
        SharedPreferenceHelper.storeTaxiRideGroupSuggestionUpdate(taxiGroupId: taxiRidePassenger.taxiGroupId ?? 0, taxiUpdateSuggestion: nil)
        MyTaxiRidesPersistenceHelper.saveClosedTaxiRide(taxiRide: taxiRidePassenger)
    }
    
    public func getNextRecentTaxiRidePassenger() -> TaxiRidePassenger? {
        AppDelegate.getAppDelegate().log.debug("")
        var earliest : TaxiRidePassenger?
        for taxiRidePassenger in activeTaxiRides {
            
            if earliest == nil || earliest!.startTimeMs! > taxiRidePassenger.startTimeMs! {
                earliest = taxiRidePassenger
            }
        }
        return earliest
    }
    func getClosedTaxiRidePassenger(taxiRideId: Double) -> TaxiRidePassenger?{
        if let taxiRide = closedTaxiRides.first(where: {$0.id == taxiRideId}) {
            return taxiRide
        } else {
            return nil
        }
    }
    func checkForDuplicateRideOnSameDay(taxiRide: TaxiRidePassenger) -> TaxiRidePassenger?{
        for activeRide in activeTaxiRides{
            if validateRideRedundancyOnSameDay(taxiRide: taxiRide, existingTaxiRide: activeRide){
                return activeRide
            }
        }
        return nil
    }
    public func validateRideRedundancyOnSameDay(taxiRide : TaxiRidePassenger , existingTaxiRide : TaxiRidePassenger) -> Bool{
        AppDelegate.getAppDelegate().log.debug("\(String(describing: taxiRide.id))")
        let newRideStartPoint = CLLocation(latitude: taxiRide.startLat ?? 0, longitude: taxiRide.startLng ?? 0)
        let existingRideStartPoint = CLLocation(latitude: existingTaxiRide.startLat ?? 0, longitude: existingTaxiRide.startLng ?? 0)
        let newRideEndPoint = CLLocation(latitude: taxiRide.endLat ?? 0, longitude: taxiRide.endLng ?? 0)
        let existingRideEndPoint = CLLocation(latitude: existingTaxiRide.endLat ?? 0, longitude: existingTaxiRide.endLng ?? 0)
        let diffStartTimes =  DateUtils.getDifferenceBetweenTwoDatesInMins(time1: taxiRide.startTimeMs, time2: existingTaxiRide.startTimeMs)
        
        return newRideStartPoint.distance(from: existingRideStartPoint) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES &&
            newRideEndPoint.distance(from: existingRideEndPoint) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES &&
            diffStartTimes < MyActiveRidesCache.THRESHOLD_TIME_BETWEEN_TWO_POINTS_FOR_DAY_IN_MINS && taxiRide.id != existingTaxiRide.id
    }
    
    func getBookedTaxipoolRides() -> [TaxiRidePassenger]{
        return activeTaxiRides.filter({$0.getShareType() == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING})
    }
    //MARK: Get carpool matches
    func getCarpoolPassengerMatches(taxiRide: TaxiRidePassenger,dataReceiver: CarpoolPassengerDataReceiver){
        if let matchedCarpoolPassengerHolder = carpoolPassengerMatches[taxiRide.id ?? 0]{
            let timeDiff = DateUtils.getTimeDifferenceInSeconds(date1: NSDate() , date2: matchedCarpoolPassengerHolder.queryTime ?? NSDate())
            if timeDiff < MyActiveTaxiRideCache.QUERY_RESULT_EXPIRY_PERIOD_IN_SECONDS{
                AppDelegate.getAppDelegate().log.debug("Cache contains some carpool passenger matches those are still valid")
                dataReceiver.receivedCarpoolPassengerList(carpoolMatches: matchedCarpoolPassengerHolder.queryResult)
                return
            }
        }
        
        AppDelegate.getAppDelegate().log.debug("Cache carpool passenger matches are not valid or not contains")
        TaxiSharingRestClient.getCarpoolPassengerMatchesForTaxipool(taxiRidePassengerId: taxiRide.id ?? 0, taxiGroupId: taxiRide.taxiGroupId ?? 0, filterPassengerRideId: nil) { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let carpoolMatches = Mapper<MatchingTaxiPassenger>().mapArray(JSONObject: responseObject!["resultData"]) ?? [
                    MatchingTaxiPassenger]()
                self?.carpoolPassengerMatches[taxiRide.id ?? 0] = MatchedCarpoolPassengerHolder(queryTime: NSDate(), queryResult: carpoolMatches)
                dataReceiver.receivedCarpoolPassengerList(carpoolMatches: carpoolMatches)
            }else{
                dataReceiver.carpoolMatchesRetrivalFailed(responseObject: responseObject, error: error)
            }
        }
    }
    func getCarpoolMatchedUser(taxiRide: TaxiRidePassenger,filterPassengerRideId: Double,complitionHandler: @escaping(_ matchedUser: MatchingTaxiPassenger?, _ responseObject: NSDictionary?,_ error: NSError?) -> ()){
        if let matchedCarpoolPassengerHolder = carpoolPassengerMatches[taxiRide.id ?? 0]{
            if let matchedUser = matchedCarpoolPassengerHolder.queryResult.first(where: {$0.userid == filterPassengerRideId}){
                complitionHandler(matchedUser,nil,nil)
                return
            }
        }
        QuickRideProgressSpinner.startSpinner()
        TaxiSharingRestClient.getCarpoolPassengerMatchesForTaxipool(taxiRidePassengerId: taxiRide.id ?? 0, taxiGroupId: taxiRide.taxiGroupId ?? 0, filterPassengerRideId: nil) {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let carpoolMatches = Mapper<MatchingTaxiPassenger>().mapArray(JSONObject: responseObject!["resultData"]) ?? [
                    MatchingTaxiPassenger]()
                if !carpoolMatches.isEmpty{
                    complitionHandler(carpoolMatches[0],nil,nil)
                }
            }else{
                complitionHandler(nil,responseObject,error)
            }
        }
    }
    //MARK: Outgoing invites to carpol users
    
    func getOutGoingTaxipoolInvites(taxiRideId: Double) -> [TaxiPoolInvite]{
        return taxipoolInvites.filter({ $0.invitingRideId == Int(taxiRideId) && ($0.status?.uppercased() == TaxiPoolInvite.TAXI_INVITE_STATUS_OPEN || $0.status?.uppercased() == TaxiPoolInvite.TAXI_INVITE_STATUS_RECEIVED || $0.status?.uppercased() == TaxiPoolInvite.TAXI_INVITE_STATUS_READ)})
    }
    
    func getTaxiOutgoingInvite(taxiRideId: Double,userId: Double) -> TaxiPoolInvite?{
        if let taxiInvite = taxipoolInvites.first(where: {$0.invitingRideId == Int(taxiRideId) && $0.invitedUserId == Int(userId)}){
            return taxiInvite
        }else{
            return nil
        }
    }
    
    func removeTaxiOutgoingInvite(inviteId: String){
        if let index = taxipoolInvites.firstIndex(where: {$0.id == inviteId}){
            taxipoolInvites.remove(at: index)
        }
    }
    
    //MARK: incoming invite from taxi to carpool
    func storeIncomingTaxipoolInvite(taxipoolInvite: TaxiPoolInvite){
        if let index = taxipoolInvites.firstIndex(where: {$0.id == taxipoolInvite.id}){
            taxipoolInvites[index] = taxipoolInvite
        }else{
            taxipoolInvites.append(taxipoolInvite)
        }
        NotificationCenter.default.post(name: .taxiInvitationReceived, object: nil)
    }
    
    func getIncomingTaxipoolInvitesForRide(rideId: Double) -> [TaxiPoolInvite]{
        return taxipoolInvites.filter({ $0.invitedRideId == Int(rideId) && ($0.status?.uppercased() == TaxiPoolInvite.TAXI_INVITE_STATUS_OPEN || $0.status?.uppercased() == TaxiPoolInvite.TAXI_INVITE_STATUS_RECEIVED || $0.status?.uppercased() == TaxiPoolInvite.TAXI_INVITE_STATUS_READ)})
    }
    
    func getIncomingTaxipoolInvite(rideId: Double,taxiUserId: Double) -> TaxiPoolInvite?{
        if let taxiInvite = taxipoolInvites.first(where: {$0.invitedRideId == Int(rideId) && $0.invitingUserId == Int(taxiUserId)}){
            return taxiInvite
        }else{
            return nil
        }
    }
    
    func removeTaxiIncomingInvite(inviteId: String){
        if let index = taxipoolInvites.firstIndex(where: {$0.id == inviteId}){
            taxipoolInvites.remove(at: index)
        }
    }
    
    func updateTaxipoolInvite(taxiInvite: TaxiPoolInvite){
        
        if taxiInvite.status == TaxiPoolInvite.TAXI_INVITE_STATUS_CANCEL ||
           taxiInvite.status == TaxiPoolInvite.TAXI_INVITE_STATUS_ACCEPTED ||
           taxiInvite.status == TaxiPoolInvite.TAXI_INVITE_STATUS_REJECTED ||
           taxiInvite.status == TaxiPoolInvite.TAXI_INVITE_STATUS_JOINED_OTHER ||
           taxiInvite.status == TaxiPoolInvite.TAXI_INVITE_STATUS_JOINED_SAME
        {
            if let index = taxipoolInvites.firstIndex(where: {$0.id == taxiInvite.id || $0.invitedUserId == taxiInvite.invitedUserId}){
                taxipoolInvites.remove(at: index)
            }
            NotificationStore.getInstance().removeNotificationForTaxiPoolInvite(invite: taxiInvite)
        }else{
            if let index = taxipoolInvites.firstIndex(where: {$0.id == taxiInvite.id || $0.invitedUserId == taxiInvite.invitedUserId}){
                taxipoolInvites[index] = taxiInvite
            }else{
                taxipoolInvites.append(taxiInvite)
            }
        }
        NotificationCenter.default.post(name: .taxiInvitationReceived, object: nil)
    }
    
    func getInvitesFromServer(){
        let taxipoolRides = getBookedTaxipoolRides()
        var srcRideIds = [String]()
        for taxipool in taxipoolRides{
            srcRideIds.append(StringUtils.getStringFromDouble(decimalNumber: taxipool.id ?? 0))
        }
        var dstRideIds = [String]()
        if let carpoolPassengerRids = MyActiveRidesCache.getRidesCacheInstance()?.getRequestedPassengerRides(){
            for ride in carpoolPassengerRids{
                dstRideIds.append(StringUtils.getStringFromDouble(decimalNumber: ride.rideId))
            }
        }
        if srcRideIds.isEmpty && dstRideIds.isEmpty{
            return
        }
        TaxiSharingRestClient.getIncomingAndOutGoingInvitations(srcRideIds: srcRideIds, destRideIds: dstRideIds) { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self?.taxipoolInvites = Mapper<TaxiPoolInvite>().mapArray(JSONObject: responseObject!["resultData"]) ?? [TaxiPoolInvite]()
                NotificationCenter.default.post(name: .taxiInvitationReceived, object: nil)
            }
        }
    }
}
