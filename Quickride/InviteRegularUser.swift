//
//  InviteRegularUser.swift
//  Quickride
//
//  Created by QuickRideMac on 20/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
class InviteRegularUser {
    
    var matchedRegularUser : MatchedRegularUser
    var viewController :UIViewController
    
    init(matchedRegularUser :MatchedRegularUser,viewController :UIViewController){
        self.matchedRegularUser = matchedRegularUser
        self.viewController  = viewController
    }
    func fillPickUpAndDropLocationsIfRequiredAndInvite(){
        AppDelegate.getAppDelegate().log.debug("fillPickUpAndDropLocationsIfRequiredAndInvite()")
        
        QuickRideProgressSpinner.startSpinner()
        let dispatchQueue = DispatchQueue.main
        var dispatchGroup :DispatchGroup? = DispatchGroup()
        
        dispatchGroup?.enter()
        dispatchQueue.async(group: dispatchGroup) {
            if self.matchedRegularUser.pickupLocationAddress != nil && self.matchedRegularUser.pickupLocationAddress!.isEmpty == false{
                guard let  dG = dispatchGroup else {
                    return
                }
                dG.leave()
            }else{
                LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.pickup.InviteRegularUser", coordinate: CLLocationCoordinate2D(latitude: self.matchedRegularUser.pickupLocationLatitude!, longitude: self.matchedRegularUser.pickupLocationLongitude!), handler: { (location,error) -> Void in

                    if location != nil{
                        self.matchedRegularUser.pickupLocationAddress = location!.shortAddress
                    }else{
                        self.matchedRegularUser.pickupLocationAddress = ""
                    }
                    
                    guard let  dG = dispatchGroup else {
                        return
                    }
                    dG.leave()
                })
            }
        }
        dispatchGroup?.enter()
        dispatchQueue.async(group: dispatchGroup) {
            if self.matchedRegularUser.dropLocationAddress != nil && self.matchedRegularUser.dropLocationAddress!.isEmpty == false{
                guard let  dG = dispatchGroup else {
                    return
                }
                dG.leave()
            }else{
                LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.drop.InviteRegularUser", coordinate: CLLocationCoordinate2D(latitude: self.matchedRegularUser.dropLocationLatitude!, longitude: self.matchedRegularUser.dropLocationLongitude!), handler: { (location,error) -> Void in

                    if location != nil{
                        self.matchedRegularUser.dropLocationAddress = location!.shortAddress
                        
                    }else{
                        self.matchedRegularUser.dropLocationAddress = ""
                        
                    }
                    guard let  dG = dispatchGroup else {
                        return
                    }
                    dG.leave()
                })
            }
        }
        dispatchGroup?.notify(queue: dispatchQueue) {
            dispatchGroup = nil
            self.completeInvite()
            
        }
        
    }
    func completeInvite(){
        
    }
}
