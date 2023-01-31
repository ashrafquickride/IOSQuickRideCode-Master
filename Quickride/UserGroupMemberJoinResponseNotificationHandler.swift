//
//  UserGroupMemberJoinResponseNotificationHandler.swift
//  Quickride
//
//  Created by rakesh on 3/16/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserGroupMemberJoinResponseNotificationHandler : NotificationHandler{
    
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        let iconURI = clientNotification.iconUri
        if iconURI == nil{
            imageView.image = UIImage(named : "group_circle")
        }else{
            ImageCache.getInstance().getImageFromCache(imageUrl: iconURI!, imageSize: ImageCache.DIMENTION_TINY, handler: { (image, imageURI) in
                if image != nil{
                    imageView.image = image!.circle
                }else{
                    imageView.image = UIImage(named : "group_circle")
                }
            })
        }
    }
    
    override func handleNewUserNotification(clientNotification: UserNotification)
    {
        let group = Mapper<Group>().map(JSONString: clientNotification.msgObjectJson!)
        group!.currentUserStatus = GroupMember.MEMBER_STATUS_CONFIRMED
        UserDataCache.getInstance()!.addOrUpdateGroup(newGroup: group!)
        super.handleNewUserNotification(clientNotification: clientNotification)

    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        let group = Mapper<Group>().map(JSONString: userNotification.msgObjectJson!)
        if group == nil {
            return
        }
        group?.currentUserStatus = GroupMember.MEMBER_STATUS_CONFIRMED
        let groupInformationViewController =  UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupInformationViewController") as! GroupInformationViewController
        groupInformationViewController.initializeDataBeforePresenting(group: group)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: groupInformationViewController, animated: false)
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
 
}
