//
//  FacebookLoginManager.swift
//  Quickride
//
//  Created by Admin on 15/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit

typealias FacebookLoginCompletionBlock = (Dictionary<String, AnyObject>?, Error?) -> Void

class FacebookLoginManager {
    
 
    //MARK:- Public functions
    class func fetchUserProfile(onCompletion : @escaping FacebookLoginCompletionBlock){
        validatePermissionAndFetchProfile(onCompletion: onCompletion)
    }
    
    class private func validatePermissionAndFetchProfile(onCompletion: @escaping FacebookLoginCompletionBlock){
        if AccessToken.current != nil{
            getUserDetails(onCompletion: onCompletion)
        } else {
            LoginManager().logIn(permissions: [.publicProfile, .email, .userGender, .userBirthday], viewController: ViewControllerUtils.getCenterViewController()) { (result) in
                switch result{
                case .cancelled :
                    AppDelegate.getAppDelegate().log.debug("Facebook Login Error :- User Cancelled")
                case .failed(let error) :
                    AppDelegate.getAppDelegate().log.debug("Facebook Login Error :- \(error.localizedDescription)")
                    onCompletion(nil, error)
                case .success(granted: let permission, declined: let declinedPermission, token: let accessToken) :
                    AppDelegate.getAppDelegate().log.debug("Permission granted for facebook with profile : \(permission),\(declinedPermission),\(accessToken)")
                    getUserDetails(onCompletion: onCompletion)
                }
            }
        }
    }
    
    class private func getUserDetails(onCompletion: @escaping FacebookLoginCompletionBlock){
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, gender, email, first_name, last_name, picture.type(large)"])) { (_,result, error) in
            if error != nil{
                AppDelegate.getAppDelegate().log.debug("Facebook Getting User Details Error :- \(error!.localizedDescription)")
                onCompletion(nil, error)
                return
            }
            if let resultData = result as? [String : AnyObject]{
                onCompletion(resultData, nil)
            }
        }
        connection.start()
    }
}
