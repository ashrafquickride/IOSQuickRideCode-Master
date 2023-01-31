//
//  GreetingsViewController.swift
//  Quickride
//
//  Created by Admin on 14/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie
import CoreLocation

class GreetingsViewController: UIViewController {
    
    @IBOutlet weak var welcomeAnimationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startAnimation()
        stopAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func startAnimation(){
        welcomeAnimationView.animation = Animation.named("welcome")
        welcomeAnimationView.play()
        welcomeAnimationView.loopMode = .loop
    }
    
    private func stopAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.welcomeAnimationView.stop()
            if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied{
                let turnLocationOnVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LocationPermissionViewController") as! LocationPermissionViewController
                turnLocationOnVC.initialiseData { (isEnabled) in
                    if isEnabled{
                        self?.navigateToQuickRidePledgeVC()
                    }
                }
                self?.navigationController?.pushViewController(turnLocationOnVC, animated: false)
            }else{
                self?.navigateToQuickRidePledgeVC()
            }
        }
    }
    
    private func navigateToQuickRidePledgeVC(){
        var pledgeDetails: [String]?
        if UserDataCache.getInstance()?.userProfile?.preferredRole == UserProfile.PREFERRED_ROLE_RIDER{
            pledgeDetails = Strings.pledge_details_ride_giver
        }else{
            pledgeDetails = Strings.pledge_details_ride_taker
        }
        let qrPledgeVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickridePledgeViewController") as! QuickridePledgeViewController
        qrPledgeVC.initializeDataBeforePresenting(titles: Strings.pledge_titles, messages: pledgeDetails!, images: Strings.pledgeImages, actionName: Strings.i_agree_caps, heading: Strings.pledge_title_text) { [weak self] () in
            guard let self = `self` else { return }
            if UserDataCache.getInstance()?.userProfile?.preferredRole == UserProfile.PREFERRED_ROLE_RIDER{
                SharedPreferenceHelper.setDisplayStatusForRideGiverPledge(status: true)
            }else{
                SharedPreferenceHelper.setDisplayStatusForRideTakerPledge(status: true)
            }
            self.navigateToNextScreen()
        }
        self.navigationController?.pushViewController(qrPledgeVC, animated: false)
    }
    
    private func navigateToNextScreen(){
        DispatchQueue.main.async {
            
            LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
            NotificationStore.getInstance().processRecentNotifiation()
            NotificationStore.getInstance().getAllPendingNotificationsFromServer()
            let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: routeViewController, animated: false)
            if let _ = SharedPreferenceHelper.getViewPrefixForDeepLink() {
                ViewControllerNavigationUtils.openSpecificViewController(viewController: nil)
            }else {
                RideManagementUtils.updateStatusAndNavigate(isFromSignupFlow: false, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
            }
            
        }
    }
  
}
