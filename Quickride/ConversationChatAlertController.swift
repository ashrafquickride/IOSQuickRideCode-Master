//
//  ConversationChatAlertController.swift
//  Quickride
//
//  Created by QuickRideMac on 7/28/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI

protocol chatClearDelegate{
    func clearConversation()
}
class ConversationChatAlertController : NSObject,MFMailComposeViewControllerDelegate{
    
    var alertController : UIAlertController?
    var presentConatctUserBasicInfo : UserBasicInfo?
    var viewController :UIViewController?
    var supportCall : Bool?
    init(viewController :UIViewController, presentConatctUserBasicInfo : UserBasicInfo?, supportCall : Bool){
        self.viewController = viewController
        self.presentConatctUserBasicInfo = presentConatctUserBasicInfo
        self.supportCall = supportCall
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController?.view.tintColor = Colors.alertViewTintColor
    }
    func profileAlertAction()
    {
        AppDelegate.getAppDelegate().log.debug("")
        let profileAlertAction = UIAlertAction(title: Strings.profile, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.navigateToUserProfile()
        })
        alertController?.addAction(profileAlertAction)
    }
    func navigateToUserProfile()
    {
        let callSupport: CommunicationType?
        if supportCall == true{
            callSupport = CommunicationType.Call
        }
        else{
            callSupport = CommunicationType.Chat
        }
        let profileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: self.presentConatctUserBasicInfo!.userId),isRiderProfile: RideManagementUtils.getUserRoleBasedOnRide(), rideVehicle: nil, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profileDisplayViewController, animated: false)
    }
    
    func clearChatAction(delegate : chatClearDelegate)
    {
        AppDelegate.getAppDelegate().log.debug("")
        let clearChatAlertAction = UIAlertAction(title: Strings.clear_chat, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.clearChat(delegate: delegate)
        })
        alertController?.addAction(clearChatAlertAction)

    }
    func clearChat(delegate : chatClearDelegate)
    {
        ConversationCache.getInstance().handleChatClearScenario(userId: self.presentConatctUserBasicInfo!.userId!)
        delegate.clearConversation()
    }
    func addRemoveAlertAction(){
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(removeUIAlertAction)
        
    }
    func showAlertController(){
        viewController!.present(alertController!, animated: false, completion: {
            self.alertController!.view.tintColor = Colors.alertViewTintColor
        })
    }
    func reportToUserAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let reportToUserAction = UIAlertAction(title: Strings.report, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.reportUser()
        })
        alertController?.addAction(reportToUserAction)
    }
    
    func reportUser(){
        let screen = UIScreen.main
        if let window = UIApplication.shared.keyWindow {
            
            UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0);
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            HelpUtils.sendEmailToSupport(viewController: viewController!, image: image,listOfIssueTypes: Strings.list_of_report_types)
        }
        
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }

}
