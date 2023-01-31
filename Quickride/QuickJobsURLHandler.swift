//
//  QuickJobsURLHandler.swift
//  Quickride
//
//  Created by Halesh on 06/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickJobsURLHandler{
    static func handleJob(shortUrl : URL){
        QuickRideProgressSpinner.startSpinner()
        shortUrl.expandURLWithCompletionHandler { (longURL) in
            QuickRideProgressSpinner.stopSpinner()
            if longURL != nil && longURL!.absoluteString.contains("postedJobDetail"){
                SharedPreferenceHelper.storeQuickJobUrl(parameter: longURL?.absoluteString)
                DispatchQueue.main.async {
                    if SessionManagerController.sharedInstance.isSessionManagerInitialized() == true, let jobUrl = SharedPreferenceHelper.getQuickJobUrl(){
                        showPerticularJobInQuickJobPortal(jobUrl: jobUrl)
                    }
                }
            }
        }
    }
    
    static func showPerticularJobInQuickJobPortal(jobUrl: String){
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = 3
        routeTabBar.setUrlToLoad(urlString: jobUrl)
        SharedPreferenceHelper.storeQuickJobUrl(parameter: nil)
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: routeTabBar, animated: false)
    }
}
