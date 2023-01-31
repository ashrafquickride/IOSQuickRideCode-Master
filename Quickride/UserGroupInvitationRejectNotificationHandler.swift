//
//  UserGroupInvitationRejectNotificationHandler.swift
//  Quickride
//
//  Created by rakesh on 3/16/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserGroupInvitationRejectNotificationHandler : NotificationHandler{
    
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        let iconURI = clientNotification.iconUri
        if iconURI == nil{
            imageView.image = UIImage(named : "group_circle")
        }else{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI!, placeHolderImg: UIImage(named : "group_circle"),imageSize: ImageCache.DIMENTION_TINY)
        }
    }
    
    override func handleNewUserNotification(clientNotification: UserNotification) {
        
        let group = Mapper<Group>().map(JSONString: clientNotification.msgObjectJson!)
        UserDataCache.getInstance()!.deleteGroupFromList(groupId: group!.id)
        super.handleNewUserNotification(clientNotification: clientNotification)
   
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    
    
}
