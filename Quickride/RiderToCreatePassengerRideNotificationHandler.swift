//
//  RiderToCreatePassengerRideNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 25/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RiderToCreatePassengerRideNotificationHandler: NotificationHandler,SelectedUserDelegate {
    var userNotification : UserNotification?
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid : Bool) -> Void) {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid{
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty, let rideId = Double(groupValue), let ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId) else {
                return handler(false)
            }
            return handler(ride.status != Ride.RIDE_STATUS_STARTED)
        }
    }

    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handleTap()")
        self.userNotification = userNotification
        handleNeutralAction(userNotification: userNotification, viewController: viewController)
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
      
      AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
       self.userNotification = userNotification
      
        let matchedRider = Mapper<MatchedRider>().map(JSONString: userNotification.msgObjectJson!)
        let matchedUserTimeData = Mapper<RideTimeData>().map(JSONString: userNotification.msgObjectJson!)
        matchedRider!.startDate = AppUtil.createNSDate(dateString: matchedUserTimeData!.startDate)?.getTimeStamp()
        matchedRider!.pickupTime = AppUtil.createNSDate(dateString: matchedUserTimeData!.pickupTime)?.getTimeStamp()
        matchedRider!.dropTime = AppUtil.createNSDate(dateString: matchedUserTimeData!.dropTime)?.getTimeStamp()
        matchedRider!.passengerReachTimeTopickup = AppUtil.createNSDate(dateString: matchedUserTimeData!.passengerReachTimeTopickup)?.getTimeStamp()

        createPassengerRideAndInvite(matchedRider: matchedRider!)
    }
    func createPassengerRideAndInvite(matchedRider : MatchedRider){
      AppDelegate.getAppDelegate().log.debug("createPassengerRideAndInvite()")
        let ride = Ride(userId: Double(QRSessionManager.getInstance()!.getUserId())!, rideType: Ride.PASSENGER_RIDE, startAddress: matchedRider.fromLocationAddress!, startLatitude: matchedRider.fromLocationLatitude!, startLongitude: matchedRider.fromLocationLongitude!, endAddress: matchedRider.toLocationAddress!, endLatitude: matchedRider.toLocationLatitude!, endLongitude: matchedRider.toLocationLongitude!, startTime: matchedRider.startDate!)
        let passengerRide = PassengerRide(ride: ride)
        let createPassengerRideHandler = CreatePassengerRideHandler(ride: passengerRide, rideRoute: nil, isFromInviteByContact: false, targetViewController: ViewControllerUtils.getCenterViewController(), parentRideId: nil,relayLegSeq: nil)
        createPassengerRideHandler.createPassengerRide { (passengerRide, error) -> Void in
            if passengerRide != nil{
                self.inviteRider(matchedRider: matchedRider, passengerRide: passengerRide!)
            }
        }
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
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
      AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.join
    }
    
    override func handleNeutralAction(userNotification: UserNotification, viewController: UIViewController?) {


      AppDelegate.getAppDelegate().log.debug("handleNeutralAction()")

        self.userNotification = userNotification


        let matchedRider = Mapper<MatchedRider>().map(JSONString: userNotification.msgObjectJson!)
        let rideTimeData = Mapper<RideTimeData>().map(JSONString: userNotification.msgObjectJson!)
        matchedRider?.startDate = AppUtil.createNSDate(dateString: rideTimeData!.startDate)?.getTimeStamp()
        matchedRider!.pickupTime = AppUtil.createNSDate(dateString: rideTimeData!.pickupTime)?.getTimeStamp()
        matchedRider!.dropTime = AppUtil.createNSDate(dateString: rideTimeData!.dropTime)?.getTimeStamp()
        matchedRider!.passengerReachTimeTopickup = AppUtil.createNSDate(dateString: rideTimeData!.passengerReachTimeTopickup)?.getTimeStamp()
    
        let ride = Ride(userId: Double(QRSessionManager.getInstance()!.getUserId())!, rideType: Ride.PASSENGER_RIDE, startAddress: matchedRider!.fromLocationAddress!, startLatitude: matchedRider!.fromLocationLatitude!, startLongitude: matchedRider!.fromLocationLongitude!, endAddress: matchedRider!.toLocationAddress!, endLatitude: matchedRider!.toLocationLatitude!, endLongitude: matchedRider!.toLocationLongitude!, startTime: matchedRider!.startDate!)
        
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: ride, matchedUserList: [matchedRider!], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, selectedUserDelegate: self)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {

      AppDelegate.getAppDelegate().log.debug("getNeutralActionNameWhenApplicable()")

       return Strings.VIEW
    }
    @objc func selectedUser(selectedUser: MatchedUser) {
      AppDelegate.getAppDelegate().log.debug("selectedUser()")
        createPassengerRideAndInvite(matchedRider: selectedUser as! MatchedRider)
    }
}
