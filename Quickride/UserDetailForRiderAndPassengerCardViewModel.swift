//
//  UserDetailForRiderAndPassengerCardViewModel.swift
//  Quickride
//
//  Created by Quick Ride on 7/14/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserDetailForRiderAndPassengerCardViewModel  {
    
    static let RIDE_MATCHES_COUNT = "rideMatchesCount"
    static let RIDE_MATCHES_BUCKET = "rideMatchesBucket"
    static let SERVER_ERROR = "serverError"
    static let NS_ERROR = "nSError"

    var currentUserRide : Ride
    var isModerator = false
    var isFromRideCreation = false

    var rideDetailInfo : RideDetailInfo?
    var passengersInfo = [RideParticipant]()
    var outGoingRideInvites = [RideInvitation]()
    var incomingRideInvites = [RideInvitation]()
    var selectedPassengerId : Double = 0
    var taxiPoolInvites = [TaxiPoolInvite]()
    var updatedRouteId: Double?

    init() {
         self.currentUserRide = Ride()
    }
    init(currentUserRide: Ride, isFromRideCreation: Bool) {
        self.currentUserRide = currentUserRide
        
        self.isFromRideCreation = isFromRideCreation
        self.rideDetailInfo = LiveRideViewModelUtil.initializeRideDetailInfo(currentUserRide: currentUserRide)
        if let ride = rideDetailInfo?.currentUserRide, let rideParticipants = rideDetailInfo?.rideParticipants {
            self.currentUserRide = ride
            isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: currentUserRide, rideParticipantObjects: rideParticipants)
        }
        RideInviteCache.getInstance().addRideInviteStatusListener(rideInvitationUpdateListener : self)
        validateAndGetRideInvites()
        initializePassengerInfos()
    }
    
    private func validateAndGetRideInvites() {
        getIncomingInivtesForTheRide(ride: currentUserRide)
        getOutGoingInvitesForRide(ride: currentUserRide)
        if currentUserRide is PassengerRide{
            taxiPoolInvites = MyActiveTaxiRideCache.getInstance().getIncomingTaxipoolInvitesForRide(rideId: currentUserRide.rideId)
        }

    }
        
    func getTaxiPoolInvitation() {
        taxiPoolInvites = MyActiveTaxiRideCache.getInstance().getIncomingTaxipoolInvitesForRide(rideId: currentUserRide.rideId)
    }
    private func getOutGoingInvitesForRide(ride: Ride){
        if isModerator {
            outGoingRideInvites.removeAll()
            return
        }
        if let rideType = ride.rideType {
            var invites = RideInviteCache.getInstance().getInvitationsForRide(rideId: ride.rideId, rideType: rideType)
                invites.sort(by: {$0.invitationTime < $1.invitationTime})
                outGoingRideInvites = invites
        }
    }
    
    private func getIncomingInivtesForTheRide(ride : Ride){
        if !isIncomingInvitesAllowed(currentUserRide: ride){
            incomingRideInvites.removeAll()
            return
        }
        var rideId: Double?
        var rideType: String?
        if isModerator {
            rideId = rideDetailInfo?.riderRide?.rideId
            rideType = rideDetailInfo?.riderRide?.rideType
        } else {
            rideId = ride.rideId
            rideType = ride.rideType
        }
        if let rideId = rideId, let rideType = rideType {
            
            var invites  = RideInviteCache.getInstance().getReceivedInvitationsOfRide(rideId: rideId, rideType: rideType)
            invites.sort(by: {$0.invitationTime < $1.invitationTime})
            incomingRideInvites = invites

            
        }
    }
    
    func getRiderRideId() -> Double {
        return LiveRideViewModelUtil.getRiderRideId(currentUserRide: currentUserRide)
    }
    private func isIncomingInvitesAllowed(currentUserRide : Ride) -> Bool {
        if isModerator, let riderRide = rideDetailInfo?.riderRide, riderRide.availableSeats <= 0{
             return false
        } else if !isModerator , let passengerRide = currentUserRide as? PassengerRide, Ride.RIDE_STATUS_REQUESTED != passengerRide.status{
            return false
        } else if let riderRide = currentUserRide as? RiderRide, riderRide.availableSeats <= 0{
            return false
        }
        return true
    }
    
  
    func getAutoConfirmSentInvitesAndRequests(handler : @escaping (_ autoSentInvites :[RideInvitation]) -> Void){
        
        var autoSentInvites = [RideInvitation]()
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        for invite in outGoingRideInvites{
            if invite.autoInvite == true  {
                autoSentInvites.append(invite)
                var userId = invite.passengerId
                if currentUserRide.rideType == Ride.PASSENGER_RIDE {
                    userId = invite.riderId
                }
                group.enter()
                queue.async {
                    UserDataCache.getInstance()?.getUserBasicInfo(userId: userId, handler: { (userBasicInfo, responseError, error) in
                        group.leave()
                    })
                    
                }
            }
        }
        group.notify(queue: queue){
            handler(autoSentInvites)
        }
        
    }
    
    private func initializePassengerInfos(){
        guard let rideDetailInfo = rideDetailInfo else {
            return
        }
        passengersInfo = RideViewUtils.getPasengersInfo(rideParticipants: rideDetailInfo.rideParticipants, isOverlappigRouteToConsider: true)
    }
    
    func getRiderId() -> Double {
        if let passengerRide = currentUserRide as? PassengerRide {
            return passengerRide.riderId
        }else{
            return currentUserRide.userId
        }
    }
    func isRideMatchesAvaiable() -> Bool {
        if passengersInfo.isEmpty && incomingRideInvites.isEmpty && outGoingRideInvites.isEmpty &&  taxiPoolInvites.isEmpty {
            return false
        }
        return true
    }
    func findRideMatchesToInvite() {
        if let riderRide = currentUserRide as? RiderRide{
            MatchedUsersCache.getInstance().getAllMatchedPassengers(ride: riderRide, rideRoute: nil, overviewPolyline: riderRide.routePathPolyline, capacity: riderRide.availableSeats, fare: riderRide.farePerKm, requestSeqId: 1, displaySpinner: false, dataReceiver: self)
        } else if let passengerRide = currentUserRide as? PassengerRide{
            MatchedUsersCache.getInstance().getAllMatchedRiders(ride: passengerRide, rideRoute: nil, overviewPolyline: passengerRide.routePathPolyline, noOfSeats: passengerRide.noOfSeats, requestSeqId: 1, displaySpinner: false, dataReceiver: self)
        }
    }
    func updateFreezeRide(freezeRide : Bool,handler : @escaping (_ responseError : ResponseError?,_ error : NSError?) -> Void){
        guard let riderRide = currentUserRide as? RiderRide else {
            return
        }
        RiderRideRestClient.freezeRide(rideId: currentUserRide.rideId, freezeRide: freezeRide, targetViewController: nil, complitionHandler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                riderRide.freezeRide = freezeRide
                MyActiveRidesCache.getRidesCacheInstance()?.updateRiderRide(riderRide: riderRide)
                handler(nil,nil)
            } else {
                let result = RestResponseParser<RiderRide>().parse(responseObject: responseObject, error: error)
                handler(result.1,result.2)
            }
        })
    }
    func isPassengerAdditionAllowed() -> Bool{
      if let riderRide = currentUserRide as? RiderRide, (riderRide.availableSeats > 0 || riderRide.cumulativeOverlapDistance < 0.85*(riderRide.distance!*Double(riderRide.capacity))){
        return true
      }
      return false
    }
    func isRideJoinAllowed() -> Bool{
        if let passengerRide = currentUserRide as? PassengerRide, passengerRide.riderRideId != 0 {
            return false
        }
        return true
    }
    func isStartRideAllowed() -> Bool {
        let rideStatus = RideStatus(ride: currentUserRide)
        return rideStatus.isStartRideAllowed()
    }
    func isStopRideAllowed() -> Bool {
        let rideStatus = RideStatus(ride: currentUserRide)
        return rideStatus.isStopRideAllowed()
    }
    func isCheckOutRideAllowed() -> Bool {
        let rideStatus = RideStatus(ride: currentUserRide)
        return rideStatus.isCheckOutRideAllowed()
    }
    func isSelectedPassengerToPickup(participantId : Double) -> Bool {
        return false
    }
    func getApplicableActionOnPassengerSelection(rideParticipant : RideParticipant) -> [String]{
        LiveRideViewModelUtil.getApplicableActionOnPassengerSelection(rideParticipant: rideParticipant, riderRide: rideDetailInfo?.riderRide, currentUserRide: currentUserRide)
    }

    func getPassengerRideParticipant(participantId : Double) -> RideParticipant? {
      AppDelegate.getAppDelegate().log.debug("\(participantId)")
      
      for passenger in passengersInfo{
        if(passenger.userId == participantId){
          return passenger
        }
      }
      return nil
    }
    func getRiderVehicle() -> Vehicle?{
        guard let riderRide = rideDetailInfo?.riderRide else {
            return nil
        }
        let vehicle = Vehicle(ownerId:riderRide.userId,vehicleModel: riderRide.vehicleModel,vehicleType: riderRide.vehicleType,registrationNumber: riderRide.vehicleNumber,capacity: riderRide.capacity,fare: riderRide.farePerKm,makeAndCategory: riderRide.makeAndCategory,additionalFacilities: riderRide.additionalFacilities,riderHasHelmet : riderRide.riderHasHelmet)
        vehicle.imageURI = riderRide.vehicleImageURI
        return vehicle
    }
    

    
    func getMatchedPassengerForRideInvitation(rideInvitation : RideInvitation, handler : @escaping (_ matchedPassenger : MatchedPassenger?) -> Void){
        RouteMatcherServiceClient.getMatchingPassenger(passengerRideId: rideInvitation.passenegerRideId, riderRideId: rideInvitation.rideId, targetViewController: nil) { (responseObject, error) in
            let result = RestResponseParser<MatchedPassenger>().parse(responseObject: responseObject, error: error)
            guard let matchedPassenger = result.0 else {
                handler(nil)
                return
            }
            if rideInvitation.newFare != -1{
                matchedPassenger.newFare = rideInvitation.newFare
            }
            if matchedPassenger.pickupLocationAddress == nil{
                matchedPassenger.pickupLocationAddress = rideInvitation.pickupAddress
                matchedPassenger.pickupLocationLatitude = rideInvitation.pickupLatitude
                matchedPassenger.pickupLocationLongitude = rideInvitation.pickupLongitude
            }
            if matchedPassenger.dropLocationAddress == nil{
                matchedPassenger.dropLocationAddress = rideInvitation.dropAddress
                matchedPassenger.dropLocationLatitude = rideInvitation.dropLatitude
                matchedPassenger.dropLocationLongitude = rideInvitation.dropLongitude
            }
            handler(matchedPassenger)
        }
    }
    func updatePassengerRideStatus(rideParticipant: RideParticipant, status: String , handler : @escaping (_ responseError : ResponseError?,_ error : NSError?) -> Void){
        PassengerRideServiceClient.updatePassengerRideStatus(passengerRideId: rideParticipant.rideId, joinedRiderRideId:LiveRideViewModelUtil.getRiderRideId(currentUserRide: currentUserRide), passengerId: rideParticipant.userId, status: status,fromRider: true, otp: nil, viewController: nil,  completionHandler:  { (responseObject, error) in
            let result = RestResponseParser<Ride>().parse(responseObject: responseObject, error: error)
            handler(result.1,result.2)
        })
    }
    
    func getMatchedUserForInvite(rideInvitation: RideInvitation,handler : @escaping(_ matchedUser : MatchedUser?, _ responseError : ResponseError?, _ error : NSError?) -> Void) {
        
        var rideType: String
        var rideId = 0.0
        var userId = 0.0
        if currentUserRide.rideType == Ride.RIDER_RIDE || isModerator{
            if rideInvitation.rideType == TaxiPoolConstants.Taxi {
                rideType = TaxiPoolConstants.Taxi

            }else{
                rideType = Ride.PASSENGER_RIDE

            }
            rideId = rideInvitation.passenegerRideId
            userId = rideInvitation.passengerId
        }else{
            rideType = Ride.RIDER_RIDE
            rideId = rideInvitation.rideId
            userId = rideInvitation.riderId
        }
        if rideId == 0 && rideInvitation.invitingUserId == currentUserRide.userId{
            if currentUserRide.rideType == Ride.RIDER_RIDE {
                validateAndGetMatchedPassenger(rideInvitation: rideInvitation, handler: handler)
            }else {
                validateAndGetMatchedRider(rideInvitation: rideInvitation, handler: handler)
            }
            return
        }
        if rideId == 0 && userId == 0 {
            return handler(nil,nil,nil)
        }
       let matchedUserRetrievalTask =  MatchedUserRetrievalTask(userId: userId, rideId: rideId, rideType: rideType, rideInvitation: rideInvitation) { (matchedUser, rideInvitation, responseError, error) in
             if let errorCode = responseError?.errorCode {
                if errorCode == RideValidationUtils.PASSENGER_ALREADY_JOINED_THIS_RIDE ||
                    errorCode == RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE ||
                    errorCode == RideValidationUtils.INSUFFICIENT_SEATS_ERROR ||
                    errorCode == RideValidationUtils.RIDE_ALREADY_COMPLETED ||
                    errorCode == RideValidationUtils.RIDE_CLOSED_ERROR ||
                    errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR ||
                    errorCode == RideValidationUtils.RIDES_DONT_MATCH_ANYMORE
                 {
                    self.removeRideInvigation(rideInvitation: rideInvitation)
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
                }
            }
            handler(matchedUser,responseError,error)
        }
        matchedUserRetrievalTask.getMatchedUser()
        
    }
   
    func validateAndGetMatchedPassenger(rideInvitation : RideInvitation,handler : @escaping(_ matchedUser : MatchedUser?, _ responseError : ResponseError?, _ error : NSError?) -> Void) {
                   UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.passengerId, handler: { (userBasicInfo, responseError, error) in
                       if let userBasicInfo = userBasicInfo{
                        let matchedPassenger = MatchedPassenger(ride: self.currentUserRide, rideInvitation: rideInvitation, userProfile: userBasicInfo)
                           handler(matchedPassenger,nil,nil)
                       }else{
                           handler(nil,responseError,error)
                       }
                   })
                    
    }
    func validateAndGetMatchedRider(rideInvitation : RideInvitation, handler : @escaping(_ matchedUser : MatchedUser?, _ responseError : ResponseError?, _ error : NSError?) -> Void){
        UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.riderId, handler: { (userBasicInfo, responseError, error) in
            if let userBasicInfo = userBasicInfo{
                let matchedRider = MatchedRider(ride: self.currentUserRide, rideInvitation: rideInvitation, userProfile: userBasicInfo)
                handler(matchedRider,nil,nil)
            }else{
                handler(nil,responseError,error)
            }
        })
    }
    
    func updateRideInvitationStatusAsSeen(rideInvitation : RideInvitation){
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitation.rideInvitationId)
        if rideInvitation.invitingUserId != UserDataCache.getCurrentUserId() && rideInvitation.invitationStatus != RideInvitation.RIDE_INVITATION_STATUS_READ{
            RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_READ, viewController: nil) { (responseObject, error) in
                rideInvitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_READ
                let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation)
                RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
            }
        }
    }
    func removeRideInvigation(rideInvitation : RideInvitation){
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitation.rideInvitationId)
        RideInviteCache.getInstance().removeInvitation(id: rideInvitation.rideInvitationId)

    }
    
    func isETAvaialbleForNextPickup(riderCurrentLocation : RideParticipantLocation) -> Bool {
        
        if let riderRide = rideDetailInfo?.riderRide, Ride.RIDE_STATUS_STARTED == riderRide.status,riderRide.startTime - NSDate().getTimeStamp() < 60*60*1000 {
            return true
        }
        return false
    }
    
    func getNextPassengerIdToPickup(riderCurrentLocation : RideParticipantLocation) -> (Double,Int) {
        
        if selectedPassengerId != 0 {
            for (index,particpant) in passengersInfo.enumerated(){
                if selectedPassengerId == particpant.userId{
                    return(selectedPassengerId,index)
                }
            }
            return (selectedPassengerId,0)
        }
        var nextPassengerToPickup : RideParticipant?
        var nextPassengerToPickupIndex = -1
        for (index,rideParticipant) in passengersInfo.enumerated(){
            if rideParticipant.rider || (Ride.RIDE_STATUS_SCHEDULED != rideParticipant.status && Ride.RIDE_STATUS_DELAYED != rideParticipant.status){
                continue
            }
            if nextPassengerToPickup == nil || nextPassengerToPickup!.distanceFromRiderStartToPickUp > rideParticipant.distanceFromRiderStartToPickUp{
                nextPassengerToPickup = rideParticipant
                nextPassengerToPickupIndex = index
                
            }
        }
        if nextPassengerToPickup != nil && nextPassengerToPickupIndex != -1{
            updateSelectedPassengerId(selectedPassengerId: nextPassengerToPickup!.userId)
            return(nextPassengerToPickup!.userId,nextPassengerToPickupIndex)
        }
        return (0,0)
        
    }
    func getParticipantETAInfoFor(passengerId : Double,riderCurrentLocation : RideParticipantLocation) -> ParticipantETAInfo?{
        
        guard let participantETAInfos = riderCurrentLocation.participantETAInfos, !participantETAInfos.isEmpty else {
            return nil
        }
        for participantETAInfo in participantETAInfos {
            if passengerId == participantETAInfo.participantId{
                return participantETAInfo
            }
        }
        return nil
    }
    func getTimeTakesToReachPickup(etaInfo : ParticipantETAInfo,creationTime : Double) -> String {
        
        let durationInTrafficMinutes = etaInfo.durationInTraffic
        if durationInTrafficMinutes <= 0 {
            return "1 min\naway"
        }else if durationInTrafficMinutes <= 59 {
            return String(etaInfo.durationInTraffic) + " min\naway"
        }else if (durationInTrafficMinutes%60 == 0){
            return String(durationInTrafficMinutes/60)+" hour\naway"
        }else{
            return String(durationInTrafficMinutes/60)+" hour\naway"
        }
        
    }
    func getDistanceToReachPickup(etaInfo : ParticipantETAInfo,creationTime : Double) -> String {
        
        let distanceInMeters = etaInfo.routeDistance.roundToPlaces(places: 0)
        if distanceInMeters > 1000 {
            var distanceInKM : Double = distanceInMeters / 1000
            return String(distanceInKM.roundToPlaces(places: 1)) + " km away"
        }else if (distanceInMeters > 999) {
            return "1 km away"
        } else if (distanceInMeters > 10){
            return String(Int(distanceInMeters)) + " m away"
        } else {
            return "1 m away"
        }
    }
    
    func updateSelectedPassengerId(selectedPassengerId : Double){
        self.selectedPassengerId = selectedPassengerId
        var userInfo = [String : Double]()
        userInfo[LiveRideNSNotificationConstants.SELECTED_PASSENGER_ID] = selectedPassengerId
        NotificationCenter.default.post(name: .selectedPassengerChanged, object: nil, userInfo: userInfo)
    }
    
    func getTaxipoolDetails(taxiInvite: TaxiPoolInvite,complitionHandler: @escaping TaxiSharingRestClient.responseJSONCompletionHandler){
        updateTaxiInviteStatus(taxiInvite: taxiInvite)
        if taxiInvite.invitedRideId != 0{
            TaxiSharingRestClient.getInvitedTaxiPoolerDetails(taxiGroupId: taxiInvite.taxiRideGroupId, passengerRideId: taxiInvite.invitedRideId,completionHandler: complitionHandler)
        }else{
            TaxiSharingRestClient.getInviteByContactTaxiPoolerDetails(taxiGroupId: taxiInvite.taxiRideGroupId, startTime: taxiInvite.pickupTimeMs, startLat: taxiInvite.fromLat, startLng: taxiInvite.fromLng, endLat: taxiInvite.toLat, endLng: taxiInvite.toLng, noOfSeats: 1, reqToSetAddress: true, completionHandler: complitionHandler)
        }
    }
    func updateTaxiInviteStatus(taxiInvite: TaxiPoolInvite){ //taxi invite status update
        TaxiSharingRestClient.updateTaxiInviteStatus(inviteId: taxiInvite.id ?? "", invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_READ){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                var taxiInvite = taxiInvite
                taxiInvite.status = TaxiPoolInvite.TAXI_INVITE_STATUS_READ
                MyActiveTaxiRideCache.getInstance().updateTaxipoolInvite(taxiInvite: taxiInvite)
            }
        }
    }
}
//MARK: RideInvitationUpdateListener delegate
extension UserDetailForRiderAndPassengerCardViewModel : RideInvitationUpdateListener {
    
    func rideInvitationStatusUpdated() {
        validateAndGetRideInvites()
        NotificationCenter.default.post(name: .rideMatchesUpdated, object: self)
    }
}

extension UserDetailForRiderAndPassengerCardViewModel : MatchedUsersDataReceiver {
    func receiveMatchedRidersList(requestSeqId: Int, matchedRiders: [MatchedRider], currentMatchBucket: Int) {
        var userInfo = [AnyHashable : Any]()
        userInfo[UserDetailForRiderAndPassengerCardViewModel.RIDE_MATCHES_COUNT] = matchedRiders.count
        userInfo[UserDetailForRiderAndPassengerCardViewModel.RIDE_MATCHES_BUCKET] = currentMatchBucket
        NotificationCenter.default.post(name: .matchedUsersToInviteResult, object: self, userInfo: userInfo)
    }
    
    func receiveMatchedPassengersList(requestSeqId: Int, matchedPassengers: [MatchedPassenger], currentMatchBucket: Int) {
        var userInfo = [AnyHashable : Any]()
        userInfo[UserDetailForRiderAndPassengerCardViewModel.RIDE_MATCHES_COUNT] = matchedPassengers.count
        userInfo[UserDetailForRiderAndPassengerCardViewModel.RIDE_MATCHES_BUCKET] = currentMatchBucket
        NotificationCenter.default.post(name: .matchedUsersToInviteResult, object: self, userInfo: userInfo)
    }
    
    func matchingRidersRetrievalFailed(requestSeqId: Int, responseObject: NSDictionary?, error: NSError?) {
        var userInfo = [AnyHashable : Any]()
        let result = RestResponseParser<MatchedUser>().parse(responseObject: responseObject, error: error)
        userInfo[UserDetailForRiderAndPassengerCardViewModel.SERVER_ERROR] = result.1
        userInfo[UserDetailForRiderAndPassengerCardViewModel.NS_ERROR] = result.2
        NotificationCenter.default.post(name: .matchedUsersToInviteResult, object: self, userInfo: userInfo)
    }
    
    func matchingPassengersRetrievalFailed(requestSeqId: Int, responseObject: NSDictionary?, error: NSError?) {
        var userInfo = [AnyHashable : Any]()
        let result = RestResponseParser<MatchedUser>().parse(responseObject: responseObject, error: error)
        userInfo[UserDetailForRiderAndPassengerCardViewModel.SERVER_ERROR] = result.1
        userInfo[UserDetailForRiderAndPassengerCardViewModel.NS_ERROR] = result.2
        NotificationCenter.default.post(name: .matchedUsersToInviteResult, object: self, userInfo: userInfo)
    }
    func getNextPassengerETAFromServer(participantId: Double,startLat: Double, startLng: Double, endLat: Double, endLng: Double, handler: @escaping (_ etaInfo : ParticipantETAInfo) -> Void) {
        guard let riderRide = rideDetailInfo?.riderRide else { return  }
        var routeId: Double = 0
        if let updatedRouteId = updatedRouteId, updatedRouteId != 0 {
            routeId = updatedRouteId
        }else if let riderRouteId = riderRide.routeId {
            routeId = riderRouteId
        }
        ETAFinder.getInstance().getETA(userId: riderRide.userId, rideId: riderRide.rideId, useCase: "iOS.App.NextRideTaker.LiveRide", source: LatLng(lat: startLat, long: startLng), destination: LatLng(lat: endLat, long: endLng), routeId: routeId, startTime: NSDate().getTimeStamp(), vehicleType: getVehicleTypeForEtaService(vehicleType: riderRide.vehicleType),routeStartLatitude: riderRide.startLatitude , routeStartLongitude: riderRide.startLongitude, routeEndLatitude: riderRide.endLatitude!, routeEndLongitude: riderRide.endLongitude!, routeWaypoints: riderRide.waypoints, routeOverviewPolyline: riderRide.routePathPolyline) { [weak self] (etaResponse) in
           
            let participantETAInfo = ParticipantETAInfo(participantId: participantId, destinationLatitude: etaResponse.destination!.latitude, destinationLongitude: etaResponse.destination!.longitude, routeDistance: etaResponse.distanceInKM*1000, durationInTraffic: etaResponse.timeTakenInSec/60, duration: etaResponse.timeTakenInSec/60, error: etaResponse.error)
            self?.updatedRouteId = etaResponse.routeId
            handler(participantETAInfo)
        }
    }
    func getVehicleTypeForEtaService( vehicleType : String?) -> String{
        guard let type = vehicleType else {
            return "Car"
        }
        switch type {
        case Vehicle.VEHICLE_TYPE_BIKE:
            return "Bike"
        default:
            return "Car"
        }
    }
    
}

