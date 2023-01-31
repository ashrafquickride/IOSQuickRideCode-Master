//
//  QuickJobsNotificationHandler.swift
//  Quickride
//
//  Created by QR Mac 1 on 06/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class QuickJobsNotificationHandler: NotificationHandler{
    
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        let iconURI = clientNotification.iconUri
        if iconURI == nil{
            imageView.image = UIImage(named: "jobs_notification")
        }else{
            ImageCache.getInstance().setImageToViewFromURL(imageView: imageView, imageUrl: iconURI)
        }
    }
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        let jobNotification = Mapper<QuickJobNotification>().map(JSONString: msgObjectJson)
        if let jobUrl = jobNotification?.fallbackUrl{
            QuickJobsURLHandler.showPerticularJobInQuickJobPortal(jobUrl: jobUrl)
        }
    }
}

struct QuickJobNotification: Mappable{
    
    var fallbackUrl: String?
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.fallbackUrl <- map["fallbackUrl"]
    }
}
