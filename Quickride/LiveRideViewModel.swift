//
//  LiveRideViewModel.swift
//  Quickride
//
//  Created by Vinutha on 19/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import GoogleMaps
import ObjectMapper
import MessageUI
import Polyline
import CoreLocation

protocol PassengerRideUpdateDelegate {
    func passengerRideUpdated(ride: Ride)
}

protocol GetDefaultLinkedWalletBalanceDelegate {
    func balanceReceived()
}
class LiveRideViewModel {

    var currentUserRide : Ride?
    var rideDetailInfo : RideDetailInfo?
    var isRideDetailInfoRetrieved = false
    var isFromRideCreation = false
    var isFreezeRideRequired = false
    var isFromSignupFlow = false
    var isWalkPathViewHidden = true
    var isMapFullView = false
    var isParticipantlocationLoaded = false
    var policyUrl : String?
    var insurancePoints : Double?
    var selectedPassengerId : Double = 0
    var closedDialogueDisplayed = false
    var isModerator = false
    var ridePaymentDetails: RidePaymentDetails?
    //Mark: Constant
    static let MIN_TIME_DIFF_CURRENT_LOCATION  = 10
    static let MIN_TIME_DIFF_FOR_ETA  = 60
    static var MAP_ZOOM :Float = 16
    static let LOCATION_REFRESH_TIME_THRESHOLD_IN_SECS = 60.0
    //MARK:TaxiPool
    var taxiRideId: Double? = 0
    //MARK: Relay ride
    var firstRelayRide: Ride?
    var secondRelayRide: Ride?
    var requiredToShowRelayRide: String?
    var isTaxiRideReachedDestination: Bool?
    var jobPromotionData = [JobPromotionData]()
    var outstationTaxiAvailabilityInfo: OutstationTaxiAvailabilityInfo?
    //MARK: OfferList
    var finalOfferList: [Offer] = []
    var detailEstimatedFare : DetailedEstimateFare?
    var matchedTaxipool: MatchedTaxiRideGroup?
    var userInteractedWithMap = false
    var doRefreshLocation = false
    var updatedRouteId: Double? 
    init() {

    }

    init (riderRideId : Double,rideObj : Ride?,isFromRideCreation : Bool, isFreezeRideRequired : Bool, isFromSignupFlow: Bool,relaySecondLegRide: Ride?,requiredToShowRelayRide: String) {
        self.isFreezeRideRequired = isFreezeRideRequired
        self.isFromSignupFlow = isFromSignupFlow
        self.isFromRideCreation = isFromRideCreation
        if requiredToShowRelayRide == RelayRideMatch.SHOW_FIRST_RELAY_RIDE{
            self.firstRelayRide = rideObj
            self.secondRelayRide = relaySecondLegRide
            self.currentUserRide = validateAndInitializeCurrentUserRide(rideObj: rideObj, riderRideId: riderRideId)
        }else if requiredToShowRelayRide == RelayRideMatch.SHOW_SECOND_RELAY_RIDE{
            self.firstRelayRide = rideObj
            self.secondRelayRide = relaySecondLegRide
            self.currentUserRide = validateAndInitializeCurrentUserRide(rideObj: relaySecondLegRide, riderRideId: riderRideId)
        }else{
            self.currentUserRide = validateAndInitializeCurrentUserRide(rideObj: rideObj, riderRideId: riderRideId)
            self.firstRelayRide = currentUserRide
        }
        self.requiredToShowRelayRide = requiredToShowRelayRide
    }

    func isRideDataValid() -> Bool{

        if currentUserRide == nil{
            return false
        }else {
            return true
        }
    }

    func getCurrentUserStatusImRide() -> String?{
        guard let rideParticipants = rideDetailInfo!.rideParticipants  else {
            return nil
        }
        guard let currentRideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: currentUserRide!.userId, rideParticipants: rideParticipants) else {
            return nil
        }
        return currentRideParticipant.status
    }
    
    func getRiderParticipantInfo() -> RideParticipant?{
        guard let currentUserRide = currentUserRide else {
            return nil
        }
        let rideDetailInformation =  LiveRideViewModelUtil.initializeRideDetailInfo(currentUserRide: currentUserRide)
        guard let rideParticipants = rideDetailInformation?.rideParticipants else {
            return nil
        }
        for rideParticipant in rideParticipants {
            if rideParticipant.rider {
                return rideParticipant
            }
        }
        return nil
    }


    func validateAndInitializeCurrentUserRide(rideObj : Ride?,riderRideId : Double) -> Ride? {
        guard let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance() else {
            return nil
        }
        if let ride  = rideObj, ride.rideType == Ride.RIDER_RIDE {
          return myActiveRidesCache.getRiderRide(rideId: ride.rideId)
        }else if let ride = rideObj, ride.rideType == Ride.PASSENGER_RIDE {
            myActiveRidesCache.delegateForTaxiPool = self
            return myActiveRidesCache.getPassengerRide(passengerRideId: ride.rideId)

        } else if riderRideId != 0 {

            if let riderRide = myActiveRidesCache.getRiderRide(rideId: riderRideId), riderRide.status != Ride.RIDE_STATUS_CANCELLED , riderRide.status != Ride.RIDE_STATUS_COMPLETED {
                return  riderRide
            }else if let passengerRide = myActiveRidesCache.getPassengerRideByRiderRideId(riderRideId: riderRideId), passengerRide.status != Ride.RIDE_STATUS_CANCELLED , passengerRide.status != Ride.RIDE_STATUS_COMPLETED{
                return passengerRide
            }
        }
        return nil
    }

    func updateIsModerator(){
        if let participants = rideDetailInfo?.rideParticipants {
            isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: currentUserRide, rideParticipantObjects: participants)
        }else{
            isModerator = false
        }
    }

    func getRiderRideId() -> Double{

        return LiveRideViewModelUtil.getRiderRideId(currentUserRide: currentUserRide)
    }
    var handler : ((_ responseError: ResponseError?, _ error: NSError?) -> Void)?

    func getRideDetailInfo(handler : @escaping (_ responseError: ResponseError?, _ error: NSError?) -> Void){
        self.handler = handler
        guard let ride = currentUserRide else { return }
        if ride.rideType == Ride.PASSENGER_RIDE {
            if let passengerRide = currentUserRide as? PassengerRide, isTaxiRide(ride: passengerRide) {
                QuickRideProgressSpinner.startSpinner()
                self.taxiRideId = passengerRide.taxiRideId ?? 0.0
                MyActiveRidesCache.getRidesCacheInstance()?.getTaxiDetailInfo(taxiRideId: self.taxiRideId ?? 0.0, passengerRideId: ride.rideId, myRidesCacheListener: self)
            } else {
                if getRiderRideId() != 0 {
                    MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfo(riderRideId: getRiderRideId(), currentuserRide: ride, myRidesCacheListener: self)
                }
            }

        } else {
        MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfo(riderRideId: getRiderRideId(), currentuserRide: ride, myRidesCacheListener: self)
        }
    }
    func loadRideParticipantLocations(handler : @escaping () -> Void){
        guard let rideDetailInfo = rideDetailInfo else {
            return handler()
        }
        if  isParticipantlocationLoaded &&  rideDetailInfo.rideParticipantLocations != nil  {
            return handler()
        }
        MyActiveRidesCache.getRidesCacheInstance()?.getRideParticipantLocationAndRefresh(riderRideId: rideDetailInfo.riderRideId!, handler: { (participantLocations) in
            self.isParticipantlocationLoaded = true
            if let participantLocations  = participantLocations {
                self.rideDetailInfo?.rideParticipantLocations = participantLocations
            }
            if rideDetailInfo.rideParticipantLocations == nil {
                self.rideDetailInfo?.rideParticipantLocations = [RideParticipantLocation]()
            }
            return handler()
        })

    }
    func getCurrentUserParticipantETAInfo() -> ParticipantETAInfo? {
        guard let rideParticipantLocations = rideDetailInfo?.rideParticipantLocations, !rideParticipantLocations.isEmpty else {
            return nil
        }
        guard let riderRide = rideDetailInfo?.riderRide else {
            return nil
        }
        for rideParticipantLocation in rideParticipantLocations {
            if rideParticipantLocation.userId == riderRide.userId {
                guard let participantETAInfos = rideParticipantLocation.participantETAInfos, !participantETAInfos.isEmpty else {
                    return nil
                }
                for participantETAInfo in participantETAInfos {
                    if participantETAInfo.participantId == currentUserRide?.userId {
                        participantETAInfo.lastUpdateTime = rideParticipantLocation.lastUpdateTime!
                        return participantETAInfo
                    }
                }
            }
        }
        return nil
    }

    func getFareDetails() -> Double {
        if let passengerRide = currentUserRide as? PassengerRide{
            if passengerRide.status == Ride.RIDE_STATUS_REQUESTED {
                return 0
            }
            if passengerRide.newFare > -1{
                return passengerRide.newFare
            }else{
                return passengerRide.points
            }
        } else {
            return 0
        }
    }

    func getPassengersParticipantInfo() -> [RideParticipant]{
        var passengers = [RideParticipant]()
        if taxiRideId != 0 {
            if rideDetailInfo?.rideParticipants?.count == 0{
                return []
            } else {
               return rideDetailInfo?.rideParticipants ?? []
            }
        }
        guard let rideParticipants = rideDetailInfo?.rideParticipants, rideParticipants.count > 1 else {
            return passengers
        }
        for rideParticipant in rideParticipants {
            if rideParticipant.rider || !rideParticipant.hasOverlappingRoute{
                continue
            }
            passengers.append(rideParticipant)
        }
        return passengers
    }

    func getGMSBoundsToFocusBasedOnStatus() -> (GMSCoordinateBounds?,[CLLocationCoordinate2D]?)?{
        guard let currentParticipantRide = currentUserRide else {
            return nil
        }
         if isModerator || Ride.RIDER_RIDE == currentParticipantRide.rideType {

            guard let riderRide = rideDetailInfo?.riderRide else {
                return nil
            }

            if Ride.RIDE_STATUS_STARTED == riderRide.status {
                var start : CLLocationCoordinate2D
                var end : CLLocationCoordinate2D?
                if let riderCurrentLocatin = getRiderCurrentLocationBasedOnStatus(){
                    start = CLLocationCoordinate2DMake(riderCurrentLocatin.latitude!, riderCurrentLocatin.longitude!)
                   
                } else {
                    start = CLLocationCoordinate2DMake(riderRide.startLatitude, riderRide.startLongitude)
                }

                if let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: selectedPassengerId, rideParticipants: rideDetailInfo?.rideParticipants){
                    end = CLLocationCoordinate2DMake(rideParticipant.startPoint!.latitude, rideParticipant.startPoint!.longitude)
                }
                var arr = [start]
                if let end = end {
                    arr.append(end)
                }
                return (nil,arr)

            }  else {
                guard let gmsPath =  GMSPath(fromEncodedPath: riderRide.routePathPolyline) else {
                    return nil
                }
                return (GMSCoordinateBounds(path:gmsPath), nil)
            }

        } else {

            if  let riderRide = rideDetailInfo?.riderRide , Ride.RIDE_STATUS_STARTED == riderRide.status,let passengerRide = currentParticipantRide as? PassengerRide {

                var start : CLLocationCoordinate2D
                var end: CLLocationCoordinate2D?
                var passengerLocation : CLLocationCoordinate2D?

               
                if let riderCurrentLocatin = getRiderCurrentLocationBasedOnStatus(){
                    start = CLLocationCoordinate2DMake(riderCurrentLocatin.latitude!, riderCurrentLocatin.longitude!)
                    if passengerRide.status != Ride.RIDE_STATUS_STARTED {
                        end = CLLocationCoordinate2DMake(passengerRide.pickupLatitude, passengerRide.pickupLongitude)
                        
                       
                    }
                } else {
                    start = CLLocationCoordinate2DMake(passengerRide.pickupLatitude, passengerRide.pickupLongitude)
                    end = CLLocationCoordinate2DMake(passengerRide.dropLatitude, passengerRide.dropLongitude)

                }
                if passengerRide.status != Ride.RIDE_STATUS_STARTED ,let prevLocation = LocationChangeListener.getInstance().previousLocationUpdate, (passengerRide.pickupTime - NSDate().getTimeStamp() < 15*60*1000 || rideDetailInfo?.getRideParticipantLocation(userId:riderRide.userId) != nil)  {
                    passengerLocation = prevLocation.coordinate
                }
                var arr = [start]
                if let passengerLocation = passengerLocation {
                    arr.append(passengerLocation)
                }
                if let end = end {
                    arr.append(end)
                }
                return (nil,arr)
            } else if let riderRide = rideDetailInfo?.riderRide , (Ride.RIDE_STATUS_SCHEDULED == riderRide.status || Ride.RIDE_STATUS_DELAYED == riderRide.status),let passengerRide = currentParticipantRide as? PassengerRide {
                if passengerRide.status != Ride.RIDE_STATUS_STARTED ,let prevLocation = LocationChangeListener.getInstance().previousLocationUpdate, (passengerRide.pickupTime - NSDate().getTimeStamp() < 15*60*1000 || rideDetailInfo?.getRideParticipantLocation(userId:riderRide.userId) != nil) {
                    let arr = [prevLocation.coordinate,CLLocationCoordinate2D(latitude: passengerRide.pickupLatitude, longitude: passengerRide.pickupLongitude)]
                    return (nil, arr)
                }else{
                    guard let gmsPath =  GMSPath(fromEncodedPath: passengerRide.pickupAndDropRoutePolyline) else {
                        return nil
                    }
                    return (GMSCoordinateBounds(path: gmsPath), nil)
                }
               

            } else {
                guard let gmsPath =  GMSPath(fromEncodedPath: currentParticipantRide.routePathPolyline) else {
                    return nil
                }
                return (GMSCoordinateBounds(path: gmsPath), nil)
            }

        }
    }

    func getETAForParticipant(riderParticipantLocation : RideParticipantLocation, participantId : Double) -> ParticipantETAInfo?{
        if let participantETAInfos = riderParticipantLocation.participantETAInfos{
            for participantETAInfo in participantETAInfos{
                if participantETAInfo.participantId == participantId{
                    return participantETAInfo
                }
            }
        }
        return nil
    }

    func getRiderCurrentLocationBasedOnStatus() -> RideParticipantLocation? {
        guard let riderRide = rideDetailInfo?.riderRide else {
            return nil
        }
        if Ride.RIDE_STATUS_SCHEDULED == riderRide.status || Ride.RIDE_STATUS_DELAYED == riderRide.status {
            let riderStartLocation = RideParticipantLocation(rideId: riderRide.rideId,userId:  riderRide.userId, latitude: riderRide.startLatitude, longitude: riderRide.startLongitude, bearing: 0, participantETAInfos: nil)
            riderStartLocation.lastUpdateTime = NSDate().timeIntervalSince1970*1000
            return riderStartLocation
        }else {
            return RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: riderRide.userId, rideParticipantLocations: rideDetailInfo?.rideParticipantLocations)
        }
    }
    func isPassengerPendingToPickup() -> Bool {
        guard let rideParticipants = rideDetailInfo?.rideParticipants else{
            return false
        }
        for rideParticipant in rideParticipants {
            if !rideParticipant.rider && (Ride.RIDE_STATUS_SCHEDULED == rideParticipant.status || Ride.RIDE_STATUS_DELAYED == rideParticipant.status){
                return true
            }
        }
        return false
    }
    func validateAndGetETAForPassenger (){
        guard !isModerator, let currentParticipantRide = currentUserRide as? PassengerRide, let riderRide = rideDetailInfo?.riderRide else {
            return
        }

        if Ride.RIDE_STATUS_STARTED != riderRide.status {
            return
        }
        if Ride.RIDE_STATUS_STARTED == currentParticipantRide.status &&
            Ride.RIDE_STATUS_STARTED == riderRide.status {
            return
        }
        getETAForPassenger()
    }
    func validateAndGetETAForRider () -> ParticipantETAInfo?{
        if currentUserRide?.rideType != Ride.RIDER_RIDE && !isModerator {
            return nil
        }
        guard let riderRide = rideDetailInfo?.riderRide else {
            return nil
        }

        if Ride.RIDE_STATUS_STARTED != riderRide.status {
            return nil
        }
        if isPassengerPendingToPickup(){
            return nil
        }
        return getCurrentUserParticipantETAInfo()
    }

    func updateRideRoute(ride: Ride?, route: RideRoute, isRouteDeviated: Bool) {
        guard let ride = ride else { return }
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.updateRideRoute(rideId: ride.rideId, rideType: ride.rideType!, rideRoute: route, viewController: nil) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let updatedRoute = Mapper<RideRoute>().map(JSONString: responseObject!["resultData"] as! String)

                if updatedRoute != nil{
                    MyActiveRidesCache.getRidesCacheInstance()?.updateRideRoute(rideRoute: updatedRoute!, rideId: ride.rideId, rideType: ride.rideType!)
                    var userInfo = [String : Ride]()
                    if isRouteDeviated {
                        if let updatedRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: ride.rideId) {
                            userInfo[LiveRideNSNotificationConstants.RIDE] = updatedRide
                        }
                    } else {
                        userInfo[LiveRideNSNotificationConstants.RIDE] = ride
                    }
                    NotificationCenter.default.post(name: .rideUpdated, object: nil, userInfo: userInfo)
                }
            }else{
                SharedPreferenceHelper.saveRouteDeviationStatus(id: ride.rideId, status: RouteDeviationDetector.FAILED)
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
    func updateUserPreferredPickupDrop(userPreferredPickupDrop: UserPreferredPickupDrop) {
        UserRestClient.saveOrUpdateUserPreferredPickupDrop(userId: QRSessionManager.getInstance()?.getUserId(), userPreferredPickupDropJsonString: userPreferredPickupDrop.toJSONString(), viewContrller: nil) { (responseObject, error) in
            let result = RestResponseParser<UserPreferredPickupDrop>().parse(responseObject: responseObject, error: error)
            if let userPreferredPickupDrop = result.0{
                UserDataCache.getInstance()?.storeUserPreferredPickupDrops(userPreferredPickupDrop: userPreferredPickupDrop)
            }
        }
    }

    func updatePassengerRideWithNewPickup(matchedUser: MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?, handler : @escaping () -> Void){
        guard let existinPassengerRide = currentUserRide as? PassengerRide else {
            return
        }
        PassengerRideServiceClient.updatePassengerRide(rideId: existinPassengerRide.rideId, startAddress: existinPassengerRide.startAddress, startLatitude: existinPassengerRide.startLatitude, startLongitude: existinPassengerRide.startLongitude, endAddress: existinPassengerRide.endAddress, endLatitude: existinPassengerRide.endLatitude!, endLongitude: existinPassengerRide.endLongitude!, startTime: existinPassengerRide.startTime, noOfSeats: existinPassengerRide.noOfSeats, route: nil, pickupAddress: matchedUser.pickupLocationAddress!,pickupLatitude: matchedUser.pickupLocationLatitude!,pickupLongitude: matchedUser.pickupLocationLongitude!,dropAddress: existinPassengerRide.dropAddress,dropLatitude: existinPassengerRide.dropLatitude,dropLongitude: existinPassengerRide.dropLongitude,pickupTime: matchedUser.pickupTime,dropTime: existinPassengerRide.dropTime,points : matchedUser.points!,overlapDistance: matchedUser.distance!, allowRideMatchToJoinedGroups: existinPassengerRide.allowRideMatchToJoinedGroups, showMeToJoinedGroups: existinPassengerRide.showMeToJoinedGroups, pickupNote: userPreferredPickupDrop?.note,viewController: nil, completionHandler: { (responseObject, error) in
                   QuickRideProgressSpinner.stopSpinner()
                   if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                       if let passenegerRideUpdate = Mapper<PassengerRide>().map(JSONObject: responseObject!["resultData"])
                       {
                            self.currentUserRide = passenegerRideUpdate
                           MyActiveRidesCache.getRidesCacheInstance()?.updateExistingRide(ride: passenegerRideUpdate)
                           handler()
                       }
                   } else {
                       ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                   }
               })

    }
    func checkCurrentRideIsValidForRecurringRide() -> Bool {
        if currentUserRide == nil {
            return false
        }
        let regularRide  = RegularRide(ride: currentUserRide!)
        if RecurringRideUtils().isValidDistance(ride: currentUserRide!){
            return false
        }else if MyRegularRidesCache.getInstance().checkForDuplicate(regularRide: regularRide){
            return false
        }else{
            return true
        }
    }

    func initiateEmeregency(url: String){
        TaxiPoolRestClient.initiateTaxiEmergency(type: "CarPool", userId: UserDataCache.getInstance()?.userId ?? "", payload: getPayLoad(),rideTrackUrl: url, acknowledgedBy: "Support team") { (responseObject, error) in }
    }

    private func getPayLoad() -> String{
        let payload = EmergencyPayload(userId: StringUtils.getStringFromDouble(decimalNumber: currentUserRide?.userId), userName: currentUserRide?.userName ?? "", mobileNo: SharedPreferenceHelper.getLoggedInUserContactNo(), riderId: StringUtils.getStringFromDouble(decimalNumber: rideDetailInfo?.riderRide?.userId), rideType: currentUserRide?.rideType ?? "", riderName: rideDetailInfo?.riderRide?.userName)
        return payload.toJSONString() ?? ""
    }
}

extension LiveRideViewModel: TaxiPoolDetailsUpdateDelegate {
    func fetchNewRideDetailInfoTaxiPool() {
        MyActiveRidesCache.singleCacheInstance?.taxiPoolRideDetailInfoFromServer(taxiRideId: taxiRideId!, passengerRideId: currentUserRide!.rideId, myRidesCacheListener: self)
    }
}
extension LiveRideViewModel: MyRidesCacheListener {

    func receiveRideDetailInfo(rideDetailInfo: RideDetailInfo) {
        QuickRideProgressSpinner.stopSpinner()
        self.rideDetailInfo = rideDetailInfo
        if let currentUserRide = rideDetailInfo.currentUserRide{
            self.currentUserRide = currentUserRide
        }
        updateIsModerator()
        handler?(nil,nil)

    }

    func onRetrievalFailure(responseError: ResponseError?, error: NSError?) {
        handler?(responseError,error)

    }

    func receiveClosedRides(closedRiderRides: [Double : RiderRide], closedPassengerRides: [Double : PassengerRide]) {}

    func receivedActiveRides(activeRiderRides closedRiderRides: [Double : RiderRide], activePassengerRides closedPassengerRides: [Double : PassengerRide]) {}

    func receiveActiveRegularRides(regularRiderRides: [Double : RegularRiderRide], regularPassengerRides: [Double : RegularPassengerRide]) {}
}

//MARK: TaxiPOOL
extension LiveRideViewModel {
    func isTaxiRide(ride: PassengerRide) -> Bool {
        if ride.taxiRideId == 0 || ride.taxiRideId == nil {
            return false
        } else {
            return true
        }
    }

    func taxiReachedToPickUpLocation(updatedLocation: CLLocationCoordinate2D) {
        if let taxiShareRide = rideDetailInfo?.taxiShareRide {
            let coordinate1 = CLLocation(latitude: updatedLocation.latitude, longitude: updatedLocation.longitude)
            var coordinate2: CLLocation?
            for data in taxiShareRide.taxiShareRidePassengerInfos ?? [] {
                if data.passengerUserId == Double(QRSessionManager.sharedInstance?.getUserId() ?? "0") {
                    coordinate2 = CLLocation(latitude: data.dropLatitude ?? 0.0, longitude: data.dropLongitude ?? 0.0)
                    break
                }else{
                    continue
                }
            }
            if let coordinate2 = coordinate2{
                let distance = coordinate1.distance(from: coordinate2)
                if distance <= 100 {
                    isTaxiRideReachedDestination = true
                }else{
                    isTaxiRideReachedDestination = nil
                }
            }else{
                isTaxiRideReachedDestination = nil
            }
        }else{
            isTaxiRideReachedDestination = nil
            return
        }
    }

    func isStepsNeedToShow() -> Bool {
        guard let taxiShareRide = rideDetailInfo?.taxiShareRide else { return true}
        var status = true
        for taxiPassengerData in taxiShareRide.taxiShareRidePassengerInfos ?? [] {
            if (taxiPassengerData.passengerUserId == Double(QRSessionManager.sharedInstance?.getUserId() ?? "0")) && (taxiPassengerData.joinStatus == TaxiShareRidePassengerInfos.PAYMENT_PENDING) {
                    status = false
            }
        }
        return status
    }
}
//MARK: OutStation TaxiPOOL
extension LiveRideViewModel {
    func getJourneyTypeId() -> Int {
        if rideDetailInfo?.taxiShareRide?.journeyType == TaxiShareRide.ROUND_TRIP {
            return 1
        }else{
            return 0
        }
    }

    func getInitialFareForTaxiPool() -> Double{
        for data in rideDetailInfo?.taxiShareRide?.taxiShareRidePassengerInfos ?? [] {
            if data.passengerUserId == Double(QRSessionManager.sharedInstance?.getUserId() ?? "0"){
                return data.initialFare?.roundToPlaces(places: 2) ?? 0.0
            }
        }
        return 0.0
    }

    func getAdvancePaidForTaxiPool() -> Double {
        for data in rideDetailInfo?.taxiShareRide?.taxiShareRidePassengerInfos ?? [] {
            if data.passengerUserId == Double(QRSessionManager.sharedInstance?.getUserId() ?? "0"){
                return data.advanceAmount?.roundToPlaces(places: 2) ?? 0.0
            }
        }
        return 0.0
    }
}

extension LiveRideViewModel {
    func getOffers() {
        var filterList = [Offer]()
        if let offers = ConfigurationCache.getInstance()?.offersList{
            for offer in offers {
                if offer.displayType == Strings.displaytype_both && (offer.targetDevice == Strings.targetdevice_all || offer.targetDevice == Strings.targetdevice_ios) && offer.offerScreenImageUri != nil && offer.offerScreenImageUri!.isEmpty == false {
                    filterList.append(offer)
                }
            }
            if !filterList.isEmpty {
                updateOfferAsPerPreferedRole(filterOfferList: filterList)
            }
        }
    }

    private func updateOfferAsPerPreferedRole(filterOfferList : [Offer]) {
        guard let roleAtSignup = UserDataCache.getInstance()?.getLoggedInUserProfile()?.roleAtSignup else { return }
        var finalOfferList = [Offer]()
        for offer in filterOfferList {
            if (UserProfile.PREFERRED_ROLE_PASSENGER == roleAtSignup && offer.targetRole == Strings.targetrole_passenger) || (UserProfile.PREFERRED_ROLE_RIDER == roleAtSignup && offer.targetRole == Strings.targetrole_rider) {
                finalOfferList.append(offer)
            } else if offer.targetRole == Strings.targetrole_both {
                finalOfferList.append(offer)
            }
        }
        if !finalOfferList.isEmpty {
            let sortedOfferList = finalOfferList.shuffled()
            getFinalOfferList(offerList: sortedOfferList)
        }
    }

    private func getFinalOfferList(offerList: [Offer]) {
        if offerList.count <= 5{
            self.finalOfferList = offerList
        }else{
            self.finalOfferList = Array(offerList[0..<5])
        }
    }
    func  getETAForPassenger(){
        if let passengerRide = currentUserRide as? PassengerRide,let riderCurrentLocation = getRiderCurrentLocationBasedOnStatus(), riderCurrentLocation.latitude != 0 ,riderCurrentLocation.longitude != 0,let riderRide = rideDetailInfo?.riderRide{
            var routeId: Double = 0
            if let updatedRouteId = updatedRouteId, updatedRouteId != 0 {
                routeId = updatedRouteId
            }else if let riderRouteId = riderRide.routeId {
                routeId = riderRouteId
            }
            ETAFinder.getInstance().getETA(userId: passengerRide.userId, rideId: passengerRide.rideId, useCase: "iOS.App.Passenger.Eta.ETACalculator.LiveRide", source: LatLng(lat: riderCurrentLocation.latitude!, long: riderCurrentLocation.longitude!), destination: LatLng(lat: passengerRide.pickupLatitude, long: passengerRide.pickupLongitude), routeId: routeId, startTime: riderRide.startTime, vehicleType: riderRide.vehicleType!, routeStartLatitude: riderRide.startLatitude, routeStartLongitude: riderRide.startLongitude, routeEndLatitude: riderRide.endLatitude!, routeEndLongitude: riderRide.endLongitude!, routeWaypoints: riderRide.waypoints, routeOverviewPolyline: riderRide.routePathPolyline) { etaResponse in
                let passengerETAInfo = ParticipantETAInfo(participantId: passengerRide.userId, destinationLatitude: passengerRide.pickupLatitude, destinationLongitude: passengerRide.pickupLongitude,routeDistance : etaResponse.distanceInKM*1000, durationInTraffic: etaResponse.timeTakenInSec/60, duration: etaResponse.timeTakenInSec/60, error: etaResponse.error)
                self.updatedRouteId = etaResponse.routeId
                passengerETAInfo.lastUpdateTime = riderCurrentLocation.lastUpdateTime ?? 0
                var userInfo = [String: ParticipantETAInfo]()
                userInfo["passengerETAInfo"] = passengerETAInfo
                NotificationCenter.default.post(name: .receivedPassengerETAInfo, object: nil, userInfo: userInfo)
            }
        }
    }
    private func handlePassengerETAFailureCase(){
        let passengerETAInfo = self.getCurrentUserParticipantETAInfo()
        var userInfo = [String: ParticipantETAInfo]()
        userInfo["participantETAInfo"] = passengerETAInfo
        NotificationCenter.default.post(name: .receivedPassengerETAInfo, object: nil, userInfo: userInfo)
    }
}
//MARK: Job Promotion Visibility
extension LiveRideViewModel {
    func getJobPromotionAd(handler : @escaping () -> Void) {
        JobPromotionUtils.getJobPromotionDataBasedOnScreen(screenName: ImpressionAudit.LiveRide) {[weak self](jobPromotionData) in
            self?.jobPromotionData = jobPromotionData
            handler()
        }
    }
}
extension LiveRideViewModel{
    func getTaxiOptions(handler: @escaping (_ result: Bool) -> Void) {
        if let passengerRide = currentUserRide as? PassengerRide {
            if !isOutstationRide() && passengerRide.noOfSeats == 1 && (passengerRide.distance ?? 0) < ConfigurationCache.getObjectClientConfiguration().minDistanceForInterCityRide{
                AvailableTaxiCache.getInstance().getMatchingTaxipool(scheduleRide: passengerRide) { [weak self] (response) in
                    if let matchedTaxiRideGroup = response{
                        self?.matchedTaxipool = matchedTaxiRideGroup
                        handler(true)
                    }else{
                        self?.getAvailableTaxi(handler: handler)
                    }
                }
            }else{
                getAvailableTaxi(handler: handler)
            }
        }
    }

    private func getAvailableTaxi(handler: @escaping (_ result: Bool) -> Void){
        if let passengerRide = currentUserRide as? PassengerRide {
            AvailableTaxiCache.getInstance().getAvailableTaxis(passengerRide: passengerRide, handler: { ( response ) in
                if let result = response.result {
                    self.detailEstimatedFare = result
                    handler(true)
                }
            })
        }
    }
    func isOutstationRide() -> Bool{
        if currentUserRide?.distance ?? 0 > ConfigurationCache.getObjectClientConfiguration().minDistanceForInterCityRide{
            return true
        }else{
            return false
        }
    }

    func isAllPassengerPickupCompleted() -> Bool{
        guard let rideParticipants = rideDetailInfo?.rideParticipants else { return true }
        if isModerator || currentUserRide?.status == Ride.RIDE_STATUS_STARTED {
            for rideParticipant in  rideParticipants {
                if rideParticipant.status == Ride.RIDE_STATUS_SCHEDULED || rideParticipant.status == Ride.RIDE_STATUS_DELAYED{
                    return false
                }
            }
        }
        return true
    }
    
    
}
extension LiveRideViewModel {

    func startLocationUpates() {
        doRefreshLocation = true
        refreshLocation()
        
    }
    func stopLocationUpates() {
        doRefreshLocation = false
    }
   
    
    private func refreshLocation(){
        DispatchQueue.global().asyncAfter(deadline: .now()+10) {
            guard let riderRide = self.rideDetailInfo?.riderRide,let currentUserRide = self.currentUserRide, self.doRefreshLocation else { return }
            let diff =  DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: riderRide.startTime, time2: NSDate().getTimeStamp())
            if diff >= 60 {
                return
            }
            let participantMarkerUpdateTask = ParticipantMarkerUpdateTask(currentParticipantRide: currentUserRide)
            participantMarkerUpdateTask.pullLatestLocationUpdatesBasedOnExpiry()
            
            self.refreshLocation()
            
        }
        
    }
    
    func getRidePaymentDetails(complitionHandler: @escaping(_ responseError: ResponseError?,_ error: NSError?)-> ()){
        guard currentUserRide?.rideType == Ride.PASSENGER_RIDE else {
            return
        }
        BillRestClient.getRidePaymentDetails(userId: currentUserRide?.userId ?? 0, rideId: currentUserRide?.rideId ?? 0, includeCaptureReleaseTxn: false, sourceApplication: Strings.carpool.uppercased()) { responseObject, error in
            let result = RestResponseParser<RidePaymentDetails>().parseArray(responseObject: responseObject, error: error)
            if let ridePaymentDetails = result.0, !ridePaymentDetails.isEmpty {
                self.ridePaymentDetails = ridePaymentDetails[0]
                complitionHandler(nil, nil)
            }
        }
    }
    
    func getOutGoingInvitesCount() -> Int {
        if let rideId = currentUserRide?.rideId, let rideType = currentUserRide?.rideType {
            var invites = RideInviteCache.getInstance().getInvitationsForRide(rideId: rideId, rideType: rideType)
           return invites.count
        }
        return 0
    }
    
    func getPaymentPendingRideCountForPassengerRide() -> Int{
        if let rideId = currentUserRide?.rideId, let rideType = currentUserRide?.rideType {
            var invites = RideInviteCache.getInstance().getInvitationsForRide(rideId: rideId, rideType: rideType)
            let paymentPendingRideInvites = invites.filter({$0.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING})
            return paymentPendingRideInvites.count
        }
        return 0
    }
}
