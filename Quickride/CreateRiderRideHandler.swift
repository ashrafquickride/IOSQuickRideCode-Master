//
//  CreateRiderRideHandler.swift
//  Quickride
//
//  Created by QuickRide on 01/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public typealias createRiderRideCompletionHandler = (_ riderRide : RiderRide?, _ error: ResponseError?) -> Void

class CreateRiderRideHandler {
  var riderRideObj :RiderRide
  var rideRoute : RideRoute?
  var isFromInviteByContact: Bool?
  var targetViewController : UIViewController?
  static let RIDER_RIDE_UTC_SERVICE_PATH = "QRRiderRide/utc"

  init(ride : RiderRide,rideRoute : RideRoute?,isFromInviteByContact: Bool,targetViewController : UIViewController?){
    self.riderRideObj = ride
    self.rideRoute = rideRoute
    self.isFromInviteByContact = isFromInviteByContact
    self.targetViewController = targetViewController
  }
  func createRiderRide(handler : @escaping createRiderRideCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("createRiderRide()")
    let startTime :String = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: riderRideObj.startTime))
    
    let availableSeats = riderRideObj.availableSeats
    let startAddress = riderRideObj.startAddress
    let startLatitude = riderRideObj.startLatitude
    let userId = QRSessionManager.sharedInstance!.getUserId()
    let endLongitude = riderRideObj.endLongitude!
    let startLongitude = riderRideObj.startLongitude
    let farePerKm = riderRideObj.farePerKm
    let endLatitude = riderRideObj.endLatitude!
    let endAddress = riderRideObj.endAddress
    let vehicleModel = riderRideObj.vehicleModel
    
    
    var params = ["availableSeats":"\(availableSeats)",
                  "startAddress":"\(startAddress)",
                  "startLatitude":"\(startLatitude)",
                  "userId":"\(userId)",
                  "endLongitude":"\(endLongitude)",
                  "startLongitude":"\(startLongitude)",
                  "farePerKm":"\(farePerKm)",
                  "startTime":"\(startTime)",
                  "endLatitude":"\(endLatitude)",
                  "endAddress":"\(endAddress)",
                  "vehicleModel":"\(vehicleModel)",
                  "capacity":"\(riderRideObj.capacity)"
      
      ] as Dictionary<String, String>
    if rideRoute != nil{
      params[Ride.FLD_ROUTE] =   Mapper().toJSONString(rideRoute!)!
    }
    if riderRideObj.vehicleType != nil{
      params["vehicleType"] = riderRideObj.vehicleType!
    }else{
      params["vehicleType"] = Vehicle.VEHICLE_TYPE_CAR
    }
    if riderRideObj.vehicleNumber == nil || riderRideObj.vehicleNumber?.isEmpty == true{
      params["vehicleNumber"] = nil
    }else{
      params["vehicleNumber"] = riderRideObj.vehicleNumber!
    }
    if riderRideObj.promocode != nil{
      params[Ride.FLD_PROMOCODE] = riderRideObj.promocode!
    }
    if riderRideObj.additionalFacilities != nil{
      params["additionalFacilities"] = riderRideObj.additionalFacilities
    }
    if riderRideObj.makeAndCategory != nil{
      params["vehicleMakeAndCategory"] = riderRideObj.makeAndCategory
    }
    params["id"] = StringUtils.getStringFromDouble(decimalNumber: riderRideObj.vehicleId)
    if riderRideObj.vehicleImageURI != nil{
      
      params["imageURI"] = riderRideObj.vehicleImageURI!
    }
    params["riderHasHelmet"] = String(riderRideObj.riderHasHelmet)
    params[Ride.IS_FROM_INVITE_BY_CONTACT] = String(isFromInviteByContact!)
    
    let createRideUrl = (AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + CreateRiderRideHandler.RIDER_RIDE_UTC_SERVICE_PATH)
    QuickRideProgressSpinner.startSpinner()
    HttpUtils.postJSONRequestWithBody(url: createRideUrl, targetViewController: targetViewController, handler: { (responseObject, error) -> Void in
        QuickRideProgressSpinner.stopSpinner()
      if(responseObject != nil) && ((responseObject!.value(forKey: "result")! as! String) == "SUCCESS"){
        
        let riderRide:RiderRide? = Mapper<RiderRide>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as RiderRide
        MyActiveRidesCache.singleCacheInstance?.addNewRide(ride: riderRide!)
        UserDataCache.getInstance()?.setUserRecentRideType(rideType: Ride.RIDER_RIDE)
        self.activateBestMatchAlert(ride: riderRide)
        handler(riderRide!, nil)
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
