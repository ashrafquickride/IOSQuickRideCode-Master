//
//  FacebookLoginManager.swift
//  Quickride
//
//  Created by Admin on 15/10/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation
import FacebookLogin
import FacebookCore

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
                    print("user Cancelled")
                case .failed(let error) :
                    onCompletion(nil, error)
                case .success(granted: let permission, declined: let declinedPermission, token: let accessToken) :
                    print("Permission granted with profile : \(permission),\(declinedPermission),\(accessToken)")
                    getUserDetails(onCompletion: onCompletion)
                }
            }
        }
    }
    
    class private func getUserDetails(onCompletion: @escaping FacebookLoginCompletionBlock){
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, gender, email, first_name, last_name, picture.type(large)"])) { (_,result, error) in
            if error != nil{
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
