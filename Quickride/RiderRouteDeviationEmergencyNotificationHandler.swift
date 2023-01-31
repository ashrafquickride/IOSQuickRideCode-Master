//
//  RiderRouteDeviationEmergencyNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 13/04/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RiderRouteDeviationEmergencyNotificationHandler: NotificationHandler,EmergencyInitiator {
  var passengerRideId : String?
  static var ROUTE_DEVIATION_STATUS : String?
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification,handler : @escaping (_ valid : Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification){
            valid in
            if !valid{
                return handler(valid)
            }
            guard let msgObjectJson = clientNotification.msgObjectJson, !msgObjectJson.isEmpty, let passengerRideId = Double(msgObjectJson), let ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: passengerRideId) else {
                return handler(false)
            }
            
            handler(ride.status != Ride.RIDE_STATUS_REQUESTED)
            
        }
    }

  override func handleNewUserNotification(clientNotification: UserNotification) {
    //let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3*60 * Int64(NSEC_PER_SEC))
    let time = DispatchTime(uptimeNanoseconds: UInt64(3*60*Int64(NSEC_PER_SEC)))
    DispatchQueue.main.asyncAfter(deadline: time) {
        if RiderRouteDeviationEmergencyNotificationHandler.ROUTE_DEVIATION_STATUS == RideRoute.ROUTE_DEVIATION_REJECTED{
            return
        }
    //dispatch_after(time, DispatchQueue.main) {
      //}
      self.passengerRideId = clientNotification.msgObjectJson
      if self.passengerRideId == nil{
        return
      }
      let passenger = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: Double(self.passengerRideId!)!)
      if passenger != nil && passenger!.riderRideId != 0{
        self.checkForTheEmergencyContact(riderRideId: passenger!.riderRideId)
      }
      
    }
    super.handleNewUserNotification(clientNotification: clientNotification)
  }
  override func handleTap(userNotification: UserNotification, viewController: UIViewController?){
    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
  }
  override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
    
    passengerRideId = userNotification.msgObjectJson
    if passengerRideId == nil{
      return
    }
    RoutePathServiceClient.updateRouteDeviationToRideEngine(passengerRideId: Double(passengerRideId!)!, status: RideRoute.ROUTE_DEVIATION_REJECTED, viewController: ViewControllerUtils.getCenterViewController()) { (responseObject, error) in
      RiderRouteDeviationEmergencyNotificationHandler.ROUTE_DEVIATION_STATUS = RideRoute.ROUTE_DEVIATION_REJECTED
    }
    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
  }
  
  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    return Strings.deviation_accepted
  }
  
  
  func checkForTheEmergencyContact(riderRideId : Double){
    
    
    let emergencyContactNo = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().emergencyContact
    if emergencyContactNo == nil || emergencyContactNo!.isEmpty {
      
        self.initiateEmergency(riderRideId: riderRideId)
      }
  }
  
  override func getParams(notification: UserNotification) -> NSDictionary {
    var params = [String : String]()
    params[Ride.FLD_PASSENGERRIDEID] = notification.msgObjectJson
    return params as NSDictionary
  }
  
  
  func initiateEmergency(riderRideId :Double){
    
    AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: self)
    
    let emergencyService =  EmergencyService(viewController: ViewControllerUtils.getCenterViewController())
    
    let shareRidePath = ShareRidePath(viewController: ViewControllerUtils.getCenterViewController(), rideId: StringUtils.getStringFromDouble(decimalNumber: riderRideId))
    shareRidePath.prepareRideTrackCoreURL { (url) in
      emergencyService.startEmergency(urlToBeAttended: url)
    }
  }
  func emergencyCompleted() {
  
    AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: nil)
  }
}
