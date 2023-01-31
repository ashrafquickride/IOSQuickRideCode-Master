//
//  RoutesAsyncTask.swift
//  Quickride
//
//  Created by KNM Rao on 22/11/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class UserFavouriteRouteTask :RouteReceiver {
  
  
  static let ROUTE_NOT_FOUND_BETWEEN_HOME_AND_OFFICE = 7004
  var homeLocation: UserFavouriteLocation?
  var officeLocation: UserFavouriteLocation?
  
  init(homeLocation:UserFavouriteLocation,officeLocation:UserFavouriteLocation){
    self.homeLocation = homeLocation
    self.officeLocation = officeLocation
  }
  
  func getRoutesBetweenHomeAndOfficeLocation(){
    
    AppDelegate.getAppDelegate().log.debug("getRoutesBetweenHomeAndOfficeLocation()")
    
    //home to office
    MyRoutesCache.getInstance()?.getUserRoutes(useCase: "iOS.App.User.HomeToOffice.SessionInitialization",rideId: 0, startLatitude: homeLocation?.latitude ?? 0, startLongitude: homeLocation?.longitude ?? 0, endLatitude: officeLocation?.latitude ?? 0, endLongitude: officeLocation?.longitude ?? 0, weightedRoutes: false, routeReceiver: self)
    //office to home
    MyRoutesCache.getInstance()?.getUserRoutes(useCase: "iOS.App.User.OfficeToHome.SessionInitialization",rideId: 0,startLatitude: officeLocation?.latitude ?? 0 , startLongitude: officeLocation?.longitude ?? 0, endLatitude: homeLocation?.latitude ?? 0, endLongitude: homeLocation?.longitude ?? 0, weightedRoutes: false, routeReceiver: self)
    }
    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
    
  }
  
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {
        if let object = responseObject,let responseError = Mapper<ResponseError>().map(JSONObject: object["resultData"]),responseError.errorCode == UserFavouriteRouteTask.ROUTE_NOT_FOUND_BETWEEN_HOME_AND_OFFICE{
            UIApplication.shared.keyWindow?.makeToast(Strings.route_not_found_error)
            deleteHomeLocation()
            deleteOfficeLocation()
        }
    }
    
    func deleteHomeLocation(){
        UserRestClient.deleteFavouriteLocations(id: homeLocation?.locationId ?? 0, viewController: ViewControllerUtils.getCenterViewController(), completionHandler: { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: self.homeLocation!)
                SharedPreferenceHelper.storeHomeLocation(homeLocation: nil)
            }
        })
    }
    
    func deleteOfficeLocation(){
        UserRestClient.deleteFavouriteLocations(id: officeLocation?.locationId ?? 0, viewController: ViewControllerUtils.getCenterViewController(), completionHandler: { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: self.officeLocation!)
                SharedPreferenceHelper.storeOfficeLocation(officeLocation: nil)
            }
        })
    }
}
