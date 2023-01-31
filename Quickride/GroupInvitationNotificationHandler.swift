//
//  GroupInvitationNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 7/20/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class GroupInvitationNotificationHandler : RideDirectInviteNotificationHandler {
    
    override func handleNeutralAction(userNotification: UserNotification, viewController: UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("")
        if UserNotification.NOT_TYPE_RM_GROUP_INVITATION == userNotification.type {
            unJoinUserFromGroup(userNotification: userNotification)
        }
        super.handleNeutralAction(userNotification: userNotification,viewController : viewController)
    }
    override func getNegativeActionNameWhenApplicable(userNotification : UserNotification) -> String?{
            return nil
    }
    override func getPositiveActionNameWhenApplicable(userNotification : UserNotification) -> String?{
            return Strings.VIEW
     }
    
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String?
    {
            return Strings.exit_group
    }

    func  unJoinUserFromGroup(userNotification : UserNotification)
    {
        let selectedGroup : UserRouteGroup? = getUserRouteGroup(groupId: Double(userNotification.groupValue!)!)
        if(selectedGroup == nil)
        {
            NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
            return
        }
        
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: String(format: Strings.exit_group_confirm, arguments: [selectedGroup!.groupName!]), message2: nil, positiveActnTitle: Strings.no_caps,negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: ViewControllerUtils.getCenterViewController(), handler: { (result) in
            if Strings.yes_caps == result{
                GroupExitTask.userRouteGroupExitingTask(userRouteGroup: selectedGroup!, userId: QRSessionManager.getInstance()!.getUserId(), viewController: ViewControllerUtils.getCenterViewController(), completionHandler: { (error) -> Void in
                    if error == nil{
                        NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
                        UIApplication.shared.keyWindow?.makeToast( String(format: Strings.exit_group_success, arguments: [selectedGroup!.groupName!]))
                    }
                })
            }
        })
        
    }
    
    func getUserRouteGroup(groupId : Double) -> UserRouteGroup?
    {
        let userRouteGroups : [UserRouteGroup] = UserDataCache.getInstance()!.getUserRouteGroups()
        var selectedUserRouteGroup : UserRouteGroup?
        if !userRouteGroups.isEmpty
        {
            for userRouteGroup in userRouteGroups
            {
                if(userRouteGroup.id == groupId)
                {
                    selectedUserRouteGroup = userRouteGroup
                    break
                }
            }
        }
        return selectedUserRouteGroup
    }
}
