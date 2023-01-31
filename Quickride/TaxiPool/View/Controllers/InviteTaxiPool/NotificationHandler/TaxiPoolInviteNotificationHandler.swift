//
//  TaxiPoolInviteNotificationHandler.swift
//  Quickride
//
//  Created by Ashutos on 9/15/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiPoolInviteNotificationHandler: NotificationHandler {
    var userNotification : UserNotification?
    var viewController :UIViewController?
    private var dataObj: TaxiInviteEntity?
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.ACCEPT
    }
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.VIEW
    }
    override func handleNeutralAction(userNotification: UserNotification, viewController :UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handleTap()")
        super.handleNeutralAction(userNotification: userNotification, viewController: viewController)
        if userNotification.status != RideInvitation.RIDE_INVITATION_STATUS_READ{
            updateTaxiInviteStatus(notification: userNotification)
        }
        if let taxiInvite = Mapper<TaxiPoolInvite>().map(JSONString: userNotification.msgObjectJson ?? ""){
            getTaxipoolDetails(taxiInvite: taxiInvite, viewController: viewController) { (matchedTaxiRideGroup) in
                let taxipoolInviteDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolInviteDetailsViewController") as! TaxipoolInviteDetailsViewController
                taxipoolInviteDetailsViewController.showReceivedTaxipoolInvite(taxipoolInvite: taxiInvite,matchedTaxiRideGroup: matchedTaxiRideGroup,isFromJoinMyRide: false)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: taxipoolInviteDetailsViewController, animated: false)
            }
        }else{
            UIApplication.shared.keyWindow?.makeToast("Service internal error")
        }
    }
    
    func getTaxipoolDetails(taxiInvite: TaxiPoolInvite,viewController :UIViewController?,complitionHandler: @escaping( _ matchedTaxiRideGroup: MatchedTaxiRideGroup) -> ()){
        if taxiInvite.invitedRideId != 0{
            QuickRideProgressSpinner.startSpinner()
            TaxiSharingRestClient.getInvitedTaxiPoolerDetails(taxiGroupId: taxiInvite.taxiRideGroupId, passengerRideId: taxiInvite.invitedRideId) {(responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if var matchedTaxiRideGroup = Mapper<MatchedTaxiRideGroup>().map(JSONObject: responseObject!["resultData"]){
                        let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(rideId: Double(taxiInvite.invitedRideId))
                        matchedTaxiRideGroup.pickupAddress = passengerRide?.startAddress
                        matchedTaxiRideGroup.dropAddress = passengerRide?.endAddress
                        matchedTaxiRideGroup.minPoints = taxiInvite.minFare
                        matchedTaxiRideGroup.maxPoints = taxiInvite.maxFare
                        complitionHandler(matchedTaxiRideGroup)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            }
        }else{
            QuickRideProgressSpinner.startSpinner()
            TaxiSharingRestClient.getInviteByContactTaxiPoolerDetails(taxiGroupId: taxiInvite.taxiRideGroupId, startTime: taxiInvite.pickupTimeMs, startLat: taxiInvite.fromLat, startLng: taxiInvite.fromLng, endLat: taxiInvite.toLat, endLng: taxiInvite.toLng, noOfSeats: 1, reqToSetAddress: true){(responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let matchedTaxiRideGroup = Mapper<MatchedTaxiRideGroup>().map(JSONObject: responseObject!["resultData"]){
                        complitionHandler(matchedTaxiRideGroup)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            }
        }
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("Positive action\(userNotification)")
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        if userNotification.status != RideInvitation.RIDE_INVITATION_STATUS_READ{
            updateTaxiInviteStatus(notification: userNotification)
        }
        QuickRideProgressSpinner.startSpinner()
        if let taxiInvite = Mapper<TaxiPoolInvite>().map(JSONString: userNotification.msgObjectJson ?? ""){
            getTaxipoolDetails(taxiInvite: taxiInvite, viewController: viewController) { (matchedTaxiRideGroup) in
                self.createTaxiForCarpoolUser(matchedTaxiRideGroup: matchedTaxiRideGroup, taxiInvite: taxiInvite, viewController: viewController)
            }
        }else{
            UIApplication.shared.keyWindow?.makeToast("Service internal error")
        }
    }
    
    private func createTaxiForCarpoolUser(matchedTaxiRideGroup: MatchedTaxiRideGroup,taxiInvite: TaxiPoolInvite,viewController :UIViewController?){
        let startLocation = Location(latitude: matchedTaxiRideGroup.pickupLat, longitude: matchedTaxiRideGroup.pickupLng, shortAddress: matchedTaxiRideGroup.pickupAddress)
        let endLocation = Location(latitude: matchedTaxiRideGroup.dropLat, longitude: matchedTaxiRideGroup.dropLng, shortAddress: matchedTaxiRideGroup.dropAddress)
        let vehicleDetail = FareForVehicleClass(taxiType: TaxiPoolConstants.TRIP_TYPE_LOCAL, fixedFareId: taxiInvite.fixedFareRefId ?? "", vehicleClass: TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_ANY, selectedMaxFare: taxiInvite.maxFare, shareType: TaxiPoolConstants.SHARE_TYPE_ANY_SHARING)
        let createTaxiDetails = CreateTaxiPoolHandler(startLocation: startLocation, endLocation: endLocation, tripType: TaxiPoolConstants.TRIP_TYPE_LOCAL, routeId: nil, startTime: Double(matchedTaxiRideGroup.pickupTimeMs), selectedVehicleDetails: vehicleDetail, endTime: nil, journeyType: TaxiPoolConstants.JOURNEY_TYPE_ONE_WAY, advancePercentageForOutstation: nil, refRequestId: nil, viewController: viewController ?? ViewControllerUtils.getCenterViewController(),couponCode: nil, paymentMode: nil,taxiGroupId: Double(taxiInvite.taxiRideGroupId),refInviteId: taxiInvite.id,commuteContactNo: nil, commutePassengerName: nil)
        createTaxiDetails.createTaxiPool { (data, error) in
            if let data = data,let taxiRidePassenger = data.taxiRidePassenger {
                TaxiRideDetailsCache.getInstance().setTaxiRideDetailsToCache(rideId: taxiRidePassenger.id ?? 0, taxiRidePassengerDetails: data)
                MyActiveTaxiRideCache.getInstance().addNewRideToCache(taxiRidePassenger: taxiRidePassenger)
                let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
                taxiLiveRide.initializeDataBeforePresenting(rideId: taxiRidePassenger.id ?? 0)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
            }
        }
    }
    
    func updateTaxiInviteStatus(notification: UserNotification){ //taxi invite status update
        guard var taxiInvite = Mapper<TaxiPoolInvite>().map(JSONString: notification.msgObjectJson ?? "")else { return }
        TaxiSharingRestClient.updateTaxiInviteStatus(inviteId: taxiInvite.id ?? "", invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_READ){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                taxiInvite.status = TaxiPoolInvite.TAXI_INVITE_STATUS_READ
                let jsonMessage = Mapper().toJSONString(taxiInvite , prettyPrint: true)
                notification.msgObjectJson = jsonMessage
                NotificationStore.getInstance().updateNotification(notification: notification)
            }
        }
    }
}
