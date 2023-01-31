//
//  RideDetailViewCellViewModel.swift
//  Quickride
//
//  Created by Vinutha on 11/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol RideActionCompletionDelegate : class {
    func stopAnimatingProgressView(matchedUser: MatchedUser?)
    func displayAckForRideRequest(matchedUser: MatchedUser)
}

class RideDetailViewCellViewModel {
    
    var rideInvitation: RideInvitation?
    var ride : Ride?
    var matchedUser:MatchedUser?
    var viewType: DetailViewType?
    var selectedIndex = 0
    var routeMetrics: RouteMetrics?
    var selectedUserDelegate: SelectedUserDelegate?
    var displaySpinner = false
    private var rideActionCompletionDelegate: RideActionCompletionDelegate?
    private var rideInviteActionCompletionListener : RideInvitationActionCompletionListener?
        
    func initialiseUIWithData(ride: Ride?, matchedUser: MatchedUser, viewType: DetailViewType, selectedIndex: Int, routeMetrics: RouteMetrics?, rideActionCompletionDelegate: RideActionCompletionDelegate?, rideInviteActionCompletionListener : RideInvitationActionCompletionListener?, selectedUserDelegate: SelectedUserDelegate?) {
        self.matchedUser = matchedUser
        self.ride = ride
        self.viewType = viewType
        self.selectedIndex = selectedIndex
        self.routeMetrics = routeMetrics
        self.selectedUserDelegate = selectedUserDelegate
        self.rideActionCompletionDelegate = rideActionCompletionDelegate
        self.rideInviteActionCompletionListener = rideInviteActionCompletionListener
    }
    
    func isFavouritePartner() -> Bool{
        let isFavoritePartner = UserDataCache.getInstance()?.isFavouritePartner(userId: matchedUser?.userid ?? 0)
        if isFavoritePartner == nil || !isFavoritePartner!{
            return true
        }else{
            return false
        }
    }
    
    func getCompanyName() -> String {
        return UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: matchedUser?.profileVerificationData, companyName: matchedUser?.companyName?.capitalized)
    }
    
    func getFirstTimeOfferDetails() -> String?{
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if matchedUser?.userRole == MatchedUser.RIDER {
            return  String(format: Strings.dollar_sym_msg_for_rider, arguments: [matchedUser?.name ?? "",matchedUser?.name ?? "",StringUtils.getStringFromDouble(decimalNumber: clientConfiguration.firstRideBonusPoints)])
        }else{
            return String(format: Strings.dollar_sym_msg, arguments: [matchedUser?.name ?? "",matchedUser?.name ?? "",StringUtils.getStringFromDouble(decimalNumber: clientConfiguration.firstRideBonusPoints)])
        }
    }
    
    func getDistanceString( distance: Double) -> String {
        if distance > 1000{
            var convertDistance = (distance/1000)
            let roundTodecimalTwoPoints = convertDistance.roundToPlaces(places: 1)
            return "\(roundTodecimalTwoPoints) \(Strings.KM)"
        } else {
            let roundTodecimalTwoPoints = Int(distance)
            return "\(roundTodecimalTwoPoints) \(Strings.meter)"
        }
    }
    
    func checkForRideStatusStartedAndSetStatus() -> Bool{
        if MatchedUser.RIDER ==  matchedUser?.userRole && Ride.RIDE_STATUS_STARTED == (matchedUser as? MatchedRider)?.rideStatus {
            return true
        }else{
            return false
        }
    }
    
    func getOutGoingInviteForRide() -> RideInvitation? {
        var getTheInvitation: RideInvitation?
        let allInvitedRides = RideInviteCache.getInstance().getInvitationsForRide(rideId: ride!.rideId, rideType: ride!.rideType!)
        for invite in allInvitedRides{
            if Ride.PASSENGER_RIDE == invite.rideType && invite.rideId == matchedUser?.rideid {
                getTheInvitation = invite
                break
            }
            if Ride.RIDER_RIDE == invite.rideType && invite.passenegerRideId == matchedUser?.rideid {
                getTheInvitation = invite
                break
            }
        }
        return getTheInvitation
    }
    
    func prepareDataForProfileView() -> ProfileData {
        var vehicle : Vehicle?
        var userRole : UserRole?
        if matchedUser?.userRole == MatchedUser.RIDER || matchedUser?.userRole == MatchedUser.REGULAR_RIDER{
            userRole = UserRole.Rider
        } else {
            userRole = UserRole.Passenger
        }
        if let ridetype = matchedUser?.userRole, ridetype == MatchedUser.RIDER, let matchedRider = matchedUser as? MatchedRider,let vehicleNumber = matchedRider.vehicleNumber{
            vehicle = Vehicle(ownerId : matchedRider.userid ?? 0, vehicleModel : matchedRider.model ?? "",vehicleType: matchedRider.vehicleType, registrationNumber : vehicleNumber, capacity : matchedRider.capacity ?? 0, fare : matchedRider.fare!, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
            vehicle?.imageURI = matchedRider.vehicleImageURI
        }else if let ridetype = matchedUser?.userRole, ridetype == MatchedUser.REGULAR_RIDER{
            let matchedRider = matchedUser as? MatchedRegularRider
            vehicle = Vehicle(ownerId : matchedRider?.userid ?? 0, vehicleModel : matchedRider?.model ?? "", vehicleType: matchedRider?.vehicleType,registrationNumber : matchedRider?.vehicleNumber, capacity : matchedRider?.capacity ?? 0, fare : matchedRider?.fare ?? 0, makeAndCategory : matchedRider?.vehicleMakeAndCategory,additionalFacilities : matchedRider?.additionalFacilities,riderHasHelmet : matchedRider?.riderHasHelmet ?? false)
            vehicle?.imageURI = matchedRider?.vehicleImageURI
        }
        return ProfileData(vehicle: vehicle, userRole: userRole!)
    }
}
//MARK: Invite
extension RideDetailViewCellViewModel {
    
    func inviteClicked(matchedUser: MatchedUser?, viewController: UIViewController?,displaySpinner: Bool) {
        guard let matchedUser = matchedUser, let viewController = viewController else {
            self.rideActionCompletionDelegate?.stopAnimatingProgressView(matchedUser: nil)
            return
        }
        let invitation = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: ride!.rideId, rideType: ride!.rideType!, matchedUserRideId: matchedUser.rideid!, matchedUserTaxiRideId: (matchedUser as? MatchedPassenger)?.passengerTaxiRideId)
        var newFare: Double = 0
        if invitation?.rideType == Ride.PASSENGER_RIDE || invitation?.rideType == Ride.REGULAR_PASSENGER_RIDE {
            newFare = invitation?.newRiderFare ?? 0
        }else{
            newFare = invitation?.newFare ?? 0
        }
        if invitation != nil && matchedUser.newFare == newFare {
            matchedUser.pickupTime = invitation!.pickupTime
            matchedUser.dropTime = invitation!.dropTime
            matchedUser.pickupTimeRecalculationRequired = false
            joinMatchedUser(matchedUser: matchedUser, displayPointsConfirmation: true,invitation: invitation!, viewController: viewController)
        }else{
            inviteMatchedUser(matchedUser: matchedUser, invite: invitation, viewController: viewController, displaySpinner: displaySpinner)
        }
    }
    
    func inviteMatchedUser(matchedUser : MatchedUser, invite : RideInvitation?, viewController: UIViewController, displaySpinner: Bool?) {
        if matchedUser.userRole == MatchedUser.RIDER {
            if (invite != nil && invite!.fareChange) {
                if (matchedUser.newFare < invite!.newFare){
                    invitingRider(matchedUser: matchedUser, viewController: viewController, displaySpinner: displaySpinner)
                } else {
                    joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!, viewController: viewController)
                }
            } else if (matchedUser.newFare != -1) && (matchedUser.newFare < matchedUser.points ?? 0) {
                invitingRider(matchedUser: matchedUser, viewController: viewController, displaySpinner: displaySpinner)
            } else if invite == nil {
                invitingRider(matchedUser: matchedUser, viewController: viewController, displaySpinner: displaySpinner)
            } else {
                joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!, viewController: viewController)
            }
        } else if matchedUser.userRole == MatchedUser.PASSENGER {
            if (invite != nil && invite!.fareChange) {
                if (matchedUser.newFare > invite!.newFare){
                    invitingPassenger(matchedUser: matchedUser, viewController: viewController, displaySpinner: displaySpinner)
                } else {
                    joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!, viewController: viewController)
                }
            } else if (matchedUser.newFare != -1) && (matchedUser.newFare > matchedUser.points ?? 0) {
                invitingPassenger(matchedUser: matchedUser, viewController: viewController, displaySpinner: displaySpinner)
            } else if invite == nil {
                invitingPassenger(matchedUser: matchedUser, viewController: viewController, displaySpinner: displaySpinner)
            } else {
                joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!, viewController: viewController)
            }
        }
    }
    
    func joinMatchedUser(matchedUser : MatchedUser,displayPointsConfirmation : Bool,invitation : RideInvitation, viewController: UIViewController){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if matchedUser.verificationStatus == false && SharedPreferenceHelper.getJoinWithUnverifiedUsersStatus() == false && SharedPreferenceHelper.getCurrentUserGender() == User.USER_GENDER_FEMALE && Int(matchedUser.noOfRidesShared) <= clientConfiguration.minNoOfRidesReqNotToShowJoiningUnverifiedDialog{
            let alertControllerWithCheckBox = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AlertControllerWithCheckBox") as! AlertControllerWithCheckBox
            alertControllerWithCheckBox.initializeDataBeforePresenting(alertTitle: Strings.dont_show_again_title, checkBoxText: Strings.dont_show_again_checkBox_text, handler: { (result,dontShow) in
                SharedPreferenceHelper.setJoinWithUnverifiedUsersStatus(status: dontShow)
                if Strings.yes_caps == result{
                    self.continueJoin(invitation: invitation, displayPointsConfirmation: displayPointsConfirmation,matchedUser : matchedUser, viewController: viewController)
                } else {
                    self.rideActionCompletionDelegate?.stopAnimatingProgressView(matchedUser: matchedUser)
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: alertControllerWithCheckBox)
        }else{
            self.continueJoin(invitation: invitation, displayPointsConfirmation: displayPointsConfirmation,matchedUser : matchedUser, viewController: viewController)
        }
    }
    
    func invitingRider(matchedUser : MatchedUser, viewController: UIViewController, displaySpinner: Bool?) {
        var selectedRiders = [MatchedRider]()
        guard let matchedUser = (matchedUser as? MatchedRider) else { return }
        selectedRiders.append(matchedUser)
        InviteRiderHandler(passengerRide: ride as! PassengerRide, selectedRiders: selectedRiders, displaySpinner: displaySpinner ?? false, selectedIndex: nil, viewController: viewController).inviteSelectedRiders(inviteHandler: { (error,nserror) in
            if error == nil && nserror == nil{
                self.rideActionCompletionDelegate?.displayAckForRideRequest(matchedUser: matchedUser)
            }
            self.rideActionCompletionDelegate?.stopAnimatingProgressView(matchedUser: matchedUser)
        })
    }
    
    func invitingPassenger(matchedUser : MatchedUser, viewController: UIViewController, displaySpinner: Bool?) {
        var selectedPassengers = [MatchedPassenger]()
        guard let matchedUser = (matchedUser as? MatchedPassenger) else { return }
        selectedPassengers.append(matchedUser)
        InviteSelectedPassengersAsyncTask(riderRide: ride as! RiderRide, selectedUsers: selectedPassengers, viewController: viewController, displaySpinner: displaySpinner ?? false, selectedIndex: nil, invitePassengersCompletionHandler: { (error,nserror) in
            if error == nil && nserror == nil{
                self.rideActionCompletionDelegate?.displayAckForRideRequest(matchedUser: matchedUser)
            }
            self.rideActionCompletionDelegate?.stopAnimatingProgressView(matchedUser: matchedUser)
        }).invitePassengersFromMatches()
    }
    
    func continueJoin(invitation : RideInvitation,displayPointsConfirmation: Bool,matchedUser : MatchedUser, viewController: UIViewController){
        if matchedUser.userRole == MatchedUser.RIDER{
            if let passengerRide = ride as? PassengerRide {
                JoinPassengerToRideHandler(viewController: viewController, riderRideId: matchedUser.rideid ?? 0, riderId: matchedUser.userid ?? 0, passengerRideId: passengerRide.rideId, passengerId: passengerRide.userId,rideType: matchedUser.userRole, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude ?? 0, pickupLongitude: matchedUser.pickupLocationLongitude ?? 0, pickupTime: matchedUser.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude ?? 0, dropLongitude: matchedUser.dropLocationLongitude ?? 0, dropTime: matchedUser.dropTime, matchingDistance: matchedUser.distance ?? 0, points: matchedUser.points ?? 0,newFare: matchedUser.newFare, noOfSeats: passengerRide.noOfSeats, rideInvitationId: invitation.rideInvitationId,invitingUserName : invitation.invitingUserName!,invitingUserId : invitation.invitingUserId,displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: (matchedUser as! MatchedRider).riderHasHelmet, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: matchedUser.matchPercentage ?? 0, riderRouteMatchPercentage: matchedUser.matchPercentageOnMatchingUserRoute, moderatorId: nil,listener: rideInviteActionCompletionListener).joinPassengerToRide(invitation: invitation)
            }
        } else if matchedUser.userRole == MatchedUser.PASSENGER {
            if let riderRide = ride as? RiderRide {
                var rideType: String
                var rideId: Double
                if let matchedPassenger = matchedUser as? MatchedPassenger, matchedPassenger.passengerTaxiRideId != 0 {
                    rideType = TaxiPoolConstants.Taxi
                    rideId = Double(matchedPassenger.passengerTaxiRideId)
                }else {
                    rideType = matchedUser.userRole ?? ""
                    rideId = matchedUser.rideid ?? 0
                }
                
                JoinPassengerToRideHandler(viewController: viewController, riderRideId: riderRide.rideId, riderId: riderRide.userId, passengerRideId: rideId, passengerId: matchedUser.userid ?? 0,rideType: rideType, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude ?? 0, pickupLongitude: matchedUser.pickupLocationLongitude ?? 0, pickupTime: matchedUser.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude ?? 0, dropLongitude: matchedUser.dropLocationLongitude ?? 0, dropTime: matchedUser.dropTime, matchingDistance: matchedUser.distance ?? 0, points: matchedUser.points ?? 0,newFare: matchedUser.newFare, noOfSeats: (matchedUser as? MatchedPassenger)?.requiredSeats ?? 0, rideInvitationId: invitation.rideInvitationId,invitingUserName : invitation.invitingUserName!,invitingUserId : invitation.invitingUserId, displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: false, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: matchedUser.matchPercentageOnMatchingUserRoute, riderRouteMatchPercentage: matchedUser.matchPercentage ?? 0, moderatorId: nil, listener: rideInviteActionCompletionListener).joinPassengerToRide(invitation: invitation)
            }
        }else{
            selectedUserDelegate?.selectedUser?(selectedUser: matchedUser)
            selectedUserDelegate?.saveRide?(ride: ride ?? Ride())
        }
    }
}
