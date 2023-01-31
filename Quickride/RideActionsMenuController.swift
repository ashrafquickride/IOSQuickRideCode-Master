//
//  RideActionsMenuController.swift
//  Quickride
//
//  Created by QuickRideMac on 26/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import RevealMenuController
import UIKit

protocol RideActionDelegate{
    func rideArchived(ride : Ride)
    func handleFreezeRide(freezeRide : Bool)
    func handleEditRoute()
}
class RideActionsMenuController : VehicleDetailsUpdateListener{

    var ride : Ride?
    weak var viewController :UIViewController?
    var rideUpdateListener : RideObjectUdpateListener?
    var rideActionDelegate : RideActionDelegate?
    var isFromRideView = false
    init(ride :Ride,isFromRideView : Bool,viewController : UIViewController,rideUpdateListener : RideObjectUdpateListener,delegate: RideActionDelegate){
        self.ride = ride
        self.viewController = viewController
        self.rideUpdateListener = rideUpdateListener
        self.isFromRideView = isFromRideView
        self.rideActionDelegate = delegate
    }

    func freezeRide(){
        let freezeRideConfirmationViewController = UIStoryboard(name: "LiveRideView",bundle: nil).instantiateViewController(withIdentifier: "FreezeRideConfirmationViewController") as! FreezeRideConfirmationViewController
        freezeRideConfirmationViewController.initialiseFreezeRideConfirmation() { (isConfirmed) in
            if isConfirmed {
                self.handleFreezeRide(freezeRide: true)
            }
        }
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: freezeRideConfirmationViewController, animated: false, completion: nil)
    }
    
    func handleFreezeRide(freezeRide : Bool)
    {
        QuickRideProgressSpinner.startSpinner()
        RiderRideRestClient.freezeRide(rideId: self.ride!.rideId, freezeRide: freezeRide, targetViewController: self.viewController, complitionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let riderRide = self.ride as? RiderRide {
                    riderRide.freezeRide = freezeRide
                }
                if !freezeRide {
                    UIApplication.shared.keyWindow?.makeToast(Strings.ride_unfreezed, point: CGPoint(x: (self.viewController?.view.frame.size.width)!/2, y: (self.viewController?.view.frame.size.height)!-200), title: nil, image: nil, completion: nil)
                    
                    self.rideActionDelegate?.handleFreezeRide(freezeRide: freezeRide)
                } else {
                    UIApplication.shared.keyWindow?.makeToast(Strings.ride_freezed, point: CGPoint(x: (self.viewController?.view.frame.size.width)!/2, y: (self.viewController?.view.frame.size.height)!-200), title: nil, image: nil, completion: nil)
                    self.rideActionDelegate?.handleFreezeRide(freezeRide: freezeRide)
                }
            }
            else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        })
    }
    
    func cancelRide(rideParticipants: [RideParticipant]?) {
        guard let viewController = self.viewController else { return }
        if self.ride!.rideType == Ride.REGULAR_RIDER_RIDE || self.ride!.rideType == Ride.REGULAR_PASSENGER_RIDE{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.ride_delete_message, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: viewController, handler: { (result) in
                if result == Strings.yes_caps{
                    let cancelRegularRideTask : CancelRegularRideTask = CancelRegularRideTask(ride: self.ride!, rideType: self.ride!.rideType, viewController: viewController)
                    cancelRegularRideTask.cancelRegularRide()
                }
            })
        }else{
            let passengerRide = self.ride! as? PassengerRide
            if passengerRide == nil || passengerRide?.taxiRideId == nil || passengerRide?.taxiRideId == 0.0{
                
                let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationAndUnJoinViewController") as! RideCancellationAndUnJoinViewController
                rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(rideParticipants: rideParticipants, rideType: self.ride?.rideType, isFromCancelRide: true, ride: self.ride,vehicelType: nil,rideUpdateListener: self.rideUpdateListener, completionHandler: {
                })
                ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
            } else {
                RideCancelActionProxy.getCancelRideInformation(ride: self.ride!, cancelReason: "", uiViewController: viewController, completionhandler: { (compensation) -> Void in
                    QuickRideProgressSpinner.stopSpinner()
                    let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard,bundle: nil).instantiateViewController(withIdentifier: "CancelTaxiPoolViewController") as! CancelTaxiPoolViewController
                    rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(taxiRide: nil, completionHandler: { (cancelReason) in
                        QuickRideProgressSpinner.startSpinner()
                        RideCancelActionProxy.cancelRide(ride: self.ride!, cancelReason: cancelReason, isWaveOff: false, viewController: viewController, handler: {
                            QuickRideProgressSpinner.stopSpinner()
                        })
                    })
                    ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
                })
            }
            
        }
    }
    
    func repeatRide(){
        let newRide : Ride?
        if ride?.rideType == Ride.RIDER_RIDE{
            newRide = (ride as! RiderRide).copy() as? RiderRide
        }else{
            newRide = (ride as! PassengerRide).copy() as? PassengerRide
        }
        RepeatRideController(ride: newRide! , viewController: viewController!).repeatRide()
    }
    
    func createReturnRide(){
        let newRide : Ride?
        if  ride?.rideType == Ride.RIDER_RIDE{
            newRide = (ride!.copy() as! RiderRide)
        }else{
            newRide = (ride!.copy() as! PassengerRide)
        }
        ReturnRideCreation(viewController: viewController!, ride: newRide!).createReturnRide()
    }

    func cancelCurrentRideAndCreateNewRideWithDifferentRole()
    {
        if self.ride!.rideType == Ride.PASSENGER_RIDE{
            let vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
            if vehicle!.vehicleId == 0 || vehicle!.registrationNumber.isEmpty == true
            {
                self.displayVehicleConfigurationDialog(userVehicle: vehicle!)
                return
            }
            else
            {
                self.VehicleDetailsUpdated()
            }
        }
        else
        {
            let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride!.expectedEndTime, time2: ride!.startTime)
            let rideRoute = RideRoute(routeId: ride!.routeId!,overviewPolyline : ride!.routePathPolyline,distance :ride!.distance!,duration : Double(duration), waypoints : ride!.waypoints)
            QuickRideProgressSpinner.startSpinner()
            RideCancelActionProxy.cancelRide(ride: ride!, cancelReason: RideCancelActionProxy.USER_ROLE_CHANGED, isWaveOff: false, viewController: self.viewController!, handler: {
                if self.ride!.rideType == Ride.RIDER_RIDE{
                    let newRide = PassengerRide(ride : self.ride!)
                    CreatePassengerRideHandler(ride: newRide, rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: self.viewController, parentRideId: nil,relayLegSeq: nil).createPassengerRide(handler: { (passengerRide, error) in
                        if passengerRide != nil{
                            self.moveToNewRide(ride : passengerRide!)
                            QuickRideProgressSpinner.stopSpinner()
                        }
                    })
                }
            })
        }
    }
    func displayVehicleConfigurationDialog(userVehicle : Vehicle){
        AppDelegate.getAppDelegate().log.debug("displayVehicleConfigurationDialog()")
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.vehicle_details, message2: nil, positiveActnTitle: Strings.configure_caps, negativeActionTitle : Strings.cancel_caps,linkButtonText: nil, viewController: self.viewController, handler: { (result) in
            if Strings.configure_caps == result{

                let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
                vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false, rideConfigurationDelegate: nil,vehicle : nil,listener : self)
                ViewControllerUtils.displayViewController(currentViewController: self.viewController, viewControllerToBeDisplayed: vehicleSavingViewController, animated: false)
            }
        })
    }
    func VehicleDetailsUpdated()
    {
        let newRide = RiderRide(ride : self.ride!)
        let vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        newRide.vehicleId = vehicle!.vehicleId
        newRide.vehicleType = vehicle!.vehicleType
        newRide.vehicleModel = vehicle!.vehicleModel
        newRide.vehicleNumber = vehicle!.registrationNumber
        newRide.makeAndCategory = vehicle!.makeAndCategory
        newRide.farePerKm = vehicle!.fare
        newRide.additionalFacilities = vehicle!.additionalFacilities
        newRide.capacity = vehicle!.capacity
        newRide.availableSeats = vehicle!.capacity
        newRide.riderHasHelmet = vehicle!.riderHasHelmet
        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride!.expectedEndTime, time2: ride!.startTime)
        let rideRoute = RideRoute(routeId: ride!.routeId!,overviewPolyline : ride!.routePathPolyline,distance :ride!.distance!,duration : Double(duration), waypoints : ride!.waypoints)
        QuickRideProgressSpinner.startSpinner()
        RideCancelActionProxy.cancelRide(ride: ride!, cancelReason: RideCancelActionProxy.USER_ROLE_CHANGED, isWaveOff: false, viewController: self.viewController!, handler: {
            if self.ride!.rideType == Ride.PASSENGER_RIDE{
                CreateRiderRideHandler(ride: newRide, rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: self.viewController).createRiderRide(handler: { (riderRide, error) in
                    if riderRide != nil{
                        self.moveToNewRide(ride : riderRide!)
                        QuickRideProgressSpinner.stopSpinner()
                    }
                })
            }
        })
    }
    func moveToNewRide(ride : Ride){
        AppDelegate.getAppDelegate().log.debug("")
        viewController?.navigationController?.popViewController(animated: false)
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }

    func archiveRide(){
        AppDelegate.getAppDelegate().log.debug("archiveRide()")
        switch ride!.rideType {
        case Ride.RIDER_RIDE? :
            RiderRideRestClient.updateRideStatus(rideId: ride!.rideId, status: Ride.RIDE_STATUS_ARCHIVED, targetViewController: viewController, complitionHandler: { (responseObject, error) in

            })
            MyClosedRidesCache.getClosedRidesCacheInstance().deleteRiderRide(rideId: ride!.rideId)
            rideActionDelegate?.rideArchived(ride: ride!)
            break
        case Ride.PASSENGER_RIDE? :
            let passengerRide = ride as! PassengerRide
            PassengerRideServiceClient.updatePassengerRideStatus(passengerRideId: passengerRide.rideId, joinedRiderRideId: passengerRide.riderRideId, passengerId: passengerRide.userId, status: Ride.RIDE_STATUS_ARCHIVED,fromRider: false, otp: nil, viewController: viewController, completionHandler: { (responseObject, error) in

            })

            MyClosedRidesCache.getClosedRidesCacheInstance().deletePassengerRide(rideId: ride!.rideId)
            rideActionDelegate?.rideArchived(ride: ride!)
            break
        default:
            break
        }

    }
    func createRegularRide()  {
      AppDelegate.getAppDelegate().log.debug("createRegularRide()")
       let regularRideCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.regularRideCreationViewController) as! RegularRideCreationViewController
        regularRideCreationViewController.initializeView(createRideAsRecuringRide: true, ride: ride?.copy() as? Ride)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: regularRideCreationViewController, animated: false)
      }
    func rescheduleRide(){
        RescheduleRide(ride: self.ride!, viewController: self.viewController!,moveToRideView: false).rescheduleRide()
    }
    
    func showShareOptions(){
        var rideId: String
        if ride?.rideType == Ride.RIDER_RIDE{
            rideId = StringUtils.getStringFromDouble(decimalNumber : ride?.rideId)
        }else{
            rideId =  StringUtils.getStringFromDouble(decimalNumber : (ride as! PassengerRide).riderRideId)
        }
        let shareRidePath = ShareRidePath(viewController: viewController!, rideId: rideId)
        shareRidePath.showShareOptions()
    }
    

    func updateRegularRideStatus(status : String){
        AppDelegate.getAppDelegate().log.debug("updateRegularRiderRidStatus() \(status)")
        if Ride.REGULAR_RIDER_RIDE == ride?.rideType{
            QuickRideProgressSpinner.startSpinner()
            RegularRiderRideServiceClient.updateRegularRiderRideStatus(id: ride!.rideId, status: status, handler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                self.handleRegularRideUpdateResponse(responseObject: responseObject,error: error,status : status)
            })
        }else if Ride.REGULAR_PASSENGER_RIDE == ride?.rideType{
            QuickRideProgressSpinner.startSpinner()
            RegularPassengerRideServiceClient.updateRegularPassengerRideStatus(rideId: ride!.rideId, status: status, completionHander: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                self.handleRegularRideUpdateResponse(responseObject: responseObject,error: error,status : status)
            })
        }
    }
    func handleRegularRideUpdateResponse(responseObject: NSDictionary?,error : NSError?,status :String){
        AppDelegate.getAppDelegate().log.debug("handleRegularRideUpdateResponse() \(status)")
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            let rideStatus = RideStatus(rideId: self.ride!.rideId, userId: self.ride!.userId, status: status, rideType: self.ride!.rideType!)
            MyRegularRidesCache.getInstance().updateRideStatus(rideStatus: rideStatus)
        }else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
        }
    }
    func moveToRegularRide(){
      AppDelegate.getAppDelegate().log.debug("moveToRegularRide()")
        let recurringRideViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.recurringRideViewController) as! RecurringRideViewController
        recurringRideViewController.initializeDataBeforePresentingView(ride: ride!, isFromRecurringRideCreation: false)
        viewController!.navigationController?.pushViewController(recurringRideViewController, animated: false)
    }

    func handleRideNotesAction() {
        AppDelegate.getAppDelegate().log.debug("")
        var existedMessage : String?

        if Ride.RIDER_RIDE == ride!.rideType
        {
            existedMessage = MyActiveRidesCache.getRidesCacheInstance()?.getRideRideNotes(rideId: ride!.rideId)
        }
        else if Ride.PASSENGER_RIDE == ride!.rideType
        {
            existedMessage = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRideNotes(rideId: ride!.rideId)
        }
        if existedMessage == nil || existedMessage!.isEmpty
        {
            let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()
            existedMessage = ridePreferences?.rideNote
        }
        let textViewAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "TextViewAlertController") as! TextViewAlertController
        textViewAlertController.initializeDataBeforePresentingView(title: Strings.ride_notes_title, positiveBtnTitle: Strings.save_caps, negativeBtnTitle: Strings.cancel_caps, placeHolder: Strings.ride_notes, textAlignment: NSTextAlignment.left, isCapitalTextRequired: false, isDropDownRequired: false, dropDownReasons: nil, existingMessage: existedMessage,viewController: self.viewController, handler: { (text, result) in
            if Strings.save_caps == result
            {
                if(Ride.RIDER_RIDE == self.ride!.rideType)
                {
                    QuickRideProgressSpinner.startSpinner()
                    RiderRideRestClient.updateRideNotes(rideId: self.ride!.rideId, rideNotes: text!, ViewController: self.viewController!, completionHandler: { (responseObject, error) in
                        QuickRideProgressSpinner.stopSpinner()
                        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                            MyActiveRidesCache.getRidesCacheInstance()?.updateRiderRideNotes(rideId: self.ride!.rideId, statusMessage: text!)
                        }
                        else {
                            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                        }

                    })
                }
                else if Ride.PASSENGER_RIDE == self.ride!.rideType
                {
                    QuickRideProgressSpinner.startSpinner()
                    PassengerRideServiceClient.updateRideNotes(rideId: self.ride!.rideId, rideNotes: text!, viewController: self.viewController!, completionHandler: { (responseObject, error) in
                        QuickRideProgressSpinner.stopSpinner()
                        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                            MyActiveRidesCache.getRidesCacheInstance()?.updatePassengerRideNotes(rideId: self.ride!.rideId, statusMessage: text!)
                        }
                        else {
                            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                        }

                    })
                }
            }
        })
        if self.viewController?.navigationController != nil {
            self.viewController?.navigationController?.view.addSubview(textViewAlertController.view!)
            self.viewController?.navigationController?.addChild(textViewAlertController)
        }
        else
        {
            self.viewController?.view.addSubview(textViewAlertController.view)
            self.viewController?.addChild(textViewAlertController)
        }
    }

    func handleEditRide()
    {
        if ride != nil && ride!.checkIfRideIsValid(){
            let editRideViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideUpdateViewController") as! RideUpdateViewController
            editRideViewController.initializeDataBeforePresentingView(ride: ride!,riderRide: nil,listener : rideUpdateListener!)
            viewController!.navigationController?.pushViewController(editRideViewController, animated: false)
        }
    }

    func shareRideInSocialGroups(){
        guard let ride = ride,let userId = QRSessionManager.getInstance()?.getUserId(), let vehicleType = (ride as? RiderRide)?.vehicleType else { return }
        let joinMyRide =  JoinMyRide()
        joinMyRide.prepareDeepLinkURLForRide(rideId: StringUtils.getStringFromDouble(decimalNumber: ride.rideId), riderId: userId,from: ride.startAddress, to: ride.endAddress,startTime: ride.startTime,vehicleType: vehicleType, viewController: viewController,isFromTaxiPool: false)
    }


}
extension RevealMenuController {
    func updateBackgroundColor(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        self.view.frame = .zero
//        self.view.layoutIfNeeded()
    }

}
