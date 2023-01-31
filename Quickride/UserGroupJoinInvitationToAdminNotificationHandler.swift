//
//  UserGroupJoinInvitationToAdminNotificationHandler.swift
//  Quickride
//
//  Created by rakesh on 3/15/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserGroupJoinInvitationToAdminNotificationHandler : NotificationHandler{
    
    var groupMember : GroupMember?
    var userNotification : UserNotification?
    var viewController : UIViewController?

    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        let iconURI = clientNotification.iconUri
        if iconURI == nil{
            imageView.image = UIImage(named : "group_circle")
        }else{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI!, placeHolderImg: UIImage(named : "group_circle"),imageSize: ImageCache.DIMENTION_TINY)
        }
    }

    override func handleNewUserNotification(clientNotification: UserNotification) {
        
        let groupMember = Mapper<GroupMember>().map(JSONString: clientNotification.msgObjectJson!)
         groupMember!.status = GroupMember.MEMBER_STATUS_PENDING
        UserDataCache.getInstance()!.addMemberToGrp(groupId: groupMember!.groupId , groupMember: groupMember!)
        super.handleNewUserNotification(clientNotification: clientNotification)
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        
        self.userNotification = userNotification
        self.viewController = viewController
        let groupMember = Mapper<GroupMember>().map(JSONString: userNotification.msgObjectJson!)
        groupMember!.status = GroupMember.MEMBER_STATUS_CONFIRMED
        addMemberToGroup(groupMember: groupMember!)
    }
    
    func addMemberToGroup(groupMember : GroupMember){
       
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.addMembersToGroup(groupMember: groupMember, viewController: self.viewController,handler:{ (responseObject, error) in
          QuickRideProgressSpinner.stopSpinner()
          if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
               let groupMember = Mapper<GroupMember>().map(JSONObject: responseObject!["resultData"])
            UserDataCache.getInstance()!.updateUserGroupMember(groupMember: groupMember!)
            super.handlePositiveAction(userNotification: self.userNotification!, viewController: self.viewController)
          }else{
             ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
           }
        })
    }
    
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        
        self.userNotification = userNotification
        self.viewController = viewController
        let groupMember = Mapper<GroupMember>().map(JSONString: userNotification.msgObjectJson!)
        groupMember!.status = GroupMember.MEMBER_STATUS_REJECTED
        rejectGroupMembership(groupMember: groupMember!)
    }
    
    func rejectGroupMembership(groupMember : GroupMember){
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.rejectGroupMembership(groupMember: groupMember, viewController: self.viewController,handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
             UserDataCache.getInstance()!.deleteMemberFromGroup(groupId: groupMember.groupId, groupMember: groupMember)
             super.handleNegativeAction(userNotification: self.userNotification!, viewController: self.viewController)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        })
    }
    
    override func handleNeutralAction(userNotification: UserNotification, viewController: UIViewController?) {
        moveToGroups()
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        moveToGroups()
    }
    
    func moveToGroups(){
       let groupsViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myGroupsViewController)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: groupsViewController, animated: false)
    }
 
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.ACCEPT
    }
    
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.REJECT
    }
    
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.VIEW
    }
    


}
