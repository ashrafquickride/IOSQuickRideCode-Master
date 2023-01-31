//
//  RegularRideMatcherServiceClient.swift
//  Quickride
//
//  Created by QuickRideMac on 20/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RegularRideMatcherServiceClient {
    
    
    static let REGULAR_RIDE_MATCHER_SERVICE_JOIN_RIDES_SERVICE_PATH = "/QRRegularrideconn/joinrides/utc"
    static let REGULAR_RIDE_MATCHER_SERVICE_RIDERRIDES_PATH = "Regularroutematcher/rides/multiPickupDrop"
    static let REGULAR_RIDE_MATCHER_SERVICE_PASSENGERRIDES_PATH = "Regularroutematcher/passengers/multiPickupDrop"
    static let REGULAR_RIDE_MATCHER_SERVICE_RIDER_INVITE_SERVICE_PATH = "/QRRegularrideconn/invite/passenger/utc";
    static let REGULAR_RIDE_MATCHER_SERVICE_PASSENGER_REJECT_RIDER_INVITE_SERVICE_PATH = "/QRRegularrideconn/invite/passenger/reject";
    static let REGULAR_RIDE_MATCHER_SERVICE_PASSENGER_INVITE_SERVICE_PATH = "/QRRegularrideconn/invite/rider/utc";
    static let REGULAR_RIDE_MATCHER_SERVICE_RIDER_REJECT_PASSENGER_INVITE_SERVICE_PATH = "/QRRegularrideconn/invite/rider/reject";
    static let REGULAR_RIDE_MATCHER_SERVICE_MATCHED_RIDER_SERVICE_PATH = "Regularroutematcher/matchedrider";
    static let REGULAR_RIDE_MATCHER_SERVICE_MATCHED_PASSENGER_SERVICE_PATH = "Regularroutematcher/matchedpassenger";
    

    
    
    static func getMatchingRegularPassengerRides(rideId : Double,viewController : UIViewController,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getMatchingRegularPassengerRides() \(rideId)")
        let url = AppConfiguration.routeServerUrl+AppConfiguration.ROUTE_MATCH_serverPort+AppConfiguration.routeServerPath+REGULAR_RIDE_MATCHER_SERVICE_PASSENGERRIDES_PATH
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    
    static func getMatchingRegularRiderRides( rideId : Double,viewController : UIViewController,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getMatchingRegularRiderRides() \(rideId)")
        let url = AppConfiguration.routeServerUrl+AppConfiguration.ROUTE_MATCH_serverPort+AppConfiguration.routeServerPath+REGULAR_RIDE_MATCHER_SERVICE_RIDERRIDES_PATH
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    
    static func sendRiderInvitationToPassenger( riderRideId: Double, riderId: Double, selectedPassenger : MatchedRegularPassenger, viewController : UIViewController?,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("sendRiderInvitationToPassenger() \(riderRideId) \(riderId)")
        var params = selectedPassenger.getParams()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
        params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+REGULAR_RIDE_MATCHER_SERVICE_RIDER_INVITE_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    static func sendPassengerInvitationToRider(passengerRideId : Double, passengerId: Double,
        matchedRegularRider :MatchedRegularRider, noOfSeats: Int,viewController : UIViewController?,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
          AppDelegate.getAppDelegate().log.debug("sendPassengerInvitationToRider() \(passengerRideId) \(passengerId)")
            var params = matchedRegularRider.getParams()
            
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
        params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
        params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+REGULAR_RIDE_MATCHER_SERVICE_PASSENGER_INVITE_SERVICE_PATH
            HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    static func addPassengerToRiderRide( riderRideId :Double,  riderId: Double, passengerRideId: Double, passengerId: Double,
                                         pickupAddress: String?, pickupLatitude: Double, pickupLongitude: Double, pickupTime: Double,dropAddress: String? , dropLatitude: Double, dropLongitude: Double , dropTime: Double,matchingDistance: Double, points : Double, noOfSeats: Int, rideInvitationId: Double ,viewController : UIViewController?,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("addPassengerToRiderRide() \(riderRideId) \(riderId) \(passengerRideId) \(passengerId) \(String(describing: pickupAddress)) \(pickupLatitude) \(pickupLongitude) \(pickupTime) \(String(describing: dropAddress)) \(dropLatitude) \(dropLongitude) \(dropTime) \(matchingDistance) \(points) \(noOfSeats) \(rideInvitationId)")
        
        var params: [String: String] = [String: String]()
        
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
        params[Ride.FLD_DISTANCE] = String(matchingDistance)
        if pickupAddress != nil{
            params[Ride.FLD_PICKUP_ADDRESS] = pickupAddress!
        }
        
        params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLatitude)
        params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLongitude)
        params[Ride.FLD_PICKUP_TIME] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: pickupTime), timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
        if dropAddress != nil{
            params[Ride.FLD_DROP_ADDRESS] = dropAddress!
        }
        params[Ride.FLD_DROP_LATITUDE] = String(dropLatitude)
        params[Ride.FLD_DROP_LONGITUDE] = String(dropLongitude)
        params[Ride.FLD_DROP_TIME] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: dropTime), timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
        params[Ride.FLD_POINTS] = StringUtils.getStringFromDouble(decimalNumber: points)
        params[Ride.FLD_AVAILABLE_SEATS] = String(noOfSeats)
        params[RideInvitation.FLD_RIDE_INVITATION_ID] =  StringUtils.getStringFromDouble(decimalNumber: rideInvitationId)
        params[Ride.FLD_CURRENT_USER_ID] = UserDataCache.getInstance()?.userId ?? ""
        params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+REGULAR_RIDE_MATCHER_SERVICE_JOIN_RIDES_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController
                                     , handler: completionHandler, body: params)
    }
    static func passengerRejectedRiderInvitation(riderRideId : Double,riderId : Double,passengerRideId : Double,passengerId : Double,rideInvitationId : Double,rejectReason : String?,viewController : UIViewController?,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("passengerRejectedRiderInvitation() \(riderRideId) \(riderId) \(passengerRideId) \(passengerId) \(rideInvitationId)")
        var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
        params[RideInvitation.FLD_RIDE_INVITATION_ID] = StringUtils.getStringFromDouble(decimalNumber: rideInvitationId)
        params[RideInvitation.RIDE_INVITATION_REJECT_REASON] = rejectReason
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+REGULAR_RIDE_MATCHER_SERVICE_PASSENGER_REJECT_RIDER_INVITE_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    static func riderRejectedPassengerInvitation(riderRideId : Double,riderId : Double,passengerRideId : Double,passengerId : Double,rideInvitationId : Double,rejectReason : String?,viewController : UIViewController?,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("riderRejectedPassengerInvitation() \(riderRideId) \(riderId) \(passengerRideId) \(passengerId) \(rideInvitationId)")
        var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber:passengerId)
        params[RideInvitation.FLD_RIDE_INVITATION_ID] = StringUtils.getStringFromDouble(decimalNumber: rideInvitationId)
        params[RideInvitation.RIDE_INVITATION_REJECT_REASON] = rejectReason
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+REGULAR_RIDE_MATCHER_SERVICE_RIDER_REJECT_PASSENGER_INVITE_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    
    static func getMathchingRegularRider(rideId : Double,passengerRideId : Double,viewController : UIViewController?,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getMathchingRegularRider() \(rideId)")
        let url = AppConfiguration.routeServerUrl+AppConfiguration.ROUTE_MATCH_serverPort+AppConfiguration.routeServerPath+REGULAR_RIDE_MATCHER_SERVICE_MATCHED_RIDER_SERVICE_PATH
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    static func getMatchingRegularPassenger( rideId : Double,riderRideId : Double,viewController : UIViewController?,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getMatchingRegularPassenger() \(rideId)")
        let url = AppConfiguration.routeServerUrl+AppConfiguration.ROUTE_MATCH_serverPort+AppConfiguration.routeServerPath+REGULAR_RIDE_MATCHER_SERVICE_MATCHED_PASSENGER_SERVICE_PATH
         var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
}
