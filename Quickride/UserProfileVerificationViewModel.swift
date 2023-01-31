//
//  UserProfileVerificationViewModel.swift
//  Quickride
//
//  Created by Vinutha on 11/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol EmailValidationDelegate {
    func emailVerificationSuccess()
    func emailVerificationFailed()
}

protocol ProfileUpdateDelegate {
    func profileUpdateSuccess(isEmailUpdated: Bool)
}

class UserProfileVerificationViewModel {
    
    var profileVerificationData: ProfileVerificationData?
    var isOrgVerificationExpandable: Bool?
    var isImageVerificationExpandable: Bool?
    var isEmailValid: Bool?
    var emailValidationDelegate: EmailValidationDelegate?
    var profileUpdateDelegate: ProfileUpdateDelegate?
    var isEmailUpdated = false
    var userProfile: UserProfile?
    var companyVerificationStatus: CompanyVerificationStatus?
    
    func initialiseData(profileVerificationData: ProfileVerificationData?, userProfile: UserProfile?, emailValidationDelegate: EmailValidationDelegate?, profileUpdateDelegate: ProfileUpdateDelegate?) {
        self.profileVerificationData = profileVerificationData
        self.userProfile = userProfile
        self.emailValidationDelegate = emailValidationDelegate
        self.profileUpdateDelegate = profileUpdateDelegate
    }
    func verifyOtp(userId : Double, email : String, verificationCode : String?, viewController : UIViewController) {
        UserRestClient.passUserOfficeEmailVerification(userId: userId, email: email, verificationCode: verificationCode , viewController: viewController, responseHandler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]){
                   UserDataCache.getInstance()?.storeUserProfile(userProfile: userProfile)
                    self.userProfile = userProfile
                    self.profileVerificationData = userProfile.profileVerificationData
                }
                self.emailValidationDelegate?.emailVerificationSuccess()
            } else{
                self.emailValidationDelegate?.emailVerificationFailed()
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: viewController, handler: nil)
            }
            
        })
    }
    
    func saveImage(image: UIImage, userProfile: UserProfile, viewController: UIViewController) {
        QuickRideProgressSpinner.startSpinner()
        ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: image), targetViewController: viewController, completionHandler: {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                userProfile.imageURI = responseObject!["resultData"] as? String
                self.saveUserProfile(userProfile: userProfile, isEmailUpdate: false, viewController: viewController)
            }
            else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
    
    func saveUserProfile(userProfile: UserProfile?, isEmailUpdate: Bool, viewController: UIViewController) {
        if userProfile == nil {
            return
        }
        if !isEmailUpdate {
            QuickRideProgressSpinner.startSpinner()
        }
        ProfileRestClient.putProfileWithBody(targetViewController: viewController, body: userProfile!.getParamsMap()) { (responseObject, error) -> Void in
            if !isEmailUpdate {
                QuickRideProgressSpinner.stopSpinner()
            }
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let updatedUserProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]) {
                    UserDataCache.getInstance()?.storeUserProfile(userProfile: updatedUserProfile)
                    self.userProfile = updatedUserProfile
                    self.profileVerificationData = updatedUserProfile.profileVerificationData
                    self.profileUpdateDelegate?.profileUpdateSuccess(isEmailUpdated: isEmailUpdate)
                    self.isEmailUpdated = false
                }
                if isEmailUpdate{
                    NotificationCenter.default.post(name: .userProfileUpatedWithOrgEmail, object: self)
                }
            }else {
                if isEmailUpdate{
                    NotificationCenter.default.post(name: .userProfileUpatedFailed, object: self)
                }
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    func resendOtp() {
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.resendVerificationEmail(userId: QRSessionManager.getInstance()?.getUserId() ?? "", viewController: nil, completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as? String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.verification_resend_toast)
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        })
    }
    
    func getCompanyDomainStatus(){
        AppDelegate.getAppDelegate().log.debug("getEmailDomainStatus")
        if let range = userProfile?.email?.range(of: "@") {
            let domain = "@" + (userProfile?.email?[range.upperBound...] ?? "")
            UserRestClient.checkCompanyDomainStatus(emailDomain: String(domain)) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.companyVerificationStatus = Mapper<CompanyVerificationStatus>().map(JSONObject: responseObject!["resultData"])
                    NotificationCenter.default.post(name: .companyDomainStatusReceived, object: self)
                }
            }
        }
    }
}
