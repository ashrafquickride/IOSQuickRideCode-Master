//
//  OfflineConversationMessageHandler.swift
//  Quickride
//
//  Created by KNM Rao on 21/01/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class OfflineConversationMessageHandler: NotificationHandler {
  override func handleTap(userNotification: UserNotification,viewController : UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("\(String(describing: userNotification.msgObjectJson))")
    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    let chatVC = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
    let userBasicInfo = Mapper<UserBasicInfo>().map(JSONString: userNotification.msgObjectJson!)
    if userBasicInfo != nil{

        chatVC.initializeDataBeforePresentingView(ride: nil, userId: userBasicInfo?.userId ?? 0,isRideStarted : false, listener: nil)
        DispatchQueue.main.async {
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: chatVC, animated: false)
      }
    }
  }
  override func getNotificationAudioFilePath() -> String? {
    AppDelegate.getAppDelegate().log.debug("")
    return Bundle.main.path(forResource: "notification_sound_low", ofType: "mp3")
  }
  override func isUserEnabledThisNotification() -> Bool{
    if UserDataCache.getInstance() == nil{
      return false
    }
    let notificationSettings = UserDataCache.getInstance()!.getLoggedInUserNotificationSettings()
    return notificationSettings.conversationMessages
  }
}
