//
//  RideMatcherServiceClient.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 27/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideMatcherServiceClient {

  static var RIDE_MATCHER_SERVICE_RIDER_INVITE_SERVICE_PATH = "/QRRideconn/invite/passenger/new/utc"


  static let  RIDE_MATCHER_SERVICE_RIDER_REJECT_PASSENGER_INVITE_SERVICE_PATH = "/QRRideconn/invite/rider/reject"
  static var REGULAR_RIDE_MATCHER_SERVICE_RIDER_INVITE_SERVICE_PATH = "/QRRegularrideconn/invite/passenger"
  static var  RIDE_MATCHER_SERVICE_RIDER_INVITE_CONTACT_SERVICE_PATH = "/QRRideconn/invite/contactWithResult/new"
  static var  RIDE_MATCHER_SERVICE_RIDER_INVITE_GROUP_SERVICE_PATH = "/QRRideconn/invite/group"
  static var RIDE_MATCHER_SERVICE_INVITE_TO_SELECTED_USERS_OF_GROUP_SERVICE_PATH = "/QRRideconn/invite/group/users"
  static let  RIDE_MATCHER_SERVICE_JOIN_RIDES_SERVICE_PATH = "/QRRideconn/joinrides/utc"
  static let  RIDE_MATCHER_SERVICE_PASSENGER_REJECT_RIDER_INVITE_SERVICE_PATH = "/QRRideconn/invite/passenger/reject"
  static let  RIDE_MATCHER_SERVICE_PASSENGER_INVITE_SERVICE_PATH = "/QRRideconn/invite/rider/new/utc"
  static let  UPDATE_RIDE_INVITATION_STATUS_SERVICE_PATH = "/QRRideInvite/updateStatus"
  static let RIDE_MATCHER_SERVICE_MATCHED_DISTANCE_GETTING_SERVICE_PATH = "/QRRideconn/matchedDistance"
  static let GET_RIDE_MATCH_METRICS_NEW_PICKUP_DROP = "/QRRideconn/matchedMetricsForNewPickupDrop"
  static let MULTI_PASSENGERS_INVITE_SERVICE_PATH = "/QRRideconn/invite/passengers/multiple"
  static let MULTI_RIDERS_INVITE_SERVICE_PATH = "/QRRideconn/invite/riders/multiple"
  static let GET_ALL_RIDE_INVITATIONS_SERVICE_PATH = "/QRRideInvite/rideInvitations"
  static let GET_RIDE_INVITATION_SERVICE_PATH = "/QRRideInvite/rideinvite/id"
  static let PAY_FOR_RIDE_SERVICE_PATH = "/QRRideconn/pay"



  static func sendRiderInvitationToPassenger(riderRideId:Double, riderId:Double, passengerRideId:Double, passengerId:Double,
                                             pickupAddress:String?, pickupLatitude:Double, pickupLongitude:Double, pickupTime:Double,
                                             dropAddress:String? , dropLatitude:Double, dropLongitude:Double , dropTime:Double,
                                             matchingDistance:Double, points:Double,newFare : Double,fareChange : Bool, noOfSeats:Int,pickUpTimeRecalculationRequired :Bool,handler :@escaping RiderRideRestClient.responseJSONCompletionHandler){
    var params:Dictionary<String, String> = Dictionary<String, String>()
    params[Ride.FLD_ID] = String(riderRideId).components(separatedBy: ".")[0]
    params[Ride.FLD_USERID] = String(riderId).components(separatedBy: ".")[0]
    params[Ride.FLD_PASSENGERRIDEID] = String(passengerRideId).components(separatedBy: ".")[0]
    params[Ride.FLD_PASSENGERID] = String(passengerId).components(separatedBy: ".")[0]

    if pickupAddress?.isEmpty == false{
      params[Ride.FLD_PICKUP_ADDRESS] = pickupAddress!
    }

    params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLatitude)
    params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLongitude)
    params[Ride.FLD_PICKUP_TIME] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: pickupTime), timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
    if dropAddress?.isEmpty == false{
      params[Ride.FLD_DROP_ADDRESS] = dropAddress!
    }
    params[Ride.FLD_DROP_LATITUDE] = String(dropLatitude)
    params[Ride.FLD_DROP_LONGITUDE] = String(dropLongitude)
    params[Ride.FLD_DROP_TIME] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: dropTime), timeFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)
    params[Ride.FLD_DISTANCE] = String(matchingDistance)
    params[Ride.FLD_POINTS] = StringUtils.getStringFromDouble(decimalNumber: points)
    params[Ride.FLD_NEW_FARE] = StringUtils.getStringFromDouble(decimalNumber:  newFare)
    params[Ride.FLD_FARE_CHANGE] = String(fareChange)
    params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
    params[MatchedUser.FLD_PICK_UP_TIME_RECALCULATION_REQUIRED] = String(pickUpTimeRecalculationRequired)
    params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
    let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath + RIDE_MATCHER_SERVICE_RIDER_INVITE_SERVICE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
  }

  static func sendPassengerInvitationToRider(riderRideId : Double, riderId : Double,  passengerRideId : Double,passengerId : Double,pickupAddress : String?, pickupLatitude : Double, pickupLongitude : Double, pickupTime : Double, dropAddress : String? , dropLatitude : Double, dropLongitude : Double ,dropTime : Double,
                                             matchingDistance : Double,points : Int,newFare : Double, fareChange :Bool,noOfSeats: Int, paymentType: String?, viewController : UIViewController?,handler: @escaping RiderRideRestClient.responseJSONCompletionHandler) {
    var params = [String: String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
    params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
    params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
    params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
    if pickupAddress != nil{
      params[Ride.FLD_PICKUP_ADDRESS] = pickupAddress!
    }

    params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLatitude)
    params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLongitude)
    params[Ride.FLD_PICKUP_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: pickupTime))
    if dropAddress != nil{
      params[Ride.FLD_DROP_ADDRESS] = dropAddress
    }

    params[Ride.FLD_DROP_LATITUDE] = String(dropLatitude)
    params[Ride.FLD_DROP_LONGITUDE] = String(dropLongitude)
    params[Ride.FLD_DROP_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: dropTime))
    params[Ride.FLD_DISTANCE] = String(matchingDistance)
    params[Ride.FLD_POINTS] = String(points)
    params[Ride.FLD_NEW_FARE] = StringUtils.getStringFromDouble(decimalNumber: newFare)
    params[Ride.FLD_FARE_CHANGE] = String(fareChange)
    params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
    params[Ride.FLD_PAYMENT_TYPE] = paymentType
    params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
    let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath + RIDE_MATCHER_SERVICE_PASSENGER_INVITE_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
  }

  static func sendInvitationToContact( rideId : Double, rideType : String, contact :  String, paymentType: String?, viewController : UIViewController, complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
    var  params = [String: String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
    params[Ride.FLD_RIDETYPE] = rideType
    params[Contact.CONTACT] = contact
    params[Ride.FLD_PAYMENT_TYPE] = paymentType
    params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
    let url =  AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath+RIDE_MATCHER_SERVICE_RIDER_INVITE_CONTACT_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: complitionHandler, body: params)
  }
    static func sendInvitationToGroup(riderRideId : Double,rideType : String, selectedGroupIds : String,viewController : UIViewController,complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        var  params = [String: String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_RIDETYPE] = rideType
        params[Ride.FLD_RIDE_GROUP_ID] = selectedGroupIds
        params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
        let url =  AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath+RIDE_MATCHER_SERVICE_RIDER_INVITE_GROUP_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: complitionHandler, body: params)
    }
    static func sendInvitationToSelectedUserOfGroup(riderRideId : Double,rideType : String, userIds : String, groupId : Double, viewController : UIViewController,complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        var  params = [String: String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_RIDETYPE] = rideType
        params[User.FLD_PHONE] = userIds
        params[Ride.FLD_RIDE_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
        params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
        let url =  AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath+RIDE_MATCHER_SERVICE_INVITE_TO_SELECTED_USERS_OF_GROUP_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: complitionHandler, body: params)
    }

  static func passengerRejectedRiderInvitation( riderRideId : Double,  riderId : Double, passengerRideId : Double, passengerId: Double, rideInvitationId: Double, rideType : String, rejectReason :String?,viewController : UIViewController? ,complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){

    var params =  [String: String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
    params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
    params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
    params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
    params[RideInvitation.FLD_RIDE_INVITATION_ID] = StringUtils.getStringFromDouble(decimalNumber: rideInvitationId)
    params[RideInvitation.RIDE_INVITATION_REJECT_REASON] = rejectReason
    let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath+RIDE_MATCHER_SERVICE_PASSENGER_REJECT_RIDER_INVITE_SERVICE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: complitionHandler, body: params)
  }
  static func riderRejectedPassengerInvitation( riderRideId : Double,  riderId : Double,  passengerRideId : Double,
                                                passengerId: Double, rideInvitationId: Double , rideType: String, rejectedReason: String?, moderatorId: String?, viewController: UIViewController?, completeionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
    var params = [String: String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
    params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
    params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
    params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
    params[RideInvitation.FLD_RIDE_INVITATION_ID] = StringUtils.getStringFromDouble(decimalNumber: rideInvitationId)
    params[RideInvitation.RIDE_INVITATION_REJECT_REASON] = rejectedReason
    params[RideInvitation.RIDE_MODERATOR_ID] = moderatorId
    let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath+RIDE_MATCHER_SERVICE_RIDER_REJECT_PASSENGER_INVITE_SERVICE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completeionHandler, body: params)
  }

    static func addPassengerToRiderRide( riderRideId : Double,  riderId: Double, passengerRideId: Double, passengerId: Double,pickupAddress : String?, pickupLatitude: Double, pickupLongitude: Double, pickupTime: Double?,dropAddress: String? , dropLatitude: Double, dropLongitude: Double , dropTime: Double?,matchingDistance: Double, points: Double, newFare: Double,fareChange :Bool,noOfSeats: Int, rideInvitationId: Double,pickupTimeRecalculationRequired : Bool,passengerRouteMatchPercentage : Int,riderRouteMatchPercentage : Int, rideType: String?, paymentType: String?, moderatorId: String?, viewController: UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        var params = [String: String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
        params[Ride.FLD_DISTANCE] =   String(matchingDistance)
        if pickupAddress != nil{
            params[Ride.FLD_PICKUP_ADDRESS] = pickupAddress
        }
        params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLatitude)
        params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLongitude)
        if pickupTime != nil{
            params[Ride.FLD_PICKUP_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: pickupTime!))
        }
        if dropAddress != nil{
            params[Ride.FLD_DROP_ADDRESS] = dropAddress
        }
        params[Ride.FLD_DROP_LATITUDE] = String(dropLatitude)
        params[Ride.FLD_DROP_LONGITUDE] = String(dropLongitude)
        if dropTime != nil{
            params[Ride.FLD_DROP_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: dropTime!))
        }
        params[Ride.FLD_POINTS] = StringUtils.getPointsInDecimal(points: points)
        params[Ride.FLD_AVAILABLE_SEATS] = String(noOfSeats)
        params[RideInvitation.FLD_RIDE_INVITATION_ID] = StringUtils.getStringFromDouble(decimalNumber: rideInvitationId)
        params[Ride.FLD_NEW_FARE] = StringUtils.getStringFromDouble(decimalNumber: newFare)
        params[Ride.FLD_FARE_CHANGE] = String(fareChange)
        params[Ride.FLD_RECALCULATE_PICKUP_DROP_TRAFFIC] = String(pickupTimeRecalculationRequired)
        params[RideInvitation.MATCH_PERCENTAGE_PSGR] = String(passengerRouteMatchPercentage)
        params[RideInvitation.MATCH_PERCENTAGE_RIDER] = String(riderRouteMatchPercentage)
        params[Ride.FLD_PAYMENT_TYPE] = paymentType
        params[Ride.FLD_RIDETYPE] = rideType
        params[RideInvitation.RIDE_MODERATOR_ID] = moderatorId
        params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
        let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath+RIDE_MATCHER_SERVICE_JOIN_RIDES_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    static func updateRideInvitationStatus(invitationId : Double, invitationStatus : String,viewController : UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        var params : [String :String] = [String :String]()
        params[RideInvitation.FLD_RIDE_INVITATION_ID] = StringUtils.getStringFromDouble(decimalNumber: invitationId)
        params[RideInvitation.RIDE_INVITATION_STATUS] = invitationStatus
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+UPDATE_RIDE_INVITATION_STATUS_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    
    static func getMatchingDistance(riderRideId : Double,passengerRideId : Double,rideType : String, pickupLat : Double, pickupLng : Double,dropLat : Double,dropLng : Double, viewController : UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        var params = [String: String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_RIDETYPE] = rideType
        
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLat)
        params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLng)
        params[Ride.FLD_DROP_LATITUDE] = String(dropLat)
        params[Ride.FLD_DROP_LONGITUDE] = String(dropLng)
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+RIDE_MATCHER_SERVICE_MATCHED_DISTANCE_GETTING_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    static func getRideMatchMetricsForNewPickupDrop(riderRideId : Double,passengerRideId : Double,riderId : Double,passengerId : Double,pickupLat : Double,pickupLng : Double,dropLat : Double,dropLng : Double,noOfSeats : Int, viewController : UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        var params = [String: String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
        params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLat)
        params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLng)
        params[Ride.FLD_DROP_LATITUDE] = String(dropLat)
        params[Ride.FLD_DROP_LONGITUDE] = String(dropLng)
        params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
        
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+GET_RIDE_MATCH_METRICS_NEW_PICKUP_DROP
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    
    static func sendInvitationToPassengers( rideId : Double,riderId : Double, matchedUsers : String,invitePosition: String?,currentSortFilterStatus: String?, viewController : UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
        params[MatchedUser.MATCHED_USER] = matchedUsers
        params[MatchedUser.INVITEE_SORT_POSITION] = invitePosition
        params[MatchedUser.CURRENT_SORT_FILTER_STATUS] = currentSortFilterStatus
        params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+MULTI_PASSENGERS_INVITE_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    
  
    static func sendInvitationToRiders(rideId : Double, passengerId : Double,noOfSeats : Int, matchedUsers : String,isFromPreferredRider : Bool, paymentType: String?,invitePosition: String?,currentSortFilterStatus: String?,passengerRequiresHelmet: Bool , viewController : UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        var params = [String : String]()
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
        params[MatchedUser.MATCHED_USER] = matchedUsers
        params[MatchedPassenger.REQUIRED_SEATS] = String(noOfSeats)
        params[PassengerRide.PREFERRED_RIDER] = String(isFromPreferredRider)
        params[Ride.FLD_PAYMENT_TYPE] = paymentType
        params[MatchedUser.INVITEE_SORT_POSITION] = invitePosition
        params[MatchedUser.CURRENT_SORT_FILTER_STATUS] = currentSortFilterStatus
        params[MatchedUser.PASSENGERREQUIRESHELMET] = String(passengerRequiresHelmet)
        params[Ride.FLD_PAY_AFTER_CONFIRM] = "true"
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+MULTI_RIDERS_INVITE_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)

    }
    
    static func getAllRideInvitations(userId: String?, rideIdList: String?, completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler) {
        var params =  [String: String]()
        params[Ride.FLD_USERID] = userId
        params[Ride.FLD_ID] = rideIdList
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+GET_ALL_RIDE_INVITATIONS_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    static func getRideInvite(userId: Double, inviteId: Double, completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler) {
        var params =  [String: String]()
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params[RideInvitation.FLD_RIDE_INVITATION_ID] = StringUtils.getStringFromDouble(decimalNumber: inviteId)
        let url = AppConfiguration.rideConnectivityServerUrlIP+AppConfiguration.RC_serverPort+AppConfiguration.rideConnectivityServerPath+GET_RIDE_INVITATION_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func payForRideToConfirmRide(userId: Double, passengerRideId : Double , paymentType: String, completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        var params =  [String: String]()
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params[Ride.FLD_PAYMENT_TYPE] = paymentType
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath + PAY_FOR_RIDE_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
}
