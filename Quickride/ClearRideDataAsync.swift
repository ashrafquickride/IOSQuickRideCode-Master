//
//  ClearRideDataAsync.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 19/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ClearRideDataAsync {


  func clearRideData(rideStatus:RideStatus){
    AppDelegate.getAppDelegate().log.debug("clearRideData()")
    DispatchQueue.main.async() { () -> Void in
      if(rideStatus.rideType == Ride.RIDER_RIDE){
        self.completeRiderRide(rideStatus: rideStatus)
      }else{
        self.completePassengerRide(rideStatus: rideStatus)
      }
    }
  }

  func completeRiderRide(rideStatus:RideStatus){

     AppDelegate.getAppDelegate().log.debug("completeRiderRide()")
    UserDataCache.getInstance()!.refreshAccountInformationInCache()

    if(Ride.RIDE_STATUS_CANCELLED == rideStatus.status){
      MyActiveRidesCache.singleCacheInstance?.removeRideDetailInformationForRiderRide(riderRideId: rideStatus.rideId)
    }
    if (Ride.RIDE_STATUS_COMPLETED == rideStatus.status){
        let rideDetailInfo = MyActiveRidesCache.singleCacheInstance?.getRideDetailInfoIfExist(riderRideId: rideStatus.rideId)
        if rideDetailInfo != nil && rideDetailInfo?.rideParticipants != nil{
            for rideParticipant in rideDetailInfo!.rideParticipants! {
                if rideParticipant.rider{
                    continue
                }
                let contact = Contact(userId: rideStatus.userId, contactId : StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), contactName : rideParticipant.name!, contactGender : rideParticipant.gender, contactType : Contact.RIDE_PARTNER, imageURI : rideParticipant.imageURI , supportCall : rideParticipant.callSupport, contactNo: nil,defaultRole: Ride.RIDER_RIDE)
                UserDataCache.getInstance()?.storeRidePartnerContact(contact: contact)
            }
        }
        SharedPreferenceHelper.clearRideDetailInfo(riderRideId: StringUtils.getStringFromDouble(decimalNumber: rideStatus.rideId))
    }
    SharedPreferenceHelper.removeRideLocationSequenceNo(rideId : rideStatus.rideId)
    SharedPreferenceHelper.saveSortAndFilterStatus(rideId: rideStatus.rideId, status: nil, rideType: rideStatus.rideType ?? "")
    SharedPreferenceHelper.storeInvitedGroupIds(rideId: rideStatus.rideId, groupIds: nil)
    SharedPreferenceHelper.storeInvitedPhoneBookContacts(rideId: rideStatus.rideId, contacts: nil)
    deleteNotificationOfRide(rideStatus: rideStatus)
    removeGroupChatCacheData(rideStatus: rideStatus)
    ETACalculator.getInstance().clearRouteMetricsForRoute(riderRideId: rideStatus.rideId)
  }

  func completePassengerRide(rideStatus:RideStatus){

     AppDelegate.getAppDelegate().log.debug("completePassengerRide()")
    UserDataCache.getInstance()!.refreshAccountInformationInCache()

    if(rideStatus.joinedRideId != 0 && rideStatus.status == Ride.RIDE_STATUS_CANCELLED){
      MyActiveRidesCache.singleCacheInstance?.removeRideDetailInformationForRiderRide(riderRideId: rideStatus.joinedRideId)
    }
    if (Ride.RIDE_STATUS_COMPLETED == rideStatus.status){
        let rideDetailInfo = MyActiveRidesCache.singleCacheInstance?.getRideDetailInfoIfExist(riderRideId: rideStatus.joinedRideId)
        if rideDetailInfo != nil && rideDetailInfo?.rideParticipants != nil{
            for rideParticipant in rideDetailInfo!.rideParticipants! {
                if rideParticipant.rider{
                    let contact = Contact(userId: rideStatus.userId, contactId : StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), contactName : rideParticipant.name!, contactGender : rideParticipant.gender, contactType : Contact.RIDE_PARTNER, imageURI : rideParticipant.imageURI , supportCall : rideParticipant.callSupport,contactNo: nil,defaultRole: Ride.PASSENGER_RIDE)
                UserDataCache.getInstance()?.storeRidePartnerContact(contact: contact)
                    break
                }
            }
        }
        SharedPreferenceHelper.clearRideDetailInfo(riderRideId: StringUtils.getStringFromDouble(decimalNumber: rideStatus.joinedRideId))
    }
    SharedPreferenceHelper.removeRideLocationSequenceNo(rideId : rideStatus.joinedRideId)
    SharedPreferenceHelper.saveSortAndFilterStatus(rideId: rideStatus.rideId, status: nil,rideType: rideStatus.rideType ?? "")
    deleteNotificationOfRide(rideStatus: rideStatus)
    removeGroupChatCacheData(rideStatus: rideStatus)
    ETACalculator.getInstance().clearRouteMetricsForRoute(riderRideId: rideStatus.joinedRideId)
  }

  func deleteNotificationOfRide(rideStatus:RideStatus){
     AppDelegate.getAppDelegate().log.debug("deleteNotificationOfRide()")
    if(Ride.RIDER_RIDE == rideStatus.rideType){
      NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupName: UserNotification.NOT_GRP_RIDER_RIDE, groupValue: StringUtils.getStringFromDouble(decimalNumber : rideStatus.rideId))
      NotificationStore.getInstance().removeInvitationWithGroupNameAndGroupValue(groupName: UserNotification.NOT_GRP_RIDER_RIDE, groupValue: StringUtils.getStringFromDouble(decimalNumber : rideStatus.rideId))

    }else{
      NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupName: UserNotification.NOT_GRP_PASSENGER_RIDE, groupValue: StringUtils.getStringFromDouble(decimalNumber : rideStatus.rideId))
      NotificationStore.getInstance().removeInvitationWithGroupNameAndGroupValue(groupName: UserNotification.NOT_GRP_PASSENGER_RIDE, groupValue: StringUtils.getStringFromDouble(decimalNumber : rideStatus.rideId))
    }
  }

  func removeGroupChatCacheData(rideStatus:RideStatus){
     AppDelegate.getAppDelegate().log.debug("removeGroupChatCacheData()")
    RidesGroupChatCache.getInstance()?.deleteChatMessagesOfARide(rideId: rideStatus.rideId)
    RidesGroupChatCache.getInstance()?.resetUnreadMessageCountOfARide(rideId: rideStatus.rideId)
    NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupName: UserNotification.NOT_GRP_CHAT, groupValue: String(rideStatus.rideId).components(separatedBy: ".")[0])

  }

}
