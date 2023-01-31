//
//  NotificationView.swift
//  Quickride
//
//  Created by QuickRideMac on 02/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper

class NotificationView: UIView {
    
    @IBOutlet weak var viewTopPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonVIewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var positiveButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var negativeButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var neutralButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var positiveButton: UIButton!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var neutralButton: UIButton!
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    //Moderator
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var moderatorImageView: UIImageView!
    @IBOutlet weak var moderatorTitleView: UIView!
    @IBOutlet weak var moderatorTitleViewHeightConstraint: NSLayoutConstraint!
    
    var notification : UserNotification?
    var notificationHandler : NotificationHandler?
    var viewController : UIViewController?
    var timer : Timer?
    
    func show(viewController: UIViewController,notification: UserNotification,notificationHandler: NotificationHandler) {
        DispatchQueue.main.async(){ [self] in
            if ViewCustomizationUtils.hasTopNotch{
                topConstraint.constant = 45
            }else{
                topConstraint.constant = 20
            }
            self.notification = notification
            self.viewController = viewController
            self.notificationHandler = notificationHandler
            
            titleLabel.text = notification.title
            messageLabel.text = notification.description
            notificationHandler.setNotificationIcon(clientNotification: notification, imageView: notificationIcon)
            checkActionAndAddButtons()
            checkAndShowModeratorIconAndText()
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NotificationView.tapped(_:))))
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(NotificationView.swipe(_:)))
            swipeLeft.direction = .left
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(NotificationView.swipe(_:)))
            swipeRight.direction = .right
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(NotificationView.swipe(_:)))
            swipeRight.direction = .up
            notificationView.addGestureRecognizer(swipeLeft)
            notificationView.addGestureRecognizer(swipeRight)
            notificationView.addGestureRecognizer(swipeUp)
            if notification.sendFrom != 0{
                notificationIcon.isUserInteractionEnabled = true
                notificationIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NotificationView.notificationIconTapped(_:))))
            }
            
            NotificationStore.getInstance().presentDisplayingNotification?.removeFromSuperview()
            UIApplication.shared.keyWindow?.addSubview(self)
            NotificationStore.getInstance().setPresentDisplayingNotification(view: self)
            timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(NotificationView.removeView), userInfo: nil, repeats: true)
            UIView.animate(withDuration: 0.8, delay: 0, options: [.transitionCurlUp],
                           animations: {
                            self.notificationView.frame.origin.y += self.notificationView.bounds.height
            }, completion: nil)
            self.notificationView.layoutIfNeeded()
            self.layoutIfNeeded()
            self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: notificationView.frame.size.height)
        }
    }
    
    private func checkAndShowModeratorIconAndText() {
        if RideViewUtils.isModetatorNotification(userNotification: notification) {
            moderatorTitleView.isHidden = false
            moderatorImageView.isHidden = false
        } else {
            moderatorTitleView.isHidden = true
            moderatorImageView.isHidden = true
        }
    }
    
    
    private func checkActionAndAddButtons(){
        AppDelegate.getAppDelegate().log.debug("checkAndaddActionButton()")
        if let actionName = notificationHandler?.getPositiveActionNameWhenApplicable(userNotification: notification!){
            positiveButton.isHidden = false
            positiveButton.setTitle(actionName, for: UIControl.State.normal)
            buttonsView.isHidden = false
        }else{
            positiveButton.isHidden = true
        }
        
        if let actionName = notificationHandler?.getNegativeActionNameWhenApplicable(userNotification: notification!){
            negativeButton.isHidden = false
            negativeButton.setTitle(actionName, for: UIControl.State.normal)
            buttonsView.isHidden = false
        }else{
            negativeButton.isHidden = true
        }
        
        if let actionName = notificationHandler!.getNeutralActionNameWhenApplicable(userNotification: notification!){
            neutralButton.isHidden = false
            neutralButton.setTitle(actionName, for: UIControl.State.normal)
            buttonsView.isHidden = false
        }else{
            neutralButton.isHidden = true
        }
        let width = (buttonsView.frame.size.width-80)/3
        positiveButtonWidth.constant = width
        negativeButtonWidth.constant = width
        neutralButtonWidth.constant = width
    }
    
    @objc func tapped(_ gesture : UITapGestureRecognizer){
        removeView()
        notificationHandler?.handleTap(userNotification: notification!, viewController: viewController)
    }
    
    @objc func notificationIconTapped(_ gesture : UITapGestureRecognizer){
        if notification == nil || notification!.sendFrom == 0{
            return
        }
        let profile:ProfileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: notification!.sendFrom),isRiderProfile: RideManagementUtils.getUserRoleBasedOnRide(), rideVehicle: nil,userSelectionDelegate: nil,displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profile, animated: false)
        removeView()
    }
    
    @objc func removeView(){
        removeFromSuperview()
    }
    
    @objc func swipe(_ gesture : UISwipeGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("swipe()")
        if gesture.direction == .left{
            removeNotificationFromLeft()
        }else if gesture.direction == .right{
            removeNotificationFromRight()
        }else{
            removeNotificationFromUp()
        }
    }
    
    private func removeNotificationFromLeft(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionFlipFromRight],
                       animations: {
                        self.notificationView.frame.origin.x += self.notificationView.bounds.width
                        self.notificationView.frame.origin.x = 0
                       }, completion: {(_ completed: Bool) -> Void in
                        self.notificationView.isHidden = true
                        self.removeFromSuperview()
                       })
    }
    private func removeNotificationFromRight(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionFlipFromLeft],
                       animations: {
                        self.notificationView.frame.origin.x += self.notificationView.bounds.width
                       }, completion: {(_ completed: Bool) -> Void in
                        self.notificationView.isHidden = true
                        self.removeFromSuperview()
                       })
    }
    
    private func removeNotificationFromUp(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionFlipFromRight],
                       animations: {
                        self.notificationView.frame.origin.y = 0
                        self.notificationView.frame.origin.y += 0
                       }, completion: {(_ completed: Bool) -> Void in
                        self.notificationView.isHidden = true
                        self.removeFromSuperview()
                       })
    }
    
    
    @IBAction func positiveActionClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("positiveActionClicked")
        positiveButton.isEnabled = false
        removeView()
        notificationHandler?.handlePositiveAction(userNotification: notification!, viewController: nil)
    }
    
    @IBAction func negativeButtonClicked(_ sender: Any) {
        negativeButton.isEnabled = false
        removeView()
        notificationHandler?.handleNegativeAction(userNotification: notification!, viewController: nil)
    }
    
    @IBAction func neutralButtonClicked(_ sender: Any) {
        removeView()
        notificationHandler?.handleNeutralAction(userNotification: notification!, viewController: nil)
    }
}
