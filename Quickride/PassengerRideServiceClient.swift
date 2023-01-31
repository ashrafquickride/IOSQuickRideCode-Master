//
//  PassengerRideServiceClient.swift
//  Quickride
//
//  Created by KNM Rao on 04/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class PassengerRideServiceClient{

  public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void


  private static let PASSENGER_RIDE_RESOURCE_PATH : String = "/QRPassengerRide"
  private static let PASSENGER_RIDE_STATUS_RESOURCE_PATH : String = "/QRPassengerRide/status"
  private static let PASSENGER_RIDE_COMPLETE_RESOURCE_PATH : String = "/QRPassengerRide/complete"
  private static let PASSENGER_RIDE_RESCHEDULE_RESOURCE_PATH = "QRPassengerRide/reschedule/utc"
  private static let UPDATE_RIDE_STATUS_MESSAGE_SERVICE_PATH = "/QRPassengerRide/rideNotes"
  static let UPADATE_PASSENGER_RIDE = "/QRPassengerRide/update/utc"
  public static let PASSENGER_RIDES_CANCEL_SERVICE_PATH = "/QRPassengerRide/cancelRidesInBulk"
  public static let CANCEL_PASSENGER_RIDE = "/QRPassengerRide/cancelRide"

  private static let baseServerUrl: String = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath

  public static func getPassengerRide(rideId : Double, targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getPassengerRide() \(rideId)")
    let getRiderUrl = baseServerUrl + PASSENGER_RIDE_RESOURCE_PATH
    AppDelegate.getAppDelegate().log.debug("")
   var params = [String : String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
     HttpUtils.getJSONRequestWithBody(url: getRiderUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  public static func cancelPassengerRide(rideId : Double, userId: Double,cancelReason : String?, isWaveOff: Bool, targetViewController : UIViewController?, complitionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("\(rideId)")

    let cancelRideURL = baseServerUrl + CANCEL_PASSENGER_RIDE
    var params = [String : String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
    params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: userId)
    params[Ride.FLD_CANCEL_REASON] = cancelReason
    params[Ride.FLD_WAVEOFF] = String(isWaveOff)

    HttpUtils.putRequestWithBody(url: cancelRideURL, targetViewController: targetViewController, handler: complitionHandler, body: params)

  }
  public static func reschedulePassengerRide(passengerRideId : Double, startTime : Double,viewController : UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("reschedulePassengerRide() \(passengerRideId) \(startTime)")
    var params : [String : String] = [String : String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
    params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime))

    let url  = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + PASSENGER_RIDE_RESCHEDULE_RESOURCE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
  }
    static func updatePassengerRideStatus(passengerRideId : Double, joinedRiderRideId : Double, passengerId: Double,  status : String,fromRider : Bool, otp: String?, viewController : UIViewController?,completionHandler:@escaping RiderRideRestClient.responseJSONCompletionHandler )
  {
    AppDelegate.getAppDelegate().log.debug("  () \(passengerRideId) \(joinedRiderRideId) \(passengerId) \(status)")
    var params =  [String : String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
    params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: joinedRiderRideId)
    params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: passengerId)
    params[Ride.FLD_STATUS] = status
    params[Ride.UPDATE_BY_RIDER] = String(fromRider)
    params[Ride.FLD_DEVICE] = "ios"
    params[User.FLD_PICKUP_OTP] = otp

    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + PASSENGER_RIDE_STATUS_RESOURCE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
  }

    static func updateRideNotes(rideId : Double, rideNotes : String, viewController : UIViewController?,completionHandler:@escaping RiderRideRestClient.responseJSONCompletionHandler )
  {
    var params =  [String : String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
    params[Ride.FLD_RIDE_NOTES] = rideNotes
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATE_RIDE_STATUS_MESSAGE_SERVICE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
  }
  
    static func updatePassengerRide(rideId: Double, startAddress: String, startLatitude: Double, startLongitude: Double, endAddress: String, endLatitude: Double, endLongitude: Double, startTime: Double?, noOfSeats: Int?, route: RideRoute?,pickupAddress: String?, pickupLatitude: Double?, pickupLongitude: Double?, dropAddress: String?, dropLatitude: Double?, dropLongitude: Double?,pickupTime: Double?,dropTime : Double?,points : Double?,overlapDistance : Double?,allowRideMatchToJoinedGroups:Bool,showMeToJoinedGroups:Bool,pickupNote: String?,viewController :UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_STARTADDRESS] = startAddress
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        params[Ride.FLD_ENDADDRESS] = endAddress
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude)
        if startTime != nil {
            params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime!))
        }
        if noOfSeats != nil {
            params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats!)
        }
        if route != nil {
            params[Ride.FLD_ROUTE_ID] =  StringUtils.getStringFromDouble(decimalNumber: route!.routeId)
            params[Ride.FLD_ROUTE] =  Mapper().toJSONString(route!)
        } else {
            params[Ride.FLD_ROUTE_ID] = "0"
        }

        if pickupLatitude != nil && pickupLongitude != nil{
          if pickupAddress != nil{
            params[Ride.FLD_PICKUP_ADDRESS] = pickupAddress
          }
          params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLatitude!)
          params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLongitude!)
            params[Ride.FLD_PICKUP_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: pickupTime!))
        }
        if dropLatitude != nil && dropLongitude != nil{
          if dropAddress != nil{
            params[Ride.FLD_DROP_ADDRESS] = dropAddress
          }
          params[Ride.FLD_DROP_LATITUDE] = String(dropLatitude!)
          params[Ride.FLD_DROP_LONGITUDE] = String(dropLongitude!)
            params[Ride.FLD_DROP_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: dropTime!))
        }
        if points != nil{
            params[Ride.FLD_POINTS] = StringUtils.getStringFromDouble(decimalNumber: points)
        }
        if overlapDistance != nil{
          params[Ride.FLD_OVERLAPDISTANCE] = String(overlapDistance!)
        }
            params[Ride.FLD_JOINED_GROUP_RESTRICTION] = String(allowRideMatchToJoinedGroups)
            params[Ride.FLD_SHOW_ME_TO_JOINED_GRPS] = String(showMeToJoinedGroups)
        if pickupNote != nil {
            params[Ride.FLD_PICKUP_NOTE] = pickupNote
        }
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPADATE_PASSENGER_RIDE
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }

    public static func cancelPassengerRidesBulk(rideIds : String?, userId: String, targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("cancelPassengerRidesBulk() \(String(describing: rideIds)) \(userId)")
        let getPassengerUrl = baseServerUrl + PASSENGER_RIDES_CANCEL_SERVICE_PATH
        var params = [String : String]()
        params[Ride.FLD_ID] = rideIds
        params[Ride.FLD_USERID] = userId

        HttpUtils.putJSONRequestWithBody(url: getPassengerUrl, targetViewController: targetViewController, handler: completionHandler, body: params)
    }
}
