//
//  RidePreferenceViewModel.swift
//  Quickride
//
//  Created by Admin on 12/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import SimplZeroClick

class RidePreferenceViewModel{
    var isEligiableForSimpl = true
    var isUserSelectedSimpl = false
    var isSimpleOfferPresent = false
    var isFromSignUpFlow = true
    
    init(isFromSignUpFlow: Bool) {
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    
    init(){
    }
    
    func updateUserProfile(viewController : UIViewController,preferredRole : String){
        if let userProfile = SharedPreferenceHelper.getUserProfileObject(){
            userProfile.roleAtSignup = preferredRole
            ProfileRestClient.putProfileWithBody(targetViewController: viewController, body: userProfile.getParamsMap()) { (responseObject, error) -> Void in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]){
                        SharedPreferenceHelper.storeUserProfileObject(userProfileObj: userProfile)
                        UserDataCache.getInstance()?.storeUserProfile(userProfile: userProfile)
                    }
                }
            }
        }
    }
    
    func checkSimplEligibilityForCurrentUser(){
        let userProfile = SharedPreferenceHelper.getUserProfileObject()
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
        let user = GSUser(phoneNumber: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.currentUser?.contactNo), email: email!)
        user.headerParams = params
        GSManager.shared().checkApproval(for: user) { (approved, firstTransaction, text, error) in
            if error != nil {
                self.isEligiableForSimpl = false
            }else if approved{
                self.isEligiableForSimpl = true
            }else{
                self.isEligiableForSimpl = false
            }
        }
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        let linkedWallets = clientConfiguration.linkedWalletOffers
        if let index = linkedWallets.index(where: {$0.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL}), linkedWallets[index].offerText != nil{
            isSimpleOfferPresent = true
        }
    }
    
    func linkSimplWallet(viewController: UIViewController){
        AccountRestClient.linkSIMPLAccountToQRInSignUp(userId: UserDataCache.getInstance()?.userId, handler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
            }
        })
    }
    func updateOrgEmail(){
        guard let userProfile = SharedPreferenceHelper.getUserProfileObject() else { return }
        if let organisationEmail = SharedPreferenceHelper.getOrganizationEmailId(),UserProfile.checkIsOfficeEmailAndConveyAccordingly(emailId: organisationEmail) || AppUtil.isValidEmailId(emailId: organisationEmail) || UserProfileValidationUtils.isOrganisationEmailIdIsValid(orgEmail: organisationEmail) {
            userProfile.email = organisationEmail
            SharedPreferenceHelper.storeUserProfileObject(userProfileObj: userProfile)
            ProfileRestClient.putProfileWithBody(targetViewController: nil, body: userProfile.getParamsMap()) { (responseObject, error) -> Void in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]){
                        UserDataCache.getInstance()?.storeUserProfile(userProfile: userProfile)
                        SharedPreferenceHelper.saveOrganizationEmailId(emailId: nil)
                    }
                }
            }
        }
    }
}
