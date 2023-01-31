//
//  SendInviteViewModel.swift
//  Quickride
//
//  Created by Vinutha on 11/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import GoogleMaps

protocol JoinTaxiPoolResponse{
    func pickupAndDropUptingFailed(responseObject: NSDictionary?,error: NSError?)
    func createOrJoinTaxiResponse(taxiShareRide: TaxiShareRide?)
}

class SendInviteViewModel {
    
    var matchedUsers = [MatchedUser]()
    var allMatchedUsers = [MatchedUser]()
    var selectedMatches = [Double : Bool]()
    var selectedUserIndex : Int = -1
    var currentMatchBucket = MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH
    var contentOffset : CGFloat = 0
    var verificationInfoWindowSelectedView = -1
    var callOptionEnableSelectedRow = -1
    var callOptionEnabledId = [Double]()
    var sortAndFilterStatus = [String : String]()
    var readyToGoMatchIndex = 0
    var backGroundView: UIView?
    var readyToGoMatches = [MatchedUser]()
    var taxiRideID: Double?
    var shareType: String?
    var joinTaxiId: Double?
    var isFilterApplied = false
    var isLoadMoreTapped = false
    
    var scheduleRide : Ride?
    var isFromCanceRide = false
    var isFromRideCreation = false
    var isRequiredToShowAllMatatches = false
    var isRequiredToShowAllRelayRides = false
    var relayRides = [RelayRideMatch]()
    var changedStartTimeForTaxiPool: Double?
    static var isAnimating = false
    var inActiveMatches = [MatchedUser]()
    var matchedTaxipool: MatchedTaxiRideGroup?
    var detailEstimatedFare : DetailedEstimateFare?
    
    init(scheduleRide : Ride,isFromCanceRide: Bool, isFromRideCreation: Bool){
        self.scheduleRide = scheduleRide
        self.isFromCanceRide = isFromCanceRide
        self.isFromRideCreation = isFromRideCreation
    }
    
    init() {
        
    }
    
    func getMatchingOptions(matchedUsersDataReceiver: MatchedUsersDataReceiver){
        guard let ride = scheduleRide else { return }
        if Ride.RIDER_RIDE == ride.rideType{
            guard let riderRide = ride as? RiderRide else { return }
            MatchedUsersCache.getInstance().getAllMatchedPassengers(ride: ride, rideRoute: nil, overviewPolyline: ride.routePathPolyline, capacity: riderRide.availableSeats, fare: riderRide.farePerKm, requestSeqId: 1,displaySpinner: false, dataReceiver: matchedUsersDataReceiver)
        } else {
            guard let passengerRide = ride as? PassengerRide else { return }
            MatchedUsersCache.getInstance().getAllMatchedRiders(ride: ride, rideRoute: nil, overviewPolyline: ride.routePathPolyline, noOfSeats: passengerRide.noOfSeats , requestSeqId: 1,displaySpinner: false, dataReceiver: matchedUsersDataReceiver)
        }
    }
    
    func completeRejectAction(rejectReason : String?, rideInvitation : RideInvitation, rideType : String,viewController: UIViewController,rideInvitationActionCompletionListener: RideInvitationActionCompletionListener){
        if Ride.RIDER_RIDE == rideType {
            let riderRejectPassengerInvitationTask = RiderRejectPassengerInvitationTask(rideInvitation: rideInvitation, moderatorId: nil, viewController: viewController, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: rideInvitationActionCompletionListener)
            riderRejectPassengerInvitationTask.rejectPassengerInvitation()
        } else {
            let passengerRejectRiderInvitationTask = PassengerRejectRiderInvitationTask(rideInvitation: rideInvitation, viewController: viewController, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: rideInvitationActionCompletionListener)
            passengerRejectRiderInvitationTask.rejectRiderInvitation()
        }
    }
    
    func inviteSelelctedUsers(viewController: UIViewController){
        if scheduleRide?.rideType == Ride.RIDER_RIDE{
            var selectedPassengers : [MatchedPassenger] = [MatchedPassenger]()
            if matchedUsers.isEmpty == true{
                UIApplication.shared.keyWindow?.makeToast( Strings.no_passengers_to_invite)
                return
            }
            var noOfPassengersSelected = 0
            for index in 0...matchedUsers.count-1{
                if selectedMatches[matchedUsers[index].rideid!] == true{
                    let passenger = matchedUsers[index] as! MatchedPassenger
                    selectedPassengers.append(passenger)
                    noOfPassengersSelected = noOfPassengersSelected+passenger.requiredSeats
                }
            }
            if selectedPassengers.isEmpty == false{
                let invitePassengers : InviteSelectedPassengersAsyncTask = InviteSelectedPassengersAsyncTask(riderRide: scheduleRide as! RiderRide, selectedUsers: selectedPassengers,viewController: viewController, displaySpinner: true, selectedIndex: nil,invitePassengersCompletionHandler: { (error,nserror) in
                    if error == nil && nserror == nil{
                        //                      self.popToLiveRideMapViewController()
                    }
                })
                invitePassengers.invitePassengersFromMatches()
            }
        }else{
            var selectedRiders = [MatchedRider]()
            if matchedUsers.isEmpty == true{
                UIApplication.shared.keyWindow?.makeToast( Strings.no_rider_to_invite)
                return
            }
            for index in 0...matchedUsers.count-1{
                if selectedMatches[matchedUsers[index].rideid!] == true{
                    selectedRiders.append( matchedUsers[index] as! MatchedRider)
                }
            }
            if selectedRiders.isEmpty == false{
                let inviteRider : InviteRiderHandler = InviteRiderHandler(passengerRide: scheduleRide as! PassengerRide, selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: viewController)
                inviteRider.inviteSelectedRiders(inviteHandler: { (error,nsError) -> Void in
                    if error == nil && nsError == nil{
                        //                      self.popToLiveRideMapViewController()
                    }
                })
            }
        }
    }
    func isOutstationRide() -> Bool{
        if scheduleRide?.distance ?? 0 > ConfigurationCache.getObjectClientConfiguration().minDistanceForInterCityRide{
            return true
        }else{
            return false
        }
    }
    func putFavouritePartnersOnTop(actualMatchedUsers : [MatchedUser]) -> [MatchedUser]{
        var connectedMatchedUsers = [MatchedUser]()
        var newMatchedUsers = [MatchedUser]()
        for matchedUser in actualMatchedUsers{
            if UserDataCache.getInstance() != nil && UserDataCache.getInstance()!.isFavouritePartner(userId: matchedUser.userid!){
                connectedMatchedUsers.append(matchedUser)
            }else{
                newMatchedUsers.append(matchedUser)
            }
        }
        connectedMatchedUsers.append(contentsOf: newMatchedUsers)
        return connectedMatchedUsers
    }
    
    func loadMoreViewTapped(matchedUsersDataReceiver: MatchedUsersDataReceiver){
        if scheduleRide?.rideType == Ride.RIDER_RIDE{ MatchedUsersCache.getInstance().getMatchedPassengersFromServerForNextBucketAndRefreshInCache(ride: scheduleRide!, rideRoute: nil, noOfSeats: (scheduleRide as! RiderRide).availableSeats, fare: (scheduleRide as! RiderRide).farePerKm, overviewPolyline: scheduleRide!.routePathPolyline, currentMatchBucket: currentMatchBucket, dataReceiver: matchedUsersDataReceiver)
        }else{ MatchedUsersCache.getInstance().getMatchedRidersFromServerForNextBucketAndRefreshInCache(ride: scheduleRide!, rideRoute: nil, noOfSeats: (scheduleRide as! PassengerRide).noOfSeats, overviewPolyline: scheduleRide?.routePathPolyline, currentMatchBucket: currentMatchBucket, dataReceiver: matchedUsersDataReceiver)
        }
    }
    func getTaxiOptions(handler: @escaping (_ result: Bool) -> Void) {
        if let passengerRide = scheduleRide as? PassengerRide {
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
        if let passengerRide = scheduleRide as? PassengerRide {
            AvailableTaxiCache.getInstance().getAvailableTaxis(passengerRide: passengerRide, handler: { ( response ) in
                if let result = response.result {
                    self.detailEstimatedFare = result
                    handler(true)
                }
            })
        }
    }
    
    func changeBestMatchAlertStatus(){
        if let rideMatchAlertRegistration = SharedPreferenceHelper.getBestMatchAlertActivetdRides(routeId: scheduleRide?.routeId ?? 0){
            var status = RideMatchAlertRegistration.ACTIVE
            if rideMatchAlertRegistration.status == RideMatchAlertRegistration.ACTIVE{
                status = RideMatchAlertRegistration.INACTIVE
            }else{
                status = RideMatchAlertRegistration.ACTIVE
            }
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.updateBestMatchAlertStatus(rideMatchAlertId: String(rideMatchAlertRegistration.id), userId: UserDataCache.getInstance()?.userId ?? "", status: status, completionController: {(responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    if let rideMatchAlertRegistration = Mapper<RideMatchAlertRegistration>().map(JSONObject:responseObject!["resultData"]){
                        SharedPreferenceHelper.storeBestMatchAlertActivetdRides(routeId: self.scheduleRide?.routeId ?? 0, rideMatchAlertRegistration: rideMatchAlertRegistration)
                    }
                    NotificationCenter.default.post(name: .bestMatchAlertCreated, object: self)
                }else{
                    var userInfo = [String: Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .bestMatchAlertCreationFailed, object: self, userInfo: userInfo)
                }
            })
        }
    }
    
    func prepareRouteMetrics(rideParticipantLocation: RideParticipantLocation, matchedUser: MatchedUser) -> RouteMetrics? {
        var participantEta: ParticipantETAInfo?
        if let participantETAInfos = rideParticipantLocation.participantETAInfos {
            for participantETAInfo in participantETAInfos{
                if participantETAInfo.participantId == matchedUser.userid {
                    participantEta = participantETAInfo
                    break
                }
            }
        }
        if let eta = participantEta {
            let routeMetrics = RouteMetrics()
            routeMetrics.fromLat = rideParticipantLocation.latitude!
            routeMetrics.fromLng = rideParticipantLocation.longitude!
            routeMetrics.toLat = eta.destinationLatitude
            routeMetrics.toLng = eta.destinationLongitude
            routeMetrics.error = eta.error
            routeMetrics.journeyDurationInTraffic = eta.durationInTraffic
            routeMetrics.journeyDuration = eta.duration
            routeMetrics.routeDistance = eta.routeDistance
            routeMetrics.creationTime = rideParticipantLocation.lastUpdateTime ?? NSDate().getTimeStamp()
            return routeMetrics
        }
        return nil
    }
    
    func getRouteMetrics(rideParticipantLocation: RideParticipantLocation) -> RouteMetrics? {
        if let ride = scheduleRide {
            let readyToGoMatch = readyToGoMatches[readyToGoMatchIndex]
            let startDate = readyToGoMatch.startDate
            let riderRideId = readyToGoMatch.rideid
            let riderCurrentLatitude = rideParticipantLocation.latitude
            let riderCurrentLongitude = rideParticipantLocation.longitude
            let pickupLocationLatitude = readyToGoMatch.pickupLocationLatitude
            let pickupLocationLongitude = readyToGoMatch.pickupLocationLongitude
            if readyToGoMatch.userid == nil || startDate == nil || riderRideId == nil || riderCurrentLatitude == nil || riderCurrentLongitude == nil || pickupLocationLatitude == nil || pickupLocationLongitude == nil {
                return nil
            }
            let originLatLng = CLLocationCoordinate2D(latitude: riderCurrentLatitude!, longitude: riderCurrentLongitude!)
            let destinationLatLng = CLLocationCoordinate2D(latitude: pickupLocationLatitude!, longitude: pickupLocationLongitude!)
            let key = ETACalculator.getInstance().getKey(riderRideId: riderRideId!, dest: destinationLatLng)
            if let routeMetrics = SharedPreferenceHelper.getRouteMetrics(key: key) {
                if routeMetrics.creationTime == 0 || DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: NSDate(timeIntervalSince1970: routeMetrics.creationTime/1000)) >= 2*60 {
                    ETACalculator.getInstance().getRouteMetricsForMatchedRider(riderRideId: riderRideId!, matchedUser: readyToGoMatch,rideId: ride.rideId, origin: originLatLng, destination: destinationLatLng,useCase:"iOS.App.Passenger.Eta.ETACalculator.RideToMatch") { (routeMetrics) in
                        NotificationCenter.default.post(name: .receivedRidePresentLocation, object: self)
                    }
                }
                return routeMetrics
            } else {
                ETACalculator.getInstance().getRouteMetricsForMatchedRider(riderRideId: riderRideId!,matchedUser: readyToGoMatch, rideId: ride.rideId,origin: originLatLng, destination: destinationLatLng, useCase: "iOS.App.Passenger.Eta.ETACalculator.RideToMatch") { (routeMetrics) in
                    NotificationCenter.default.post(name: .receivedRidePresentLocation, object: self)
                }
            }
        }
        return nil
    }
    func checkForRidePresentLocation(targetViewController: UIViewController){
        let readyToGoMatch = readyToGoMatches[readyToGoMatchIndex]
        let startDate = readyToGoMatch.startDate
        let riderRideId = readyToGoMatch.rideid
        if startDate == nil || riderRideId == nil{
            return
        }
        LocationUpdationServiceClient.getRiderParticipantLocation(rideId: riderRideId!, targetViewController: targetViewController, completionHandler: {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                let rideParticipantLocation = Mapper<RideParticipantLocation>().map(JSONObject:responseObject!["resultData"])!
                SharedPreferenceHelper.storeMatchedUserLocation(userId: rideParticipantLocation.userId, rideParticipantLocation: rideParticipantLocation)
                if readyToGoMatch.userid != rideParticipantLocation.userId {
                    return
                }
                NotificationCenter.default.post(name: .receivedRidePresentLocation, object: self)
            } else {
                SharedPreferenceHelper.storeMatchedUserLocation(userId: readyToGoMatch.userid, rideParticipantLocation: nil)
            }
        })
    }
    
    func getInviteButtonTitle() -> String{
        if scheduleRide?.rideType == Ride.RIDER_RIDE{
            return Strings.invite_all.uppercased()
        }else{
            return Strings.request_all.uppercased()
        }
    }
    
    func upadteRouteMatchPercentage(value: Int,viewController: UIViewController){
        guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() else { return }
        if self.scheduleRide?.rideType == Ride.RIDER_RIDE,value < ridePreferences.rideMatchPercentageAsRider{
            ridePreferences.rideMatchPercentageAsRider = value
            SaveRidePreferencesTask(ridePreferences: ridePreferences, viewController: viewController, receiver: nil).saveRidePreferences()
        }else if self.scheduleRide?.rideType == Ride.PASSENGER_RIDE,value < ridePreferences.rideMatchPercentageAsRider{
            ridePreferences.rideMatchPercentageAsPassenger = value
            SaveRidePreferencesTask(ridePreferences: ridePreferences, viewController: viewController, receiver: nil).saveRidePreferences()
        }
    }
    
    func updatePickupAndDropLocationUpadte(pickUpLocation:Location,dropLocation: Location,requestLocationType : String,viewController: UIViewController,joinTaxiPoolResponse: JoinTaxiPoolResponse){
        guard let rideObj = scheduleRide else {return}
        let ride = rideObj as! PassengerRide
        if let newStartTime = changedStartTimeForTaxiPool {
            ride.startTime = newStartTime
        }
        ride.startLatitude = pickUpLocation.latitude
        ride.startLongitude = pickUpLocation.longitude
        ride.startAddress = pickUpLocation.address ?? ""
        ride.endLatitude = dropLocation.latitude
        ride.endLongitude = dropLocation.longitude
        ride.endAddress = dropLocation.address ?? ""
        
        PassengerRideServiceClient.updatePassengerRide(rideId: ride.rideId, startAddress: ride.startAddress, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endAddress: ride.endAddress, endLatitude: ride.endLatitude!, endLongitude: ride.endLongitude!, startTime: ride.startTime, noOfSeats: nil, route: nil, pickupAddress: nil,pickupLatitude: nil,pickupLongitude: nil,dropAddress: nil,dropLatitude: nil,dropLongitude: nil,pickupTime: nil,dropTime: nil,points : nil,overlapDistance: nil, allowRideMatchToJoinedGroups: false, showMeToJoinedGroups: false, pickupNote: nil,viewController: viewController, completionHandler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let passenegerRideUpdate = Mapper<PassengerRide>().map(JSONObject: responseObject!["resultData"])
                if passenegerRideUpdate != nil {
                    MyRidesPersistenceHelper.updatePassengerRide(passengerRide: passenegerRideUpdate!)
                }
                self.createOrJoinTaxiPool(viewController: viewController,joinTaxiPoolResponse: joinTaxiPoolResponse)
            } else {
                joinTaxiPoolResponse.pickupAndDropUptingFailed(responseObject: responseObject, error: error)
                
            }
        })
    }
    
    func createOrJoinTaxiPool(viewController: UIViewController,joinTaxiPoolResponse: JoinTaxiPoolResponse) {
        let defaultPaymentMethod = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if shareType != nil {//create and Join
            guard let shareType = self.shareType else {return}
            let createJoinTaxiPool = CreateAndJoinTaxiPoolHandler(rideId: scheduleRide?.rideId ?? 0.0, shareType: shareType, paymentType: defaultPaymentMethod?.type ?? "",tripType: nil,journeyType: nil,toTime: nil,carType: nil, selectedPaymentPercentage: nil, isRideNeedToCancel: false, viewController: viewController)
            createJoinTaxiPool.creteAndJoinTaxiPool { (data, error) in
                joinTaxiPoolResponse.createOrJoinTaxiResponse(taxiShareRide: data)

            }
        } else { //matching card join
            guard let joinId = joinTaxiId else {return}
            let joinTaxiPoolHandler = JoinTaxiPoolHandler(rideId: scheduleRide?.rideId ?? 0.0,matchedShareTaxiId: joinId, paymentType: defaultPaymentMethod?.type, taxiInviteId: nil, isRideNeedToCancel: false, viewController: viewController)
            joinTaxiPoolHandler.joinTaxiPool { (data, error) in
                joinTaxiPoolResponse.createOrJoinTaxiResponse(taxiShareRide: data)
            }
        }
    }
    
    func updateExistingRide(data: TaxiShareRide) {
        let rideObj = self.scheduleRide as? PassengerRide
        rideObj?.taxiRideId = data.id
        MyActiveRidesCache.getRidesCacheInstance()?.updateExistingRide(ride: rideObj!)
    }
    func cancelSelectedUser(invitation: RideInvitation,viewController: UIViewController){
        RideMatcherServiceClient.updateRideInvitationStatus(invitationId: invitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: viewController) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast(Strings.invite_cancelled_toast, point: CGPoint(x: viewController.view.frame.size.width/2, y: viewController.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                invitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_CANCELLED
                let rideInvitationStatus = RideInviteStatus(rideInvitation: invitation)
                RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
                NotificationCenter.default.post(name: .cancelRideInvitationSuccess, object: self)
            }else{
                var userInfo = [String: Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .cancelRideInvitationFailed, object: self, userInfo: userInfo)
            }
        }
    }
    func checkRideIsEligiableToGetRelayRides(matchedUsersList: [MatchedUser]){
        if SharedPreferenceHelper.getRelayRideStatusForCurrentRide(rideId: scheduleRide?.rideId ?? 0) == true || (scheduleRide?.rideType == Ride.PASSENGER_RIDE && (scheduleRide as? PassengerRide)?.relayLeg != 0){
            return
        }
        var bestMatchs = [MatchedUser]()
        for match in matchedUsersList{
            let clientConfiguartion = ConfigurationCache.getObjectClientConfiguration()
            if match.matchPercentage ?? 0 > clientConfiguartion.minMatchingPercentForBestMatchToRetrieveRelayRides{
                bestMatchs.append(match)
                if bestMatchs.count > 3{
                    break
                }
            }
        }
        if bestMatchs.count < 3 {
            getRelayRideMatchesForCurrentRide()
        }
    }
    private func getRelayRideMatchesForCurrentRide(){
        RouteMatcherServiceClient.getMatchingRelayRides(passengerRideId: scheduleRide?.rideId ?? 0,userId: scheduleRide?.userId ?? 0) {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let relayMatches = Mapper<RelayMatch>().mapArray(JSONObject: responseObject!["resultData"])
                self.prepareRelayRideMatches(relayMatches: relayMatches ?? [RelayMatch]())
            }
        }
    }
    
    private func prepareRelayRideMatches(relayMatches: [RelayMatch]){
        if relayMatches.isEmpty{
            return
        }
        relayRides.removeAll()
        for relayMatch in relayMatches{
            for secondLegMatch in relayMatch.secondLegMatches{
                LocationCache.getCacheInstance( ).getLocationInfoForLatLng(useCase: "iOS.App.pickup.RelayRide", coordinate: CLLocationCoordinate2D(latitude: relayMatch.firstLegMatch?.dropLocationLatitude ?? 0, longitude: relayMatch.firstLegMatch?.dropLocationLongitude ?? 0), handler: { (location, error) in
                    if location != nil{
                        relayMatch.firstLegMatch?.dropLocationAddress = location!.shortAddress
                    }
                })
                
                LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.pickup.RelayRide", coordinate: CLLocationCoordinate2D(latitude: secondLegMatch.pickupLocationLatitude ?? 0, longitude: secondLegMatch.pickupLocationLongitude ?? 0), handler: { (location, error) in
                    if location != nil{
                        secondLegMatch.pickupLocationAddress = location!.shortAddress
                        let dropLocation = relayMatch.firstLegMatch?.dropLocationAddress?.components(separatedBy: ",")
                        let shortDropLocation = dropLocation?[0]
                        let points = (relayMatch.firstLegMatch?.points ?? 0) + (secondLegMatch.points ?? 0)
                        let routeMatchPer = (relayMatch.firstLegMatch?.matchPercentage ?? 0) + (secondLegMatch.matchPercentage ?? 0)
                        let stopOverTime = DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: secondLegMatch.pickupTime, time2: relayMatch.firstLegMatch?.dropTime)
                        let relayRideMatch = RelayRideMatch(firstLegMatch: relayMatch.firstLegMatch, secondLegMatch: secondLegMatch, midLocationLat: relayMatch.firstLegMatch?.dropLocationLatitude ?? 0, midLocationLng: relayMatch.firstLegMatch?.dropLocationLongitude ?? 0, midLocationAddress: shortDropLocation ?? "", totalPoints: points, timeDeviationInMins: stopOverTime, totalMatchingPercent: routeMatchPer)
                        self.relayRides.append(relayRideMatch)
                        NotificationCenter.default.post(name: .receivedRelayRides, object: self)
                    }
                })
                
            }
        }
    }
    
    func getTaxiPoints() -> Double{
        var minFare = 0.0
        let fareForTaxis = detailEstimatedFare?.fareForTaxis ?? [EstimatedFareForTaxi]()
        for estimatedFare in fareForTaxis {
            let fares = estimatedFare.fares
            for fareForVehicle in fares {
                if minFare == 0 || minFare > fareForVehicle.minTotalFare!{
                    minFare = fareForVehicle.minTotalFare!
                }
            }
        }
        return minFare;
    }
}

