//
//  PassengersFoundRemainderToRiderNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 25/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class PassengersFoundRemainderToRiderNotificationHandler: NotificationHandler,SelectedUserDelegate {
  
  var userNotification : UserNotification?
  var riderRide : RiderRide?
  var viewController : UIViewController?
  override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
    
    self.userNotification = userNotification
    self.viewController = viewController
    super.handleTap(userNotification: userNotification, viewController: viewController)
    let matchedPassenger = Mapper<MatchedPassenger>().map(JSONString: userNotification.msgObjectJson!)
    let matchedUserTimeData = Mapper<RideTimeData>().map(JSONString: userNotification.msgObjectJson!)
    matchedPassenger?.startDate = AppUtil.createNSDate(dateString: matchedUserTimeData!.startDate)?.getTimeStamp()
    matchedPassenger!.pickupTime = AppUtil.createNSDate(dateString: matchedUserTimeData!.pickupTime)?.getTimeStamp()
    matchedPassenger!.dropTime = AppUtil.createNSDate(dateString: matchedUserTimeData!.dropTime)?.getTimeStamp()
    matchedPassenger!.passengerReachTimeTopickup = AppUtil.createNSDate(dateString: matchedUserTimeData!.passengerReachTimeTopickup)?.getTimeStamp()
    riderRide =  MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: Double(userNotification.groupValue!)!)
    if riderRide == nil{
        return
    }
    let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
    mainContentVC.initializeData(ride: riderRide!, matchedUserList: [matchedPassenger!], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, selectedUserDelegate: self)
    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
 }

    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler : @escaping (_ valid : Bool) -> Void)
    {
        
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification){
            valid in
            if !valid{
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty, let rideId = Double(groupValue),  let ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId), ride.availableSeats > 0, let matchedPassenger = Mapper<MatchedPassenger>().map(JSONString: clientNotification.msgObjectJson!) else { return  handler(false)
            }
            
            guard let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: rideId),let rideParticipants = rideDetailInfo.rideParticipants, !rideParticipants.isEmpty else {
                return handler(true)
            }
           
            let result = rideParticipants.first { rideparticipant in
                rideparticipant.userId == matchedPassenger.userid
            }
            return handler(result == nil)
        }
    }
    override func handleTextToSpeechMessage(userNotification : UserNotification)
    {
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache == nil || userNotification.groupValue == nil || userNotification.groupValue!.isEmpty{
            return
        }
        let rideId = Double(userNotification.groupValue!)
        if rideId == nil
        {
            return
        }
        let ride = myActiveRidesCache!.getRiderRide(rideId: rideId!)
        if ride != nil
        {
            if Ride.RIDE_STATUS_STARTED == ride!.status{
                checkRiderRideStatusAndSpeakInvitation(text: userNotification.title!, time: NotificationHandler.delay_time)
            }
        }
    }

  @objc func selectedUser(selectedUser: MatchedUser) {
    AppDelegate.getAppDelegate().log.debug("selectedUser()")
    var selectePassengers : [MatchedPassenger] = [MatchedPassenger]()
    selectePassengers.append(selectedUser as! MatchedPassenger)
    
    let invitePassengers = InviteSelectedPassengersAsyncTask(riderRide: riderRide!, selectedUsers: selectePassengers, viewController: ViewControllerUtils.getCenterViewController(), displaySpinner: true, selectedIndex: nil) { (error,nserror) in
        if error == nil && nserror == nil{
            super.handlePositiveAction(userNotification: self.userNotification!, viewController: nil)
        }
    }
    invitePassengers.invitePassengersFromMatches()
  }
}
