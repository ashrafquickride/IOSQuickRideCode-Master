//
//  QuickShareNotificationHandler.swift
//  Quickride
//
//  Created by QR Mac 1 on 11/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class QuickShareNotificationHandler{
    
    //MARK: My posts
    func getAndShowMyPostedProduct(userNotification: UserNotification, viewController: UIViewController?) {
        getPostedProduct(userNotification: userNotification, viewController: viewController)
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = 2
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: routeTabBar, animated: false)
    }
    
    private func getPostedProduct(userNotification: UserNotification,viewController: UIViewController?){
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        let productNotification = Mapper<ProductNotification>().map(JSONString: msgObjectJson)
        if let notification = productNotification,let listingId = notification.listingId{
            QuickShareSpinner.start()
            QuickShareRestClient.getMyPostedProduct(listingId: listingId, userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
                QuickShareSpinner.stop()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let product = Mapper<PostedProduct>().map(JSONObject: responseObject!["resultData"]){
                        let postedProductDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PostedProductDetailsViewController") as! PostedProductDetailsViewController
                        postedProductDetailsViewController.initialiseProductDetails(postedProduct: product)
                        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: postedProductDetailsViewController, animated: false)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            }
        }
    }
    
    //MARK: My Orders
    func getAndShowParticularOrder(userNotification: UserNotification, viewController: UIViewController?,segment: String) {
        getMyOrder(userNotification: userNotification, viewController: viewController, segment: segment)
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = 2
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: routeTabBar, animated: false)
    }
    private func getMyOrder(userNotification: UserNotification,viewController: UIViewController?,segment: String){
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        let productNotification = Mapper<ProductNotification>().map(JSONString: msgObjectJson)
        if let notification = productNotification,let listingId = notification.listingId,let orderId = notification.orderId{
            QuickShareSpinner.start()
            QuickShareRestClient.getParticularOrder(listingId: listingId, userId: UserDataCache.getInstance()?.userId ?? "", orderId: orderId){ (responseObject, error) in
                QuickShareSpinner.stop()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let order = Mapper<Order>().map(JSONObject: responseObject!["resultData"]){
                        if segment == QuickShareHomePageViewModel.PLACED_ORDER{
                            self.showPlacedOrder(order: order, viewController: viewController)
                        }else{
                            self.showReceivedOrder(order: order, viewController: viewController)
                        }
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            }
        }
    }
    private func showPlacedOrder(order: Order,viewController: UIViewController?){
        let orderedProductDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OrderedProductDetailsViewController") as! OrderedProductDetailsViewController
        orderedProductDetailsViewController.initialiseOrderDetails(order: order, isFromMyOrder: true)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: orderedProductDetailsViewController, animated: false)
    }
    
    private func showReceivedOrder(order: Order,viewController: UIViewController?){
        let sellerOrderDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SellerOrderDetailsViewController") as! SellerOrderDetailsViewController
        sellerOrderDetailsViewController.initailiseReceivedOrder(order: order, isFromMyOrder: true)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: sellerOrderDetailsViewController, animated: false)
    }
    
    //MARK: Available Products
    func showProduct(viewController: UIViewController?,userNotification: UserNotification) {
        getProduct(userNotification: userNotification, viewController: viewController)
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = 2
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: routeTabBar, animated: false)
    }
    private func getProduct(userNotification: UserNotification,viewController: UIViewController?){
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        let productNotification = Mapper<ProductNotification>().map(JSONString: msgObjectJson)
        if let notification = productNotification{
            QuickShareSpinner.start()
            QuickShareRestClient.getSeletedProduct(listingId: notification.listingId ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
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
struct ProductNotification: Mappable{
    
    var listingId: String?
    var requestId: String?
    var orderId: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.listingId <- map["listingId"]
        self.requestId <- map["requestId"]
        self.orderId <- map["orderId"]
    }
}
