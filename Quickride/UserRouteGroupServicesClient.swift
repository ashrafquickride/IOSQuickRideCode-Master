//
//  UserRouteGroupServicesClient.swift
//  Quickride
//
//  Created by QuickRideMac on 12/15/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserRouteGroupServicesClient {
    
    typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void

    static let RIDE_PATH_GROUP_SERVICE_PATH = "QRUserRouteGroup"
    static let ALL_RIDE_PATH_GROUP_GETTING_SERVICE_PATH = RIDE_PATH_GROUP_SERVICE_PATH+"/all"
    static let RIDE_PATH_SUGGESTED_GROUPS_GETTING_SERVICE_PATH = RIDE_PATH_GROUP_SERVICE_PATH+"/matcher"
    static let RIDE_PATH_GROUP_ADDING_EXITING_MEMBER_SERVICE_PATH = RIDE_PATH_GROUP_SERVICE_PATH+"/groupMember"
    static let USER_ROUTE_GROUP_MEMBERS_GETTING_SERVICE_PATH = RIDE_PATH_GROUP_ADDING_EXITING_MEMBER_SERVICE_PATH+"/all"
    static let USER_ID = "userId"
    private static let baseServerUrl : String = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath

    
    static func getAllGroupsOfUser(userId : String,completionHandler : @escaping responseJSONCompletionHandler)
    {
        var params = [String : String]()
        params[USER_ID] = userId
        let getAllGroupsUrl = baseServerUrl + ALL_RIDE_PATH_GROUP_GETTING_SERVICE_PATH

        HttpUtils.getJSONRequestWithBody(url: getAllGroupsUrl, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func createNewGroup(body : [String : String],targetViewController : UIViewController?,completionHandler : @escaping responseJSONCompletionHandler)
    {
        let createNewGroupsUrl = UserRouteGroupServicesClient.baseServerUrl + UserRouteGroupServicesClient.RIDE_PATH_GROUP_SERVICE_PATH
        
        HttpUtils.postRequestWithBody(url: createNewGroupsUrl, targetViewController: targetViewController, handler: completionHandler,body: body)
    }
    
    static func getAllSuggestedGroups(homeLocation : Location?,officeLocation : Location?, appName : String, completionHandler : @escaping responseJSONCompletionHandler)
    {
        let suggestedGroupsUrl = UserRouteGroupServicesClient.baseServerUrl + UserRouteGroupServicesClient.RIDE_PATH_SUGGESTED_GROUPS_GETTING_SERVICE_PATH

        var params = [String : String]()
        if homeLocation != nil{
            params[UserRouteGroup.FROM_LOC_ADDRESS] = homeLocation!.completeAddress
            params[UserRouteGroup.FROM_LOC_LATITUDE] = String(homeLocation!.latitude)
            params[UserRouteGroup.FROM_LOC_LONGITUDE] = String(homeLocation!.longitude)
        }
        
        if officeLocation != nil{
            params[UserRouteGroup.TO_LOC_LATITUDE] = String(officeLocation!.latitude)
            params[UserRouteGroup.TO_LOC_LONGITUDE] = String(officeLocation!.longitude)
            params[UserRouteGroup.TO_LOCATION_ADDRESS] = officeLocation!.completeAddress
        }
        params[User.FLD_APP_NAME] = appName

        HttpUtils.getJSONRequestWithBody(url: suggestedGroupsUrl, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func getGroup(groupId : Double,completionHandler : @escaping responseJSONCompletionHandler)
    {
        let getGroupsUrl = baseServerUrl + RIDE_PATH_GROUP_SERVICE_PATH

        var params = [String : String]()
        params[UserRouteGroup.ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
        HttpUtils.getJSONRequestWithBody(url: getGroupsUrl, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func addUserToGroup(body : [String : String],targetViewController : UIViewController?,completionHandler : @escaping responseJSONCompletionHandler)
    {
        let addUserToGroupUrl = baseServerUrl + RIDE_PATH_GROUP_ADDING_EXITING_MEMBER_SERVICE_PATH
        
        HttpUtils.postRequestWithBody(url: addUserToGroupUrl, targetViewController: targetViewController, handler: completionHandler,body: body)
    }
    static func exitFromGroup(groupId : Double,userId : String,targetViewController: UIViewController?,completionHandler : @escaping responseJSONCompletionHandler)
    {
        let exitGroupUrl = baseServerUrl + RIDE_PATH_GROUP_ADDING_EXITING_MEMBER_SERVICE_PATH
        var params = [String : String]()
        params[UserRouteGroupMember.USER_ID] = userId
        params[UserRouteGroupMember.GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
        
        HttpUtils.deleteJSONRequest(url: exitGroupUrl,params : params, targetViewController: targetViewController, handler : completionHandler)

    }
    
    
    static func getAllMembersOfAGroup(groupId : Double,completionHandler : @escaping responseJSONCompletionHandler)
    {
        let getMembersOfGroupUrl = baseServerUrl + USER_ROUTE_GROUP_MEMBERS_GETTING_SERVICE_PATH
        
        var params = [String : String]()
        params[UserRouteGroup.ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
        HttpUtils.getJSONRequestWithBody(url: getMembersOfGroupUrl, targetViewController: nil, params: params, handler: completionHandler)
    }

}
