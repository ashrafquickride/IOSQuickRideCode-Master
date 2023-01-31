//
//  RideActionHandler.swift
//  Quickride
//
//  Created by Quick Ride on 3/28/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

struct RideActionHandler {
    
    weak var viewController: UIViewController?
    var ride: Ride
    var rideActionDelegate: RideActionDelegate
    
    init(ride: Ride, viewController: UIViewController, rideActionDelegate : RideActionDelegate) {
        self.viewController = viewController
        self.ride = ride
        self.rideActionDelegate = rideActionDelegate
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
        RiderRideRestClient.freezeRide(rideId: self.ride.rideId, freezeRide: freezeRide, targetViewController: self.viewController, complitionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let riderRide = self.ride as? RiderRide {
                    riderRide.freezeRide = freezeRide
                }
                if !freezeRide {
                    UIApplication.shared.keyWindow?.makeToast(Strings.ride_unfreezed, point: CGPoint(x: (self.viewController?.view.frame.size.width)!/2, y: (self.viewController?.view.frame.size.height)!-200), title: nil, image: nil, completion: nil)
                    
                    self.rideActionDelegate.handleFreezeRide(freezeRide: freezeRide)
                } else {
                    UIApplication.shared.keyWindow?.makeToast(Strings.ride_freezed, point: CGPoint(x: (self.viewController?.view.frame.size.width)!/2, y: (self.viewController?.view.frame.size.height)!-200), title: nil, image: nil, completion: nil)
                    self.rideActionDelegate.handleFreezeRide(freezeRide: freezeRide)
                }
            }
            else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        })
    }
    
    func cancelCurrentRideAndCreateNewRideWithDifferentRole()
    {
        guard let viewController = viewController else {
            return
        }

        if self.ride.rideType == Ride.PASSENGER_RIDE{
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
            let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride.expectedEndTime, time2: ride.startTime)
            let rideRoute = RideRoute(routeId: ride.routeId!,overviewPolyline : ride.routePathPolyline,distance :ride.distance!,duration : Double(duration), waypoints : ride.waypoints)
            QuickRideProgressSpinner.startSpinner()
            RideCancelActionProxy.cancelRide(ride: ride, cancelReason: RideCancelActionProxy.USER_ROLE_CHANGED, isWaveOff: false, viewController: viewController, handler: {
                if self.ride.rideType == Ride.RIDER_RIDE{
                    let newRide = PassengerRide(ride : self.ride)
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
    
    
    
    func moveToNewRide(ride : Ride){
        AppDelegate.getAppDelegate().log.debug("")
        viewController?.navigationController?.popViewController(animated: false)
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    
    
    
    func handleCancelRide(riderRide: RiderRide?, rideParticipants: [RideParticipant]?, rideCancelDelegate: RideCancelDelegate, rideUpdateDelegate: RideObjectUdpateListener){
        if self.ride.rideType == Ride.REGULAR_RIDER_RIDE || self.ride.rideType == Ride.REGULAR_PASSENGER_RIDE{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.ride_delete_message, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: viewController, handler: { (result) in
                if result == Strings.yes_caps{
                    let cancelRegularRideTask : CancelRegularRideTask = CancelRegularRideTask(ride: self.ride, rideType: self.ride.rideType, viewController: viewController)
                    cancelRegularRideTask.cancelRegularRide()
                }
            })
        }else{
                
                let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationAndUnJoinViewController") as! RideCancellationAndUnJoinViewController
                rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(rideParticipants: rideParticipants, rideType: self.ride.rideType, isFromCancelRide: true, ride: self.ride,vehicelType: riderRide?.vehicleType,rideUpdateListener: rideUpdateDelegate, completionHandler: {
                    rideCancelDelegate.rideCancelled()
                })
                ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
            
            
        }
    }
}
extension RideActionHandler : VehicleDetailsUpdateListener {
    func VehicleDetailsUpdated()
    {
        let newRide = RiderRide(ride : self.ride)
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
        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride.expectedEndTime, time2: ride.startTime)
        let rideRoute = RideRoute(routeId: ride.routeId!,overviewPolyline : ride.routePathPolyline,distance :ride.distance!,duration : Double(duration), waypoints : ride.waypoints)
        QuickRideProgressSpinner.startSpinner()
        RideCancelActionProxy.cancelRide(ride: ride, cancelReason: RideCancelActionProxy.USER_ROLE_CHANGED, isWaveOff: false, viewController: self.viewController!, handler: {
            if self.ride.rideType == Ride.PASSENGER_RIDE{
                CreateRiderRideHandler(ride: newRide, rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: self.viewController).createRiderRide(handler: { (riderRide, error) in
                    if let riderRide  = riderRide{
                        MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoFromServerByHandler(currentUserRide: riderRide, handler: { rideDetailInfo, responseError, error in
                            self.moveToNewRide(ride : riderRide)
                            QuickRideProgressSpinner.stopSpinner()
                        })
                       
                    }
                })
            }
        })
    }
}
