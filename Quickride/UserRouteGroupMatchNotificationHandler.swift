//
//  UserRouteGroupMatchNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 25/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserRouteGroupMatchNotificationHandler: NotificationHandler, UserRouteGroupJoinReceiver {
    
    var userNotification : UserNotification?
    var viewController : UIViewController?

    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid : Bool) -> Void) {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid{
                return handler(valid)
            }
            guard let userRouteGroup = Mapper<UserRouteGroup>().map(JSONString: clientNotification.msgObjectJson!) else {
                return handler(false)
            }
            guard let existedGroups = UserDataCache.getInstance()?.getUserRouteGroups(), !existedGroups.isEmpty else {
                 return handler(true)
             }
            let found = existedGroups.first { group in
               return group.id == userRouteGroup.id
            }
            return handler(found == nil)
        }
        
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
       AppDelegate.getAppDelegate().log.debug("handleTap()")
        super.handleTap(userNotification: userNotification, viewController: viewController)
        self.userNotification = userNotification
        self.viewController = viewController
        let userRouteGroup = Mapper<UserRouteGroup>().map(JSONString: userNotification.msgObjectJson!)
        navigateToGroupViewActivity(userRouteGroup: userRouteGroup!)
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
        let userRouteGroup = Mapper<UserRouteGroup>().map(JSONString: userNotification.msgObjectJson!)
        UserRouteGroupJoin.groupJoin(foundGroup: userRouteGroup!, receiver: self)
    }
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
    }
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
      AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.join
    }
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.ignore
    }
    private func navigateToGroupViewActivity(userRouteGroup : UserRouteGroup)
    {
        let userRouteGroupCreateVC : UserRouteGroupCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserRouteGroupCreationViewController") as! UserRouteGroupCreationViewController
        userRouteGroupCreateVC.initializeDataBeforePresenting(selectedUserRouteGroup : userRouteGroup, enableJoinOption: true, isDisplayMode: true, isFromRideView: false, fromLocation: nil, toLocation: nil, rideId: nil, rideType: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: userRouteGroupCreateVC, animated: false)

    }
    
    func joinedRidePathGroup(joinedGroup : UserRouteGroup)
    {
        if self.userNotification != nil{
         super.handlePositiveAction(userNotification: self.userNotification!, viewController: self.viewController)
        }
        UIApplication.shared.keyWindow?.makeToast( String(format: Strings.route_group_join_message, arguments: [joinedGroup.groupName!]))
    }
    func userJoinedThisGroupAlready()
    {
        UIApplication.shared.keyWindow?.makeToast( Strings.user_joined_group)
    }
}
