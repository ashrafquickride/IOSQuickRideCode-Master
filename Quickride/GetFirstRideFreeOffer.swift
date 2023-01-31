//
//  GetFirstRideFreeOffer.swift
//  Quickride
//
//  Created by Halesh on 02/04/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import SimplZeroClick

class GetFirstRideFreeOffer: UIView {
    
    @IBOutlet weak var offerView: UIView!
    
    @IBOutlet weak var offerLabel: UILabel!
    
    @IBOutlet weak var offerImageView: UIImageView!
    
    private var rideType: String?
    private var freeRides = 3
    
    func initializeView(x: CGFloat, y: CGFloat,rideType: String){
        self.rideType = rideType
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: offerView, cornerRadius: 15, corner1: .topLeft, corner2: .topRight)
        offerView.backgroundColor = UIColor(netHex: 0xF9A825)
        offerLabel.text = String(format: Strings.first_ride_free_msg, arguments: [String(freeRides)])
        offerImageView.image = offerImageView.image?.withRenderingMode(.alwaysTemplate)
        offerImageView.tintColor = .black
        offerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(offerViewTapped(_:))))
    }
    
    @objc private func offerViewTapped(_ gesture : UITapGestureRecognizer){
        navigateToProfileVerificationViewController()
    }
    
    private func navigateToProfileVerificationViewController(){
        guard let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData,!profileVerificationData.profileVerified else {
            return
        }
        let profileVerificationVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileVerificationViewController") as! ProfileVerificationViewController
        profileVerificationVC.initializeViews(rideType: rideType) { [weak self] in
            guard let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData else {
                return
            }
            if  profileVerificationData.emailVerified{
                self?.removeFromSuperview()
                self?.checkSimplSdkApprovalStatus()
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: profileVerificationVC)
    }
    
    
   private func checkSimplSdkApprovalStatus(){
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        let email = userProfile?.email == nil ?
            userProfile?.emailForCommunication == nil ? "" : userProfile?.emailForCommunication
            : userProfile?.email
        
        
        var params :[String : Any] = [:]
        if let profileVerificationData = userProfile?.profileVerificationData{
            params["email_verification_status"] = String(profileVerificationData.emailVerified)
            params["govt_id_verified"] = String(profileVerificationData.persIDVerified)
        }
        params["first_name"] = userProfile?.userName
        params["employer_name"] = userProfile?.companyName
        
        if let homeLocation = UserDataCache.getInstance()?.getHomeLocation(){
            params["user_location_origin"] = String(homeLocation.latitude!) + "," + String(homeLocation.longitude!)
        }
        
        if let officeLocation = UserDataCache.getInstance()?.getOfficeLocation(){
            params["user_location_destination"] = String(officeLocation.latitude!) + "," + String(officeLocation.longitude!)
        }
        
        if let numberOfRidesAsRider = userProfile?.numberOfRidesAsRider,let numberOfRidesAsPassenger = userProfile?.numberOfRidesAsPassenger{
            params["successful_txn_count"] = String(numberOfRidesAsRider+numberOfRidesAsPassenger)
        }
        
        let user = GSUser(phoneNumber: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.currentUser?.contactNo), email: email!)
        user.headerParams = params
        
        QuickRideProgressSpinner.startSpinner()
        GSManager.shared().checkApproval(for: user) { (approved, firstTransaction, text, error) in
            QuickRideProgressSpinner.stopSpinner()
            if approved{
                let simplAndFirstRideFreeOfferViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SimplAndFirstRideFreeOfferViewController") as! SimplAndFirstRideFreeOfferViewController
                ViewControllerUtils.addSubView(viewControllerToDisplay: simplAndFirstRideFreeOfferViewController)
            }
        }
    }
}
