//
//  RemoveFavoriteLocationTask.swift
//  Quickride
//
//  Created by Vinutha on 4/18/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol RemoveFavouriteLocationReciever
{
    func favouriteLocationRemoved()
}
class RemoveFavoriteLocationTask{
   static func removeSelectedFavoriteLocation(favoriteLocation : UserFavouriteLocation, viewController: UIViewController, receiver : RemoveFavouriteLocationReciever) {
    AppDelegate.getAppDelegate().log.debug("")
    let favouriteLocationToDelete = favoriteLocation
    QuickRideProgressSpinner.startSpinner()
    UserRestClient.deleteFavouriteLocations(id: favouriteLocationToDelete.locationId!, viewController: viewController, completionHandler: { (responseObject, error) -> Void in
        QuickRideProgressSpinner.stopSpinner()
       if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            
            UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: favouriteLocationToDelete)
             receiver.favouriteLocationRemoved()
        }
       else{
            ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: viewController, handler: nil)
        }
    })
    
}
    
}
