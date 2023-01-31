//
//  UserProfileVerificationNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 4/8/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserProfileVerificationNotificationHandler : NotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            var verificationStatus : Int = 0
            let userProfile = UserDataCache.getInstance()?.userProfile
            if userProfile != nil {
                verificationStatus = userProfile!.verificationStatus
            }
            if verificationStatus == 0
            {
                return handler(true)
                
            }
            return handler(false)
        }
        
    }

    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        moveToVerifyProfilePage(viewController: viewController)
    }
    
    private func moveToVerifyProfilePage(viewController: UIViewController?) {
        let verifyProfileViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
        verifyProfileViewController.intialData(isFromSignUpFlow: false)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: verifyProfileViewController, animated: false)
    }
    override func handleTap(userNotification: UserNotification,viewController :UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("\(userNotification)")
        super.handleTap(userNotification: userNotification, viewController: viewController)
        
        let profileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: (QRSessionManager.getInstance()?.getUserId())!,isRiderProfile: UserRole.None, rideVehicle: nil, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profileDisplayViewController, animated: false)
    }
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.verify_now
    }
}
