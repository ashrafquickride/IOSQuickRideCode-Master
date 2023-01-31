//
//  PassengerRideDelayedAlertNotificationHandler.swift
//  Quickride
//
//  Created by rakesh on 2/7/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PassengerRideDelayedAlertNotificationHandler : NotificationHandler,SelectedUserDelegate{

  
    var userNotification: UserNotification?
    var viewController : UIViewController?

    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
       
        handleNeutralAction(userNotification: userNotification, viewController: viewController)
    }
    
    override func handleNeutralAction(userNotification: UserNotification, viewController: UIViewController?) {
        
        self.userNotification = userNotification
        self.viewController = viewController
        let passengerRide = self.getPassengerRide(userNotification: userNotification)
        if passengerRide == nil{
            return
        }
        let matchedRider = self.getMatchedRider(userNotification: userNotification)
        if matchedRider == nil{
            return
        }
        self.moveToMatchedRideDetailView(matchedUser : matchedRider!,ride : passengerRide!, viewController: viewController)
    }
    
    func moveToMatchedRideDetailView(matchedUser : MatchedUser,ride : Ride, viewController: UIViewController?){
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: ride, matchedUserList: [matchedUser], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false,  selectedUserDelegate: self)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)

      
    }
    
    func getPassengerRide(userNotification: UserNotification) -> PassengerRide?{
      
        let currentUserPassengerRideIdString = userNotification.groupValue
        if currentUserPassengerRideIdString == nil || currentUserPassengerRideIdString!.isEmpty{
            return nil
        }
        let currentUserPassengerRideId = Double(currentUserPassengerRideIdString!)
        
        if currentUserPassengerRideId == nil || currentUserPassengerRideId == 0{
            return nil
        }
        let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: currentUserPassengerRideId!)
        return passengerRide
    }
    
    func getMatchedRider(userNotification: UserNotification) -> MatchedRider?{
        
        let matchedRider = Mapper<MatchedRider>().map(JSONString: userNotification.msgObjectJson!)
        let matchedUserTimeData = Mapper<RideTimeData>().map(JSONString: userNotification.msgObjectJson!)
        
        matchedRider?.startDate = AppUtil.createNSDate(dateString: matchedUserTimeData!.startDate)?.getTimeStamp()
        matchedRider!.pickupTime = AppUtil.createNSDate(dateString: matchedUserTimeData!.pickupTime)?.getTimeStamp()
        matchedRider!.dropTime = AppUtil.createNSDate(dateString: matchedUserTimeData!.dropTime)?.getTimeStamp()
        matchedRider!.passengerReachTimeTopickup = AppUtil.createNSDate(dateString: matchedUserTimeData!.passengerReachTimeTopickup)?.getTimeStamp()
        
        return matchedRider
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        
        self.userNotification = userNotification
        let passengerRide = self.getPassengerRide(userNotification: userNotification)
        if passengerRide == nil{
            return
        }
        let matchedRider = self.getMatchedRider(userNotification: userNotification)
        if matchedRider == nil{
            return
        }
        sendInviteToMatchedRider(passengerRide:passengerRide!,matchedRider : matchedRider!)
    }
    
    func sendInviteToMatchedRider(passengerRide:PassengerRide,matchedRider : MatchedRider){
       var selectedRiders = [MatchedRider]()
       selectedRiders.append(matchedRider)
        InviteRiderHandler(passengerRide: passengerRide , selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: ViewControllerUtils.getCenterViewController()).inviteSelectedRiders(inviteHandler: { (error,nserror) in
           
            if error == nil && nserror == nil{
                super.handlePositiveAction(userNotification: self.userNotification!, viewController: ViewControllerUtils.getCenterViewController())
            }
        })
    }
    
    override func getPositiveActionNameWhenApplicable(userNotification : UserNotification) -> String?{
        return Strings.SWITCH
    }
    
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String?
    {
        return Strings.VIEW
    }

    func selectedUser(selectedUser: MatchedUser) {
        
        var selectedRiders = [MatchedRider]()
        let passengerRide = self.getPassengerRide(userNotification: self.userNotification!)
        if passengerRide == nil{
            return
        }
        selectedRiders.append(selectedUser as! MatchedRider)
        InviteRiderHandler(passengerRide: passengerRide! , selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: ViewControllerUtils.getCenterViewController()).inviteSelectedRiders(inviteHandler: { (error,nserror) in
            
            if error == nil && nserror == nil{
                super.handlePositiveAction(userNotification: self.userNotification!, viewController: ViewControllerUtils.getCenterViewController())
            }
        })
 
    }

}
