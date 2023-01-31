//
//  OfflineGroupConversationMessageNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 3/20/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class OfflineGroupConversationMessageNotificationHandler : NotificationHandler {
    override func handleTap(userNotification: UserNotification,viewController : UIViewController?) {
        
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        self.displayGroupChatViewController(userNotification: userNotification)
    }
    func displayGroupChatViewController(userNotification : UserNotification){
        
        let message = Mapper<GroupConversationMessage>().map(JSONString: userNotification.msgObjectJson!)
        if message == nil{
            return
        }
        let group = UserDataCache.getInstance()?.getGroupWithGroupId(groupId: message!.groupId)
        if group == nil{
            return
        }
        let chatVC = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserGroupChatViewController") as! UserGroupChatViewController
        chatVC.initializeDataBeforePresenting(group: group!)
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: chatVC, animated: false)
    }
    public override func getNotificationAudioFilePath() -> String? {
        AppDelegate.getAppDelegate().log.debug("")
        return Bundle.main.path(forResource: "notification_sound_low", ofType: "mp3")
    }
}
