//
//  VerificationStatusNotificationHandler.swift
//  Quickride
//
//  Created by Vinutha on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class VerificationStatusNotificationHandler: NotificationHandler {
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        moveToVerifyProfilePage(viewController: viewController)
    }
    
    private func moveToVerifyProfilePage(viewController: UIViewController?) {
        let verifyProfileViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
        verifyProfileViewController.intialData(isFromSignUpFlow: false)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: verifyProfileViewController, animated: false)
    }
}
