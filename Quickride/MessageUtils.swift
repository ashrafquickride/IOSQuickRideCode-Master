//
//  MessageUtils.swift
//  Quickride
//
//  Created by Admin on 30/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class MessageUtils {
    static func isMessageAllowedToDisplay(message: String, latitude: Double, longitude: Double) -> Bool{
        let splittedMessages = message.split(separator: " ")
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil
        {
            clientConfiguration = ClientConfigurtion()
        }
        let illegalMessages = clientConfiguration!.illegalChatMessages
            for message in splittedMessages{
                for illegalMessage in illegalMessages{
                    if message.lowercased() == illegalMessage.lowercased(){
                        return false
                    }
                }
            }
        let result = isConversationContainsUnacceptableDigitPattern(message: message, latitude: latitude, longitude: longitude)
        if !result {
            return true
        } else {
            return false
        }
    }
    
    static func isConversationContainsUnacceptableDigitPattern(message: String?, latitude: Double, longitude: Double) -> Bool
    {
        if message == nil || latitude != 0 || longitude != 0 {
            return false
        }
        else {
            do {
                let regex = try NSRegularExpression(pattern: "(\\d+(?:\\.\\d+)?)")
                let results = regex.matches(in: message!,
                                                range: NSRange(message!.startIndex..., in: message!))
                let nsString = NSString(string: message!)
                let listOfSubString = results.map { nsString.substring(with: $0.range) }
                for result in listOfSubString {
                    if let number = Int(result), number >= 100 {
                        return true
                    } else {
                        continue
                    }
                }
            } catch let error {
                AppDelegate.getAppDelegate().log.debug("\(error.localizedDescription)")
                return false
            }
        }
        return false
    }
    
    static func getUnreadCountOfChat() -> Int{
        var unreadCount = 0
        if let activeRiderRides = MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides().values{
            for riderRide in activeRiderRides{
                unreadCount = unreadCount + (RidesGroupChatCache.getInstance()?.getUnreadMessageCountOfRide(rideId: riderRide.rideId) ?? 0)
            }
        }
        if let activePassengerRides = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRides().values{
            for passengerRide in activePassengerRides{
                unreadCount = unreadCount + (RidesGroupChatCache.getInstance()?.getUnreadMessageCountOfRide(rideId: passengerRide.riderRideId) ?? 0)
            }
        }
        if let contactsList = UserDataCache.getInstance()?.getRidePartnerContacts(){
            for contact in contactsList{
                if let contactIdStr = contact.contactId, let  contactId = Double(contactIdStr){
                    unreadCount = unreadCount + ConversationCache.getInstance().getUnreadMessageCountOfUser(sourceId: contactId)
                }
            }
        }
        if let myGroups = UserDataCache.getInstance()?.joinedGroups{
            for group in myGroups{
                unreadCount = unreadCount + (UserGroupChatCache.getInstance()?.getUnreadMessageCountOfGroup(groupId: group.id) ?? 0)
            }
        }
        return unreadCount
    }
}
