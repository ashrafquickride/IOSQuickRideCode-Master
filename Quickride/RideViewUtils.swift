//
//  RideViewUtils.swift
//  Quickride
//
//  Created by KNM Rao on 04/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias successActionCompletionHandler = () -> Void

public class RideViewUtils{

  private  var statusStringKeyStore : [String : String] = [String : String]()

  init(){
    statusStringKeyStore[Ride.RIDE_STATUS_COMPLETED] = "Ride Completed"
    statusStringKeyStore[Ride.RIDE_STATUS_CANCELLED] = "Ride Cancelled"
    statusStringKeyStore[Ride.RIDE_STATUS_SCHEDULED] = "Ride Confirmed"
    statusStringKeyStore[Ride.RIDE_STATUS_DELAYED] = "Ride Delayed"
    statusStringKeyStore[Ride.RIDE_STATUS_STARTED] = "Ride In-Progress"
    statusStringKeyStore[Ride.RIDE_STATUS_REQUESTED] = "Finding Rider"
  }


  public static func isRideClosed(riderRideId : Double) -> Bool{
    AppDelegate.getAppDelegate().log.debug("isRideClosed()")
    let myRidesCache  = MyActiveRidesCache.getRidesCacheInstance()
    var ride : Ride? = myRidesCache?.getRiderRide(rideId: riderRideId)
    if ride == nil{
        ride = myRidesCache?.getPassengerRideByRiderRideId(riderRideId: riderRideId)
        let rideStatus = ride?.status
        if rideStatus == Ride.RIDE_STATUS_COMPLETED {
            return true
        }else{
            return false
        }
    }else{
      let rideStatus = ride?.status
      return rideStatus == Ride.RIDE_STATUS_CANCELLED || rideStatus == Ride.RIDE_STATUS_COMPLETED
    }

  }

  public  func getRideStatusAsTitle(status : String, rideType : String) -> String {
    AppDelegate.getAppDelegate().log.debug("getRideStatusAsTitle()")
    var title : String? =  statusStringKeyStore[status]
    if title == nil{
      title = statusStringKeyStore[Ride.RIDE_STATUS_SCHEDULED]!
    }
    if rideType == Ride.RIDER_RIDE && status == Ride.RIDE_STATUS_SCHEDULED{
      title = "Ride Scheduled"
    }
    return title!
  }

   static func isCancelActionAllowed(currentRideStatus : RideStatus) -> Bool{
    AppDelegate.getAppDelegate().log.debug("isCancelActionAllowed()")
    return currentRideStatus.isCancelRideAllowed()
  }

   static func isControlActionAllowed(currentRideStatus : RideStatus) -> Bool{
    AppDelegate.getAppDelegate().log.debug("isControlActionAllowed()")
    return (currentRideStatus.isStartRideAllowed() || currentRideStatus.isStopRideAllowed() ||
      currentRideStatus.isCheckInRideAllowed() || currentRideStatus.isCheckOutRideAllowed()
      || currentRideStatus.isDelayedCheckinAllowed())
  }



 static func getUserRole(currentParticipantRide : Ride?) -> UserRole {
    AppDelegate.getAppDelegate().log.debug("getUserRole()")
    var userRole : UserRole?

    if currentParticipantRide?.rideType == Ride.PASSENGER_RIDE{
      userRole = UserRole.Passenger
    }else{
      userRole = UserRole.Rider
    }
    return userRole!
  }

   static func isStatusUpdateForCurrentRide(newRideStatus : RideStatus?,  currentParticipantRide : Ride?, associatedRiderRide : RiderRide?) ->Bool
  {
    AppDelegate.getAppDelegate().log.debug("isStatusUpdateForCurrentRide()")

    if(currentParticipantRide  != nil){
      if(newRideStatus?.rideId == currentParticipantRide?.rideId){
        return true
      }
    }
    if(associatedRiderRide != nil){
        if(newRideStatus?.joinedRideId == associatedRiderRide?.rideId){
            return true
        }
    }
    return false
  }

   static func isRedundantStatusUpdate(newRideStatus : RideStatus ,currentRideStatus : RideStatus ) ->Bool{
    AppDelegate.getAppDelegate().log.debug("isRedundantStatusUpdate()")
    var isAlreadyUpdated : Bool = false
    if (currentRideStatus.status == newRideStatus.status) &&
      newRideStatus.userId == currentRideStatus.userId{
      isAlreadyUpdated = true
    }
    return isAlreadyUpdated
  }

    public static func getRideParticipantLocationFromRideParticipantLocationObjects(participantId : Double?, rideParticipantLocations : [RideParticipantLocation]?) -> RideParticipantLocation? {
        if participantId == nil || rideParticipantLocations == nil{
            return nil
        }
        for participantLocation in rideParticipantLocations!{
            if participantLocation.userId == participantId{
                return participantLocation
            }
        }
        return nil
    }

  public static func getRideParticipantObjForParticipantId(participantId : Double, rideParticipants : [RideParticipant]?) -> RideParticipant? {
    AppDelegate.getAppDelegate().log.debug("getRideParticipantObjForParticipantId() \(participantId)")
    if rideParticipants == nil {return nil}
    for rideParticipant in rideParticipants!{
      if(rideParticipant.userId == participantId){
        checkCurrentUserVerificationStatusAndHandleChatAndCall(rideParticipant: rideParticipant)
        return rideParticipant
      }
    }
    return nil
  }

   static func checkCurrentUserVerificationStatusAndHandleChatAndCall(rideParticipant : RideParticipant?){
        if rideParticipant == nil {
            return
        }

    }
  static func getRideStartTime(ride : Ride, format : String) -> String{
    AppDelegate.getAppDelegate().log.debug("getRideStartTime()")
    var startTime : Double? = nil
    if Ride.PASSENGER_RIDE == ride.rideType,let participantRide =  ride as? PassengerRide{
        
      startTime = participantRide.pickupTime
    }
    if startTime == nil || startTime == 0{
      startTime = ride.startTime
    }
    if startTime == nil || startTime == 0{
        startTime = NSDate().getTimeStamp()
    }
    
    return AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: startTime!/1000), format : format)
  }

  public static func getRideParticipantIndexForParticipantId(participantId : Double, rideParticipants : [RideParticipant]?) -> Int {
    AppDelegate.getAppDelegate().log.debug("getRideParticipantIndexForParticipantId() \(participantId)")
    if rideParticipants == nil || rideParticipants?.isEmpty == true {
      return -1
    }
    for index in 0...rideParticipants!.count-1{
      if(rideParticipants![index].userId == participantId){
        return index
      }
    }
    return -1
  }

    public static func getRiderFromRideParticipant(rideParticipants : [RideParticipant]?) -> RideParticipant? {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: rideParticipants))")
        guard let rideParticipants = rideParticipants else { return nil }
        var rideParticipantAsRider: RideParticipant?
        for rideParticipant in rideParticipants {
            if rideParticipant.status == Ride.RIDE_STATUS_COMPLETED || rideParticipant.status == Ride.RIDE_STATUS_CANCELLED {
                continue
            }
            if rideParticipant.rider {
                rideParticipantAsRider = rideParticipant
                break
            }
        }
        return rideParticipantAsRider
    }
    
    public static func getPasengersInfo(rideParticipants : [RideParticipant]?, isOverlappigRouteToConsider: Bool) -> [RideParticipant] {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: rideParticipants))")
        var passengersInfo  = [Double : RideParticipant]()
        if rideParticipants == nil {return [RideParticipant]()}
        for rideParticipant in rideParticipants!{
            if rideParticipant.rider || rideParticipant.status == Ride.RIDE_STATUS_COMPLETED || rideParticipant.status == Ride.RIDE_STATUS_CANCELLED || (!rideParticipant.hasOverlappingRoute && isOverlappigRouteToConsider) {
                continue
            }
            passengersInfo[rideParticipant.userId] = rideParticipant
        }
        var passengers = [RideParticipant]()
        for passenger in passengersInfo{
            passengers.append(passenger.1)
        }
    	passengers.sort(by: {$0.distanceFromRiderStartToPickUp ?? 0 < $1.distanceFromRiderStartToPickUp ?? 0})
        return passengers
    }

    public static func getPassengersYetToPickupInOrder(rideParticipants : [RideParticipant]?) -> [RideParticipant] {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: rideParticipants))")
        var passengersInfo  = [Double : RideParticipant]()
        if rideParticipants == nil {return [RideParticipant]()}
        for rideParticipant in rideParticipants!{
            if rideParticipant.rider || rideParticipant.status == Ride.RIDE_STATUS_COMPLETED || rideParticipant.status == Ride.RIDE_STATUS_CANCELLED || rideParticipant.status == Ride.RIDE_STATUS_STARTED {
                continue
            }
            passengersInfo[rideParticipant.userId] = rideParticipant
        }
        var passengers = [RideParticipant]()
        for passenger in passengersInfo{
            passengers.append(passenger.1)
        }
        passengers.sort(by: {$0.distanceFromRiderStartToPickUp ?? 0 < $1.distanceFromRiderStartToPickUp ?? 0})
        return passengers
    }

    public static func setBorderToUserImageBasedOnStatus(image : UIImageView, status : String){
        AppDelegate.getAppDelegate().log.debug("setBorderToUserImageBasedOnStatus() \(status)")
        image.layer.cornerRadius = image.bounds.size.width/2;
        image.layer.masksToBounds = true
        image.layer.borderWidth = 2.0

        if(Ride.RIDE_STATUS_STARTED == status){
            image.layer.borderColor = UIColor(netHex: 0x49d16e).cgColor
        }else if(Ride.RIDE_STATUS_DELAYED == status){
            image.layer.borderColor = UIColor(netHex: 0xe48f8f).cgColor
        }else{
            image.layer.borderColor = UIColor.white.cgColor
        }
    }

  public static func setRideParticipantImageForStatus(rideParticipantInfo : RideParticipant?) -> UIImageView?{
    AppDelegate.getAppDelegate().log.debug("setRideParticipantImageForStatus()")
    if rideParticipantInfo == nil{
      return nil
    }
    var userImage : UIImageView
    if(rideParticipantInfo!.imageURI != nil && rideParticipantInfo!.imageURI?.isEmpty == false) {
      let profileImage = AppUtil.saveImage(url: rideParticipantInfo!.imageURI!)
      userImage = UIImageView(image: UIImage(contentsOfFile: profileImage))
    }
    else {
      userImage = UIImageView(image: ImageCache.getInstance().getDefaultUserImage(gender: rideParticipantInfo!.gender!))
    }

    RideViewUtils.setBorderToUserImageBasedOnStatus(image: userImage, status: (rideParticipantInfo?.status)!)
    return userImage
  }

  public static func getRideParticipantImage(rideParticipantInfo : RideParticipant?) -> UIImage?{
    AppDelegate.getAppDelegate().log.debug("getRideParticipantImage()")
    if rideParticipantInfo == nil{
      return nil
    }
    if(rideParticipantInfo!.imageURI != nil && rideParticipantInfo!.imageURI?.isEmpty == false){
      let profileImage = AppUtil.saveImage(url: rideParticipantInfo!.imageURI!)
      return  UIImage(contentsOfFile: profileImage)!
    }
    else {
      return ImageCache.getInstance().getDefaultUserImage(gender: rideParticipantInfo!.gender!)
    }
  }
    static func removeRideParticipant(effectingUserId : Double,unjoiningUserId : Double,rideParticipants : [RideParticipant],riderRideId : Double, ride: Ride?, viewController : UIViewController, completionHandler: successActionCompletionHandler?){
        AppDelegate.getAppDelegate().log.debug("removeRideParticipant() \(effectingUserId) \(unjoiningUserId) \(riderRideId)")

        let rideParticipant  = RideViewUtils.getRideParticipantObjForParticipantId(participantId: effectingUserId, rideParticipants: rideParticipants)
        if rideParticipant == nil {
            return
        }
        let unjoiningUserRideType : String?
        let passengerUserId : Double
        let passengerRideId : Double
        let unjoiningParticipantInfo = RideViewUtils.getRideParticipantObjForParticipantId(participantId: unjoiningUserId, rideParticipants: rideParticipants)
        if  unjoiningParticipantInfo == nil {
            return
        }
        if (rideParticipant?.rider == true){
            passengerRideId = (unjoiningParticipantInfo?.rideId)!
            passengerUserId = (unjoiningParticipantInfo?.userId)!
            unjoiningUserRideType = Ride.PASSENGER_RIDE
        }else{
            passengerRideId = (rideParticipant?.rideId)!
            passengerUserId = (rideParticipant?.userId)!
            unjoiningUserRideType = Ride.RIDER_RIDE
        }
        let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationAndUnJoinViewController") as! RideCancellationAndUnJoinViewController

        rideCancellationAndUnJoinViewController.initializeDataForUnjoin(rideParticipants: rideParticipants, rideType: ride?.rideType, ride: ride, riderRideId: riderRideId, unjoiningUserRideId: passengerRideId, unjoiningUserId: passengerUserId, unjoiningUserRideType: unjoiningUserRideType) {
            completionHandler?()
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
    }

  static func isLatestLocationUpdateExpired(lastUpdateTime : Double?) -> Bool {
    if lastUpdateTime == nil || (NSDate().getTimeStamp()/1000 - lastUpdateTime!/1000) > Double(AppConfiguration.LOCATION_REFRESH_TIME_THRESHOLD_IN_SECS) {
      return true
    } else {
      return false
    }
  }

    static func displaySubscriptionDialogueBasedOnStatus(){

        let isDismissViewRequired = ConfigurationCache.getObjectClientConfiguration().subscriptionMandatory
        if UserDataCache.SUBSCRIPTION_STATUS == true{

            let subscriptionAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "SubscriptionAlertController") as! SubscriptionAlertController
            subscriptionAlertController.intializeDataBeforePresenting(isDismissViewRequired:isDismissViewRequired)
            let displayViewController = ViewControllerUtils.getCenterViewController()
            ViewControllerUtils.addSubView(viewControllerToDisplay: subscriptionAlertController)
        }
    }
    static func getRideParticipantMapFromList(rideParticipantLocations : [RideParticipantLocation]?) -> [Double : RideParticipantLocation]{
        if rideParticipantLocations == nil || rideParticipantLocations!.isEmpty{
            return [Double : RideParticipantLocation]()
        }
        var rideParticipantLocationDict = [Double : RideParticipantLocation]()

        for  rideParticipantLocation in rideParticipantLocations! {
            rideParticipantLocationDict[rideParticipantLocation.userId!] = rideParticipantLocation
        }
        return rideParticipantLocationDict
    }

    static func isRiderAllowedToPickup() -> Bool{
        if UserDataCache.getInstance()?.userProfile?.verificationStatus == 1 || (Int((UserDataCache.getInstance()?.userProfile?.numberOfRidesAsRider)!) + Int((UserDataCache.getInstance()?.userProfile?.numberOfRidesAsPassenger)!
            )) >= 10 {
            return true
        }
      return false
    }
    static func getRideEtequetiesToDisplayBasedOnRole(type : String) -> String{
        var etiqueties : [String]
        if type == Ride.RIDER_RIDE{
            etiqueties = Strings.riderEtiqutteDescription
        }else{
            etiqueties = Strings.rideTakerEtiqutteDescription
        }
        var description = etiqueties[0]
        for index in 1...etiqueties.count-1 {
            description = description + " | "+etiqueties[index]
        }
        return description
    }

    static func getSortAndFilterData(rideId: Double,rideType: String) -> String?{
        let sortStatus = DynamicFiltersCache.getInstance().getDynamicFiltersStatusForRide(rideId: rideId, rideType: rideType)
        let sortData = "sortData-\(sortStatus?[DynamicFiltersCache.SORT_CRITERIA] ?? DynamicFiltersCache.SORT_AS_RECOMMENDED)"
        let filterStatus = DynamicFiltersCache.getInstance().getDynamicFiltersStatusForRide(rideId: rideId, rideType: rideType)
        let filterData = "\(DynamicFiltersCache.USERS_CRITERIA)-\( filterStatus?[DynamicFiltersCache.USERS_CRITERIA] ?? DynamicFiltersCache.PREFERRED_USERS_VERIFIED) ,\(DynamicFiltersCache.VEHICLE_CRITERIA)-\(filterStatus?[DynamicFiltersCache.VEHICLE_CRITERIA] ?? DynamicFiltersCache.PREFERRED_ALL), \(DynamicFiltersCache.GENDER_CRITERIA)-\(filterStatus?[DynamicFiltersCache.GENDER_CRITERIA] ?? DynamicFiltersCache.PREFERRED_ALL)"

        if sortStatus?[DynamicFiltersCache.SORT_CRITERIA] != nil || filterStatus?[DynamicFiltersCache.USERS_CRITERIA] != nil || filterStatus?[DynamicFiltersCache.PREFERRED_VEHICLE_CAR] != nil || filterStatus?[DynamicFiltersCache.GENDER_CRITERIA] != nil {
            return "\(filterData) - \(sortData)"
        }else{
            return nil
        }
    }

    static func checkIfPassengerEnabledRideModerator(ride: Ride?, rideParticipantObjects: [RideParticipant]) -> Bool {
        let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()
        if ride?.rideType != Ride.PASSENGER_RIDE || ride?.status != Ride.RIDE_STATUS_STARTED || ridePreference == nil || !ridePreference!.rideModerationEnabled {
            return false
        }
        let rideParticipantAsRider = self.getRidPartcipantAsRider(rideParticipantObjects: rideParticipantObjects)
        if rideParticipantAsRider != nil && rideParticipantAsRider!.rideModerationEnabled && rideParticipantAsRider!.status == Ride.RIDE_STATUS_STARTED {
            return true
        }
        return false
    }

    static func getRidPartcipantAsRider(rideParticipantObjects: [RideParticipant]) -> RideParticipant? {
        var rideParticipantAsRider: RideParticipant?
        for rideParticipant in rideParticipantObjects {
            if rideParticipant.rider {
                rideParticipantAsRider = rideParticipant
                break
            }
        }
        return rideParticipantAsRider
    }

    static func isModetatorNotification(userNotification: UserNotification?) -> Bool{
        if userNotification?.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_TO_MODERATOR || userNotification?.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_WITH_REQUESTED_FARE_TO_MODERATOR {
            return true
        }
        return false
    }

    static func isOTPRequiredToPickupPassenger(rideParticipant: RideParticipant, ride: Ride?, riderProfile: UserProfile?) -> Bool {
        if !rideParticipant.otpRequiredToPickup {
            return false
        }
        if Int(rideParticipant.points!) > ConfigurationCache.getObjectClientConfiguration().thresholdPointsToRestrictOTP || ride?.distance ?? 0 >= ConfigurationCache.getObjectClientConfiguration().minDistanceForInterCityRide {
            return true
        }
        if let userProfile = riderProfile, let emailVerified = userProfile.profileVerificationData?.emailVerified, !emailVerified, Int(userProfile.numberOfRidesAsRider) < ConfigurationCache.getObjectClientConfiguration().thresholdNoOfRidesForUnVerifiedNewRiderToRestrictOTP {
            
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId))
            return contact == nil || contact!.contactType != Contact.RIDE_COMPLETED_RIDE_PARTNER
            
//            return true
        }
        return false
       
    }

    static func getFilteredMatchedRiderBasedOnMatchPercentage(rideObj: Ride, matchedRiders: [MatchedRider]) -> [MatchedRider] {
        let differece = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: rideObj.startTime, time2: NSDate().getTimeStamp())
        var readyToGoMatches = [MatchedRider]()
        if differece < 15 {
            var filteredMatchedRiders1 = [MatchedRider]()
            var filteredMatchedRiders2 = [MatchedRider]()
            for matchedRider in matchedRiders {
                if matchedRider.matchPercentage! >= 90 {
                    if matchedRider.matchPercentage! < 95 {
                        filteredMatchedRiders1.append(matchedRider)
                    } else if matchedRider.matchPercentage! <= 100 {
                        filteredMatchedRiders2.append(matchedRider)
                    }
                }
            }
            var notStartedMatchedRider = [MatchedRider]()
            filteredMatchedRiders2.sort(by: { $0.matchPercentage ?? 0 > $1.matchPercentage ?? 0})
            for matchedRider in filteredMatchedRiders2 {
                let differece = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: matchedRider.pickupTime, time2: NSDate().getTimeStamp())
                if differece < 15 {
                    matchedRider.isReadyToGo = true
                    if matchedRider.rideStatus == Ride.RIDE_STATUS_STARTED {
                        readyToGoMatches.append(matchedRider)
                    } else {
                        notStartedMatchedRider.append(matchedRider)
                    }
                }
            }
            readyToGoMatches.append(contentsOf: notStartedMatchedRider)
            if readyToGoMatches.count <= 7 {
                notStartedMatchedRider.removeAll()
                filteredMatchedRiders1.sort(by: { $0.matchPercentage ?? 0 > $1.matchPercentage ?? 0})
                for matchedRider in filteredMatchedRiders1 {
                    let differece = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: matchedRider.pickupTime, time2: NSDate().getTimeStamp())
                    if differece < 15 {
                        matchedRider.isReadyToGo = true
                        if matchedRider.rideStatus == Ride.RIDE_STATUS_STARTED {
                            readyToGoMatches.append(matchedRider)
                        } else {
                            notStartedMatchedRider.append(matchedRider)
                        }
                    }
                }
                readyToGoMatches.append(contentsOf: notStartedMatchedRider)
            }
            return readyToGoMatches.prefix(7).map{ $0 }
        }
        return readyToGoMatches
    }
}
