//
//  MatchedUserCellViewModel.swift
//  Quickride
//
//  Created by Ashutos on 13/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

struct ProfileData {
    var vehicle: Vehicle?
    var userRole: UserRole?
    init(vehicle: Vehicle?,userRole: UserRole?) {
        self.vehicle = vehicle
        self.userRole = userRole
    }
}

class MatchedUserCellViewModel {
    var rideId : Double?
    var rideType : String?
    var ride : Ride?
    var row:Int?
    var selectedUser = false
    var matchedUser:MatchedUser?
    
    func setRideTimeBasedOnLongDistance(matchedUser: MatchedUser,longDistance : Int,time : Double?) -> String {
        return DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
    }
    
    func isFavouritePartner() -> Bool{
        let isFavoritePartner = UserDataCache.getInstance()?.isFavouritePartner(userId: matchedUser!.userid!)
        if isFavoritePartner == nil || !isFavoritePartner!{
            return true
        }else{
            return false
        }
    }
    
    func getCompanyName() -> String {
        return UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: matchedUser?.profileVerificationData, companyName: matchedUser?.companyName?.capitalized)
    }
    
    func checkForRideStatusStartedAndSetStatus() -> Bool{
        if MatchedUser.RIDER ==  matchedUser!.userRole && Ride.RIDE_STATUS_STARTED == (matchedUser as! MatchedRider).rideStatus {
            return true
        }else{
            return false
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
    
    func getOutGoingInviteForRide() -> RideInvitation? {
        var getTheInvitation: RideInvitation?
        let allInvitedRides = RideInviteCache.getInstance().getInvitationsForRide(rideId: rideId!, rideType: rideType!)
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
        if matchedUser!.userRole == MatchedUser.RIDER{
            let matchedRider = matchedUser as! MatchedRider
            vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel : matchedRider.model!,vehicleType: matchedRider.vehicleType, registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity!, fare : matchedRider.fare!, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
            vehicle?.imageURI = matchedRider.vehicleImageURI
        }else if matchedUser!.userRole == MatchedUser.REGULAR_RIDER{
            let matchedRider = matchedUser as! MatchedRegularRider
            vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel : matchedRider.model!, vehicleType: matchedRider.vehicleType,registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity, fare : matchedRider.fare, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
            vehicle?.imageURI = matchedRider.vehicleImageURI
        }
        var userRole : UserRole?
        if matchedUser!.userRole == MatchedUser.RIDER || matchedUser!.userRole == MatchedUser.REGULAR_RIDER{
            userRole = UserRole.Rider
        } else {
            userRole = UserRole.Passenger
        }
        return ProfileData(vehicle: vehicle, userRole: userRole!)
    }
    
    func getFirstTimeOfferDetails() -> String?{
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if matchedUser!.userRole == MatchedUser.RIDER {
            return  String(format: Strings.dollar_sym_msg_for_rider, arguments: [matchedUser!.name!,matchedUser!.name!,StringUtils.getStringFromDouble(decimalNumber: clientConfiguration.firstRideBonusPoints)])
        }else{
            return String(format: Strings.dollar_sym_msg, arguments: [matchedUser!.name!,matchedUser!.name!,StringUtils.getStringFromDouble(decimalNumber: clientConfiguration.firstRideBonusPoints)])
        }
    }
    
    func callTheRespectiveMatchUser() {
        guard let ride = ride, let rideType = ride.rideType else { return }
        let refID = rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: matchedUser!.userid), refId: refID, name: matchedUser?.name ?? "", targetViewController: ViewControllerUtils.getCenterViewController())
    }
    
    func getTextForLastRideCreated(lastRideCreatedTime : Double) -> String {
        let lastRideCreatedDate = NSDate(timeIntervalSince1970: lastRideCreatedTime/1000)
        var dateDifference = DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: lastRideCreatedDate)
        if dateDifference < 1{
            dateDifference = 1
        }
        var text = Strings.last_ride_created
        if dateDifference == 1{
            text = text+String(dateDifference)+Strings.day_ago
        }else{
            text = text+String(dateDifference)+Strings.days_ago
        }
        return text
    }
    
    func getErrorMessageForCall() -> String?{
        if (matchedUser?.userRole == MatchedUser.RIDER || matchedUser?.userRole == MatchedUser.REGULAR_RIDER) && !RideManagementUtils.getUserQualifiedToDisplayContact(){
            return Strings.link_wallet_for_call_msg
        }else if let enableChatAndCall = matchedUser?.enableChatAndCall, !enableChatAndCall{
            return Strings.chat_and_call_disable_msg
        }else if matchedUser?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            return Strings.call_joined_partner_msg
        }else if matchedUser?.callSupport == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }
        return nil
    }
}
