//
//  GroupExitTask.swift
//  Quickride
//
//  Created by QuickRideMac on 7/19/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias groupExitCompletionHandler = (_ error: ResponseError?) -> Void

class GroupExitTask
{
    static func userRouteGroupExitingTask(userRouteGroup : UserRouteGroup,userId : String, viewController : UIViewController, completionHandler : @escaping groupExitCompletionHandler)
    {
        QuickRideProgressSpinner.startSpinner()
        UserRouteGroupServicesClient.exitFromGroup(groupId: userRouteGroup.id!, userId: userId, targetViewController: viewController, completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if UserDataCache.getInstance() != nil
                {
                    UserDataCache.getInstance()!.deleteUserRidePathGroup(ridePathGroup: userRouteGroup)
                    completionHandler(nil)
                }
            }else
            {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })

    }
}
