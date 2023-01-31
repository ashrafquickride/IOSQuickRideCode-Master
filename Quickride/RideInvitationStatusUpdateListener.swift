//
//  RideInvitationStatusUpdateListener.swift
//  Quickride
//
//  Created by QuickRideMac on 18/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideInvitationStatusUpdateListener: TopicListener {
    
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        let newRideInvitationStatus = Mapper<RideInviteStatus>().map(JSONString: messageObject as! String)
        
        if RideInvitation.RIDE_INVITATION_STATUS_CANCELLED == newRideInvitationStatus!.invitationStatus || RideInvitation.RIDE_INVITATION_STATUS_CANCELLED_RIDE == newRideInvitationStatus!.invitationStatus || RideInvitation
          .RIDE_INVITATION_STATUS_USER_JOINED_OTHER_RIDE == newRideInvitationStatus!.invitationStatus || RideInvitation.RIDE_INVITATION_STATUS_COMPLETED_RIDE == newRideInvitationStatus!.invitationStatus || RideInvitation.RIDE_INVITATION_STATUS_USER_JOINED_SAME_RIDE == newRideInvitationStatus!.invitationStatus||RideInvitation.RIDE_INVITATION_STATUS_REJECTED == newRideInvitationStatus!.invitationStatus || RideInvitation.RIDE_INVITATION_STATUS_UNJOINED == newRideInvitationStatus!.invitationStatus || RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED == newRideInvitationStatus!.invitationStatus{
            
          let notificationStore = NotificationStore.getInstanceIfExists()
          if notificationStore == nil {
            return
          }
          notificationStore?.removeInviteNotificationByInvitation(invitationId: newRideInvitationStatus!.invitationId)
      }
        RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: newRideInvitationStatus!)
  }
}
