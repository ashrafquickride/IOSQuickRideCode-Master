//
//  InstallReferrer.swift
//  Quickride
//
//  Created by Admin on 22/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import FirebaseDynamicLinks

typealias urlPreparationCompletionHandler = (_ urlString: String?) -> Void

class InstallReferrer{
    
    static func handleReferralCode(shortUrl : URL){
        if SharedPreferenceHelper.getCurrentUserReferralCode() == nil{
            QuickRideProgressSpinner.startSpinner()
            shortUrl.expandURLWithCompletionHandler { (longURL) in
                QuickRideProgressSpinner.stopSpinner()
                if longURL != nil && longURL!.absoluteString.contains("referrer"){
                    let urlComponents = URLComponents(string: longURL!.absoluteString)
                    if urlComponents != nil && urlComponents!.queryItems != nil && !urlComponents!.queryItems!.isEmpty{
                        SharedPreferenceHelper.storeCurrentUserReferralCode(referralCode: urlComponents!.queryItems![0].value!)
                    }
                }
            }
        }
    }
    
    static func prepareURLForDeepLink(referralCode : String,completionHandler : @escaping urlPreparationCompletionHandler){
        
        let queryItems = URLQueryItem(name: "referrer", value: referralCode)
        let urlComps = NSURLComponents(string: AppConfiguration.quickride_url)!
        urlComps.queryItems = [queryItems]
        
        if let link = URL(string: urlComps.url!.absoluteString){
            
            let dynamicLinksDomainURIPrefix = AppConfiguration.quickride_firebase_link
            
            let dynamicIOSParams = DynamicLinkIOSParameters(bundleID: "com.disha.ios.quickride")
            
            dynamicIOSParams.fallbackURL = URL(string: AppConfiguration.application_link)
            
            let dynamicAndroidParams = DynamicLinkAndroidParameters(packageName: "com.disha.quickride")
            
            dynamicAndroidParams.fallbackURL = URL(string: AppConfiguration.application_link_android_url)
            
            let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
            
            linkBuilder?.iOSParameters = dynamicIOSParams
            linkBuilder?.androidParameters = dynamicAndroidParams
        
            if let longDynamicLink = linkBuilder?.url{
                generateShortUrl(longUrl: longDynamicLink,completionHandler: completionHandler)
            }else{
                completionHandler(nil)
            }
        } else {
            completionHandler(nil)
        }
        
        
        
        
    }
    
    static func generateShortUrl(longUrl : URL,completionHandler : @escaping urlPreparationCompletionHandler){
        DynamicLinkComponents.shortenURL(longUrl, options: nil) { url, warnings, error in
            if let url = url {
                completionHandler(url.absoluteString)
            }else {
                completionHandler(longUrl.absoluteString)
            }
       }
    }
    
    
}
