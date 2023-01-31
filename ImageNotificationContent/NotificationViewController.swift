//
//  NotificationViewController.swift
//  ImageNotificationContent
//
//  Created by Admin on 09/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import SDWebImage

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        let aps = content.userInfo["aps"] as? [String: AnyObject]
        if aps != nil{
            let alertBody = aps!["alert"]
            if alertBody != nil{
                self.titleLabel.text = alertBody!.value(forKey: "title") as? String
                self.descriptionLabel.text = alertBody!.value(forKey: "body") as? String
            }
        }
        if let urlImageString = content.userInfo["attachment_url"] as? String{
            let URL = NSURL(string: urlImageString)
            
            if URL == nil{
                return
            }
            
            self.imageView.sd_setImage(with: URL as URL?, completed: nil)
        }
    }

}

