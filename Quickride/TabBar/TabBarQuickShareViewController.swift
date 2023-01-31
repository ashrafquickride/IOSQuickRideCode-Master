//
//  TabBarQuickShareViewController.swift
//  Quickride
//
//  Created by Halesh on 12/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TabBarQuickShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_BAZAARY_ONBORDING_DETAILS), !status {
            checkBazaaryOnbordingStatus()
        }else {
            setUpUI()
        }
    }
    
    func setUpUI() {
        let quickShareHomePageViewController  = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickShareHomePageViewController") as! QuickShareHomePageViewController
        quickShareHomePageViewController.initialseQuickShareHomePage( covidCareHome: false)
        
        quickShareHomePageViewController.view.frame = self.view.bounds
        quickShareHomePageViewController.willMove(toParent: self)
        self.view.addSubview(quickShareHomePageViewController.view)
        self.addChild(quickShareHomePageViewController)
        quickShareHomePageViewController.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ContainerTabBarViewController.indexToSelect = 2
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func checkBazaaryOnbordingStatus(){
            let bazaarySignupInfoVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "BazaarySignupInfoViewController") as! BazaarySignupInfoViewController
        bazaarySignupInfoVC.initializeData { (completed) in
            if completed{
                self.setUpUI()
            }
        }
            
            bazaarySignupInfoVC.view.frame = self.view.bounds
            bazaarySignupInfoVC.willMove(toParent: self)
            self.view.addSubview(bazaarySignupInfoVC.view)
            self.addChild(bazaarySignupInfoVC)
            bazaarySignupInfoVC.didMove(toParent: self)
    }
}
