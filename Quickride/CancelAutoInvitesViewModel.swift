//
//  CancelAutoInvitesViewModel.swift
//  Quickride
//
//  Created by Halesh K on 07/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol CancelAutoInvitesViewModelDelegate: class {
    func cancelledAllAutoInvites()
}

class CancelAutoInvitesViewModel {
     
    //MARK: Variables
    var autoSentInvites = [RideInvitation]()
    var rideType: String?
    var moreButtontapped = false
    weak var delegate: CancelAutoInvitesViewModelDelegate?
    
    func cancelAutoSentInvites(viewController: UIViewController){
        QuickRideProgressSpinner.startSpinner()
        for rideInvite in autoSentInvites{
            RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvite.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: viewController) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    rideInvite.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_CANCELLED
                    let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvite)
                    RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
                }
            }
        }
        QuickRideProgressSpinner.stopSpinner()
        delegate?.cancelledAllAutoInvites()
    }
}
