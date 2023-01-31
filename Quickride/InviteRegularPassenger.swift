//
//  InviteRegularPassenger.swift
//  Quickride
//
//  Created by QuickRideMac on 20/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class InviteRegularPassenger: InviteRegularUser {
    
    var riderRideId : Double = 0
    var riderId : Double = 0
    
    init(matchedRegularUser :MatchedRegularUser,riderRideId : Double,riderId : Double,viewController : UIViewController) {
        self.riderRideId = riderRideId
        self.riderId = riderId
        super.init(matchedRegularUser: matchedRegularUser,viewController :viewController)
    }
    func sendRegularRideInvitationToPassenger(){
        AppDelegate.getAppDelegate().log.debug("sendRegularRideInvitationToPassenger()")
        fillPickUpAndDropLocationsIfRequiredAndInvite()
    }
    override func completeInvite() {
      AppDelegate.getAppDelegate().log.debug("completeInvite()")
        RegularRideMatcherServiceClient.sendRiderInvitationToPassenger(riderRideId: riderRideId, riderId: riderId, selectedPassenger: matchedRegularUser as! MatchedRegularPassenger, viewController: viewController) { (responseObject, error) -> Void in
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
