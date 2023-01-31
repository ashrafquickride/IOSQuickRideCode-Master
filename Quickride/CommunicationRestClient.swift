//
//  CommunicationRestClient.swift
//  Quickride
//
//  Created by QuickRideMac on 06/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CommunicationRestClient {

    typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    
    static let USER_ALERT_STATUS_UPDATE_SERVICE_PATH = "/QRUserNotification/updateStatus"
    static let ALL_USER_NOTIFICATIONS_PATH = "/QRUserNotification"
    static let UPDATE_ALL_EVENT_STATUS = "QREventUpdate/updatestatus"
    static let GET_ALL_PENDING_STATUS = "QREventUpdate"
    static let GET_USER_NOTIFICATION_PATH = "QRUserNotification/uniqueId"
    static let GET_EVENT_UPDATE = "QREventUpdate/uniqueId"
    
    static let communicationServerUrl = AppConfiguration.communicationServerUrlIP+AppConfiguration.CM_serverPort+AppConfiguration.communicationServerPath
    
    static func updateStatus(uniqueId : Double, status : String, userId: String, notificationType: String,
                             completionHandler : @escaping RideServicesClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("updateStatus() \(uniqueId) \(status)")
        var params : [String: String] = [String: String]()
        params[UserNotification.UNIQUE_ID] = StringUtils.getStringFromDouble(decimalNumber: uniqueId)
        params[UserNotification.STATUS] = status
        params[User.FLD_USER_ID] = userId
        params[UserNotification.TYPE] = notificationType
        HttpUtils.putJSONRequestWithBody(url: communicationServerUrl+USER_ALERT_STATUS_UPDATE_SERVICE_PATH, targetViewController: nil, handler: completionHandler, body: params)
    }
    
    static func getAllUserNotificationsFromServer(userId : String,viewController : UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        let url = communicationServerUrl+ALL_USER_NOTIFICATIONS_PATH
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    
    static func getUserNotificationForId(notificationId: String, viewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
        let url = AppConfiguration.communicationServerUrlIP+AppConfiguration.CM_serverPort+AppConfiguration.communicationServerPath + GET_USER_NOTIFICATION_PATH
        var params = [String : String]()
        params[UserNotification.UNIQUE_ID] = notificationId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    
    static func updateEventStatus(uniqueId: String, sendTo : String, viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[EventUpdate.Unique_Id] = uniqueId
        params[EventUpdate.send_to] = sendTo
        let  url = communicationServerUrl + UPDATE_ALL_EVENT_STATUS
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getAllPendingStatusUpdate(userId: String,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        
        let  url = communicationServerUrl + GET_ALL_PENDING_STATUS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func getEventUpdateForRefId(uniqueId: String, viewController : UIViewController?, handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[UserNotification.UNIQUE_ID] = uniqueId
        let  url = communicationServerUrl + GET_EVENT_UPDATE
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }

}
