//
//  EventServiceRestClient.swift
//  Quickride
//
//  Created by iDisha on 25/05/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation

class EventServiceRestClient {
    
    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    
    static let UPDATE_ALL_EVENT_STATUS = "QREventUpdate/updatestatus"
    static let GET_ALL_PENDING_STATUS = "QREventUpdate"
    static let GET_EVENT_UPDATE = "QREventUpdate/uniqueId"
    
    static func updateEventStatus(uniqueId: String, sendTo : String, viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[EventUpdate.Unique_Id] = uniqueId
        params[EventUpdate.send_to] = sendTo
        let  url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATE_ALL_EVENT_STATUS
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getAllPendingStatusUpdate(userId: String,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        
        let  url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_ALL_PENDING_STATUS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func getEventUpdateForRefId(uniqueId: String, viewController : UIViewController?, handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[UserNotification.UNIQUE_ID] = uniqueId
        let  url = AppConfiguration.communicationServerUrl + GET_EVENT_UPDATE
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
}
