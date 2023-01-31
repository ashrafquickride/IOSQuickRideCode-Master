//
//  NotificationStore.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
public protocol NotificationChangeListener {
    func handleNotificationListChange()
}

public class NotificationStore{
    
    var totalNotifications : [Int : UserNotification] = [Int : UserNotification]()
    var notificationChangeListeners = [String : NotificationChangeListener]()
    
    
    var pendingActionNotificationCount : Int = 0
    var presentDisplayingNotification : UIView?
    private static var singleNotificationMgrInstance : NotificationStore?
    static var isNotificationSettingsRequested = false
    static var notificationAction : String?
    static let MAX_NO_OF_DAYS_TO_REMOVE_CLOSED_NOTIFICATIONS = 1
    static let MAX_THRESHOLD_TIME_TO_REMOVE_RIDE_LESS_INVITES_IN_MINS = 180.0//3 HOURS
    private var timer: Timer?
    private var lastUpdatdTime: NSDate?
    
    public func resumeUserSession(){
        AppDelegate.getAppDelegate().log.debug("resumeUserSession()")
        loadNotificationsFromDB()
    }
    
    func setPresentDisplayingNotification(view: UIView){
        presentDisplayingNotification = view
    }
    public static func getInstance() -> NotificationStore
    {
        AppDelegate.getAppDelegate().log.debug("getInstance()")
        if(singleNotificationMgrInstance == nil)
        {
            singleNotificationMgrInstance =  NotificationStore()
            singleNotificationMgrInstance!.loadNotificationsFromDB()
            
            singleNotificationMgrInstance!.startTimer()
        }
        return singleNotificationMgrInstance!
    }
    
    private func startTimer(){
        if self.timer == nil{
            self.timer = Timer.scheduledTimer(timeInterval: 15*60, target: self, selector: #selector(NotificationStore.getAllNotificationAndUpdateInCache), userInfo: nil, repeats: true)
        }
    }
    
    @objc func getAllNotificationAndUpdateInCache(){
        if lastUpdatdTime == nil {
            AppDelegate.getAppDelegate().log.debug("getAllNotificationAndUpdateInCache()")
            lastUpdatdTime = NSDate()
            self.getAllPendingNotificationsFromServer()
        } else {
            if let activeRidesCount = MyActiveRidesCache.getRidesCacheInstance()?.getUsersActiveRidesCount(), activeRidesCount > 0 {
                if DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: lastUpdatdTime!) > 15*60 {
                    AppDelegate.getAppDelegate().log.debug("getAllNotificationFor15min()")
                    lastUpdatdTime = NSDate()
                    self.getAllPendingNotificationsFromServer()
                }
            } else if DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: lastUpdatdTime!) > 240*60 {
                AppDelegate.getAppDelegate().log.debug("getAllNotificationFor4Hrs()")
                lastUpdatdTime = NSDate()
                self.getAllPendingNotificationsFromServer()
            }
        }
        
    }
    
    public static func getInstanceIfExists() -> NotificationStore?
    {
        AppDelegate.getAppDelegate().log.debug("getInstanceIfExists()")
        return self.singleNotificationMgrInstance
    }
    
    func getUserNotificationWithId(notificationId:Int) -> UserNotification?{
        AppDelegate.getAppDelegate().log.debug("getUserNotificationWithId()")
        for notification in totalNotifications{
            if(notificationId == notification.0){
                return notification.1
            }
        }
        return nil
    }
    func isDuplicateId(uniqueId : Int) -> Bool{
        if totalNotifications[uniqueId] != nil{
            return true
        }
        return false
    }
    func getAllPendingNotificationsFromServer(){
        let userId = QRSessionManager.getInstance()?.getUserId()
        if userId != "0"{
            CommunicationRestClient.getAllUserNotificationsFromServer(userId: userId!, viewController: nil) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as? String == "SUCCESS"{
                    let notifications = Mapper<UserNotification>().mapArray(JSONObject: responseObject!["resultData"])
                    DispatchQueue.main.async() { () -> Void in
                        if notifications != nil{
                            
                            for notification in notifications!{
                                
                                let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification)
                                if notificationHandler == nil{
                                    continue
                                }
                                notificationHandler?.saveNotification(clientNotification: notification, handler: { notification in
                                    
                                })
                            }
                        }
                    }
                }
                self.notifyToNotificationChangeListener()
            }
        }
        
    }
    
    
    private func loadNotificationsFromDB(){
        AppDelegate.getAppDelegate().log.debug("loadNotificationsFromDB()")
        totalNotifications  = NotificationPersistenceHelper.getAllUserNotification()
        pendingActionNotificationCount = getActionPendingNotificationCount()
        UIApplication.shared.applicationIconBadgeNumber = pendingActionNotificationCount
        notifyToNotificationChangeListener()
    }
    
    func getActionPendingNotificationCount() -> Int{
        var count = 0
        for notification in totalNotifications  {
            let value  = notification.1
            if !value.isNotificationExpired() && value.isActionRequired == true && value.isActionTaken == false && value.status != UserNotification.NOT_STATUS_CLOSED{
                count += 1
            }
        }
        return count
    }
    func updateNotification(notification : UserNotification){
        AppDelegate.getAppDelegate().log.debug("updateNotification()")
        
        if notification.time == nil{
            notification.time = NSDate().timeIntervalSince1970
        }
        totalNotifications[notification.notificationId!] = notification
        NotificationPersistenceHelper.updateNotification(notification: notification)
    }
    
    private func notifyToNotificationChangeListener(){
        AppDelegate.getAppDelegate().log.debug("notifyToNotificationChangeListener()")
        for notificationListener in notificationChangeListeners{
            notificationListener.1.handleNotificationListChange()
        }
    }
    
    public func addNotificationListChangeListener(key : String,listener:NotificationChangeListener){
        AppDelegate.getAppDelegate().log.debug("addNotificationListChangeListener()")
        self.notificationChangeListeners[key] = listener
    }
    
    public func getAllNotifications() -> [Int:UserNotification]{
        AppDelegate.getAppDelegate().log.debug("getAllNotifications()")
        
        return totalNotifications
    }
    
    public func clearUserSession(){
        AppDelegate.getAppDelegate().log.debug("clearUserSession()")
        
        totalNotifications.removeAll()
        UIApplication.shared.cancelAllLocalNotifications()
        pendingActionNotificationCount = 0
        DispatchQueue.main.async(execute: {
            NotificationPersistenceHelper.clearAllNotifications()
        })
        notifyToNotificationChangeListener()
    }
    func removeOlderNotifications(){
        
        self.removeOlderRideLessInvites()
        let time = NSDate().addDays(daysToAdd: -NotificationStore.MAX_NO_OF_DAYS_TO_REMOVE_CLOSED_NOTIFICATIONS)
        NotificationPersistenceHelper.removeOlderNotificationsBeforeTime(time: Int(time.timeIntervalSince1970))
        for notificationListener in self.notificationChangeListeners{
            notificationListener.1.handleNotificationListChange()
        }
    }
    
    func removeOlderRideLessInvites(){
        var removalNotifications = [UserNotification]()
        
        for notification in totalNotifications{
            
            if UserNotification.NOT_TYPE_RM_CONTACT_INVITATION == notification.1.type || UserNotification.NOT_TYPE_RM_GROUP_INVITATION == notification.1.type || UserNotification.NOT_TYPE_RM_INVITATION_TO_OLD_USER == notification.1.type{
                let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: notification.1)
                if rideInvitation == nil{
                    continue
                }
                if NSDate().timeIntervalSince1970 - rideInvitation!.pickupTime/1000 >= Double(NotificationStore.MAX_THRESHOLD_TIME_TO_REMOVE_RIDE_LESS_INVITES_IN_MINS*60){
                    removalNotifications.append(notification.1)
                }
            }
            else if UserNotification.NOT_TYPE_REGULAR_RIDER_RIDE_INSTANCE_CREATION == notification.1.type || UserNotification.NOT_TYPE_REGULAR_PASSENGER_RIDE_INSTANCE_CREATION == notification.1.type || UserNotification.NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PAST_RIDER == notification.1.type
                || UserNotification.NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PAST_PASSEGER == notification.1.type || UserNotification.NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_RIDER == notification.1.type || UserNotification.NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PASSEGER == notification.1.type
                || UserNotification.NOT_TYPE_USER_TO_CREATE_RIDE == notification.1.type
            {
                if NSDate().timeIntervalSince1970 - Double(notification.1.time!) >= Double(NotificationStore.MAX_THRESHOLD_TIME_TO_REMOVE_RIDE_LESS_INVITES_IN_MINS*60){
                    removalNotifications.append(notification.1)
                }
            }
        }
        for userNotification in removalNotifications{
            deleteNotification(notificationId: userNotification.notificationId!)
        }
    }
    func purgeOldNotificationsFromPersistence(){
        AppDelegate.getAppDelegate().log.debug("purgeOldNotificationsFromPersistence()")
        let notificationId = NotificationPersistenceHelper.purgeOldestNotification()
        if notificationId != nil{
            deleteNotification(notificationId: notificationId!)
        }
    }
    
    func removeNotificationFromLocalList(userNotification:UserNotification){
        AppDelegate.getAppDelegate().log.debug("removeNotificationFromLocalList()")
        NotificationPersistenceHelper.deleteNotification(notificationId: userNotification.notificationId!)
        totalNotifications.removeValue(forKey: userNotification.notificationId!)
        if userNotification.isActionRequired && !userNotification.isActionTaken
        {
            pendingActionNotificationCount -= 1
        }
        
        notifyToNotificationChangeListener()
    }
    public func saveNewNotification(newClientNotification:UserNotification) -> UserNotification{
        AppDelegate.getAppDelegate().log.debug("saveNewNotification()")
        if NotificationHandlerFactory.getNotificationHandler(clientNotification: newClientNotification) == nil{
            return newClientNotification
        }
        if totalNotifications[newClientNotification.notificationId!] != nil{
            AppDelegate.getAppDelegate().log.debug("redundant notification")
            deleteNotification(notificationId: newClientNotification.notificationId!)
        }
        newClientNotification.time = NSDate().timeIntervalSince1970
        
        if newClientNotification.groupName != nil && newClientNotification.groupValue != nil && newClientNotification.groupName!.isEmpty == false && newClientNotification.groupValue?.isEmpty == false{
            removeOldNotificationOfSameGroupValue(groupName: newClientNotification.groupName!,groupValue: newClientNotification.groupValue!)
        }
        if  totalNotifications.count > AppConfiguration.maximumNotifications{
            purgeOldNotificationsFromPersistence()
        }
        
        NotificationPersistenceHelper.saveUserNotificationObject(userNotification: newClientNotification)
        totalNotifications[newClientNotification.notificationId!] = newClientNotification
        if isRideInvitationNotification(newClientNotification: newClientNotification){
            var rideInvitation = newClientNotification.invite
            if rideInvitation == nil {
                rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: newClientNotification)
                
            }
            if let rideInvitation = rideInvitation {
                RideInviteCache.getInstance().saveNewInvitation(rideInvitation: rideInvitation)
                RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_RECEIVED, viewController: nil, completionHandler: { (responseObject, error) in
                       })
            }
        }
        if newClientNotification.type == UserNotification.NOT_TAXI_INVITE || newClientNotification.type == UserNotification.NOT_TAXI_INVITE_BY_CONTACT{
            if let taxiInvite = Mapper<TaxiPoolInvite>().map(JSONString: newClientNotification.msgObjectJson ?? ""){
                MyActiveTaxiRideCache.getInstance().storeIncomingTaxipoolInvite(taxipoolInvite: taxiInvite)
            }
        }
            
        
        if newClientNotification.isActionRequired && !newClientNotification.isActionTaken
        {
            pendingActionNotificationCount += 1
        }
        notifyToNotificationChangeListener()
        return newClientNotification
    }
    private func isRideInvitationNotification(newClientNotification : UserNotification) -> Bool{
        if UserNotification.NOT_TYPE_RM_RIDER_INVITATION == newClientNotification.type ||
            UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION == newClientNotification.type ||
            UserNotification.NOT_TYPE_RM_RIDER_INVITATION_WITH_REQUESTED_FARE == newClientNotification.type
            || UserNotification.NOT_TYPE_RM_RIDER_INVITATION_TO_MODERATOR == newClientNotification.type
            || UserNotification.NOT_TYPE_RM_RIDE_FARE_CHNG_INVTN_TO_MDRTR == newClientNotification.type
            || UserNotification.NOT_TYPE_RM_CONTACT_INVITATION == newClientNotification.type ||
            UserNotification.NOT_TYPE_RM_INVITATION_TO_OLD_USER == newClientNotification.type ||
            UserNotification.NOT_TYPE_RM_GROUP_INVITATION == newClientNotification.type {
            return true
        }
        return false
    }
    public func deleteNotification(notificationId:Int){
        deleteNotificationInCache(notificationId: notificationId)
        notifyToNotificationChangeListener()
    }
    public func deleteNotificationInCache(notificationId:Int){
        AppDelegate.getAppDelegate().log.debug("deleteNotification()")
        let notification = totalNotifications[notificationId]
        if notification == nil { return }
        NotificationPersistenceHelper.updateNotificationStatus(notificationId: notificationId,status: UserNotification.NOT_STATUS_CLOSED)
        totalNotifications.removeValue(forKey: notificationId)
        if(notification?.isActionRequired == true && notification?.isActionTaken == false)
        {
            pendingActionNotificationCount -= 1
        }
    }
    
    public func removeOldNotificationOfSameGroupValue(groupName:String, groupValue:String){
        AppDelegate.getAppDelegate().log.debug("groupName : \(String(describing: groupName)) groupValue : \(String(describing: groupValue))")
        NotificationPersistenceHelper.deleteNotificationsOfAGroup(groupName: groupName,groupValue: groupValue)
        for notification in totalNotifications{
            
            if (groupValue == (notification.1.groupValue) && groupName == (notification.1.groupName!))
            {
                totalNotifications[notification.0] = nil
                if notification.1.isActionRequired == true && notification.1.isActionTaken == false{
                    pendingActionNotificationCount -= 1
                }
            }
        }
        self.notifyToNotificationChangeListener()
    }
    public func removeOldNotificationOfSameGroupValue( groupValue:String){
        AppDelegate.getAppDelegate().log.debug("removeOldNotificationOfSameGroupValue()")
        
        
        for notification in totalNotifications{
            
            if groupValue == notification.1.groupValue
            {
                totalNotifications[notification.0] = nil
                if notification.1.isActionRequired == true && notification.1.isActionTaken == false{
                    pendingActionNotificationCount -= 1
                }
            }
        }
        self.notifyToNotificationChangeListener()
        NotificationPersistenceHelper.updateNotificationsOfAGroup(groupValue: groupValue)
    }
    
    
    func removeInvitationWithGroupNameAndGroupValue( groupName : String, groupValue : String)
    {
        var rideType :String?
        if UserNotification.NOT_GRP_RIDER_RIDE == groupName{
            rideType = Ride.RIDER_RIDE
        }else{
            rideType = Ride.PASSENGER_RIDE
        }
        let rideId = Double(groupValue)
        var removalNotifications = [UserNotification]()
        for userNotification in totalNotifications{
            
            if isRideInvitationNotification(newClientNotification: userNotification.1) {
                guard let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification.1) else {
                    continue
                }
              
                if Ride.RIDER_RIDE == rideType{
                    if(rideInvitation.rideId == rideId){
                        RideInviteCache.getInstance().removeInvitation(id: rideInvitation.rideInvitationId)
                        removalNotifications.append(userNotification.1)
                    }
                }
                else
                {
                    if rideInvitation.passenegerRideId == rideId
                    {
                        RideInviteCache.getInstance().removeInvitation(id: rideInvitation.rideInvitationId)
                        removalNotifications.append(userNotification.1)
                    }
                }
            }
        }
        for removalNotification in removalNotifications
        {
            
            deleteNotification(notificationId: removalNotification.notificationId!)
        }
    }
    
    //MARK: Action to be taken for cancelling notification
    
    public func actionTakenForNotification(notificationId:Int){
        AppDelegate.getAppDelegate().log.debug("actionTakenForNotification()")
        
        deleteNotification(notificationId: notificationId)
        
    }
    
    

  func removeInviteNotificationByInvitation(invitationId :  Double)
  {
    var notificationId = 0
    for notifiction in totalNotifications{
      let userNotification = notifiction.1
      
      if isRideInvitationNotification(newClientNotification: userNotification) {
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if rideInvitation == nil{
          continue
        }
        if rideInvitation?.rideInvitationId == invitationId
        {
          notificationId = userNotification.notificationId!
          break
        }
      }
    }
    if notificationId > 0{
      deleteNotification(notificationId: notificationId)
    }
  }
    
    public func clearLocalMemoryOnSessionInitializationFailure() {
        AppDelegate.getAppDelegate().log.debug("clearLocalMemoryOnSessionInitializationFailure()")
        totalNotifications.removeAll()
        pendingActionNotificationCount = 0
    }
    public func removeListener(key : String){
        AppDelegate.getAppDelegate().log.debug("removeListener()")
        notificationChangeListeners.removeValue(forKey: key)
    }
    func getPendingInvitesCount() -> Int
    {
        AppDelegate.getAppDelegate().log.debug("getPendingInvitesCount()")
        
        var count = 0
        for notification in totalNotifications{
            if notification.1.msgClassName == RideInvitation.rideInviteMessageClassName{
                count += 1
            }
        }
        return count
    }
    func getPendingRideInvites() -> [RideInvitation]
    {
        AppDelegate.getAppDelegate().log.debug("getPendingRideInvites()")
        
        var rideInvites = [RideInvitation]()
        for userNotification in totalNotifications{
            let notification = userNotification.value
           
            if isRideInvitationNotification(newClientNotification: notification), let json = notification.msgObjectJson,
                let rideInvitation = Mapper<RideInvitation>().map(JSONString: json){
                rideInvites.append(rideInvitation)
            }
        }
        return rideInvites
    }
    func removeNotificationForTaxiPoolInvite(invite : TaxiPoolInvite){
       
        var found: UserNotification?
        for userNotification in totalNotifications.values {
            if let json = userNotification.msgObjectJson, let inviteFromNotif = Mapper<TaxiPoolInvite>().map(JSONString: json), invite.id == inviteFromNotif.id{
                found = userNotification
                break
            }
        }
        if let found = found {
            removeNotificationFromLocalList(userNotification: found)
        }
    }
    func processRecentNotifiation(){
        let userNotifications = SharedPreferenceHelper.getRecentNotifications()
        if (userNotifications != nil && userNotifications!.isEmpty == false) {
            for notification in userNotifications!{
                let notificationHandler: NotificationHandler? = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification)
                if notificationHandler != nil{
                    notificationHandler!.saveNotification(clientNotification: notification) {
                        notification in
                        guard let notification = NotificationStore.getInstance().totalNotifications[notification.notificationId!], let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification) else {return }
                        
                        if NotificationStore.notificationAction == nil{
                            notificationHandler.displayNotification(clientNotification: notification)
                        }else{
                            notificationHandler.handleAction(identifier: NotificationStore.notificationAction!, userNotification: notification)
                        }
                    }
                }
            }
        }
        SharedPreferenceHelper.deleteRecentNotification()
    }
}
