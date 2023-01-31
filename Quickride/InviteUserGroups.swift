//
//  InviteUserGroups.swift
//  Quickride
//
//  Created by rakesh on 3/23/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper

protocol OnGroupMemberInviteListener{
    func groupMembersInviteCompleted()
}

class InviteUserGroups{
    
    static let accountUtils = AccountUtils()
    static func inviteUserGroupstask(selectedGroups : [Group]?, rideId : Double, rideType : String, receiver : OnGroupInviteListener, viewController : UIViewController){
        if (selectedGroups == nil || selectedGroups!.isEmpty)
        {
            return
        }
        var selectedGroupIds = [Double]()
        for userGroup in selectedGroups!
        {
            let filteredMembers = userGroup.removeCurrentUserAndPendingMembers()
           if filteredMembers.count > 0
            {
                selectedGroupIds.append(userGroup.id)
            }
        }
        
        let theJSONData = try? JSONSerialization.data(
            withJSONObject: selectedGroupIds ,
            options: JSONSerialization.WritingOptions(rawValue: 0))
        
        
        let jsonString = NSString(data: theJSONData!,
                                  encoding: String.Encoding.ascii.rawValue)
        if jsonString == nil
        {
            return
        }
        accountUtils.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: viewController, handler: {(result) in
            if result == .success {
                if (!selectedGroupIds.isEmpty)
                {
                    QuickRideProgressSpinner.startSpinner()
                    GroupRestClient.sendInviteToSelectedGroup(rideId: rideId, rideType: rideType, selectedGroupIds: jsonString! as String, viewController: viewController, handler: { (responseObject, error) in
                        QuickRideProgressSpinner.stopSpinner()
                        if(responseObject == nil){
                            ErrorProcessUtils.handleError(responseObject: responseObject, error : error,viewController: viewController, handler: nil)
                            return
                        }
                        else if(responseObject!["result"] as! String == "FAILURE"){
                            let error : ResponseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])!
                            UIApplication.shared.keyWindow?.makeToast( "\(Strings.invite_failed) , \(error.userMessage!)")
                            
                        }else if(responseObject!["result"] as! String == "SUCCESS"){
                            var invitedGroups = SharedPreferenceHelper.getInvitedGroupsIds(rideId: rideId)
                            invitedGroups.append(selectedGroups?[0].id ?? 0)
                            SharedPreferenceHelper.storeInvitedGroupIds(rideId: rideId, groupIds: invitedGroups)
                            receiver.groupInviteCompleted()
                        }
                    })
                }
            }else if result == .addPayment {
                showPaymentDrawer(selectedGroups: selectedGroups, rideId: rideId, rideType: rideType, userIds: nil, groupId: nil, onGroupInviteListener: receiver, onGroupMemberInviteListener: nil, viewController: viewController)
            }
        })
    }
    
    static func inviteSelectedUserOfGroupTask(rideId : Double, rideType : String, userIds : [Double], groupId : Double, receiver : OnGroupMemberInviteListener, viewController : UIViewController)
    {
        if (userIds.isEmpty)
        {
            return
        }
        let theJSONData = try? JSONSerialization.data(
            withJSONObject: userIds ,
            options: JSONSerialization.WritingOptions(rawValue: 0))
        
        
        let jsonString = NSString(data: theJSONData!,
                                  encoding: String.Encoding.ascii.rawValue)
        if jsonString == nil
        {
            return
        }
        accountUtils.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: viewController, handler: {(result) in
            if result == .success {
                QuickRideProgressSpinner.startSpinner()
                GroupRestClient.sendInvitationToSelectedUserOfGroup(rideId: rideId, rideType: rideType, userIds: jsonString! as String, groupId: groupId, viewController: viewController,handler: { (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if(responseObject!["result"] as! String == "SUCCESS"){
                        receiver.groupMembersInviteCompleted()
                    }
                    else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error : error,viewController: viewController, handler: nil)
                    }
                })
            }else if result == .addPayment {
                showPaymentDrawer(selectedGroups: nil, rideId: rideId, rideType: rideType, userIds: userIds, groupId: groupId, onGroupInviteListener: nil, onGroupMemberInviteListener: receiver, viewController: viewController)
            }
        })
        
    }
    
    static func showPaymentDrawer(selectedGroups : [Group]?, rideId : Double, rideType : String, userIds : [Double]?, groupId : Double?, onGroupInviteListener : OnGroupInviteListener?, onGroupMemberInviteListener: OnGroupMemberInviteListener?, viewController : UIViewController){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: true) {(data) in
            if data == .selected || data == .makeDefault {
                if let userIds = userIds, let onGroupMemberInviteListener = onGroupMemberInviteListener  {
                    inviteSelectedUserOfGroupTask(rideId: rideId, rideType: rideType, userIds: userIds, groupId: groupId ?? 0, receiver: onGroupMemberInviteListener, viewController: viewController)
                }else if let selectedGroups = selectedGroups, let onGroupInviteListener = onGroupInviteListener {
                    inviteUserGroupstask(selectedGroups: selectedGroups, rideId: rideId, rideType: rideType, receiver: onGroupInviteListener, viewController: viewController)
                }
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
}
