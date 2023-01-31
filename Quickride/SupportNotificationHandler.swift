//
//  SupportNotificationHandler.swift
//  Quickride
//
//  Created by Vinutha on 6/14/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SupportNotificationHandler: NotificationHandler{
    
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named: "app_icon_small"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "app_icon_small")
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        
        if userNotification.msgObjectJson == nil{
            moveToRespectiveTab(indexToSelect: 0, viewController: viewController)
            return 
        }
        let actionText = Mapper<SupportNotification>().map(JSONString: userNotification.msgObjectJson!)
        if actionText == nil{
           super.handleTap(userNotification: userNotification, viewController: viewController)
            return
        }
        if (actionText!.url != nil && actionText!.url!.isEmpty == false){
            let queryItems = URLQueryItem(name: "&isMobile", value: "true")
            var urlcomps = URLComponents(string :  actionText!.url!)
            if let _ = urlcomps?.queryItems{
                urlcomps?.queryItems?.append(queryItems)
            }else{
                urlcomps?.queryItems = [queryItems]
            }
            
            if urlcomps?.url == nil{
                return
            }
            if urlcomps?.url != nil{
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.initializeDataBeforePresenting(titleString: Strings.quickride, url: urlcomps!.url!, actionComplitionHandler: nil)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: webViewController, animated: false)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        } else if actionText!.className != nil && !actionText!.className!.isEmpty && actionText!.storyBoardName != nil && !actionText!.storyBoardName!.isEmpty {
            if let className = actionText?.className {
                switch className {
                case ViewControllerIdentifiers.routeViewController, ViewControllerIdentifiers.createRideHomeViewController:
                    moveToRespectiveTab(indexToSelect: 0, viewController: viewController)
                case ViewControllerIdentifiers.taxiHomePageViewController:
                    moveToRespectiveTab(indexToSelect: 1, viewController: viewController)
                case ViewControllerIdentifiers.quickShareHomePageViewController :
                    moveToRespectiveTab(indexToSelect: 3, viewController: viewController)
                default:
                    let moveToViewController = UIStoryboard(name: actionText!.storyBoardName!, bundle: nil).instantiateViewController(withIdentifier: actionText!.className!)
                    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: moveToViewController, animated: false)
                }
            }
        }else if let deeplink = actionText?.deeplink{
            switch deeplink {
            case SupportNotification.TAXI_INTERNAL_DEEPLINK_HOMEPAGE,SupportNotification.TAXI_INTERNAL_DEEPLINK_NEWRIDE:
                moveToRespectiveTab(indexToSelect: 1, viewController: viewController)
            case SupportNotification.QUICK_JOB_INTERNAL_DEEPLINK:
                    moveToRespectiveTab(indexToSelect: 4, viewController: viewController)
            default:
                break
            }
        } else {
            moveToRespectiveTab(indexToSelect: 0, viewController: viewController)
        }
        super.handleTap(userNotification: userNotification, viewController: viewController)
    }
    
    private func moveToRespectiveTab(indexToSelect: Int, viewController: UIViewController?) {
        let tabBarVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = indexToSelect
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: tabBarVC, animated: false)
    }
}
