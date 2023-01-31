//
//  AddProfilePictureViewModel.swift
//  Quickride
//
//  Created by Ashutos on 03/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AddProfilePictureViewModel {
    
    var userImage: UIImage?
    
    func checkAndSaveUserImage(){
        AppDelegate.getAppDelegate().log.debug("checkAndSaveUserImage()")
        let image = ImageUtils.RBResizeImage(image: userImage!, targetSize: CGSize(width: 540, height: 540))
        ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: image), targetViewController: nil, completionHandler: {(responseObject, error) in
            self.processUserImage(responseObject: responseObject,error: error)
        })
    }
    
    private func processUserImage(responseObject : NSDictionary?,error : NSError?){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            let userProfile = UserDataCache.getInstance()?.userProfile
            userProfile?.imageURI = responseObject!["resultData"] as? String
            ImageCache.getInstance().storeImageToCache(imageUrl: userProfile?.imageURI ?? "", image: userImage!)
            continueSavingUserProfile(userProfile: userProfile!)
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.PICTURE_ADDED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "" ,"context": "PROFILE"], uniqueField: User.FLD_USER_ID)
        }else {
            var userInfo = [String:Any]()
            userInfo["responseObject"] = responseObject
            userInfo["error"] = error
            NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
        }
    }
    
    func continueSavingUserProfile(userProfile: UserProfile){
        AppDelegate.getAppDelegate().log.debug("saveUserProfile()")
        ProfileRestClient.putProfileWithBody(targetViewController: nil, body: userProfile.getParamsMap()) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                guard let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]) else { return }
                UserDataCache.getInstance()?.storeUserProfile(userProfile: userProfile)
                NotificationCenter.default.post(name: Notification.Name("ProfilePictureAdded"), object: nil)
                SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD, value: true)
            }else {
                var userInfo = [String:Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func getPleadgeDetails() -> [String]{
        var pledgeDetails = [String]()
        let userProfile = UserDataCache.getInstance()?.userProfile
        if userProfile?.preferredRole == UserProfile.PREFERRED_ROLE_RIDER{
            pledgeDetails = Strings.pledge_details_ride_giver
        }else{
            pledgeDetails = Strings.pledge_details_ride_taker
        }
        return pledgeDetails
    }
}
