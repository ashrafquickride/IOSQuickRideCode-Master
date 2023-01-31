//
//  NotificationViewController.swift
//  Quickride
//
//  Created by KNM Rao on 02/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,NotificationChangeListener {
    
    @IBOutlet weak var startExploringText: UIButton!
    
    @IBOutlet weak var settingsBtn: UIButton!
    
    @IBAction func ibaAccept(_ sender: UIButton) {
        
        if notifications.count <= sender.tag{
            return
        }
        sender.isEnabled = false
        let notification = notifications[sender.tag]
        let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification)
        notificationHandler?.handlePositiveAction(userNotification: notification,viewController: self)
    }
    
    @IBAction func startExploringAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
       
    }
    
    @IBOutlet weak var clearNotificationsButton: UIButton!
    @IBAction func notificationsClearAction(_ sender: Any) {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.do_you_want_to_delete_notifications, message2: nil, positiveActnTitle: Strings.no_caps,negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                NotificationStore.getInstance().clearUserSession()
                self.loadNotifications()
            }
        })
    }
    @IBOutlet weak var noNotificationsView: UIView!
    @IBOutlet weak var notifcationsTableView: UITableView!
    
  @IBAction func ibaReject(_ sender: UIButton) {
    
    if notifications.count <= sender.tag{
        return
    }
        let notification = notifications[sender.tag]
        let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification)
        notificationHandler?.handleNegativeAction(userNotification: notification,viewController: self)
    }
    
    @IBAction func ibaProfile(_ sender: UIButton) {
        //sender.enabled = false
        if notifications.count <= sender.tag{
            return
        }
        let notification = notifications[sender.tag]
        let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification)
        notificationHandler?.handleNeutralAction(userNotification: notification,viewController: self)
    }
    
    @objc func notificaitonIconTapped(_ gesture : UITapGestureRecognizer){
        if notifications.count <= gesture.view!.tag{
            return
        }
        let notification = notifications[gesture.view!.tag]

        if notification.sendFrom == 0{
            return
        }

        let profile:ProfileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: notification.sendFrom),isRiderProfile: RideManagementUtils.getUserRoleBasedOnRide(), rideVehicle: nil,userSelectionDelegate: nil,displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: profile, animated: false)
    }
    
    @IBAction func ibaCancel(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    var notifications:[UserNotification] = [UserNotification]()
    var currentSelectedRowIndex : Int?
    static let notificationViewControllerKey = "NotificationViewController"
  
    override func viewDidLoad() {
        super.viewDidLoad()

      startExploringText.setTitleColor(Colors.defaultTextColor, for: .normal)
        
      NotificationStore.getInstance().addNotificationListChangeListener(key: NotificationViewController.notificationViewControllerKey, listener: self)
        self.notifcationsTableView.estimatedRowHeight = 80
        self.notifcationsTableView.rowHeight = UITableView.automaticDimension
        self.notifcationsTableView.isMultipleTouchEnabled = false
        self.notifcationsTableView.setNeedsLayout()
        self.notifcationsTableView.layoutIfNeeded()
        
        self.notifcationsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        loadNotifications()
        checkAndUpdateSeenStatusToServerForInvitations()
        RideViewUtils.displaySubscriptionDialogueBasedOnStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentSelectedRowIndex = nil
        self.navigationController?.isNavigationBarHidden = true
        
    }

    
    func checkAndUpdateSeenStatusToServerForInvitations(){
      AppDelegate.getAppDelegate().log.debug("checkAndUpdateSeenStatusToServerForInvitations()")
        for clientNotification in notifications{
            if clientNotification.type ==  UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION || clientNotification.type ==  UserNotification.NOT_TYPE_RM_RIDER_INVITATION || clientNotification.type ==  UserNotification.NOT_TYPE_RM_INVITATION_TO_OLD_USER || UserNotification.NOT_TYPE_RM_CONTACT_INVITATION == clientNotification.type || clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_TO_MODERATOR || clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_WITH_REQUESTED_FARE_TO_MODERATOR {
                let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: clientNotification)!

                
                if rideInvitation.invitationStatus != RideInvitation.RIDE_INVITATION_STATUS_READ{
                    RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_READ, viewController: nil, completionHandler: { (responseObject, error) in
                        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                            rideInvitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_READ
                            let jsonMessage = Mapper().toJSONString(rideInvitation , prettyPrint: true)
                            clientNotification.msgObjectJson = jsonMessage
                            NotificationStore.getInstance().updateNotification(notification: clientNotification)
                        }
                    })
                }
            }else if clientNotification.type == UserNotification.NOT_TAXI_INVITE || clientNotification.type == UserNotification.NOT_TAXI_INVITE_BY_CONTACT{
                updateTaxiInviteStatus(notification: clientNotification)
            }
        }
    }
    func updateTaxiInviteStatus(notification: UserNotification){ //taxi invite status update
        guard var taxiInvite = Mapper<TaxiPoolInvite>().map(JSONString: notification.msgObjectJson ?? "")else { return }
        TaxiSharingRestClient.updateTaxiInviteStatus(inviteId: taxiInvite.id ?? "", invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_READ){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                taxiInvite.status = TaxiPoolInvite.TAXI_INVITE_STATUS_READ
                let jsonMessage = Mapper().toJSONString(taxiInvite , prettyPrint: true)
                notification.msgObjectJson = jsonMessage
                NotificationStore.getInstance().updateNotification(notification: notification)
            }
        }
    }
    
    func handleNotificationListChange(){
        loadNotifications()
    }
    func loadNotifications(){
      notifcationsTableView.delegate = nil
      notifcationsTableView.dataSource = nil
      AppDelegate.getAppDelegate().log.debug("loadNotifications()")
        var notificationsTemp = [UserNotification]()
        let notificationsMap = NotificationStore.getInstance().getAllNotifications()
        for notificaiton in notificationsMap{
            let handler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notificaiton.1)
            if handler != nil {
                notificationsTemp.append(notificaiton.1)
          }else{
            NotificationStore.getInstance().deleteNotificationInCache(notificationId: notificaiton.1.notificationId!)
          }
        }
        if  notificationsTemp.isEmpty == true{
          noNotificationsView.isHidden = false
          notifcationsTableView.isHidden = true
          clearNotificationsButton.isHidden = true
          clearNotificationsButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
          settingsBtn.frame = CGRect(x: 272, y: 6, width: 32, height: 32)
          notifcationsTableView.delegate = nil
          notifcationsTableView.dataSource = nil
        }else{
            
            self.notifications.removeAll()
            
            noNotificationsView.isHidden = true
            notifcationsTableView.isHidden = false
            clearNotificationsButton.isHidden = false
            notificationsTemp.sort(by: { $0.time! > $1.time!})
            notifcationsTableView.delegate = self
            notifcationsTableView.dataSource = self
            notifcationsTableView.reloadData()
            for notification in notificationsTemp {
                guard let handler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification) else {
                    continue
                }
                handler.isNotificationQualifiedToDisplay(clientNotification: notification) { [self] valid in
                    if valid{
                        self.notifications.append(notification)
                        self.notifcationsTableView.reloadData()
                    }else{
                        if let id = notification.notificationId {
                            NotificationStore.getInstance().deleteNotification(notificationId: id)
                        }
                       
                    }
                    
                }
                
            }
          
         
         
        }
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      AppDelegate.getAppDelegate().log.debug("()")
        if (editingStyle == UITableViewCell.EditingStyle.delete){
            NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: notifications[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if notifications.count <= indexPath.row{
        return tableView.dequeueReusableCell(withIdentifier: "non_action", for: indexPath as IndexPath) as! NotificationWithActionTableViewCell
      }
      
        let notification = notifications[indexPath.row]
        let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification)
        
        var cell:NotificationWithActionTableViewCell?
        
        if notification.isActionRequired == true && notification.isActionTaken == false{
          if (notificationHandler!.getPositiveActionNameWhenApplicable(userNotification: notification) != nil || notificationHandler!.getNegativeActionNameWhenApplicable(userNotification: notification) != nil || notificationHandler!.getNeutralActionNameWhenApplicable(userNotification: notification) != nil){
            cell = tableView.dequeueReusableCell(withIdentifier: "action", for: indexPath as IndexPath) as? NotificationWithActionTableViewCell
            if RideViewUtils.isModetatorNotification(userNotification: notification) {
                cell!.moderatorImageView.isHidden = false
                cell!.moderatorImageViewWidthConstraint.constant = 25
                cell!.moderatorTitleView.isHidden = false
                cell!.moderatorTitleViewHeightConstraint.constant = 25
            } else {
                cell!.moderatorImageView.isHidden = true
                cell!.moderatorImageViewWidthConstraint.constant = 0
                cell!.moderatorTitleView.isHidden = true
                cell!.moderatorTitleViewHeightConstraint.constant = 0
            }
            handleUnReadNotification(cell: cell!, notification: notification,notificationHandler : notificationHandler!, indexPath : indexPath as NSIndexPath)
          }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "non_action", for: indexPath as IndexPath) as? NotificationWithActionTableViewCell
           
            cell!.iboDetail.textColor = UIColor(netHex: 0x3c3c3c)
            cell!.notifictionRowBackGround.backgroundColor = UIColor(netHex: 0xffffcc)
          }
          
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "non_action", for: indexPath as IndexPath) as? NotificationWithActionTableViewCell
            handleReadNotification(cell: cell!, notification: notification)
        }
        cell!.setNotificationIconAndTitle(notificationHandler: notificationHandler, notification: notification)
        cell!.iboTimeStamp.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(notification.time!)*1000, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aaa)
        if notification.sendFrom != 0{
            cell?.iboNotificationIcon?.isUserInteractionEnabled = true
            cell?.iboNotificationIcon?.tag = indexPath.row
            cell?.iboNotificationIcon?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NotificationViewController.notificaitonIconTapped(_:))))
        }
        else{
           cell?.iboNotificationIcon?.isUserInteractionEnabled = false
        }
        
        return cell!
        
    }
    func handleUnReadNotification(cell: NotificationWithActionTableViewCell,notification : UserNotification,notificationHandler : NotificationHandler,indexPath : NSIndexPath){
      AppDelegate.getAppDelegate().log.debug("handleUnReadNotification()")
        cell.iboDetail.textColor = Colors.receiveCallsTextColor
        
        cell.notifictionRowBackGround.backgroundColor = UIColor(netHex: 0xffffcc)
        let buttonWidth = ((self.view.frame.size.width)-100)/3
        var actionName = notificationHandler.getPositiveActionNameWhenApplicable(userNotification: notification)
        if actionName == nil{
            cell.positiveButton.isHidden = true
            
        }else{
            cell.positiveButtonWidth.constant = buttonWidth
            cell.positiveButton.isHidden = false
            cell.positiveButton.isEnabled = true
            cell.initializePositiveActnBtn(actionName: actionName!)
            cell.positiveButton.tag =  indexPath.row
        }
        actionName = notificationHandler.getNegativeActionNameWhenApplicable(userNotification: notification)
        if actionName == nil{
            cell.negativeButton.isHidden = true
            cell.negativeButtonWidth.constant = 0
        }else{
            cell.negativeButton.isHidden = false
            cell.negativeButtonWidth.constant = buttonWidth
            cell.initializeNegativeActnBtn(actionName: actionName!)
            cell.negativeButton.tag = indexPath.row
        }
        actionName = notificationHandler.getNeutralActionNameWhenApplicable(userNotification: notification)
        if actionName == nil{
            cell.neutralButton.isHidden = true
            let width = ((self.view.frame.size.width)-100)/2
            cell.positiveButtonWidth.constant = width
            cell.negativeButtonWidth.constant = width
        }
        else if cell.negativeButton.isHidden == true
        {
            cell.neutralButton.isHidden = false
            let width = ((self.view.frame.size.width)-100)/2
            cell.positiveButtonWidth.constant = width
            cell.neutralButtonWidth.constant = width
            cell.initializeNeutralActnBtn(actionName: actionName!)
            cell.neutralButton.tag = indexPath.row
        }
        else{
            cell.neutralButton.isHidden = false
            cell.neutralButtonWidth.constant = buttonWidth
            cell.initializeNeutralActnBtn(actionName: actionName!)
        }
    }
    func handleReadNotification(cell: NotificationWithActionTableViewCell,notification : UserNotification){
        AppDelegate.getAppDelegate().log.debug("handleReadNotification()")
        cell.notifictionRowBackGround.backgroundColor = UIColor(netHex: 0xffffff)
        cell.iboDetail.textColor = UIColor(netHex: 0x7e7e7e)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      AppDelegate.getAppDelegate().log.debug("tableView()")
    
        if notifications.endIndex <= indexPath.row{
           return
        }
        let notification = notifications[indexPath.row]
        let notificationHandler : NotificationHandler? = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification)
        let actionName = notificationHandler?.getPositiveActionNameWhenApplicable(userNotification: notification)
        
        if notification.isActionTaken && actionName == nil{
            NotificationStore.getInstance().actionTakenForNotification(notificationId: notification.notificationId!)
        }
    notificationHandler?.handleTap(userNotification: notification,viewController: self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        NotificationStore.getInstance().removeListener(key: NotificationViewController.notificationViewControllerKey)
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func settingsBtnTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("settingsBtnTapped()")
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        let notificationSettingsVC : NotificationSettingsViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationSettingsViewController") as! NotificationSettingsViewController
        self.navigationController?.pushViewController(notificationSettingsVC, animated: false)
    }
    
}
