//
//  InviteRideGroups.swift
//  Quickride
//
//  Created by QuickRideMac on 7/12/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

import UIKit
import ObjectMapper

protocol OnGroupInviteListener
{
    func groupInviteCompleted()
}

class InviteRideGroups
{
    static let accountUtils = AccountUtils()
    static func inviteRideGroupstask(selectedGroups : [UserRouteGroup]?, rideId : Double, rideType : String, receiver : OnGroupInviteListener, viewController : UIViewController)
    {
        
        if (selectedGroups == nil || selectedGroups!.isEmpty)
        {
            return
        }
        var selectedGroupIds = [Double]()
        for userGroup in selectedGroups!
        {
            if userGroup.memberCount! > 0
            {
                selectedGroupIds.append(userGroup.id!)
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
                    RideMatcherServiceClient.sendInvitationToGroup(riderRideId: rideId, rideType: rideType, selectedGroupIds : jsonString! as String, viewController: viewController) { (responseObject, error) in
                        
                        QuickRideProgressSpinner.stopSpinner()
                        if(responseObject == nil){
                            ErrorProcessUtils.handleError(responseObject: responseObject, error : error,viewController: viewController, handler: nil)
                            return
                        }
                        else if(responseObject!["result"] as! String == "FAILURE"){
                            let error : ResponseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])!
                            UIApplication.shared.keyWindow?.makeToast( "\(Strings.invite_failed) , \(error.userMessage!)")
                            
                        }else if(responseObject!["result"] as! String == "SUCCESS"){
                            
                            receiver.groupInviteCompleted()
                        }
                    }
                }
            }else if result == .addPayment {
                self.showPaymentDrawer(selectedGroups: selectedGroups, rideId: rideId, rideType: rideType, userIds: nil, groupId: nil, receiver: receiver, viewController: viewController)
            }
        })
    }
    
    static func inviteSelectedUserOfGroupTask(rideId : Double, rideType : String, userIds : [Double], groupId : Double, receiver : OnGroupInviteListener, viewController : UIViewController)
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
                RideMatcherServiceClient.sendInvitationToSelectedUserOfGroup(riderRideId: rideId, rideType: rideType, userIds : jsonString as! String, groupId : groupId, viewController: viewController) { (responseObject, error) in
                    
                    QuickRideProgressSpinner.stopSpinner()
                    if(responseObject!["result"] as! String == "SUCCESS"){
                        receiver.groupInviteCompleted()
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error : error,viewController: viewController, handler: nil)
                    }
                }
            }else if result == .addPayment {
                self.showPaymentDrawer(selectedGroups: nil, rideId: rideId, rideType: rideType, userIds: userIds, groupId: groupId, receiver: receiver, viewController: viewController)
            }
        })
        
    }
    
    static func showPaymentDrawer(selectedGroups : [UserRouteGroup]?, rideId : Double, rideType : String, userIds : [Double]?, groupId : Double?, receiver : OnGroupInviteListener, viewController : UIViewController){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: true) {(data) in
            if data == .selected || data == .makeDefault {
                if let userIds = userIds {
                    inviteSelectedUserOfGroupTask(rideId: rideId, rideType: rideType, userIds: userIds, groupId: groupId ?? 0, receiver: receiver, viewController: viewController)
                }else if let selectedGroups = selectedGroups {
                    inviteRideGroupstask(selectedGroups: selectedGroups, rideId: rideId, rideType: rideType, receiver: receiver, viewController: viewController)
                }
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
}
