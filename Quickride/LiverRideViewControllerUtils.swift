//
//  LiverRideViewControllerUtils.swift
//  Quickride
//
//  Created by Quick Ride on 7/26/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI

class LiveRideViewControllerUtils {
    
    static func showContactOptionView(ride: Ride?,rideParticipant: RideParticipant,viewController : UIViewController) {
          guard let name = rideParticipant.name, let callSupport = rideParticipant.callSupport else { return }
          let userBasicInfo = UserBasicInfo(userId : rideParticipant.userId, gender : rideParticipant.gender,userName : name, imageUri: rideParticipant.imageURI, callSupport : callSupport)
          let isRideStarted : Bool?
          if rideParticipant.rider && rideParticipant.status == Ride.RIDE_STATUS_STARTED && rideParticipant.callSupport != UserProfile.SUPPORT_CALL_NEVER{
              isRideStarted = true
          }else{
              isRideStarted = false
          }
          let contactOptionsDialougeViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ContactOptionsDialouge") as! ContactOptionsDialouge
        contactOptionsDialougeViewController.initializeDataBeforePresentingView(ride: ride, presentConatctUserBasicInfo : userBasicInfo,supportCall: UserProfile.isCallSupportAfterJoined(callSupport: rideParticipant.callSupport!, enableChatAndCall: rideParticipant.enableChatAndCall), delegate: nil, isRideStarted: isRideStarted!, dismissDelegate: nil)
          ViewControllerUtils.addSubView(viewControllerToDisplay: contactOptionsDialougeViewController)
      }
    
    static func sendSMS(phoneNumber:String?, message : String,viewController : UIViewController){

        let messageViewConrtoller = MFMessageComposeViewController()

        if MFMessageComposeViewController.canSendText() {
            messageViewConrtoller.body = message
            if phoneNumber != nil{
                messageViewConrtoller.recipients = [phoneNumber!]
            }
            messageViewConrtoller.messageComposeDelegate = viewController
            viewController.present(messageViewConrtoller, animated: false, completion: nil)
        }
    }
    
    static func displayConnectedUserProfile(rideParticipant : RideParticipant, riderRide : RiderRide?,viewController : UIViewController){
        let vc  = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        
        if rideParticipant.rider {
            guard let vehicle = LiveRideViewModelUtil.getRiderVehicle(riderRide : riderRide) else {
                return
            }
            vc.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId),isRiderProfile: UserRole.Rider,rideVehicle: vehicle, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: rideParticipant.rideNote, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: vc, animated: false)
        }else{
            vc.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId),isRiderProfile: UserRole.Passenger,rideVehicle: nil, userSelectionDelegate: nil, displayAction: false,isFromRideDetailView : false, rideNotes: rideParticipant.rideNote, matchedRiderOnTimeCompliance: nil, noOfSeats: rideParticipant.noOfSeats, isSafeKeeper: false)
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: vc, animated: false)
        }
    }
}
