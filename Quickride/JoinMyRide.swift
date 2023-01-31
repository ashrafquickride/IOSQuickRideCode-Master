//
//  JoinMyRide.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import FirebaseDynamicLinks

class JoinMyRide{
    
    func prepareDeepLinkURLForRide(rideId: String,riderId : String,from: String, to: String, startTime: Double, vehicleType: String, viewController: UIViewController?,isFromTaxiPool: Bool){
        let queryItems = [URLQueryItem(name: "rideId", value: rideId),URLQueryItem(name: "riderId", value: riderId),URLQueryItem(name: "isFromTaxiPool", value: String(isFromTaxiPool)),URLQueryItem(name: "referrer", value: UserDataCache.getInstance()?.getReferralCode())]
        let urlComps = NSURLComponents(string: AppConfiguration.quickride_url)!
        urlComps.queryItems = queryItems
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
                self.generateShortUrl(longUrl: longDynamicLink,from: from, to: to, startTime: startTime, vehicleType: vehicleType, viewController: viewController, isFromTaxiPool: isFromTaxiPool)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: viewController, handler: nil)
            }
        } else {
            MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: viewController, handler: nil)
        }
    }
    func getDeepLinkURLForTaxiPool(rideId: String,riderId : String,from: String, to: String, startTime: Double, handler: @escaping (_ message : String) -> Void){
        let queryItems = [URLQueryItem(name: "rideId", value: rideId),URLQueryItem(name: "riderId", value: riderId),URLQueryItem(name: "isFromTaxiPool", value: "true"),URLQueryItem(name: "referrer", value: UserDataCache.getInstance()?.getReferralCode())]
        let urlComps = NSURLComponents(string: AppConfiguration.quickride_url)!
        urlComps.queryItems = queryItems
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
                DynamicLinkComponents.shortenURL(longDynamicLink, options: nil) { url, warnings, error in
                    
                    let fromLocation = self.shortFromAndToloaction(location: from)
                    let ToLocation = self.shortFromAndToloaction(location: to)
                    let rideTime = RideValidationUtils.getRideTimeInString(rideTime: startTime) ?? ""
                    handler(String(format: Strings.share_taxi_invite_msg, arguments: [fromLocation,ToLocation,rideTime, url?.absoluteString ?? longDynamicLink.absoluteString]))
                }
            }
        }
    }
    
    private func generateShortUrl(longUrl : URL,from: String, to: String,startTime: Double, vehicleType: String, viewController: UIViewController?,isFromTaxiPool: Bool){
        DynamicLinkComponents.shortenURL(longUrl, options: nil) { url, warnings, error in
            if let url = url {
                self.shareRideContext(urlString: url.absoluteString, from: from, to: to,startTime: startTime, vehicleType: vehicleType, viewController: viewController,isFromTaxiPool: isFromTaxiPool)
            }else {
                self.shareRideContext(urlString: longUrl.absoluteString, from: from, to: to,startTime: startTime, vehicleType: vehicleType, viewController: viewController,isFromTaxiPool: isFromTaxiPool)
            }
        }
    }
   
    
    private func shareRideContext(urlString: String,from: String, to: String,startTime: Double, vehicleType: String, viewController: UIViewController?,isFromTaxiPool: Bool){
        let fromLocation = shortFromAndToloaction(location: from)
        let ToLocation = shortFromAndToloaction(location: to)
        let rideTime = RideValidationUtils.getRideTimeInString(rideTime: startTime) ?? ""
        var message = ""
        if isFromTaxiPool{
            message = String(format: Strings.share_taxi_invite_msg, arguments: [fromLocation,ToLocation,rideTime,urlString])
        }else{
            var inOrOn = ""
            if vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                inOrOn = "on"
            }else{
                inOrOn = "in"
            }
            message = String(format: Strings.share_ride_invite_msg, arguments: [fromLocation,ToLocation,rideTime,inOrOn,vehicleType,urlString])
        }
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print,UIActivity.ActivityType.copyToPasteboard]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes?.append(UIActivity.ActivityType.markupAsPDF)
            avc.excludedActivityTypes?.append(UIActivity.ActivityType.openInIBooks)
        }
        avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast(Strings.message_sent)
            }
        }
        viewController?.present(avc, animated: true, completion: nil)
    }
    
    private func shortFromAndToloaction(location: String) -> String{
        let longLocation : [String] = location.components(separatedBy: ",")
        let shortLocation = longLocation[0] + ", " + longLocation[1] + ", " + longLocation[2]
        return shortLocation
    }
    
    static func handleJoinMyRideRideId(shortUrl : URL){
        QuickRideProgressSpinner.startSpinner()
        shortUrl.expandURLWithCompletionHandler { (longURL) in
            QuickRideProgressSpinner.stopSpinner()
            if longURL != nil && longURL!.absoluteString.contains("rideId") && longURL!.absoluteString.contains("riderId"){
                let urlComponents = URLComponents(string: longURL!.absoluteString)
                if urlComponents != nil && urlComponents!.queryItems != nil && !urlComponents!.queryItems!.isEmpty{
                    var isFromTaxipool = ""
                    if longURL!.absoluteString.contains("isFromTaxiPool"){
                        isFromTaxipool = urlComponents!.queryItems![2].value!
                    }
                    SharedPreferenceHelper.storeJoinMyRideIdAndRiderId(rideId: urlComponents!.queryItems![0].value!,riderId: urlComponents!.queryItems![1].value!,isFromTaxipool: Bool(isFromTaxipool) ?? false)
                    if SessionManagerController.sharedInstance.isSessionManagerInitialized() == true, let rideId = SharedPreferenceHelper.getJoinMyRideRideId(), let riderId = SharedPreferenceHelper.getJoinMyRideRiderId(){
                        DispatchQueue.main.async {
                            let joinMyRidePassengerSideHandler =  JoinMyRidePassengerSideHandler()
                            joinMyRidePassengerSideHandler.getComplateRiderRideThroughRideId(rideId: rideId, riderId: riderId, isFromSignUpFlow: false,viewController: ViewControllerUtils.getCenterViewController())
                        }
                    }
                }
            }
        }
    }
}

