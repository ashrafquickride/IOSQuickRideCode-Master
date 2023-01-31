//
//  PassengersToPickupTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 17/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class PassengersToPickupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var otpRequiredLabel: UILabel!
    
    private var passengerToPickup: RideParticipant?
    private var viewController: UIViewController?
    private var otpVerified: Bool?
    private var ride: Ride?
    
    func initializeViews(passengerToPickup: RideParticipant, ride: Ride?, otpVerified: Bool?, viewController: UIViewController){
        self.passengerToPickup = passengerToPickup
        self.otpVerified = otpVerified
        self.viewController = viewController
        self.ride = ride
        setData()
    }
    
    private func setData() {
        if let name = passengerToPickup?.name?.capitalized {
            userNameLabel.text = name.capitalized
        }
        if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: passengerToPickup!, ride: ride,  riderProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) {
            if otpVerified != nil && otpVerified! {
                otpRequiredLabel.isHidden = true
                callButton.isHidden = true
                chatButton.isHidden = true
                userNameLabel.textColor = UIColor(netHex: 0x00B557)
            } else {
                otpRequiredLabel.isHidden = false
                callButton.isHidden = false
                chatButton.isHidden = false
                userNameLabel.textColor = UIColor.black
                if passengerToPickup!.enableChatAndCall {
                    if passengerToPickup!.callSupport == UserProfile.SUPPORT_CALL_NEVER {
                       callButton.backgroundColor = UIColor(netHex: 0xcad2de)
                    }else{
                       callButton.backgroundColor = UIColor(netHex: 0x2196f3)
                    }
                    chatButton.backgroundColor = UIColor(netHex: 0x19ac4a)
                }else{
                    callButton.backgroundColor = UIColor(netHex: 0xcad2de)
                    chatButton.backgroundColor = UIColor(netHex: 0xcad2de)
                }
            }
        } else {
            userNameLabel.textColor = UIColor.black
            otpRequiredLabel.isHidden = true
            callButton.isHidden = true
            chatButton.isHidden = true
        }
    }
    
    private func getErrorMessageForCall() -> String?{
        if passengerToPickup!.enableChatAndCall{
            if passengerToPickup!.callSupport == UserProfile.SUPPORT_CALL_NEVER{
                return Strings.no_call_please_msg
            }
        }else{
            return Strings.chat_and_call_disable_msg
        }
        return nil
    }
    
    private func getErroMessageForChat() -> String?{
        if !passengerToPickup!.enableChatAndCall{
            return Strings.chat_and_call_disable_msg
        }
        return nil
    }
    
    @IBAction func callButtonClicked(_ sender: UIButton) {
        if let callDisableMsg = getErrorMessageForCall(){
            UIApplication.shared.keyWindow?.makeToast( callDisableMsg)
            return
        }
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: passengerToPickup!.userId), refId: "", name: passengerToPickup!.name ?? "", targetViewController: viewController!)
    }
    
    @IBAction func chatButtonClicked(_ sender: UIButton) {
        if let chatDisableMsg = getErroMessageForChat(){
            UIApplication.shared.keyWindow?.makeToast( chatDisableMsg)
            return
        }
        guard let userId = passengerToPickup?.userId else { return }
        var isRideStarted = false
        if passengerToPickup!.rider && passengerToPickup!.status == Ride.RIDE_STATUS_STARTED && passengerToPickup!.callSupport != UserProfile.SUPPORT_CALL_NEVER{
            isRideStarted = true
        }else{
            isRideStarted = false
        }
        let chatConversationDialogueVC = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatConversationDialogueVC.initializeDataBeforePresentingView(ride: ride, userId: userId, isRideStarted: isRideStarted, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: chatConversationDialogueVC, animated: false)
    }
}
