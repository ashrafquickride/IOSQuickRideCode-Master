//
//  NotificationViewController.swift
//  Content Extension
//
//  Created by Admin on 04/06/18.
//  Copyright © 2018 NetCore. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import NetCorePush

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var customBgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        
        NetCoreNotificationService.sharedInstance().contentViewDidLoad(customBgView)
    }
    
    func didReceive(_ notification: UNNotification) {
        
        NetCoreNotificationService.sharedInstance().didReceive(notification)
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        NetCoreNotificationService.sharedInstance().didReceive(response) { (UNNotificationContentExtensionResponseOption) in
        }
    }

}
