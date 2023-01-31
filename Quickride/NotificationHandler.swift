//
//  NotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import AVFoundation

public class NotificationHandler :NSObject {
    
    static var playTTS = false
    
    // Action Identifiers
    public static let POSITIVE_ACTION_ID : String = "PositiveAction"
    public static let NEGATIVE_ACTION_ID : String = "NegativeAction"
    public static let NEUTRAL_ACTION_ID : String = "NeutralAction"
    public static let ACTION_PERFORMED  = "Action_Performed"
    //Categories
    public static let THREE_ACTION_CATEGORY : String = "threeActionCategory"
    public static let ONE_ACTION_CATEGORY : String = "OneActionCategory"
    public static let delay_time = DispatchTime.now() + 10
    
    public func handleNewUserNotification(clientNotification : UserNotification){
        AppDelegate.getAppDelegate().log.debug("handleNewUserNotification()")
        
        if clientNotification.rideStatus != nil{
            EventServiceProxyFactory.getEventServiceProxy(topicName: UserMessageTopicListener.getTopicName())?.onNewMessageArrivedFromServer(topicName: UserMessageTopicListener.getTopicName(), message: clientNotification.rideStatus!)
        }
        
        if !isUserEnabledThisNotification(){
            return
        }
        saveNotification(clientNotification: clientNotification) {
            notification in
            self.displayNotification(clientNotification: notification)
            
        }
        
        
        
    }
    func displayNotification(clientNotification : UserNotification){
        if UserDataCache.SUBSCRIPTION_STATUS {
            return
        }
        if AppDelegate.getAppDelegate().isNotificationNavigationRequired{
            self.handleTap(userNotification: clientNotification, viewController: ViewControllerUtils.getCenterViewController())
        }else{
            let notificationView = NotificationView.loadFromNibNamed(nibNamed: StoryBoardIdentifiers.notification_view) as! NotificationView
            notificationView.show(viewController: ViewControllerUtils.getCenterViewController(), notification: clientNotification, notificationHandler: self)
            playNotifcationSound()
            handleTextToSpeechMessage(userNotification: clientNotification)
        }
    }
    
    func saveNotification(clientNotification : UserNotification,  handler : @escaping(_ notification: UserNotification) -> Void){
        AppDelegate.getAppDelegate().log.debug("\(clientNotification)")
        if  NotificationPersistenceHelper.isNotificationAlreadyPresent(uniqueId: clientNotification.uniqueId){
            return
        }
        clientNotification.time = NSDate().timeIntervalSince1970
        
        
        var uniqueId = getUniqueNotificationId()
        while NotificationStore.getInstance().isDuplicateId(uniqueId: uniqueId) {
            uniqueId = getUniqueNotificationId()
        }
        clientNotification.notificationId = uniqueId
        if clientNotification.isAckRequired == true{
            CommunicationRestClient.updateStatus(uniqueId: clientNotification.uniqueId ?? 0, status: UserNotification.STATUS_READ, userId: QRSessionManager.getInstance()?.getUserId() ?? "", notificationType: clientNotification.type ?? "", completionHandler: { (responseObject, error) in
            })
        }
        isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if valid {
                handler(NotificationStore.getInstance().saveNewNotification(newClientNotification: clientNotification))
            }
        }
        
    }
    func isNotificationQualifiedToDisplay(clientNotification : UserNotification, handler : @escaping(_ valid: Bool) -> Void)
    {
        AppDelegate.getAppDelegate().log.debug("\(clientNotification)")
        if(clientNotification.isNotificationExpired()){
            return handler(false)
        }
        
        return handler(true)
    }
    
    
    func isUserEnabledThisNotification() -> Bool{
        return true
    }

    func setNotificationIcon(clientNotification : UserNotification,imageView : UIImageView){
        AppDelegate.getAppDelegate().log.debug("setNotificationIcon()")
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: getNotiifcationIcon(),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = getNotiifcationIcon()
        }
    }
    func getNotiifcationIcon() -> UIImage{
        AppDelegate.getAppDelegate().log.debug("getNotiifcationIcon()")
        return UIImage(named: "notification_car")!
    }
     func getUniqueNotificationId() -> Int{
        AppDelegate.getAppDelegate().log.debug("getUniqueNotificationId()")
        return Int(arc4random_uniform(10000))
    }
    func playNotifcationSound(){
        AppDelegate.getAppDelegate().log.debug("playNotifcationSound()")
        let audioFilePath = getNotificationAudioFilePath()
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            do{
                let audioPlayer = try AVAudioPlayer(contentsOf: audioFileUrl, fileTypeHint: nil)
                audioPlayer.play()
                
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
            }
            
            
        } else {
            AppDelegate.getAppDelegate().log.debug("audio file is not found")
        }
    }
    public func getNotificationAudioFilePath()-> String?{
        AppDelegate.getAppDelegate().log.debug("getNotificationAudioFilePath()")
        return Bundle.main.path(forResource: "notification_sound_low", ofType: "mp3")

    }
    
    func handleAction(identifier:String, userNotification:UserNotification){
        AppDelegate.getAppDelegate().log.debug("handleAction()")
        saveNotification(clientNotification: userNotification) { notification in
            switch (identifier) {
            case NotificationHandler.POSITIVE_ACTION_ID:
                self.handlePositiveAction(userNotification: userNotification,viewController : nil)
                break
            case NotificationHandler.NEGATIVE_ACTION_ID:
                self.handleNegativeAction(userNotification: userNotification,viewController : nil)
                break
            case NotificationHandler.NEUTRAL_ACTION_ID:
                self.handleNeutralAction(userNotification: userNotification,viewController : nil)
                break
            default:
                AppDelegate.getAppDelegate().log.debug("Error: unexpected notification action identifier!")
            }
        }
        
    }
    
    func addActions(uiLocalNotification : UILocalNotification){}
    func handleTap(userNotification : UserNotification,viewController :UIViewController?){
   }
    func handlePositiveAction(userNotification : UserNotification,viewController :UIViewController?){
        NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
    }
    func handleNegativeAction(userNotification : UserNotification,viewController :UIViewController?){
        NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
    }
    func handleNeutralAction(userNotification : UserNotification,viewController :UIViewController?){
    }
    
    func getPositiveActionNameWhenApplicable(userNotification : UserNotification) -> String?{
        return nil
    }
    func getNegativeActionNameWhenApplicable(userNotification : UserNotification) -> String?{
        return nil
    }
    func getNeutralActionNameWhenApplicable(userNotification : UserNotification) -> String?{
        return nil
    }
    
    func getParams(notification : UserNotification) -> NSDictionary{
        if notification.msgObjectJson == nil{
            return [String : String]() as NSDictionary
        }
        let nsdata = notification.msgObjectJson?.data(using: String.Encoding.utf8)
        do{
            let data = try JSONSerialization.jsonObject(with: nsdata!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            return data
        }catch {
            return [String : String]() as NSDictionary
        }
        
    }
    func getActionParams(userNotification : UserNotification) -> [String: String]{
        if userNotification.msgObjectJson == nil{
            return [String: String]()
        }
        if let notificaitonDynamicData = Mapper<NotificationDynamicData>().map(JSONObject: userNotification.msgObjectJson!) {
            return notificaitonDynamicData.getParams()
        }
        if let notificaitonDynamicData = Mapper<NotificationDynamicData>().map(JSONString: userNotification.msgObjectJson!) {
            return notificaitonDynamicData.getParams()
        }
        return [String: String]()
    }
    func handleTextToSpeechMessage(userNotification : UserNotification){
        
    }
    func checkRiderRideStatusAndSpeakInvitation(text : String, time: DispatchTime){
        let notificationSettings = UserDataCache.getInstance()?.getLoggedInUserNotificationSettings()
        if notificationSettings != nil && notificationSettings!.playVoiceForNotifications == true{
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                let utterance = AVSpeechUtterance(string: text)
                let synth = AVSpeechSynthesizer()
                synth.speak(utterance)
            })
        }
    }
}
class NotificationDynamicData : Mappable{
    var gender : String?
    var id : Double = 0.0
    func mapping(map: Map) {
        self.gender <- map["gender"]
        self.id <- map["id"]
    }
    required init?(map: Map) {
        
    }
    init(){
        
    }
    func getParams() -> [String : String]{
        var params : [String : String] = [String : String]()
        params[User.GENDER] = self.gender
        return params
    }
}

