//
//  QuickShareUrlHandler.swift
//  Quickride
//
//  Created by QR Mac 1 on 19/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import FirebaseDynamicLinks
import ObjectMapper

class QuickShareUrlHandler{
    
    static let PRODUCT_POST = "PRODUCT_POST"
    static let PRODUCT_REQUEST = "PRODUCT_REQUEST"
    
    static func handleProductUrl(shortUrl : URL){
        shortUrl.expandURLWithCompletionHandler { (longURL) in
            if let url = longURL,url.absoluteString.contains("producId"),url.absoluteString.contains("urlType"){
                let urlComponents = URLComponents(string: url.absoluteString)
                if let urlcompnts = urlComponents,let queryItems = urlcompnts.queryItems, queryItems.count >= 2{
                    if SessionManagerController.sharedInstance.isSessionManagerInitialized(){
                        DispatchQueue.main.async {
                            showProductInQuickShare(productId: queryItems[0].value, needType: queryItems[1].value, viewController: ViewControllerUtils.getCenterViewController())
                        }
                    }else{
                        SharedPreferenceHelper.storeProductUrl(url: queryItems[0].value, type: queryItems[1].value)
                    }
                }
            }
        }
    }
    
    static func prepareURLForDeepLink(producId : String,type: String,completionHandler : @escaping urlPreparationCompletionHandler){
        let queryItems = [URLQueryItem(name: "producId", value: producId),URLQueryItem(name: "urlType", value: type)]
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
                InstallReferrer.generateShortUrl(longUrl: longDynamicLink,completionHandler: completionHandler)
            }else{
                completionHandler(nil)
            }
        }else{
            completionHandler(nil)
        }
    }
    
    static func showProductInQuickShare(productId: String?,needType: String?,viewController: UIViewController?){
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = 2
        SharedPreferenceHelper.storeProductUrl(url: nil, type: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: routeTabBar, animated: false)
        guard let listingId = productId,let type = needType else { return }
        if type == PRODUCT_POST{
            QuickShareSpinner.start()
            QuickShareRestClient.getSeletedProduct(listingId: listingId, userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
                QuickShareSpinner.stop()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let product = Mapper<AvailableProduct>().map(JSONObject: responseObject!["resultData"]){
                        let productViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
                        productViewController.initialiseView(product: product, isFromOrder: false)
                        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: productViewController, animated: false)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            }
        }
    }
}
