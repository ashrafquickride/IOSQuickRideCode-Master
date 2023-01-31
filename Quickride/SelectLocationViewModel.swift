//
//  SelectLocationViewModel.swift
//  Quickride
//
//  Created by Ashutos on 20/01/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation

class SelectLocationViewModel {
    var ride: Ride?
    var favouriteLocations = [Location]()
    var predictedPlaces : [Location] = [Location]()
    var recentLocations = [Location]()
    var customizedRoutes = [UserPreferredRoute]()
    var allRecentLocations : [Location]?
    var triggeredTime : DispatchTime = .now()
    var readFromGoogle = false
    var currentSearchText: String?
    var textFieldTag = 1
    var locationSelected = Location()
    var isKeyboardVisible = false
    var selectedPreferedRoute: UserPreferredRoute?
    var isSearchStarted: Bool = false
    
    init(ride: Ride?) {
        self.ride = ride
        locationSelected.address = ride?.startAddress
        locationSelected.latitude = ride?.startLatitude ?? 0.0
        locationSelected.longitude = ride?.startLongitude ?? 0.0
    }
    
    func getRecentlocation() {
        
        allRecentLocations = getLocationsFromRecentLocations()
        if allRecentLocations != nil{
            recentLocations = []
            for recentLocation in allRecentLocations!{
                if recentLocations.count == 5{
                    break
                }
                recentLocations.append(recentLocation)
            }
        }
    }
    
    private func getLocationsFromRecentLocations() -> [Location] {
        if allRecentLocations != nil{
            return allRecentLocations!
        }
        var recents : [UserRecentLocation]?
        if UserDataCache.getInstance() != nil{
            recents = UserDataCache.getInstance()?.getRecentLocations()
        } else {
            recents = UserCoreDataHelper.getuserRecentLocationObject()
        }
        allRecentLocations = [Location]()
        if recents != nil{
            recents!.sort(by: {$0.time > $1.time})
            for recentLocation in recents!{
                let location = Location(latitude: recentLocation.latitude!,longitude: recentLocation.longitude!, shortAddress: recentLocation.recentAddressName, completeAddress: recentLocation.recentAddress, placeId: nil, locationType: Location.RECENT_LOCATION, country: recentLocation.country, state: recentLocation.state, city: recentLocation.city, areaName: recentLocation.areaName, streetName: recentLocation.streetName)
                location.name = recentLocation.recentAddressName
                allRecentLocations!.append(location)
            }
        }
        return allRecentLocations!
    }
    
    func getFavoriteLocation() {
        let favourites = UserDataCache.getInstance()?.getFavoriteLocations()
        if favourites != nil{
            favouriteLocations = []
            for favouriteLocation in favourites!{
                let location = Location(latitude: favouriteLocation.latitude!,longitude: favouriteLocation.longitude!, shortAddress: favouriteLocation.address, completeAddress: favouriteLocation.address, placeId: nil, locationType: Location.FAVOURITE_LOCATION, country: favouriteLocation.country, state: favouriteLocation.state, city: favouriteLocation.city, areaName: favouriteLocation.areaName, streetName: favouriteLocation.streetName)
                location.name = favouriteLocation.name
                favouriteLocations.append(location)
            }
        }
    }
    
    func getPreferedLocation() {
        if customizedRoutes.count != 0 {
            customizedRoutes = []
        }
        for preferredRoute in MyRoutesCachePersistenceHelper.getUserPreferredRoutes(){
            if preferredRoute.routeName != nil{
                customizedRoutes.append(preferredRoute)
            }
        }
    }
    
    func validLocationSelection(ride : Ride, fromLocation : String?, toLocation : String?, VC: UIViewController) -> Bool{
        if RideValidationUtils.validateDestinationLocation(ride: ride,locationName: toLocation!) == false{
            
            UIApplication.shared.keyWindow?.makeToast(message: Strings.destinationLocationNotAvailable, duration: 3.0, position: CGPoint(x: VC.view.frame.size.width/2, y: VC.view.frame.size.height-300))
            return true
        }
        if RideValidationUtils.validateSourceLocation(ride: ride, locationName: fromLocation!) == false{
            
            UIApplication.shared.keyWindow?.makeToast(message: Strings.sourceLocationNotAvailable, duration: 3.0, position: CGPoint(x: VC.view.frame.size.width/2, y: VC.view.frame.size.height-300))
            return true
        }
        if RideValidationUtils.isStartAndEndAddressAreSame(ride: ride){
            
            UIApplication.shared.keyWindow?.makeToast(message: Strings.startAndEndAddressNeedToBeDiff, duration: 3.0, position: CGPoint(x: VC.view.frame.size.width/2, y: VC.view.frame.size.height-300))
            return true
        }
        return false
    }
}
