//
//  CreatePassengerRideHandler.swift
//  Quickride
//
//  Created by QuickRide on 01/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
public typealias PassengerRideCompletionHandler = (_ passengerRide : PassengerRide?, _ error: ResponseError?) -> Void
class CreatePassengerRideHandler {
    
    var ride :PassengerRide
    var rideRoute : RideRoute?
    var isFromInviteByContact: Bool?
    var targetViewController : UIViewController?
    static let PASSENGER_RIDE_UTC_RESOURCE_PATH = "QRPassengerRide/utc";
    var parentRideId: Double?
    var relayLegSeq: Int?

    init(ride : PassengerRide, rideRoute : RideRoute?, isFromInviteByContact: Bool, targetViewController : UIViewController?,parentRideId: Double?,relayLegSeq: Int?){
        self.ride = ride
        self.rideRoute = rideRoute
        self.isFromInviteByContact = isFromInviteByContact
        self.targetViewController = targetViewController
        self.parentRideId = parentRideId
        self.relayLegSeq = relayLegSeq
    }
    
    func createPassengerRide(handler : @escaping PassengerRideCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("createPassengerRide()")
        var params : [String : String] = [String : String]()
        params[Ride.FLD_STARTADDRESS] = ride.startAddress
        params[Ride.FLD_STARTLATITUDE] =  String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_USERID] = (QRSessionManager.sharedInstance?.getUserId())!
        params[Ride.FLD_ENDLATITUDE] = String(ride.endLatitude!)
        params[Ride.FLD_ENDLONGITUDE] = String(ride.endLongitude!)
        params[Ride.FLD_ENDADDRESS] = ride.endAddress
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_NO_OF_SEATS] = String(ride.noOfSeats)
      if ride.promocode != nil{
        params[Ride.FLD_PROMOCODE] = ride.promocode!
      }
      
        if rideRoute != nil{
           params[Ride.FLD_ROUTE] =   Mapper().toJSONString(rideRoute!)!
        }
        params[Ride.IS_FROM_INVITE_BY_CONTACT] = String(isFromInviteByContact!)
        
        if parentRideId != nil{
            params[Ride.parentRideId] = StringUtils.getStringFromDouble(decimalNumber: parentRideId)
        }
        if relayLegSeq != nil{
           params[Ride.relayLegSeq] = String(relayLegSeq!)
        }
        
        let createRideUrl = (AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + CreatePassengerRideHandler.PASSENGER_RIDE_UTC_RESOURCE_PATH)
        if parentRideId == nil{
            QuickRideProgressSpinner.startSpinner()
        }
        HttpUtils.postJSONRequestWithBody(url: createRideUrl, targetViewController: targetViewController,handler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
          
            if responseObject != nil &&
                responseObject!.value(forKey: "result")! as! String == "SUCCESS"{
                    let passengerRide = Mapper<PassengerRide>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as PassengerRide
                    MyActiveRidesCache.getRidesCacheInstance()?.addNewRide(ride: passengerRide)
                    UserDataCache.getInstance()?.setUserRecentRideType(rideType: Ride.PASSENGER_RIDE)
                self.activateBestMatchAlert(ride: passengerRide)
                    handler(passengerRide, nil)
                }
            else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                RideManagementUtils.handleRideCreationFailureException(errorResponse: responseError!, viewController: self.targetViewController!)
                
            }else{
                   ErrorProcessUtils.handleError(responseObject: responseObject,error: error , viewController: self.targetViewController, handler: nil)
                }
            }, body: params)
    }
    
    func activateBestMatchAlert(ride: Ride?){
        guard let ride = ride else { return }
        if SharedPreferenceHelper.getBestMatchAlertActivetdRides(routeId: ride.routeId ?? 0) == nil{
            let rideMatchAlertRegistration = RideMatchAlertRegistration(userId: ride.userId, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endLatitude: ride.endLatitude ?? 0, endLongitude: ride.endLongitude ?? 0, rideType: ride.rideType ?? "", rideStartTime: ride.startTime, routeId: Int(ride.routeId ?? 0),startAddr: ride.startAddress,endAddr: ride.endAddress,distance: ride.distance ?? 0)
            UserRestClient.updateBestMatchAlertRegistration(rideMatchAlertRegistration: rideMatchAlertRegistration, completionHandler: {(responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let rideMatchAlertRegistration = Mapper<RideMatchAlertRegistration>().map(JSONObject:responseObject!["resultData"])
                    SharedPreferenceHelper.storeBestMatchAlertActivetdRides(routeId: ride.routeId ?? 0, rideMatchAlertRegistration: rideMatchAlertRegistration)
                    let notificationSettings = UserDataCache.getInstance()?.getLoggedInUserNotificationSettings()
                    notificationSettings?.rideMatch = true
                    UserDataCache.getInstance()?.storeUserUserNotificationSetting(userId: QRSessionManager.getInstance()?.getUserId() ?? "",notificationSettings: notificationSettings)
                }
            })
        }
    }
}
