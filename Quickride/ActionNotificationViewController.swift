//
//  ActionNotificationViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 12/03/16.
//  Copyright © 2016 iDisha. All rights reserved.
//

import Foundation
import UIKit

class ActionNotificationViewController: UIViewController {
    
    @IBOutlet weak var notificationTitle: UILabel!
    
    @IBOutlet weak var notificationDescription: UILabel!
    
    @IBOutlet weak var positiveButton: UIButton!
    
    @IBOutlet weak var negativeButton: UIButton!
    
    @IBOutlet weak var neutralButton: UIButton!
    
    var notificationHandler : NotificationHandler?
    var userNotification : UserNotification?
    
    func initializeDataBeforePresenting(notificationHandler : NotificationHandler,userNotification : UserNotification){
         AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting()")
        self.notificationHandler = notificationHandler
        self.userNotification = userNotification
    }
    
    override func viewDidLoad() {
         AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        self.notificationTitle.text = userNotification?.title
        self.notificationDescription.text = userNotification?.description
        ViewCustomizationUtils.addCornerRadiusToView(positiveButton, cornerRadius: 2.0)
        ViewCustomizationUtils.addCornerRadiusToView(negativeButton, cornerRadius: 2.0)
        ViewCustomizationUtils.addCornerRadiusToView(neutralButton, cornerRadius: 2.0)
        
        var actionLabel =  notificationHandler?.getPositiveActionNameWhenApplicable(userNotification!)
        if actionLabel == nil || actionLabel?.isEmpty == true{
            positiveButton.hidden = true
        }else{
            positiveButton.hidden = false
            positiveButton.setTitle(actionLabel, forState: UIControlState.Normal)
        }
        actionLabel = notificationHandler?.getNegativeActionNameWhenApplicable(userNotification!)
        if actionLabel == nil || actionLabel?.isEmpty == true{
            self.negativeButton.hidden = true
        }else{
            self.negativeButton.hidden = false
            self.negativeButton.setTitle(actionLabel, forState: UIControlState.Normal)
        }
        actionLabel = notificationHandler?.getNeutralActionNameWhenApplicable(userNotification!)
        if actionLabel == nil || actionLabel?.isEmpty == true{
            self.neutralButton.hidden = true
        }else{
            self.neutralButton.hidden = false
            self.neutralButton.setTitle(actionLabel, forState: UIControlState.Normal)
        }
    }
  
    @IBAction func cancelAction(sender: AnyObject) {
      AppDelegate.getAppDelegate().log.debug("cancelAction()")
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    @IBAction func positiveButtonAction(sender: AnyObject) {
      AppDelegate.getAppDelegate().log.debug("positiveButtonAction()")
        self.notificationHandler?.handlePositiveAction(self.userNotification!, viewController: self)
    }
    
    @IBAction func negativeButtonAction(sender: AnyObject) {
      AppDelegate.getAppDelegate().log.debug("negativeButtonAction()")
        self.notificationHandler?.handleNegativeAction(self.userNotification!, viewController: self)
    }
    
    @IBAction func neutralButtonAction(sender: AnyObject) {
      AppDelegate.getAppDelegate().log.debug("neutralButtonAction()")
        self.notificationHandler?.handleNeutralAction(self.userNotification!, viewController: self)
    }
}