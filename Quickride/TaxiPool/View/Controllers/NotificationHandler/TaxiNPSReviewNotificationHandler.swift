//
//  TaxiNPSReviewNotificationHandler.swift
//  Quickride
//
//  Created by Rajesab on 12/05/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiNPSReviewNotificationHandler: NotificationHandler{
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        if let notification = Mapper<TaxiNPSReview>().map(JSONString: msgObjectJson){
            if let url = notification.deeplinkUrl{
                let queryItems = URLQueryItem(name: "&isMobile", value: "true")
                var urlcomps = URLComponents(string :  url)
                urlcomps?.queryItems = [queryItems]
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.initializeDataBeforePresenting(titleString: Strings.quickride, url: urlcomps?.url, actionComplitionHandler: nil)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: webViewController, animated: false)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
    
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "taxi_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "taxi_notification_icon")
        }
    }
}

class TaxiNPSReview: NSObject, Mappable{
    var taxiRideId: String?
    var deeplinkUrl: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        taxiRideId <- map["taxiRideId"]
        deeplinkUrl <- map["deeplinkUrl"]
    }
}
