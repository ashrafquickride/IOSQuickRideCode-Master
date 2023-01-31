//
//  RiderFoundRemainderToPassengerNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 25/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RiderFoundRemainderToPassengerNotificationHandler: NotificationHandler,SelectedUserDelegate {
    
    var userNotification : UserNotification?
    var viewController : UIViewController?
    var passengerRide : PassengerRide?
  
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler : @escaping (_ invalid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue,let rideId = Double(groupValue), let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideId) else {
                return handler(false)
            }
            return handler(passengerRide.status == Ride.RIDE_STATUS_REQUESTED)
        }
        
    }
  
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handleTap")
        super.handleTap(userNotification: userNotification, viewController: viewController)
        self.userNotification = userNotification
        self.viewController = viewController
        super.handleTap(userNotification: userNotification, viewController: viewController)
        let matchedRider = Mapper<MatchedRider>().map(JSONString: userNotification.msgObjectJson!)
        let matchedUserTimeData = Mapper<RideTimeData>().map(JSONString: userNotification.msgObjectJson!)
        
        matchedRider?.startDate = AppUtil.createNSDate(dateString: matchedUserTimeData!.startDate)?.getTimeStamp()
        matchedRider!.pickupTime = AppUtil.createNSDate(dateString: matchedUserTimeData!.pickupTime)?.getTimeStamp()
        matchedRider!.dropTime = AppUtil.createNSDate(dateString: matchedUserTimeData!.dropTime)?.getTimeStamp()
        matchedRider!.passengerReachTimeTopickup = AppUtil.createNSDate(dateString: matchedUserTimeData!.passengerReachTimeTopickup)?.getTimeStamp()
        
        passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: Double(userNotification.groupValue!)!)
        if passengerRide == nil{
            return
        }
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: passengerRide!, matchedUserList: [matchedRider!], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false,  selectedUserDelegate: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    @objc func selectedUser(selectedUser: MatchedUser) {
        AppDelegate.getAppDelegate().log.debug("selectedUser()")
        guard let matchedRider = selectedUser as? MatchedRider,let ride = passengerRide else { return }
        inviteRider(matchedRider: matchedRider, passengerRide: ride)
    }
    private func inviteRider(matchedRider : MatchedRider,passengerRide: PassengerRide){
        var matchedRiders = [MatchedRider]()
        matchedRiders.append(matchedRider)
        let inviteRiderHandler = InviteRiderHandler(passengerRide: passengerRide, selectedRiders: matchedRiders, displaySpinner: true, selectedIndex: nil, viewController: ViewControllerUtils.getCenterViewController())
        inviteRiderHandler.inviteSelectedRiders(inviteHandler: { (error,nserror) -> Void in
            self.handleInviteResponse(error: error, nsError: nserror,matchedRider: matchedRider, passengerRide: passengerRide)
        })
    }
    private func handleInviteResponse(error : ResponseError?,nsError : NSError?,matchedRider : MatchedRider,passengerRide: PassengerRide){
        if error != nil{
            RideValidationUtils.handleRiderInvitationFailedException(error: error!, viewController: ViewControllerUtils.getCenterViewController(), addMoneyOrWalletLinkedComlitionHanler: { (result) in
                self.inviteRider(matchedRider: matchedRider, passengerRide: passengerRide)
            })
        }else if error == nil && nsError == nil{
            super.handlePositiveAction(userNotification: self.userNotification!, viewController: nil)

        }
    }
}
