//
//  CircleRestClient.swift
//  Quickride
//
//  Created by KNM Rao on 23/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class GroupRestClient {
    
    static let GROUPS_OF_USER_PATH = "/UserGroup/all"
    static let MEMBERS_OF_GROUP_PATH = "/UserGroup/member/all"
    static let GROUPS_PATH = "/UserGroup"
    static let GROUPS_SEARCH_PATH = "/UserGroup/matcher"
    static let REQUEST_NEW_MEMBER_TO_GROUP_PATH = "/UserGroup/member/request"
    static let UPDATE_GROUP_MEMBER_PATH = "/UserGroup/member/update"
    static let UPDATE_GROUP_PATH = "/UserGroup/update"
    static let ADD_MEMBER_TO_GROUP_PATH = "/UserGroup/member/add_bulk"
    static let DELETE_MEMBER_FROM_USER_GROUP = "/UserGroup/member"
    static let ADD_MEMBER_TO_USER_GROUP_PATH = "/UserGroup/member/add"
    static let REJECT_GROUP_MEMBERSHIP_PATH = "/UserGroup/member/reject"
    static let USER_GROUP_MESSAGES = "/GroupConversation"
    static let INVITE_GROUP_MEMBERS_FOR_RIDE_PATH = "/QRRideconn/invite/usergroup/users"
    static let INVITE_GROUPS_FOR_RIDE_PATH = "/QRRideconn/invite/usergroup"
    static let GET_USER_GROUP = "/UserGroup"
    
    static let baseServerUrl: String = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath
    
    static let communicationServerUrl = AppConfiguration.communicationServerUrlIP+AppConfiguration.CM_serverPort+AppConfiguration.communicationServerPath
    
    typealias responseCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    
    static func getMembersOfGroup(groupId : Double,viewController : UIViewController?,  handler :@escaping responseCompletionHandler){
        var params = [String:String]()
        params[Group.ID] = StringUtils.getStringFromDouble(decimalNumber : groupId)
        let url = baseServerUrl+MEMBERS_OF_GROUP_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func createNewGroup( group : Group,viewController : UIViewController?,  handler :@escaping responseCompletionHandler){
       var params = group.getParams()
        params[Group.IMAGE_URI] = group.imageURI
        let url = baseServerUrl+GROUPS_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func requestMembershipToGroup(group : Group,viewController : UIViewController?,handler :@escaping responseCompletionHandler){
        var params = [String:String]()
        params[GroupMember.USER_ID] = QRSessionManager.getInstance()?.getUserId()
        params[GroupMember.ID] = StringUtils.getStringFromDouble(decimalNumber:group.id)
        params[GroupMember.GROUP_NAME] = group.name
        let url = baseServerUrl+REQUEST_NEW_MEMBER_TO_GROUP_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    static func getGroupsForSearch(groupNameSearchIdentifier : String?,viewController : UIViewController?,handler :@escaping responseCompletionHandler){
        var params = [String:String]()
        params[Group.GROUP_SEARCH_IDENTIFIER] = groupNameSearchIdentifier
        params[User.FLD_USER_ID] = QRSessionManager.getInstance()?.getUserId()
        let url = baseServerUrl+GROUPS_SEARCH_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }

    static func updateGroup( group : Group,viewController : UIViewController?,  handler :@escaping responseCompletionHandler) {
        let url = baseServerUrl+UPDATE_GROUP_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: group.getParams())
    }
    
    static func addMemberToGroup(group : Group, memberId:String,viewController : UIViewController?,handler :@escaping responseCompletionHandler){
        var params = [String:String]()
        params[User.FLD_USER_ID_BULK] = memberId
        params[Group.ID] = StringUtils.getStringFromDouble(decimalNumber: group.id)
        params[Group.GROUP_NAME] = group.name
        params[User.FLD_USER_ID] = QRSessionManager.getInstance()?.getUserId().components(separatedBy: ".")[0]
        let url = baseServerUrl+ADD_MEMBER_TO_GROUP_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    
    static func deleteGroupMember(groupId : Double,memberId : Double,viewController : UIViewController?,  handler :@escaping responseCompletionHandler){
        var params = [String:String]()
        params[Group.ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
        params[GroupMember.USER_ID] = StringUtils.getStringFromDouble(decimalNumber: memberId)
        let url = baseServerUrl+DELETE_MEMBER_FROM_USER_GROUP
        HttpUtils.deleteJSONRequest(url: url, params: params, targetViewController: viewController, handler: handler)
    }
    
    
    static func addMembersToGroup(groupMember : GroupMember,viewController : UIViewController?,  handler :@escaping responseCompletionHandler){
        var params = [String:String]()
        params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber:  groupMember.userId)
        params[Group.ID] = StringUtils.getStringFromDouble(decimalNumber:   groupMember.groupId)
        params[Group.GROUP_NAME] = groupMember.groupName
        let url = baseServerUrl+ADD_MEMBER_TO_USER_GROUP_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func rejectGroupMembership(groupMember : GroupMember,viewController : UIViewController?,  handler :@escaping responseCompletionHandler){
        var params = [String:String]()
        params[GroupMember.USER_ID] = StringUtils.getStringFromDouble(decimalNumber: groupMember.userId)
        params[GroupMember.GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: groupMember.groupId)
        let url = baseServerUrl+REJECT_GROUP_MEMBERSHIP_PATH

        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
   }
  static func getGroupConversationMessages(groupId : Double, lastMessageTime : Double?, viewController : UIViewController?,  handler :@escaping responseCompletionHandler){
        var params = [String:String]()
        if lastMessageTime != nil{
            params[GroupConversationMessage.FLD_TIME] = StringUtils.getStringFromDouble(decimalNumber : lastMessageTime)
        }
        params[GroupConversationMessage.FLD_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber : groupId)
        let url = communicationServerUrl+USER_GROUP_MESSAGES
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
       
    }
    static func sendGroupConversationMessage( message : GroupConversationMessage,viewController : UIViewController?,  handler :@escaping responseCompletionHandler){
        
        let url = communicationServerUrl+USER_GROUP_MESSAGES
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: message.getParams())
    }
    
    static func sendInviteToSelectedGroup(rideId : Double,rideType : String, selectedGroupIds : String,viewController : UIViewController?,handler: @escaping responseCompletionHandler){
        var  params = [String: String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_RIDETYPE] = rideType
        params[Group.FLD_IDS_BULK] = selectedGroupIds
        
        let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath + INVITE_GROUPS_FOR_RIDE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
        
    }
    static func sendInvitationToSelectedUserOfGroup(rideId : Double,rideType : String, userIds : String, groupId : Double, viewController : UIViewController,handler: @escaping responseCompletionHandler){

        var params = [String:String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_RIDETYPE] = rideType
        params[User.FLD_PHONE] = userIds
        params[GroupMember.GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
        let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath + INVITE_GROUP_MEMBERS_FOR_RIDE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
   }

    static func getGroupOfUser(groupId : Double,viewController : UIViewController,handler: @escaping responseCompletionHandler){
        
        var params = [String:String]()
        params[Group.ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
        let url = baseServerUrl + GET_USER_GROUP
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
        
    }
    
 

}
