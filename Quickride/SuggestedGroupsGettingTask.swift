//
//  SuggestedGroupsGettingTask.swift
//  Quickride
//
//  Created by QuickRideMac on 7/7/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol SuggestedGroupsReceiver
{
    func receivedSuggestedGroups(suggestedRidePathGroups : [UserRouteGroup]?)
}

class SuggestedGroupsGettingTask
{
    static func suggestedUserRouteGroupsGettingTask(homeLoc : Location?,ofcLoc : Location?,receiver : SuggestedGroupsReceiver, viewController : UIViewController)
    {

        UserRouteGroupServicesClient.getAllSuggestedGroups(homeLocation: homeLoc,officeLocation: ofcLoc, appName: AppConfiguration.APP_NAME,completionHandler: { (responseObject, error) in
            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let suggestedRidePathGroups = Mapper<UserRouteGroup>().mapArray(JSONObject: responseObject!["resultData"])
                    receiver.receivedSuggestedGroups(suggestedRidePathGroups: suggestedRidePathGroups)
             }
            else
            {
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: viewController, handler: nil)
            }
        })
    }
}
