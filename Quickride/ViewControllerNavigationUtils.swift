//
//  ViewControllerNavigationUtils.swift
//  Quickride
//
//  Created by Admin on 06/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class ViewControllerNavigationUtils{
    
    static let VIEW_CONTROLLER_NAME_VALUES = ["profile" : ViewControllerIdentifiers.profileDisplayViewController,"help" : ViewControllerIdentifiers.helpViewController,"groups" : ViewControllerIdentifiers.myGroupsViewController,"rides" : ViewControllerIdentifiers.myRidesController,"vehicles" : ViewControllerIdentifiers.vehicleListViewController,"wallet" : ViewControllerIdentifiers.myWalletViewController,"newride" : ViewControllerIdentifiers.routeViewController,"referandearn" : ViewControllerIdentifiers.myReferralsViewController,"settings" : ViewControllerIdentifiers.myPreferencesViewController,"ecometer" : ViewControllerIdentifiers.NewEcoMeterViewController,"offers" : ViewControllerIdentifiers.myOffersViewController,"redeem" : ViewControllerIdentifiers.myWalletViewController,"recharge" : ViewControllerIdentifiers.myWalletViewController,"transfer" : ViewControllerIdentifiers.transferViewController,"bazaary_home" : ViewControllerIdentifiers.quickShareHomePageViewController]
    static let STORYBOARD_NAME_VALUES = ["profile" : StoryBoardIdentifiers.profile_storyboard,"help" : StoryBoardIdentifiers.help_storyboard,"groups" : StoryBoardIdentifiers.groups_storyboard,"rides" : StoryBoardIdentifiers.common_storyboard,"vehicles" : StoryBoardIdentifiers.vehicle_storyboard,"wallet": StoryBoardIdentifiers.account_storyboard,"newride" : StoryBoardIdentifiers.mapview_storyboard,"referandearn" : StoryBoardIdentifiers.shareandearn_storyboard,"settings" : StoryBoardIdentifiers.my_prefernces_storyboard,"ecometer" : StoryBoardIdentifiers.account_storyboard,"offers" : StoryBoardIdentifiers.common_storyboard,"redeem" : StoryBoardIdentifiers.account_storyboard,"recharge" : StoryBoardIdentifiers.account_storyboard,"transfer" : StoryBoardIdentifiers.account_storyboard,"bazaary_home": StoryBoardIdentifiers.quickShare_storyboard]
    
    static func openSpecificViewController(viewController :UIViewController?){
        
        if let viewPrefix = SharedPreferenceHelper.getViewPrefixForDeepLink(), let storyboardId = STORYBOARD_NAME_VALUES[viewPrefix], let viewControllerId = VIEW_CONTROLLER_NAME_VALUES[viewPrefix]{
            if  viewControllerId == ViewControllerIdentifiers.myOffersViewController {
                let viewController = UIStoryboard(name: storyboardId, bundle: nil).instantiateViewController(withIdentifier: viewControllerId) as! MyOffersViewController
                viewController.prepareData(selectedFilterString: nil)
                ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: viewController, animated: true)
            }else{
                let viewController = UIStoryboard(name: storyboardId, bundle: nil).instantiateViewController(withIdentifier: viewControllerId)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: viewController, animated: true)
            }
            return
        }else{
            let containerTabABarView = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
            if let deeplink = SharedPreferenceHelper.getDeepLink(){
                if deeplink.contains("quickjobs"){
                    ContainerTabBarViewController.indexToSelect = 3
                    let jobsVC = UIStoryboard(name: "MapView", bundle: nil).instantiateViewController(withIdentifier: "QuickJobsViewController")
                    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: jobsVC, animated: true)
                    SharedPreferenceHelper.storeDeepLink(parameter: nil)
                    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: containerTabABarView, animated: false)
                }else if deeplink.contains("yRoxDdrVLrT6vpgc7") || deeplink.contains("covidCare"){
                    ContainerTabBarViewController.indexToSelect = 2
                    SharedPreferenceHelper.storeDeepLink(parameter: nil)
                    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: containerTabABarView, animated: false)
                }else if let viewController = viewController {
                    AppStartupHandler.checkViewControllerAndNavigate(viewController: viewController)
                }
            }else{
                if let viewController = viewController {
                    AppStartupHandler.checkViewControllerAndNavigate(viewController: viewController)
                }
                
            }
            
        }
        SharedPreferenceHelper.storeDeepLink(parameter: nil)
        SharedPreferenceHelper.storeViewPrefixForDeepLink(parameter: nil)
    }
}
