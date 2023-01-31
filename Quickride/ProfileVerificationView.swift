//
//  ProfileVerificationView.swift
//  Quickride
//
//  Created by Admin on 27/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProfileVerificationView: UIView {
    
    //MARK: Outlets
    @IBOutlet weak var verificationStatusLabel: UILabel!
    
    //MARK: Properties
    private var rideType : String?
    
    //MARK: ViewLifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initializeView(rideType : String?,profileVerificationData : ProfileVerificationData){
        
        self.rideType = rideType
        populateData(profileVerificationData: profileVerificationData)
        
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        UserDataCache.getInstance()?.updateEntityDisplayStatus(key: UserDataCache.VERIFICATION_VIEW, status: true)
        ProfileVerificationUtils.removeView()
    }
    
    @IBAction func verificationViewClicked(_ sender: UIButton) {
        navigateToProfileVerificationViewController()
    }
    
    private func navigateToProfileVerificationViewController(){
        guard let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData,!profileVerificationData.profileVerified else {
            return
        }
        let profileVerificationVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileVerificationViewController") as! ProfileVerificationViewController
        profileVerificationVC.initializeViews(rideType: rideType) { [weak self] in
            let newCompanyStatus = SharedPreferenceHelper.getNewCompanyAddedStatus()
            guard let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData else {
                return
            }
            if profileVerificationData.profileVerified || profileVerificationData.imageVerified || profileVerificationData.emailVerified || (newCompanyStatus != nil && newCompanyStatus!) {
                ProfileVerificationUtils.removeView()
                return
            }
            self?.populateData(profileVerificationData: profileVerificationData)
        }
       ViewControllerUtils.addSubView(viewControllerToDisplay: profileVerificationVC)
        profileVerificationVC.view.layoutIfNeeded()
    }
    
    private func populateData(profileVerificationData : ProfileVerificationData){
        if !profileVerificationData.imageVerified && !profileVerificationData.emailVerified{
            verificationStatusLabel.text = Strings.profile_unverified_text
        }else if !profileVerificationData.imageVerified{
            
            verificationStatusLabel.text = Strings.image_unverified_text
            
        }else{
            verificationStatusLabel.text = Strings.org_unverified_text
        }
    }
}
