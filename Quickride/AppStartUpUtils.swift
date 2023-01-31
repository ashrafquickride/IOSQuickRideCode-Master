//
//  AppStartUpUtils.swift
//  Quickride
//
//  Created by QuickRideMac on 9/23/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AppStartUpUtils {
    
    static func checkViewControllerAndNavigate(viewController : UIViewController?)
    {
        var status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_FEATURE_SELECTION_DETAILS)
        if status != nil && status == false
        {
            let featureSelectionVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FeatureSelectionViewController") as! FeatureSelectionViewController
            self.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : featureSelectionVC)
            return
         }
        
        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS)
        if status != nil && status == false
        {
            let ridePreferencesViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RidePreferenceViewController") as! RidePreferenceViewController
            self.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : ridePreferencesViewController)
            return
         }

        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROUTE_INFO)
        if status != nil && status == false
        {
            let rideCreateViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCreateViewController") as! RideCreateViewController
            self.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : rideCreateViewController)
            return
        }
        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD)
        if status != nil && status == false
        {
            let rideCreateViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProfilePictureViewController") as! AddProfilePictureViewController
            self.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : rideCreateViewController)
            return
        }else
        {
            RideManagementUtils.updateStatusAndNavigate(isFromSignupFlow: false, viewController: viewController, handler: nil)
            return
        }
    }
    
    static func displayViewController(currentViewController: UIViewController?, viewControllerToBeDisplayed : UIViewController)
    {
    
        if currentViewController != nil {
            ViewControllerUtils.displayViewController(currentViewController: currentViewController, viewControllerToBeDisplayed: viewControllerToBeDisplayed, animated: false)
        }
        else
        {
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: viewControllerToBeDisplayed, animated: false)
        }
        
    }
}
