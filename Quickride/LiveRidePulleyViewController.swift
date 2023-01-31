////
////  LiveRidePulleyViewController.swift
////  Quickride
////
////  Created by Quick Ride on 6/25/20.
////  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
////  iDisha Info Labs Pvt Ltd. proprietary.
////
//
//import Foundation
//import Pulley
//import Lottie
//
//class LiveRidePulleyViewController: PulleyViewController {
//
//    //MARK: Outlets
//    @IBOutlet weak var viewFirstRideCreatedInfo: UIView!
//    @IBOutlet weak var labelFirstRideInfo1: UILabel!
//    @IBOutlet weak var labelFirstRideInfo2: UILabel!
//    @IBOutlet weak var backButton: UIButton!
//    @IBOutlet weak var labelRideScheduledTime: UILabel!
//    @IBOutlet weak var labelRideStatus: UILabel!
//    @IBOutlet weak var viewNotification: UIView!
//    @IBOutlet weak var buttonChat: CustomUIButton!
//    @IBOutlet weak var buttonChatWidthConstraint: NSLayoutConstraint!
//    @IBOutlet weak var buttonMenu: CustomUIButton!
//    @IBOutlet weak var buttonNoticicationIcon: CustomUIButton!
//    @IBOutlet weak var buttonPendingNotification: UIButton!
//    @IBOutlet weak var viewUnreadMsg: UIButton!
//    @IBOutlet weak var firstRideAnimationView: LOTAnimatedControl!
//    @IBOutlet weak var leftNavigationTopConstraint: NSLayoutConstraint!
////    @IBOutlet weak var topDataView: UIView!
////    @IBOutlet weak var topDataViewHeighConstraint: NSLayoutConstraint!
//
//    var riderRideId : Double?
//    var isFreezeRideRequired = false
//    var isFromSignupFlow = false
//    var rideObj : Ride?
//    var isFromRideCreation = false
//
//    func initializeDataBeforePresenting(riderRideId: Double?, rideObj: Ride?, isFromRideCreation: Bool, isFreezeRideRequired: Bool, isFromSignupFlow: Bool) {
//
//        self.riderRideId = riderRideId
//        self.isFreezeRideRequired = isFreezeRideRequired
//        self.isFromSignupFlow = isFromSignupFlow
//        self.rideObj = rideObj
//        self.isFromRideCreation = isFromRideCreation
//
//       }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let primary = segue.destination as? LiveRideMapViewController{
//            primary.initializeDataBeforePresenting(riderRideId: riderRideId, rideObj: rideObj, isFromRideCreation: isFromRideCreation, isFreezeRideRequired: isFreezeRideRequired, isFromSignupFlow: isFromSignupFlow)
//
//        }else if let secondary = segue.destination as? LiveRideCardViewController{
//            let liveRideMapVC = self.primaryContentViewController as? LiveRideMapViewController
//            secondary.initializeDataBeforePresenting(riderRideId: riderRideId, rideObj: rideObj, isFromRideCreation: isFromRideCreation, isFreezeRideRequired: isFreezeRideRequired, isFromSignupFlow: isFromSignupFlow, liveRideMapViewDelegate: liveRideMapVC.self)
//        }
//        
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //Can be removed
//        definesPresentationContext = true
//
//        if ViewCustomizationUtils.hasTopNotch{
//            leftNavigationTopConstraint.constant = 40
//        }
//
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        buttonMenu.changeBackgroundColorBasedOnSelection()
//        buttonChat.changeBackgroundColorBasedOnSelection()
//        buttonNoticicationIcon.changeBackgroundColorBasedOnSelection()
//        ViewCustomizationUtils.addBorderToView(view: buttonPendingNotification, borderWidth: 2.0, color: UIColor.white)
//        ViewCustomizationUtils.addBorderToView(view: viewUnreadMsg, borderWidth: 2.0, color: UIColor.white)
//
//
//    }
//
//    func displayRideScheduledTime(){
//        if let ride = (self.primaryContentViewController as? LiveRideMapViewController)!.liveRideViewModel.rideObj{
//            self.labelRideScheduledTime.text = RideViewUtils.getRideStartTime(ride: ride,format: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aa)
//        }
//
//
//    }
//    func updateRideViewControlsAsPerStatus(isFromSignupFlow  : Bool,rideParticipantCount : Int){
//        if !isFromSignupFlow {
//            if rideParticipantCount > 1{
//                buttonChat.isHidden = false
//                buttonChatWidthConstraint.constant = 45
//
//            }else{
//                buttonChat.isHidden = true
//                buttonChatWidthConstraint.constant = 0
//            }
//        }
//    }
//    func handleNotificationCountAndDisplay(){
//           let pendingNotificationCount =  NotificationStore.getInstance().getActionPendingNotificationCount()
//           if pendingNotificationCount > 0 {
//               buttonPendingNotification.isHidden = false
//               buttonPendingNotification.setTitle(String(pendingNotificationCount), for: .normal)
//           } else {
//               buttonPendingNotification.isHidden = true
//           }
//           let notificationsMap = NotificationStore.getInstance().getAllNotifications()
//           if notificationsMap.isEmpty {
//               viewNotification.isHidden = true
//           } else{
//               viewNotification.isHidden = false
//           }
//       }
//
//    //MARK: Displaying first ride creation animation coming from Signup flow
//    func displayFirstRideCreationView(isFromSignupFlow : Bool) {
//        if isFromSignupFlow {
//            self.viewFirstRideCreatedInfo.isHidden = false
//            self.viewFirstRideCreatedInfo.backgroundColor = UIColor(netHex: 0x00b557)
//            self.labelFirstRideInfo1.text = "Cool! You have created your first ride"
//            self.labelFirstRideInfo2.text = "Finding rides for you..."
//            firstRideAnimationView.animationView.setAnimation(named: "signup_like")
//            firstRideAnimationView.animationView.play()
//            firstRideAnimationView.animationView.loopAnimation = true
//
//        }
//        else{
//            firstRideAnimationView.animationView.stop()
//            self.viewFirstRideCreatedInfo.isHidden = true
//        }
//    }
//    func displayRideStatusAndFareDetailsToUser(text : String){
//        self.labelRideStatus.text = text
//    }
//    func checkNewMessage(){
//        let unreadCount = MessageUtils.getUnreadCountOfChat()
//        if unreadCount > 0{
//            viewUnreadMsg.isHidden = false
//            viewUnreadMsg.setTitle(String(unreadCount), for: .normal)
//        }else{
//            viewUnreadMsg.isHidden = true
//        }
//    }
//
//    func changeLabelTextAndImage(matchedUserCount: Int){
//        firstRideAnimationView.animationView.stop()
//        firstRideAnimationView.animationView.setAnimation(named: "signup_star")
//        UIView.transition(with: firstRideAnimationView.animationView,
//                          duration: 1,
//                          options: .transitionCrossDissolve,
//                          animations: {
//                            self.firstRideAnimationView.animationView.play()
//                            self.firstRideAnimationView.animationView.loopAnimation = true
//        }, completion: nil)
//        UIView.transition(with: viewFirstRideCreatedInfo,
//                          duration: 1,
//                          options: .transitionCrossDissolve,
//                          animations: {
//                            self.viewFirstRideCreatedInfo.backgroundColor = UIColor(netHex: 0xd64361)
//        }, completion: nil)
//        UIView.transition(with: labelFirstRideInfo1,
//                          duration: 1,
//                          options: .transitionCrossDissolve,
//                          animations: {
//                            self.labelFirstRideInfo1.text = "Awesome! Found " + "\(matchedUserCount)" + " rides"
//        }, completion: nil)
//        UIView.transition(with: labelFirstRideInfo2,
//                          duration: 1,
//                          options: .transitionCrossDissolve,
//                          animations: {
//                            self.labelFirstRideInfo2.text = "Redirecting there..."
//        }, completion: nil)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            if let liveRideMapViewController = self.primaryContentViewController as? LiveRideMapViewController{
//                liveRideMapViewController.liveRideViewModel.isFromSignupFlow = false
//                self.firstRideAnimationView.animationView.stop()
//                liveRideMapViewController.liveRideViewModel.moveToInvite(isFromContacts: false)
//
//            }
//        }
//    }
//
//    @IBAction func backButtonAction(_ sender: Any) {
//        if pulleyViewController?.drawerPosition == .open {
//            pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
//        } else {
//            (self.primaryContentViewController as? LiveRideMapViewController)?.goBackToCallingViewController()
//        }
//    }
//
//
//}
