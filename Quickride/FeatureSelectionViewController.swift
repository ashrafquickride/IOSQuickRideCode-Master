//
//  FeatureSelectionViewController.swift
//  Quickride
//
//  Created by Rajesab on 24/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class FeatureSelectionViewController: UIViewController {
    
    @IBOutlet weak var carpoolView: UIView!
    @IBOutlet weak var taxiView: UIView!
//    @IBOutlet weak var bazaaryView: UIView!
//    @IBOutlet weak var jobsView: UIView!
    @IBOutlet weak var carpoolButtont: UIButton!
    @IBOutlet weak var taxiButton: UIButton!
//    @IBOutlet weak var jobsButton: UIButton!
//    @IBOutlet weak var bazaaryButton: UIButton!
    
    private var featureSelectionArray = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        featureSelectionArray = [carpoolButtont,taxiButton]
        carpoolButtont.addTarget(self, action:#selector(HoldButton(_:)), for: UIControl.Event.touchDown)
        carpoolButtont.addTarget(self, action:#selector(HoldRelease(_:)), for: UIControl.Event.touchUpOutside)
        taxiButton.addTarget(self, action:#selector(HoldButton(_:)), for: UIControl.Event.touchDown)
        taxiButton.addTarget(self, action:#selector(HoldRelease(_:)), for: UIControl.Event.touchUpOutside)
//        jobsButton.addTarget(self, action:#selector(HoldButton(_:)), for: UIControl.Event.touchDown)
//        jobsButton.addTarget(self, action:#selector(HoldRelease(_:)), for: UIControl.Event.touchUpOutside)
//        bazaaryButton.addTarget(self, action:#selector(HoldButton(_:)), for: UIControl.Event.touchDown)
//        bazaaryButton.addTarget(self, action:#selector(HoldRelease(_:)), for: UIControl.Event.touchUpOutside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func featureSelectionButtonTapped(_ sender: UIButton) {
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_FEATURE_SELECTION_DETAILS, value: true)
        navigateToSelectedFeature(tag: sender.tag)
    }
    
    @objc func HoldRelease(_ sender: UIButton){
        switch sender.tag{
        case 0:
            carpoolView.backgroundColor = UIColor.white
            break
        case 1:
            taxiView.backgroundColor = UIColor.white
            break
//        case 2:
//            bazaaryView.backgroundColor = UIColor.white
//            break
//        case 3:
//            jobsView.backgroundColor = UIColor.white
//            break
        default:
            break
        }
    }
    
    @objc func HoldButton(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            carpoolView.backgroundColor = UIColor(netHex: 0xFAFAFA)
            break
        case 1:
            taxiView.backgroundColor = UIColor(netHex: 0xFAFAFA)
            break
//        case 2:
//            bazaaryView.backgroundColor = UIColor(netHex: 0xFAFAFA)
//            break
//        case 3:
//            jobsView.backgroundColor = UIColor(netHex: 0xFAFAFA)
//            break
        default:
            break
        }
    }
    
    private func navigateToSelectedFeature(tag: Int){
        SharedPreferenceHelper.storeRecentTabBarIndex(tabBarIndex: tag)
        if tag != 1{
            SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS, value: true)
            SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROUTE_INFO, value: true)
            SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD, value: true)
        }
        switch tag{
        case 0:
            let taxiSignupInfoVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiSignupInfoViewController") as! TaxiSignupInfoViewController
            self.navigationController?.pushViewController(taxiSignupInfoVC, animated: false)
            break
        case 1:
            let ridePreferencesViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RidePreferenceViewController") as! RidePreferenceViewController
            self.navigationController?.pushViewController(ridePreferencesViewController, animated: false)
            break
            
//        case 2:
//            let bazaarySignupInfoVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "BazaarySignupInfoViewController") as! BazaarySignupInfoViewController
//            self.navigationController?.pushViewController(bazaarySignupInfoVC, animated: false)
//            break
            
        case 3:
            RideManagementUtils.moveToRecentTabBar()
            break
            
        default:
            break
        }
    }
}
