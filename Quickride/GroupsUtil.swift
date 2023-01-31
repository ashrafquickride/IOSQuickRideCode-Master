//
//  GroupsUtil.swift
//  Quickride
//
//  Created by QuickRideMac on 12/21/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class GroupsUtil {
    
    static func filterMyGroupsAndSuggestedGroups(suggestedRidePathGroups : [UserRouteGroup], myGroups : [UserRouteGroup]) -> [UserRouteGroup]

    {
        var finalRidePathGroups : [UserRouteGroup] = [UserRouteGroup]();
        if(!suggestedRidePathGroups.isEmpty)
        {
            for ridePathGroup in suggestedRidePathGroups
            {
                var isExisted : Bool = false
                for myGroup in myGroups
                {
                    if ridePathGroup.id == myGroup.id
                    {
                        isExisted = true
                        break
                    }
                    else
                    {
                        continue
                    }
                }
                if(!isExisted)
                {
                    finalRidePathGroups.append(ridePathGroup)
                }
            }
            return finalRidePathGroups
        }
        return finalRidePathGroups
    }
    
    static func isApplicableForSuggesting(userRouteGroup : UserRouteGroup, fromLatitude : Double, fromLongitude : Double, toLatitude : Double, toLongitude : Double) -> Bool
    {
        let configurationCache : ConfigurationCache? = ConfigurationCache.getInstance()
        let clientConfiguration : ClientConfigurtion?
        if(configurationCache == nil)
        {
            clientConfiguration = ClientConfigurtion()
        }
        else
        {
            clientConfiguration = configurationCache!.getClientConfiguration()
        }
        var distFromAddress : Double = 0
        if(fromLatitude != 0 && fromLongitude != 0)
        {
            distFromAddress = LocationClientUtils.getDistance(fromLatitude: fromLatitude,
                                                              fromLongitude: fromLongitude, toLatitude: userRouteGroup.fromLocationLatitude!, toLongitude: userRouteGroup.fromLocationLongitude!)
        }
        var distToAddress : Double = 0;
        if(toLatitude != 0 && toLongitude != 0)
        {
            distToAddress = LocationClientUtils.getDistance(fromLatitude: toLatitude,
                                                            fromLongitude: toLongitude, toLatitude: userRouteGroup.toLocationLatitude!, toLongitude: userRouteGroup.toLocationLongitude!)
        }
        
        if(distFromAddress <= (clientConfiguration?.groupMatchingThreshold)! && distToAddress <= (clientConfiguration?.groupMatchingThreshold)!)
        {
            return true
        }
        return false
    }
    static func checkWhetherHomeLocation(locationNmae : String) -> Bool{
        if UserFavouriteLocation.HOME_FAVOURITE.caseInsensitiveCompare(locationNmae) == ComparisonResult.orderedSame{
            return true
        }
        else
        {
            return false
        }
    }
    
    static func checkWhetherOfficeLocation(locationNmae : String) -> Bool
    {
        if UserFavouriteLocation.OFFICE_FAVOURITE.caseInsensitiveCompare(locationNmae) == ComparisonResult.orderedSame
        {
            return true
        }
        else
        {
            return false
        }
    }

}
