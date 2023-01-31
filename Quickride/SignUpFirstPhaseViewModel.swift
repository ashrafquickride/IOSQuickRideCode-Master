//
//  SignUpFirstPhaseViewModel.swift
//  Quickride
//
//  Created by Admin on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import ObjectMapper

class SignUpFirstPhaseViewModel{
    
    //MARK: Properties
    var user : User?
    var userProfile : UserProfile?
    
    //MARK: Methods
        
    func performServerCallToGetUser(userId : String,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.getUser(userId: userId, targetViewController: nil, completionHandler: handler)
    }
    
    func getUserObject(responseObject: NSDictionary?) -> User?{
        return Mapper<User>().map(JSONObject: responseObject?["resultData"])
    }
    
    
    func performServerCallToGetUserProfile(userId : String,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.getProfile(userId: userId, targetViewController: nil, completionHandler: handler)
    }
    
    func getUserProfileObject(responseObject: NSDictionary?) -> UserProfile?{
        return Mapper<UserProfile>().map(JSONObject: responseObject?["resultData"])
    }
    
    func sendVerificationCodeToUser(viewController : UIViewController,user : User?,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: viewController, handler: nil)
            return
        }
        var putBodyDictionary = ["phone" : StringUtils.getStringFromDouble(decimalNumber: user?.contactNo)]
        putBodyDictionary[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
        putBodyDictionary[User.FLD_COUNTRY_CODE] = user?.countryCode
        
        UserRestClient.resendVerficiationCode(putBodyDictionary: putBodyDictionary, uiViewController: viewController, completionHandler: handler)
    }
    
}
