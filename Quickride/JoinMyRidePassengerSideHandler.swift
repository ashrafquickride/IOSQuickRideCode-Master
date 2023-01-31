//
//  JoinMyRidePassengerSideHandler.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class JoinMyRidePassengerSideHandler{
    
    private var rideId : Double?
    private weak var viewController : UIViewController?
    private var ride: Ride?
    private var isFromSignUpFlow = false
    
    func getComplateRiderRideThroughRideId(rideId: String, riderId: String,isFromSignUpFlow: Bool,viewController: UIViewController?){
        if let linkRideId = Double(rideId){
            self.rideId = linkRideId
            self.viewController = viewController
            
            getInvitedUserInfo(riderId: riderId)
        }else{
            showRideClosedDialog()
        }
    }
    
    func getInvitedUserInfo(riderId: String){
        if riderId == UserDataCache.getInstance()?.userId{
            UIApplication.shared.keyWindow?.makeToast(Strings.join_myRide_rider_error)
            if self.isFromSignUpFlow{
                RideManagementUtils.NavigateToRespectivePage(oldViewController: self.viewController, handler: nil)
            }
            return
        }else if SharedPreferenceHelper.getJoinMyRideSourceType(){
            getTaxipoolDetails(taxiRideId: rideId!, userId: riderId)
            return
        }
        QuickRideProgressSpinner.startSpinner()
        RouteMatcherServiceClient.validateInviteByContactFromRiderAndGetMatchedRider(invitationId: "0", riderRideId: StringUtils.getStringFromDouble(decimalNumber: rideId), riderId: riderId, passengerUserId: QRSessionManager.getInstance()?.getUserId() ?? "", noOfSeats: "1", viewController: viewController, completionhandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            SharedPreferenceHelper.storeJoinMyRideIdAndRiderId(rideId: nil, riderId: nil, isFromTaxipool: false)
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS"{
                    if let matchedRider = Mapper<MatchedRider>().map(JSONObject: responseObject!["resultData"]){
                        self.prepareRideObjectUsingMatchedUser(matchedUser: matchedRider)
                    }else{
                        self.showRideClosedDialog()
                    }
                }else if responseObject!["result"] as! String == "FAILURE" && responseObject!["resultData"] != nil{
                    let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    if responseError?.errorCode == 2703 {
                        MessageDisplay.displayAlert(messageString: Strings.join_myRide_rider_error, viewController: self.viewController, handler: { (result) in
                        })
                        if self.isFromSignUpFlow{
                            RideManagementUtils.NavigateToRespectivePage(oldViewController: self.viewController, handler: nil)
                        }
                        return
                    }else{
                        self.showRideClosedDialog()
                    }
                }
            } else {
                self.showRideClosedDialog()
            }
        })
    }
    
    private func prepareRideObjectUsingMatchedUser(matchedUser : MatchedUser){
        if let userIdStr = QRSessionManager.getInstance()?.getUserId(), let userId = Double(userIdStr){
            ride = Ride(userId : userId,  rideType : Ride.PASSENGER_RIDE,  startAddress : matchedUser.fromLocationAddress!,
                        startLatitude : matchedUser.fromLocationLatitude!,  startLongitude :matchedUser.fromLocationLongitude!,  endAddress : matchedUser.toLocationAddress!,
                        endLatitude: matchedUser.toLocationLatitude! ,  endLongitude: matchedUser.toLocationLongitude!, startTime : matchedUser.startDate! )
            ride?.distance = matchedUser.rideDistance
            checkUserCreatedAnyPassengerRides(matchedUser: matchedUser)
        }else{
            showRideClosedDialog()
        }
    }
    
    private func checkUserCreatedAnyPassengerRides(matchedUser: MatchedUser){
        if let rideObj = ride,let existingRide = MyActiveRidesCache.getRidesCacheInstance()?.getRedundantRide(ride: rideObj){
            let rideToPass = PassengerRide(ride: existingRide)
            moveToRideDetailView(ride: rideToPass, matchedUser: matchedUser)
        }else{
            moveToJoinMyRideDetailView(matchedUser: matchedUser)
        }
    }
    
    private func moveToRideDetailView(ride: Ride,matchedUser: MatchedUser){
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: ride, matchedUserList: [matchedUser], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, selectedUserDelegate: self)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    
    private func moveToJoinMyRideDetailView(matchedUser: MatchedUser){
        let joinMyRideDetailViewController = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "JoinMyRideDetailViewController") as! JoinMyRideDetailViewController
        joinMyRideDetailViewController.initialiseJoinMyRideView(ride: ride ?? Ride(), matchedUser: matchedUser)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: joinMyRideDetailViewController, animated: true)
    }
    
    func showRideClosedDialog(){
        let rideCompletedViewController = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCompletedViewController") as! RideCompletedViewController
        rideCompletedViewController.initializeView(actionComplitionHandler: {(completed) in
            if self.isFromSignUpFlow{
                RideManagementUtils.NavigateToRespectivePage(oldViewController: self.viewController, handler: nil)
            }
            return
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideCompletedViewController)
    }
}
extension JoinMyRidePassengerSideHandler:SelectedUserDelegate{
    //MARK: SelectUserDelegate Protocal Methods
    func saveRide(ride: Ride) {
        self.ride = ride
    }
    
    func selectedUser(selectedUser : MatchedUser){
        viewController?.dismiss(animated: false, completion: nil)
        let rideInvitation = RideInvitation()
        rideInvitation.startTime = NSDate().timeIntervalSince1970*1000
        rideInvitation.pickupLatitude = selectedUser.pickupLocationLatitude ?? 0
        rideInvitation.pickupLongitude = selectedUser.pickupLocationLongitude ?? 0
        rideInvitation.dropLatitude = selectedUser.dropLocationLatitude ?? 0
        rideInvitation.dropLongitude = selectedUser.dropLocationLongitude ?? 0
        rideInvitation.pickupAddress = selectedUser.pickupLocationAddress
        rideInvitation.dropAddress = selectedUser.dropLocationAddress
        rideInvitation.pickupTime = selectedUser.pickupTime ?? 0
        rideInvitation.points = selectedUser.points ?? 0
        rideInvitation.dropTime = selectedUser.dropTime ?? 0
        rideInvitation.rideType = Ride.PASSENGER_RIDE
        rideInvitation.noOfSeats = (ride as? PassengerRide)?.noOfSeats ?? 0
        rideInvitation.invitingUserName = selectedUser.name
        rideInvitation.invitingUserId = selectedUser.userid ?? 0
        if selectedUser.matchPercentage != nil{
            rideInvitation.matchPercentageOnPassengerRoute = selectedUser.matchPercentage!
            rideInvitation.matchPercentageOnRiderRoute = selectedUser.matchPercentageOnMatchingUserRoute
        }
        rideInvitation.passenegerRideId = ride?.rideId ?? 0
        rideInvitation.passengerId = ride?.userId ?? 0
        if selectedUser.userRole == MatchedUser.RIDER && selectedUser.newFare != rideInvitation.newFare{
            rideInvitation.newFare = selectedUser.newFare
            var selectedRiders = [MatchedRider]()
            selectedRiders.append(selectedUser as! MatchedRider)
            InviteRiderHandler(passengerRide: PassengerRide(ride: ride ?? Ride()) , selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: ViewControllerUtils.getCenterViewController()).inviteSelectedRiders(inviteHandler: { (error,nserror) in
            })
        }else{
            rideInvitation.newRiderFare = selectedUser.newFare
            rideInvitation.riderPoints = selectedUser.points ?? 0
            self.continueJoin(rideInvitation: rideInvitation,matchedUser: selectedUser)
        }
    }
    
    func continueJoin(rideInvitation : RideInvitation,matchedUser : MatchedUser){
        var riderHasHelmet = false
        if Ride.RIDER_RIDE == rideInvitation.rideType{
            riderHasHelmet = (matchedUser as! MatchedRider).riderHasHelmet
        }
        let joinPassengerToRideHandler = JoinPassengerToRideHandler(viewController: viewController, riderRideId: matchedUser.rideid!, riderId: matchedUser.userid!, passengerRideId: rideInvitation.passenegerRideId, passengerId: rideInvitation.passengerId, rideType: rideInvitation.rideType, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude!, pickupLongitude: matchedUser.pickupLocationLongitude!, pickupTime: rideInvitation.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude!, dropLongitude: matchedUser.dropLocationLongitude!, dropTime: rideInvitation.dropTime, matchingDistance: matchedUser.distance!, points: matchedUser.points!,newFare:  matchedUser.newFare, noOfSeats: rideInvitation.noOfSeats, rideInvitationId: 0.0,invitingUserName :rideInvitation.invitingUserName!,invitingUserId : rideInvitation.invitingUserId,displayPointsConfirmationAlert: true, riderHasHelmet: riderHasHelmet, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: rideInvitation.matchPercentageOnPassengerRoute, riderRouteMatchPercentage: rideInvitation.matchPercentageOnRiderRoute, moderatorId: nil ,listener: nil)
        joinPassengerToRideHandler.joinPassengerToRide(invitation: rideInvitation)
    }
}
//MARK: join my Taxipool
extension JoinMyRidePassengerSideHandler{
    func getTaxipoolDetails(taxiRideId: Double,userId: String){
        QuickRideProgressSpinner.startSpinner()
        TaxiRideDetailsCache.getInstance().getTaxiRideDetailsFromCache(rideId: taxiRideId) { (restResponse) in
            QuickRideProgressSpinner.stopSpinner()
            if let taxiRidePassengerDetails = restResponse.result,let taxiRide = taxiRidePassengerDetails.taxiRidePassenger{
                self.getTaxipoolMatchedGroup(taxiRidePassengerDetails: taxiRidePassengerDetails) { (matchedTaxiRideGroup) in
                    let userProfile = UserDataCache.getInstance()?.userProfile
                    let taxipoolInvite = TaxiPoolInvite(taxiRideGroupId: matchedTaxiRideGroup.taxiRideGroupId, invitingUserId: 0, invitingRideId: 0, invitingRideType: TaxiPoolInvite.TAXI, invitedUserId: Int(UserDataCache.getInstance()?.userId ?? "") ?? 0, invitedRideId: 0, invitedRideType: TaxiPoolInvite.TAXI,invitingUserName: taxiRide.userName,invitedUserName: userProfile?.userName ,invitingUserImageURI: taxiRide.imageURI ,invitedUserImageURI: userProfile?.imageURI ,invitingUserGender: taxiRide.gender ,invitedUserGender: userProfile?.gender ,fromLat: matchedTaxiRideGroup.startLat, fromLng: matchedTaxiRideGroup.startLng, toLat: matchedTaxiRideGroup.endLat, toLng: matchedTaxiRideGroup.endLng, distance: matchedTaxiRideGroup.distance, pickupTimeMs: matchedTaxiRideGroup.pickupTimeMs, overviewPolyLine: matchedTaxiRideGroup.routePolyline ?? "",minFare: matchedTaxiRideGroup.minPoints,maxFare: matchedTaxiRideGroup.maxPoints)
                    let taxipoolInviteDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolInviteDetailsViewController") as! TaxipoolInviteDetailsViewController
                    taxipoolInviteDetailsViewController.showReceivedTaxipoolInvite(taxipoolInvite: taxipoolInvite, matchedTaxiRideGroup: matchedTaxiRideGroup,isFromJoinMyRide: true)
                    ViewControllerUtils.displayViewController(currentViewController: self.viewController, viewControllerToBeDisplayed: taxipoolInviteDetailsViewController, animated: false)
                }
            }else{
                ErrorProcessUtils.handleResponseError(responseError: restResponse.responseError, error: restResponse.error, viewController: ViewControllerUtils.getCenterViewController())
            }
        }
    }
    
    func getTaxipoolMatchedGroup(taxiRidePassengerDetails: TaxiRidePassengerDetails,complitionHandler: @escaping( _ matchedTaxiRideGroup: MatchedTaxiRideGroup) -> ()){
        QuickRideProgressSpinner.startSpinner()
        guard let taxiRidePassenger = taxiRidePassengerDetails.taxiRidePassenger else {
            return
        }
        TaxiSharingRestClient.getInviteByContactTaxiPoolerDetails(taxiGroupId: Int(taxiRidePassenger.taxiGroupId!), startTime: Int(taxiRidePassenger.pickupTimeMs!), startLat: taxiRidePassenger.startLat!, startLng: taxiRidePassenger.startLng!, endLat: taxiRidePassenger.endLat ?? -999, endLng: taxiRidePassenger.endLng ?? -999, noOfSeats: 1, reqToSetAddress: true){(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let matchedTaxiRideGroup = Mapper<MatchedTaxiRideGroup>().map(JSONObject: responseObject!["resultData"]){
                    complitionHandler(matchedTaxiRideGroup)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
            }
        }
    }
}
