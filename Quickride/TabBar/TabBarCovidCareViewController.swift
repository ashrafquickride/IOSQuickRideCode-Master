//
//  TabBarCovidCareViewController.swift
//  Quickride
//
//  Created by HK on 26/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TabBarCovidCareViewController: UIViewController {
    
    var quickMarketSegement: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if SharedPreferenceHelper.getLoggedInUserContactNo() == "1234567890"{
            setUpJobs()
        }else{
            setUpCovidUI()
        }
    }
    
    func setUpCovidUI() {
        let quickShareHomePageViewController  = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickShareHomePageViewController") as! QuickShareHomePageViewController
        
        quickShareHomePageViewController.initialseQuickShareHomePage(covidCareHome: true)
        quickShareHomePageViewController.view.frame = self.view.bounds
        quickShareHomePageViewController.willMove(toParent: self)
        self.view.addSubview(quickShareHomePageViewController.view)
        self.addChild(quickShareHomePageViewController)
        quickShareHomePageViewController.didMove(toParent: self)
    }
    
    func setUpJobs(){
        let quickJobsViewController  = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickJobsViewController") as! QuickJobsViewController
        quickJobsViewController.view.frame = self.view.bounds
        quickJobsViewController.willMove(toParent: self)
        self.view.addSubview(quickJobsViewController.view)
        self.addChild(quickJobsViewController)
        quickJobsViewController.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ContainerTabBarViewController.indexToSelect = 2
        self.navigationController?.isNavigationBarHidden = true
    }
}
