//
//  UserRouteGroupJoin.swift
//  Quickride
//
//  Created by QuickRideMac on 12/29/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol UserRouteGroupJoinReceiver
{
    func joinedRidePathGroup(joinedGroup : UserRouteGroup)
    func userJoinedThisGroupAlready()
}
class UserRouteGroupJoin{
    var ridePathGroupMember: UserRouteGroupMember?
    var joinedGroup : UserRouteGroup?
    var ridePathGroupJoinReceiver : UserRouteGroupJoinReceiver?
    static var isUserJoinedAlready : Bool = false


    static func groupJoin(foundGroup : UserRouteGroup, receiver : UserRouteGroupJoinReceiver)
    {
        let ridePathGroupMember : UserRouteGroupMember = createRidePathGroupMember(ridePathGroup: foundGroup)
        let userDataCache : UserDataCache = UserDataCache.getInstance()!
        
        isUserJoinedAlready = isUserJoinedGroupAlready(ridePathGroupMember: ridePathGroupMember);
        if(isUserJoinedAlready)
        {
            receiver.userJoinedThisGroupAlready()
            return
        }
        QuickRideProgressSpinner.startSpinner()

        UserRouteGroupServicesClient.addUserToGroup(body: ridePathGroupMember.getParams(), targetViewController : nil,completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{

                let joinedGroup = Mapper<UserRouteGroup>().map(JSONObject: responseObject!["resultData"])
                userDataCache.addUserRidePathGroup(ridePathGroup: joinedGroup!)
                receiver.joinedRidePathGroup(joinedGroup: joinedGroup!)
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
            }
        })
    
    }
    static func createRidePathGroupMember(ridePathGroup : UserRouteGroup) -> UserRouteGroupMember
    {
        let ridePathGroupMember : UserRouteGroupMember = UserRouteGroupMember()
        ridePathGroupMember.groupId = ridePathGroup.id
        ridePathGroupMember.groupName = ridePathGroup.groupName
        ridePathGroupMember.memberType = UserRouteGroupMember.MEMBER_TYPE_MEMBER
        ridePathGroupMember.userId = Double(QRSessionManager.getInstance()!.getUserId())
        return ridePathGroupMember
    }
    
    static func isUserJoinedGroupAlready(ridePathGroupMember : UserRouteGroupMember) -> Bool
    {
        let userDataCache : UserDataCache = UserDataCache.getInstance()!
        let joinedGroups : [UserRouteGroup] = userDataCache.getUserRouteGroups()
        if(joinedGroups.isEmpty)
        {
            return false
        }
        else
        {
            for group in joinedGroups
            {
                if (group.id == ridePathGroupMember.id)
                {
                    return true
                }
            }
        }
        return false
    }

}
