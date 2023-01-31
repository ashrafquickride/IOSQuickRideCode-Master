//
//  UserGroupMemberRemoveNotificationHandler.swift
//  Quickride
//
//  Created by rakesh on 3/16/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserGroupMemberRemoveNotificationHandler : NotificationHandler{
    
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
    
    override func handleNewUserNotification(clientNotification: UserNotification) {
        
        let group = Mapper<Group>().map(JSONString: clientNotification.msgObjectJson!)
        UserDataCache.getInstance()!.deleteGroupFromList(groupId: group!.id)
        super.handleNewUserNotification(clientNotification: clientNotification)
        
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
          let myGroupsViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "MyGroupsViewController") as! MyGroupsViewController
          ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: myGroupsViewController, animated: false)
        super.handleTap(userNotification: userNotification, viewController: viewController)
    }

}
