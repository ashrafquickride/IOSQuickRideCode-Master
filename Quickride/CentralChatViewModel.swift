//
//  CentralChatViewModel.swift
//  Quickride
//
//  Created by Halesh on 19/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CentralChatViewModel{
    var centralChatList = [CentralChat]()
    var centralChatSearchedList = [CentralChat]()
    
    func getAllAvailableChatsToShowInCentralChat(groupChatListener: GroupChatMessageListener,personalChatListener: ConversationReceiver,userGroupChatListner: GroupConversationListener){
        centralChatList.removeAll()
        getActiveRiderRidesOfUser(listener: groupChatListener)
        getActivePassengerRidesOfUser(listener: groupChatListener)
        getRecentPersonalChats(listener: personalChatListener)
        getMyActiveGroups(listener: userGroupChatListner)
        getClosedRiderRidesOfUser(listener: groupChatListener)
        getClosedPassengerRidesOfUser(listener: groupChatListener)
    }
    
    
    private func getActiveRiderRidesOfUser(listener: GroupChatMessageListener){
        guard let activeRiderRides = MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides().values else { return }
        for riderRide in activeRiderRides{
            if riderRide.noOfPassengers != 0{
                prepareCentralChatOfRiderRide(riderRide: riderRide, listener: listener)
            }
        }
    }
    
    private func getActivePassengerRidesOfUser(listener: GroupChatMessageListener){
        guard let activePassengerRides = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRides().values else { return }
        for passengerRide in activePassengerRides{
            if passengerRide.riderRideId != 0{
             prepareCentralChatOfPassengerRide(passengerRide: passengerRide, listener: listener)
            }
        }
    }
    
    private func getClosedRiderRidesOfUser(listener: GroupChatMessageListener){
        guard let riderRides = MyClosedRidesCache.getClosedRidesCacheInstance().getClosedRiderRides()?.values else { return }
        for riderRide in riderRides{
            let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: riderRide.startTime, time2: NSDate().getTimeStamp())
            if riderRide.noOfPassengers != 0  && riderRide.status == Ride.RIDE_STATUS_COMPLETED && (timeDiff/60) <= 24{
                prepareCentralChatOfRiderRide(riderRide: riderRide, listener: listener)
            }
        }
    }
    
    private func getClosedPassengerRidesOfUser(listener: GroupChatMessageListener){
        guard let passengerRides = MyClosedRidesCache.getClosedRidesCacheInstance().getClosedPasssengerRides()?.values else { return }
        for passengerRide in passengerRides{
            let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: passengerRide.startTime, time2: NSDate().getTimeStamp())
            if passengerRide.riderRideId != 0 && passengerRide.status == Ride.RIDE_STATUS_COMPLETED && (timeDiff/60) <= 24{
                prepareCentralChatOfPassengerRide(passengerRide: passengerRide, listener: listener)
            }
        }
    }
    
    private func prepareCentralChatOfRiderRide(riderRide: RiderRide,listener: GroupChatMessageListener){
        let lastMessageOfRideGroup = RidesGroupChatCache.getInstance()?.getGroupChatLastMessageOfRide(rideId: riderRide.rideId)
        let rideTime = getRideTimeInString(rideTime: riderRide.startTime)
        let lastMessageWithName: String?
        if let userName = lastMessageOfRideGroup?.userName, let message = lastMessageOfRideGroup?.message, let lastMsgUserId = lastMessageOfRideGroup?.phonenumber{
            if let userId = QRSessionManager.getInstance()?.getUserId(), userId == StringUtils.getStringFromDouble(decimalNumber: lastMsgUserId){
               lastMessageWithName = "You" + ": " + message
            }else{
                lastMessageWithName = userName.capitalized + ": " + message
            }
        }else{
            if riderRide.noOfPassengers == 1{
               lastMessageWithName = String(format: Strings.number_of_rider, arguments: [String(riderRide.noOfPassengers)])
            }else{
                lastMessageWithName = String(format: Strings.number_of_riders, arguments: [String(riderRide.noOfPassengers)])
            }
        }
        let unreadCount = RidesGroupChatCache.getInstance()?.getUnreadMessageCountOfRide(rideId: riderRide.rideId)
        centralChatList.append(CentralChat(name: rideTime, imageURI: nil, lastMessage: lastMessageWithName, lastUpdateTime: lastMessageOfRideGroup?.chatTime, unreadCount: unreadCount, chatType: CentralChat.RIDE_JOIN_GROUP_CHAT, uniqueId: riderRide.rideId))
        RidesGroupChatCache.getInstance()?.addRideGroupChatListener(rideId: riderRide.rideId, listener: listener)
    }
    func removeListeners(){
        RidesGroupChatCache.getInstance()?.rideGroupChatListeners.removeAll()
        ConversationCache.getInstance().chatDialogConversationReceiver.removeAll()
        UserGroupChatCache.getInstance()?.groupConversationListeners.removeAll()
    }
    
    private func prepareCentralChatOfPassengerRide(passengerRide: PassengerRide,listener: GroupChatMessageListener){
        let lastMessageOfRideGroup = RidesGroupChatCache.getInstance()?.getGroupChatLastMessageOfRide(rideId: passengerRide.riderRideId)
        let rideTime = getRideTimeInString(rideTime: passengerRide.startTime)
        var lastMessageWithName: String?
        if let userName = lastMessageOfRideGroup?.userName, let message = lastMessageOfRideGroup?.message{
            if let userId = QRSessionManager.getInstance()?.getUserId(), let lastMsgUserId = lastMessageOfRideGroup?.phonenumber, userId == StringUtils.getStringFromDouble(decimalNumber: lastMsgUserId){
               lastMessageWithName = "You" + ": " + message
            }else{
                lastMessageWithName = userName.capitalized + ": " + message
            }
        }else{
            let numberOfRiders = MyActiveRidesCache.getRidesCacheInstance()?.getRideParicipants(riderRideId: passengerRide.riderRideId)
            if numberOfRiders!.count == 2{
               lastMessageWithName = String(format: Strings.number_of_rider, arguments: [String(numberOfRiders!.count - 1)])
            }else if numberOfRiders!.count > 2{
                lastMessageWithName = String(format: Strings.number_of_riders, arguments: [String(numberOfRiders!.count - 1)])
            }
        }
        let unreadCount = RidesGroupChatCache.getInstance()?.getUnreadMessageCountOfRide(rideId: passengerRide.riderRideId)
        centralChatList.append(CentralChat.init(name: rideTime, imageURI: nil, lastMessage: lastMessageWithName, lastUpdateTime: lastMessageOfRideGroup?.chatTime, unreadCount: unreadCount, chatType: CentralChat.RIDE_JOIN_GROUP_CHAT, uniqueId: passengerRide.riderRideId))
        RidesGroupChatCache.getInstance()?.addRideGroupChatListener(rideId: passengerRide.riderRideId, listener: listener)
    }
    private func getRideTimeInString(rideTime: Double) -> String?{
        let rideDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        let currentDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getCurrentTimeInMillis(), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        if currentDate == rideDate{
            if let rideTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a){
                return "Today, "+rideTime
            }
        }else{
            let rideTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideTime, timeFormat: DateUtils.WR_DATE_FORMAT_dd_MMM_hh_mm_aaa)
            return rideTime
        }
        return nil
    }
    
    private func getRecentPersonalChats(listener: ConversationReceiver){
        guard let contactsList = UserDataCache.getInstance()?.getRidePartnerContacts() else { return }
        for contact in contactsList{
            let lastConversationMessage = ConversationCache.getInstance().getLastConversationMessageWithUser(contact: contact)
            if lastConversationMessage != nil{
                guard let contactIdStr = contact.contactId, let  contactId = Double(contactIdStr) else { return }
                let count = ConversationCache.getInstance().getUnreadMessageCountOfUser(sourceId: contactId)
                var centralChat = CentralChat(name: contact.contactName.capitalized, imageURI: contact.contactImageURI, lastMessage: lastConversationMessage?.message, lastUpdateTime: lastConversationMessage?.time, unreadCount: count, chatType: CentralChat.PERSONAL_CHAT, uniqueId: contactId)
                centralChat.sourceApplication = lastConversationMessage?.sourceApplication
                centralChatList.append(centralChat)
                ConversationCache.getInstance().addParticularConversationListener(number: contactId, conversationReceiver: listener)
            }
        }
    }
    
    private func getMyActiveGroups(listener: GroupConversationListener){
        guard let myGroups = UserDataCache.getInstance()?.joinedGroups else { return }
        for group in myGroups {
            let unreadCount = UserGroupChatCache.getInstance()?.getUnreadMessageCountOfGroup(groupId: group.id)
            let lastConversationMessage = UserGroupChatCache.getInstance()?.getLastMessageOfGroup(groupId: group.id)
            let lastMessageWithName: String?
            if lastConversationMessage != nil{
                if let userId = QRSessionManager.getInstance()?.getUserId(), let lastMsgUserId = lastConversationMessage?.senderId, userId == StringUtils.getStringFromDouble(decimalNumber: lastMsgUserId){
                    lastMessageWithName = "You" + ": " + lastConversationMessage!.message!
                }else{
                    lastMessageWithName = lastConversationMessage!.senderName!.capitalized + ": " + lastConversationMessage!.message!
                }
            }else{
                lastMessageWithName = String(format: Strings.members, arguments: [String(group.members.count)])
            }
            var chat = CentralChat(name: group.name?.capitalized, imageURI: group.imageURI, lastMessage: lastMessageWithName, lastUpdateTime: lastConversationMessage?.time, unreadCount: unreadCount, chatType: CentralChat.USER_GROUP_CHAT, uniqueId: group.id)
            chat.lastUpdateTime = lastConversationMessage?.time
            centralChatList.append(chat)
            UserGroupChatCache.getInstance()?.addUserGroupChatListener(groupId: group.id, listener: listener)
        }
    }
    
    func upadtePerticularUserGroupInCentralChat(newMessage: GroupConversationMessage){
        var centralIndex = -1
        var found : CentralChat?
        for (index,centralChat) in centralChatList.enumerated(){
            centralIndex = index
            if centralChat.chatType == CentralChat.USER_GROUP_CHAT && centralChat.uniqueId == newMessage.groupId{
                found = centralChat
                break
            }
        }
        if found != nil{
            if let userId = QRSessionManager.getInstance()?.getUserId(), userId == StringUtils.getStringFromDouble(decimalNumber: newMessage.senderId){
                found?.lastMessage = "You" + ": " + newMessage.message!
            }else{
                found?.lastMessage = newMessage.senderName!.capitalized + ": " + newMessage.message!
            }
            found?.lastUpdateTime = newMessage.time
            found?.unreadCount = UserGroupChatCache.getInstance()?.getUnreadMessageCountOfGroup(groupId: newMessage.groupId)
            centralChatList[centralIndex] = found!
        }
    }
    
    func updatePerticularContactInCentralChat(conversationMessage: ConversationMessage){
        var centralIndex = -1
        var found : CentralChat?
        for (index,centralChat) in centralChatList.enumerated(){
            centralIndex = index
            if centralChat.chatType == CentralChat.PERSONAL_CHAT && centralChat.uniqueId == conversationMessage.sourceId{
                found = centralChat
                break
            }
        }
        if found != nil{
            found?.lastMessage = conversationMessage.message
            found?.lastUpdateTime = conversationMessage.time
            found?.sourceApplication = conversationMessage.sourceApplication
            found?.unreadCount = ConversationCache.getInstance().getUnreadMessageCountOfUser(sourceId: conversationMessage.sourceId!)
            centralChatList[centralIndex] = found!
        }
    }
    
    func updatePerticularRideJoinGroupInCentralChat(newMessage: GroupChatMessage){
       var centralIndex = -1
        var found : CentralChat?
        for (index,centralChat) in centralChatList.enumerated(){
            centralIndex = index
            if centralChat.chatType == CentralChat.RIDE_JOIN_GROUP_CHAT && centralChat.uniqueId == newMessage.rideId{
                found = centralChat
                break
            }
        }
        if found != nil{
            if let userId = QRSessionManager.getInstance()?.getUserId(), userId == StringUtils.getStringFromDouble(decimalNumber: newMessage.phonenumber){
                found?.lastMessage = "You" + ": " + newMessage.message
            }else{
                found?.lastMessage = newMessage.userName.capitalized + ": " + newMessage.message
            }
            found?.lastUpdateTime = newMessage.chatTime
            found?.unreadCount = RidesGroupChatCache.getInstance()?.getUnreadMessageCountOfRide(rideId: newMessage.rideId)
            centralChatList[centralIndex] = found!
        }
    }
}
