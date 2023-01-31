//
//  VerifyOrganisationViewModel.swift
//  Quickride
//
//  Created by Vinutha on 04/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class VerifyOrganisationViewModel {
    
    //MARK: Properties
    var delegate : ProfileVerificationViewModelDelegate?
    var errorOccured = false
    
    func verifyProfile(verificationText : String,viewController : UIViewController,email : String){
        UserRestClient.passUserOfficeEmailVerification(userId: Double(QRSessionManager.getInstance()!.getUserId())!, email: email, verificationCode: verificationText , viewController: viewController, responseHandler: { [weak self] (responseObject, error) in
            guard let self = `self` else{
                return
            }
            self.delegate?.stopSpinning()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                 self.delegate?.startEmailVerifiedAnimation()
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                self.errorOccured = true
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: viewController)
            }else{
                self.errorOccured = true
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: viewController, handler: nil)
            }
            
        })
    }
    
    func saveUserProfile(email : String?,viewController : UIViewController){
        if let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile() {
            userProfile.email = email
            ProfileRestClient.putProfileWithBody(targetViewController: viewController, body: userProfile.getParamsMap()) { [weak self](responseObject, error) -> Void in
                self?.delegate?.stopSpinning()
                guard let self = `self` else {
                    return
                }
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
                    UserDataCache.getInstance()?.storeUserProfile(userProfile: userProfile!)
                    if email != nil && !(SharedPreferenceHelper.getNewCompanyAddedStatus() ?? false){
                        self.delegate?.handleOTPViewVisibility()
                    }
                }else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            }
        }
    }
    
    func resendOTP(viewController : UIViewController) {
        guard let userId = QRSessionManager.getInstance()?.getUserId() else{
            return
        }
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.resendVerificationEmail(userId: userId, viewController: viewController, completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.verification_resend_toast)
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
}
