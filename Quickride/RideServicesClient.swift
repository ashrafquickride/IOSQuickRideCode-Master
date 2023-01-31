//
//  RideServicesClient.swift
//  Quickride
//
//  Created by KNM Rao on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideServicesClient {

    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    public static let GET_CANCEL_PENALTY_ESTIMATED = "/QRRide/estimatecancelpenalty/new"
    public static let GET_ALL_CLOSED_RIDES = "/QRRide/all/closed"
    public static let GET_ALL_ACTIVE_RIDES = "/QRRide/all/active"
    public static let GET_UNJOIN_PENALTY_ESTIMATED = "/QRRide/estimateunjoinpenalty/new"
    public static let UNJOIN_RIDE_PARTICIPANT = "QRRide/unjoin"
    public static let GET_RIDE_STATUS = "QRRide/status"
    public static let UNJOIN_PARTICIPANT_FROM_REGULAR_RIDE = "QRRide/regular/unjoin"
    public static let CO_TRAVELLERS_SERVICE_PATH = "/QRRide/cotravellers"
    public static let RIDE_ROUTE = "/QRRide/routePathPolyLine"
    public static let RIDE_SHARING_COMMUNITY_CONTRIBUTION_GETTING_SERVICE_PATH = "/QREcoMeter/rideSharingCommunityContribution"
    public static let RIDE_ROUTE_UPDATING_SERVICE_PATH = "/QRRide/rideRoute/"
    public static let PASSENGER_ETA_SERVICE_PATH = "/QRRide/eta/"
    public static let PASSENGERS_JOINED_RIDE_SERVICE_PATH = "/QRRide/joinedRide/passengers/new"
    public static let RIDE_CONTRIBUTION_SERVICE_PATH = "/QRRide/rideContribution"
    public static let ARCHIVE_RIDES_SERVICE_PATH = "/QRRide/archive/utc"
    public static let date = "Date";
    public static let CO_TRAVELLERS_EXPIRED_SERVICE_PATH = "/QRRide/cotravellers/selected"
    public static let SYNC_ACTIVE_PASSENGER_RIDE_SERVICE_PATH = "/QRRide/syncPassengerRide"
    public static let VALID_REFERRAL_CONTACTS_GETTING_SERVICE_PATH = "/QRUser/referral/contacts/ios"
    public static let MOBILE_CONTACTS = "mobileContacts";
    public static let BONUS_POINTS_CREDITING_PATH = "/QRRide/newuser/bonuspoints"
    public static let RIDE_DETAILINFO_PATH = "/QRRide/rideDetailInfo";
    public static func getEstimatedPenaltyForRideCancellation(rideId : Double ,rideType :String, userId : Double , startTime : Double,cancelReason: String,completionHandler : @escaping responseJSONCompletionHandler){

        AppDelegate.getAppDelegate().log.debug("getEstimatedPenaltyForRideCancellation() \(rideId) \(rideType) \(userId) \(startTime)")
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+GET_CANCEL_PENALTY_ESTIMATED
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : rideId)
        params[Ride.FLD_RIDETYPE] = rideType
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber : userId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber : userId)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime))
        params[Ride.FLD_CANCEL_REASON] = cancelReason

        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    public static func getAllClosedRidesOfUser(userId : String,completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getAllClosedRidesOfUser() \(userId)")
        let getClosedRides = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_ALL_CLOSED_RIDES
        var params = [String : String]()
        params[Ride.FLD_USERID] = userId
        HttpUtils.getJSONRequestWithBody(url: getClosedRides, targetViewController: nil, params: params, handler: completionHandler)
    }

    public static func getAllActiveRidesOfUser(userId : String, completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getAllActiveRidesOfUser() \(userId)")
        let getActiveRides = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_ALL_ACTIVE_RIDES
        var params = [String : String]()
        params[Ride.FLD_USERID] = userId
        HttpUtils.getJSONRequestWithBody(url: getActiveRides, targetViewController: nil, params: params, handler: completionHandler)
    }

    public static func getEstimatedPenaltyForRideUnjoin(rideId : Double,rideType : String,reason: String,viewController : UIViewController, completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getEstimatedPenaltyForRideUnjoin() \(rideId)")
        let url:String = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+GET_UNJOIN_PENALTY_ESTIMATED

        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_RIDETYPE] = rideType
        params[Ride.FLD_CANCEL_REASON] = reason

        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    public static func unjoinRideParticipantFromRide(riderRideId : Double,passengerRideId : Double, rideType : String,rideCancelReason : String?,isWaveOff: Bool,viewController : UIViewController,completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("unjoinRideParticipantFromRide() \(riderRideId) \(passengerRideId) \(rideType)")
        let url:String = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+UNJOIN_RIDE_PARTICIPANT
        var params :[String : String] = [String : String]()
        params[Ride.FLD_ID] = "\(riderRideId)".components(separatedBy:".")[0]
        params[Ride.FLD_RIDETYPE] = "\(rideType)"
        params[Ride.FLD_PASSENGERRIDEID] = "\(passengerRideId)".components(separatedBy:".")[0]
        params[Ride.FLD_CANCEL_REASON] = rideCancelReason
        params[Ride.FLD_WAVEOFF] = String(isWaveOff)

        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body : params)
    }
    public static func getRideStatus(rideId : Double, rideType :String,completionHandler : @escaping responseJSONCompletionHandler) {
        AppDelegate.getAppDelegate().log.debug("getRideStatus() \(rideId) \(rideType)")

        let url:String = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+GET_RIDE_STATUS

        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : rideId)
        params[Ride.FLD_RIDETYPE] = rideType
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    public static func unJoinParticipantFromRegularRide( regularPassengerRideId: Double,  rideType: String, viewController : UIViewController,completionHandler : @escaping responseJSONCompletionHandler) {
        AppDelegate.getAppDelegate().log.debug("unJoinParticipantFromRegularRide() \(regularPassengerRideId) \(rideType)")
        var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : regularPassengerRideId)
        params[Ride.FLD_RIDETYPE] = rideType
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+UNJOIN_PARTICIPANT_FROM_REGULAR_RIDE
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler : completionHandler, body: params)
    }
    public static func getCoTravellers( userid : String,handler: @escaping responseJSONCompletionHandler) {
        AppDelegate.getAppDelegate().log.debug("getCoTravellers() \(userid)")
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + CO_TRAVELLERS_SERVICE_PATH

        var params = [String : String]()
        params[User.FLD_PHONE] = userid

        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    public static func getRoutePath( rideId : Double,rideType : String,handler: @escaping responseJSONCompletionHandler) {
        AppDelegate.getAppDelegate().log.debug("getRoutePath() \(rideId)")
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + RIDE_ROUTE

        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : rideId)
        params[Ride.FLD_RIDETYPE] = rideType

        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    public static func getUserRideSharingCommunityContribution(userId : Double,handler: @escaping responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("getUserRideSharingCommunityContribution() \(userId)")
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + RIDE_SHARING_COMMUNITY_CONTRIBUTION_GETTING_SERVICE_PATH
        var params = [String : String]()
        params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber : userId)
        HttpUtils.getJSONRequestWithBodyUnSecure(url: url, targetViewController: nil, params: params, completionHandler: handler)
    }
    static func updateRideRoute(rideId : Double, rideType :String, rideRoute : RideRoute,viewController : UIViewController?,handler: @escaping responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("updateRideRoute() \(rideId) \(rideType) \(String(describing: rideRoute.routeId))")
        var params = [String : String]()
        params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute)
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : rideId)
        params[Ride.FLD_RIDETYPE] = rideType
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + RIDE_ROUTE_UPDATING_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    static func getETAForPassenger(currentLocationLatitude : Double, currentLocationLongitude :Double, pickupLocationLatitude : Double, pickupLocationLongitude :Double,riderRideId : Double,passengerRideId : Double,viewController : UIViewController,handler: @escaping responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("getETAForPassenger() \(currentLocationLatitude) \(currentLocationLongitude) \(pickupLocationLatitude) \(pickupLocationLongitude) \(riderRideId) \(passengerRideId)")
        var params = [String : String]()
        params[Ride.FLD_STARTLATITUDE] = String(currentLocationLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(currentLocationLongitude)

        params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLocationLatitude)
        params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLocationLongitude)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber : passengerRideId)
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber : riderRideId)

        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + PASSENGER_ETA_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func getAlreadyJoinedPassengersOfRide(riderRideId : Double, userId: String?, pickupLat: Double?, pickupLng: Double?, dropLat: Double?, dropLng: Double?, viewController : UIViewController, handler: @escaping responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("\(riderRideId)")
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : riderRideId)
        params[Ride.FLD_USERID] = userId
        params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLat ?? 0)
        params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLng ?? 0)
        params[Ride.FLD_DROP_LATITUDE] = String(dropLat ?? 0)
        params[Ride.FLD_DROP_LONGITUDE] = String(dropLng ?? 0)
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + PASSENGERS_JOINED_RIDE_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }

    static func getRideContributionForRide(rideId : String, viewController : UIViewController, handler: @escaping responseJSONCompletionHandler) {
        AppDelegate.getAppDelegate().log.debug("\(rideId)")

        var params = [String : String]()
        params[Ride.FLD_ID] = rideId
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + RIDE_CONTRIBUTION_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func archiveAllRides(date : NSDate? , userId : String , viewController : UIViewController?, handler: @escaping responseJSONCompletionHandler)
    {
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        if date != nil{
            params["Date"] = AppUtil.getDateStringFromNSDate(date: DateUtils.getDateTimeInUTC(date: date!))
        }
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + ARCHIVE_RIDES_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)

    }
    static func getExpiredCoTravellers(userId : String, expiredContacts : String,handler: @escaping responseJSONCompletionHandler)
    {
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        params[Contact.CONTACT] = expiredContacts
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + CO_TRAVELLERS_EXPIRED_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)

    }

  public static func syncActivePassengerRide(userId : Double, rideId : Double, status :  String, handler: @escaping responseJSONCompletionHandler)
  {
    var params = [String : String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
    params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber: userId)
    params[Ride.FLD_STATUS] = status
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SYNC_ACTIVE_PASSENGER_RIDE_SERVICE_PATH
    HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
  }
    static func getvalidContacts(userId : String, mobileContacts : String ,handler: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[MOBILE_CONTACTS] = mobileContacts
         let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + VALID_REFERRAL_CONTACTS_GETTING_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }

    static func creditBonusPointsToOldUser(rideType : String,rideId : Double,userId : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Ride.FLD_RIDETYPE] = rideType
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = userId
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + BONUS_POINTS_CREDITING_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }

    static func getRideDetailInfo(riderRideId : Double,currentUserRideId : Double,userId : Double,handler :@escaping responseJSONCompletionHandler ){
        var params = [String : String]()

        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber:riderRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber:userId)
        params[Ride.FLD_ID] =  StringUtils.getStringFromDouble(decimalNumber:currentUserRideId)

        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + RIDE_DETAILINFO_PATH

        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)

    }

}
