//
//  ProfileVerificationViewModel.swift
//  Quickride
//
//  Created by Admin on 15/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol ProfileVerificationViewModelDelegate {
    func displayEmailNotValidConfirmationDialog(userMessage : String)
    func handleOTPViewVisibility()
    func closeVerificationView()
    func stopButtonAnimation()
    func startEmailVerifiedAnimation()
    func startSpinning()
    func stopSpinning()
}

class ProfileVerificationViewModel{
    
    //MARK: Properties
    var userProfile = UserDataCache.getInstance()?.userProfile
    var delegate : ProfileVerificationViewModelDelegate?
    var errorOccured = false
    var rideType : String?
    
    //MARK: Methods
    
    func initializeData(rideType : String?){
        self.rideType = rideType
    }
    
    func saveUserImage(actualImage : UIImage,viewController : UIViewController){
        let image = ImageUtils.RBResizeImage(image: actualImage, targetSize: CGSize(width: 540, height: 540))
        
        ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: image), targetViewController: viewController, completionHandler: { [weak self](responseObject, error) in
            self?.processUserImage(responseObject: responseObject,error: error, actualImage: actualImage, viewController: viewController)
        })
    }
    
    private func processUserImage(responseObject : NSDictionary?,error : NSError?,actualImage : UIImage,viewController : UIViewController){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            
            userProfile!.imageURI = responseObject!["resultData"] as? String
            ImageCache.getInstance().storeImageToCache(imageUrl: userProfile!.imageURI!, image: actualImage)
            saveUserProfile(email: nil, viewController: viewController)
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.PICTURE_ADDED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "" ,"context": "SIGN_UP"], uniqueField: User.FLD_USER_ID)
        }
        else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
        }
    }
    
    
    func saveUserProfile(email : String?,viewController : UIViewController){
        ProfileRestClient.putProfileWithBody(targetViewController: viewController, body: userProfile!.getParamsMap()) { [weak self](responseObject, error) -> Void in
            self?.delegate?.stopButtonAnimation()
            guard let self = `self` else {
                return
            }
            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
                if email != nil && !(SharedPreferenceHelper.getNewCompanyAddedStatus() ?? false){
                    self.delegate?.handleOTPViewVisibility()
                }
                UserDataCache.getInstance()?.storeUserProfile(userProfile: self.userProfile!)
            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    func checkWhetherOfficialEmailIdValid(email : String) -> Bool{
       
        if UserProfile.checkIsOfficeEmailAndConveyAccordingly(emailId: email) == false
        {
            delegate?.displayEmailNotValidConfirmationDialog(userMessage: Strings.not_official_email_dialog)
            
            return false
        }
        return true
     }
    
    func verifyProfile(verificationText : String,viewController : UIViewController,email : String){

        
        UserRestClient.passUserOfficeEmailVerification(userId: Double(QRSessionManager.getInstance()!.getUserId())!, email: email, verificationCode: verificationText , viewController: viewController, responseHandler: { [weak self] (responseObject, error) in
            guard let self = `self` else{
                return
            }
            self.delegate?.stopSpinning()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]){
                   UserDataCache.getInstance()?.storeUserProfile(userProfile: userProfile)
                    self.userProfile = userProfile
                }
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
     
    
}
