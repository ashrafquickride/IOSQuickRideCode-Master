//
//  OfflineChatMessageNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class OfflineChatMessageNotificationHandler : NotificationHandler{
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty, let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance(), let riderRideId = Double(groupValue) else {
                return handler(false)
            }
            
            if let _ = myActiveRidesCache.getPassengerRideByRiderRideId(riderRideId: riderRideId) {
                return handler(true)
            }else if let _ = myActiveRidesCache.getRiderRide(rideId: riderRideId){
                return handler(true)
            }
            return handler(false)
        }
    }

    override func handleTap(userNotification: UserNotification,viewController : UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("")
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
      if RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller != nil{
        RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller?.dismiss(animated: false, completion: { 
          self.displayGroupChatViewController(userNotification: userNotification)
        })                                 
      }else{
        self.displayGroupChatViewController(userNotification: userNotification)
      }
    }
  func displayGroupChatViewController(userNotification : UserNotification){
    AppDelegate.getAppDelegate().log.debug("\(String(describing: userNotification.msgObjectJson))")
    guard let riderRideIdStr = userNotification.groupValue, let riderRideId = Double(riderRideIdStr) else { return }
    let chatVC = UIStoryboard(name: StoryBoardIdentifiers.group_chat_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
    chatVC.initailizeGroupChatView(riderRideID: riderRideId, isFromCentralChat: false)
    if Thread.isMainThread == true{
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: chatVC, animated: false)
    }else{
      DispatchQueue.main.async(){
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: chatVC, animated: false)
      }
    }
  }
    public override func getNotificationAudioFilePath() -> String? {
      AppDelegate.getAppDelegate().log.debug("")
        return Bundle.main.path(forResource: "notification_sound_low", ofType: "mp3")
    }
    public override func isUserEnabledThisNotification() -> Bool{
        let notificationSettings = UserDataCache.getInstance()!.getLoggedInUserNotificationSettings()
        return notificationSettings.conversationMessages
    }
}
