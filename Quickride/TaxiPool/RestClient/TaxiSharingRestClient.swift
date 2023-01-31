//
//  TaxiSharingRestClient.swift
//  Quickride
//
//  Created by QR Mac 1 on 08/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiSharingRestClient{
    typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    static let RouteMatchBaseURl = AppConfiguration.taxiRouteMatchServerUrlIp + AppConfiguration.TAXI_ROUTE_MATCH_SERVER_PORT + AppConfiguration.taxiRouteMatchServerPath
    static let TaxiDemandBaseURl = AppConfiguration.taxiDemandServerUrlIp + AppConfiguration.TD_serverPort + AppConfiguration.taxiDemandServerPath
    static let TaxiRideEngineBaseURL = AppConfiguration.taxiRideEngineServerUrlIp + AppConfiguration.taxiRideEngineServerPath
    static let TaxiResloveRiskBaseURL = AppConfiguration.taxiRideEngineServerUrlIp + AppConfiguration.RE_serverPort + AppConfiguration.taxiRideEngineServerPath 

    static let GET_CARPOOL_MATCHES = "/taxi/group/match/findProbablePassengers"
    static let INVITE_CARPOOL_PASSENGER = "/taxiride/invite"
    static let CANCEL_CARPOOL_PASSENGER_INVITE = "/taxiride/invite/cancel"
    static let GET_MATCHED_TAXIPOOLER = "/taxi/group/match/matchedTaxi"
    static let REJECT_INVITE = "/taxiride/invite/reject"
    static let GET_INCOMING_INVITES_FOR_CARPOOL = "/taxiride/invite/rideIds"
    static let UPDATE_TAXI_INVITE_STATUS = "/taxiride/invite/updateStatus"
    static let UPDATE_SHARING_TO_EXCLUSIVE = "/taxi/booking/updateSharingToExclusive"
    static let UPDATE_EXCLUSIVE_TO_SHARING = "/taxi/booking/updateExclusiveToSharing"
    static let INVITE_BY_CONTACT = "/taxiride/invite/contactWithResult"
    static let GET_MATCHED_TAXIPOOLER_BY_CONTACT = "/taxi/group/match/validate"
    static let GET_MATCHING_TAXIPOOL = "/taxi/group/match"
    static let GET_TAXI_PASSENGER = "/taxi/group/match/taxiPoolUserInvitedCarpoolRideGiver"
    static let INVITE_CARPOOL_RIDE_GIVER = "/QRRideconn/invite/rider/by/taxiuser"
    static let RISKY_RIDE = "/riderisk"
    static let TAXI_DRIVERSHAREING_DETAILS = "/taxi/allocation/config"
    static let RESOLVE_RISK_STATUS_PATH = "/taxiRideGroup"
    static let RESOLVE_RISK_RIDE_PATH = "/resolveRisk"

    static func getCarpoolPassengerMatchesForTaxipool(taxiRidePassengerId:Double,taxiGroupId: Double,filterPassengerRideId: Double?, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  RouteMatchBaseURl + GET_CARPOOL_MATCHES
        var params = [String: String]()
        params[Ride.FLD_USERID] = UserDataCache.getInstance()?.userId
        params[MatchingTaxiPassenger.TAXI_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params[MatchingTaxiPassenger.TAXI_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        if let id = filterPassengerRideId{
            params[MatchingTaxiPassenger.FILTER_PASSENGER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: id)
        }
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func inviteCarpoolPassenger(taxiPoolInvite: TaxiPoolInvite, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + INVITE_CARPOOL_PASSENGER
        var params = [String: String]()
        params["taxiInvite"] = Mapper().toJSONString(taxiPoolInvite, prettyPrint: false)
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func cancelCarpoolPassengerInvite(inviteId: String, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + CANCEL_CARPOOL_PASSENGER_INVITE
        var params = [String: String]()
        params["inviteId"] = inviteId
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func remaindCarpoolPassengerInvite(taxiPoolInvite: TaxiPoolInvite, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + INVITE_CARPOOL_PASSENGER
        var params = [String: String]()
        params["taxiInvite"] = Mapper().toJSONString(taxiPoolInvite, prettyPrint: false)
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getInvitedTaxiPoolerDetails(taxiGroupId: Int,passengerRideId: Int, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  RouteMatchBaseURl + GET_MATCHED_TAXIPOOLER
        var params = [String: String]()
        params["taxiGroupId"] = String(taxiGroupId)
        params["passengerRideId"] = String(passengerRideId)
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func rejectInvite(inviteId: String, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + REJECT_INVITE
        var params = [String: String]()
        params["inviteId"] = inviteId
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getIncomingAndOutGoingInvitations(srcRideIds: [String],destRideIds: [String], completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + GET_INCOMING_INVITES_FOR_CARPOOL
        var params = [String: String]()
        params["srcRideIds"] = srcRideIds.joined(separator: ",")
        params["destRideIds"] = destRideIds.joined(separator: ",")
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    static func updateTaxiInviteStatus(inviteId: String,invitationStatus: String, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + UPDATE_TAXI_INVITE_STATUS
        var params = [String: String]()
        params["inviteId"] = inviteId
        params["invitationStatus"] = invitationStatus
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func updateSharingToExclusive(taxiRidePassengerId: Double,allocateTaxiIfPoolNotConfirmed: Bool,fixedFareId: String?, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + UPDATE_SHARING_TO_EXCLUSIVE
        var params = [String: String]()
        params["taxiRidePassengerId"] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params["allocateTaxiIfPoolNotConfirmed"] = String(allocateTaxiIfPoolNotConfirmed)
        if let id = fixedFareId{
            params["fixedFareId"] = id
        }
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func updateExclusiveToSharing(taxiRidePassengerId: Double,allocateTaxiIfPoolNotConfirmed: Bool, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + UPDATE_EXCLUSIVE_TO_SHARING
        var params = [String: String]()
        params["taxiRidePassengerId"] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params["allocateTaxiIfPoolNotConfirmed"] = String(allocateTaxiIfPoolNotConfirmed)
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func taxipoolInviteByContact(taxiRidePassengerId: Double,taxiGroupId: Double,contacts: String, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  TaxiDemandBaseURl + INVITE_BY_CONTACT
        var params = [String: String]()
        params["taxiRidePassengerId"] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params["taxiGroupId"] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        params["CONTACT"] = contacts
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func getInviteByContactTaxiPoolerDetails(taxiGroupId: Int,startTime: Int,startLat: Double,startLng: Double,endLat: Double,endLng: Double,noOfSeats: Int,reqToSetAddress: Bool, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  RouteMatchBaseURl + GET_MATCHED_TAXIPOOLER_BY_CONTACT
        var params = [String: String]()
        params["taxiGroupId"] = String(taxiGroupId)
        params["userId"] = UserDataCache.getInstance()?.userId
        params["startTime"] = String(startTime)
        params["startLat"] = String(startLat)
        params["startLng"] = String(startLng)
        params["endLat"] = String(endLat)
        params["endLng"] = String(endLng)
        params["noOfSeats"] = String(noOfSeats)
        params["reqToSetAddress"] = String(reqToSetAddress)
        params["requiresFare"] = String(true)
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getMatchingTaxipool(startTime: Double,startLat: Double,startLng: Double,endLat: Double,endLng: Double,noOfSeats: Int,routeId: Double,expectedEndTime: Double,distance: Double,requiresFare: Bool, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  RouteMatchBaseURl + GET_MATCHING_TAXIPOOL
        var params = [String: String]()
        params["userId"] = UserDataCache.getInstance()?.userId
        params["startTime"] = StringUtils.getStringFromDouble(decimalNumber: startTime)
        params["expectedEndTime"] = StringUtils.getStringFromDouble(decimalNumber: expectedEndTime)
        params["startLat"] = String(startLat)
        params["startLng"] = String(startLng)
        params["endLat"] = String(endLat)
        params["endLng"] = String(endLng)
        params["noOfSeats"] = String(noOfSeats)
        params["routeId"] = StringUtils.getStringFromDouble(decimalNumber:routeId)
        params["distance"] = String(distance)
        params["requiresFare"] = String(requiresFare)
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getTaxiPassenger(taxiRidePassengerId: Double,passengerUserId: Double,riderRideId: Double, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  RouteMatchBaseURl + GET_TAXI_PASSENGER
        var params = [String: String]()
        params["taxiRidePassengerId"] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params["userId"] = UserDataCache.getInstance()?.userId
        params["passengerUserId"] = StringUtils.getStringFromDouble(decimalNumber: passengerUserId)
        params["riderRideId"] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func inviteRideGiver(taxiRideId : Double, passengerId : Double,noOfSeats : Int, matchedUsers : String, paymentType: String?,passengerRequiresHelmet: Bool , completionHandler : @escaping responseJSONCompletionHandler){
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath + INVITE_CARPOOL_RIDE_GIVER
        var params = [String: String]()
        params["taxiRideId"] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        params["passengerId"] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
        params["MatchedUser"] = matchedUsers
        params["requiredSeats"] = String(noOfSeats)
        params["paymentType"] = paymentType
        params[MatchedUser.PASSENGERREQUIRESHELMET] = String(passengerRequiresHelmet)
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func sendRiskyRide(createRideRiskInJson: String, completionHandler : @escaping responseJSONCompletionHandler){
    let url = TaxiRideEngineBaseURL + RISKY_RIDE
        var params = [String: String]()
        params["createRisk"] = createRideRiskInJson
        params[Ride.FLD_USERID] = UserDataCache.getInstance()?.userId
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func getDriverDetailsShareTime(longitude: Double, latitude: Double, completionHandler : @escaping responseJSONCompletionHandler){
        let url = TaxiDemandBaseURl + TAXI_DRIVERSHAREING_DETAILS
        var params = [String: String]()
        params["longitude"] =  String(longitude)
        params["latitude"] =  String(latitude)
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func getCustomerResolveRisk(taxiGroupId: Double,completionHandler : @escaping responseJSONCompletionHandler){
      let url = TaxiResloveRiskBaseURL + RISKY_RIDE + RESOLVE_RISK_STATUS_PATH
        var params = [String: String]()
        params["taxiGroupId"] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        params["userId"] = UserDataCache.getInstance()?.userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    

    static func sendResolveRiskSolved(resolveRisk: String, completionHandler : @escaping responseJSONCompletionHandler) {
        let url = TaxiResloveRiskBaseURL + RISKY_RIDE + RESOLVE_RISK_RIDE_PATH
        var params = [String: String]()
        params["userId"] = UserDataCache.getInstance()?.userId
        params["resolveRisk"] = resolveRisk
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
         
    }
    
}
