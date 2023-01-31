//
//  InviteRegularRider.swift
//  Quickride
//
//  Created by QuickRideMac on 20/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class InviteRegularRider: InviteRegularUser {
    
    var passengerRideId : Double = 0
    var passengerId : Double = 0
    var noOfSeats = 1
    
    init(passengerRideId : Double,passengerId : Double,matchedRegularUser :MatchedRegularUser,viewcontroller :UIViewController){
        super.init(matchedRegularUser: matchedRegularUser, viewController: viewcontroller)
        self.passengerRideId = passengerRideId
        self.passengerId = passengerId
    }
    func sendInviteToRegularRider(){
       AppDelegate.getAppDelegate().log.debug("sendInviteToRegularRider()")
        checkAndDisplayHelmetAlertIfRequired()
    }
    func checkAndDisplayHelmetAlertIfRequired()
    {
            if (matchedRegularUser as! MatchedRegularRider).riderHasHelmet
            {
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.helmet_required_alert, message2: nil, positiveActnTitle: Strings.helmet_positive_action, negativeActionTitle: Strings.helmet_negative_action, linkButtonText: nil, viewController: nil, handler: { (result) in
                    if result == Strings.helmet_positive_action{
                        self.fillPickUpAndDropLocationsIfRequiredAndInvite()
                    }
                })
                return
            }
        else
        {
                self.fillPickUpAndDropLocationsIfRequiredAndInvite()
        }
    }
    override func completeInvite() {
       AppDelegate.getAppDelegate().log.debug("completeInvite()")
        RegularRideMatcherServiceClient.sendPassengerInvitationToRider(passengerRideId: passengerRideId, passengerId: passengerId, matchedRegularRider: matchedRegularUser as! MatchedRegularRider, noOfSeats: noOfSeats, viewController: viewController) { (responseObject, error) -> Void in
            self.handleResponse(responseObject: responseObject,error: error)
        }
    }
    
    func handleResponse(responseObject: NSDictionary?,error : NSError?){
        AppDelegate.getAppDelegate().log.error("handleResponse() \(String(describing: error))")
        QuickRideProgressSpinner.stopSpinner()
        if(responseObject == nil || responseObject!["result"] as! String == "FAILURE"){
            ErrorProcessUtils.handleError(responseObject: responseObject,error : error,viewController :viewController, handler: nil)
        }else if responseObject!["result"] as! String == "SUCCESS"{
            if matchedRegularUser.name == nil{
                UIApplication.shared.keyWindow?.makeToast( Strings.invite_sent_to_selected_user)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.invite_sent+"\(matchedRegularUser.name!)")
            }
        }
    }
}
