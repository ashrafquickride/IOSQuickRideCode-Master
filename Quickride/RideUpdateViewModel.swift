//
//  RideUpdateViewModel.swift
//  Quickride
//
//  Created by Halesh on 02/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideUpdateViewModel{
    
    //MARK:Propertise
    var ride : Ride?
    var riderRide : RiderRide?
    var vehicle : Vehicle?
    var routes = [RideRoute]()
    var currentRideRoute : RideRoute?{
        if routes.isEmpty {
          return nil
        }else{
            for route in routes{
                if route.routeId == selectedRouteId{
                    return route
                }
            }
            return routes[0]
        }
    }
    var selectedRouteId : Double = -1.0
    var rideUdpateListener : RideObjectUdpateListener?
    var rideVehicleConfigurationViewController : RideVehicleConfigurationViewController?
    
    func initializeData(ride : Ride, riderRide: RiderRide?, listener : RideObjectUdpateListener?){
        if let riderRide = ride as? RiderRide{
            self.ride = riderRide.copy() as? RiderRide
        }else if let passengerRide = ride as? PassengerRide {
            self.ride = passengerRide.copy() as? PassengerRide
        }else{
            self.ride = ride
        }
        self.riderRide = riderRide
        self.rideUdpateListener = listener
        prepareVehicle()
    }
    
    func checkTimeDateVehicleVisibility() -> Bool{
        if (ride?.rideType == Ride.PASSENGER_RIDE && ride?.status != Ride.RIDE_STATUS_REQUESTED) || (ride?.rideType == Ride.RIDER_RIDE && ride?.status == Ride.RIDE_STATUS_STARTED){
            return true
        }else{
            return false
        }
    }
    
    func checkFromAndToAddressVisibility() -> Bool{
        if let passengerRide = ride as? PassengerRide {
            return true
        }
        else if ride!.status != Ride.RIDE_STATUS_STARTED || (ride!.isKind(of: RiderRide.self) && (ride as! RiderRide).noOfPassengers == 0){
            return true
        }else{
            return false
        }
    }
    
    func getMostFavourableRoute(listener: RouteReceiver){
        if(ride!.startLatitude != 0 && ride!.startLongitude != 0 && ride!.endLatitude != 0 && ride!.endLongitude != 0){
            MyRoutesCache.getInstance()?.getUserRoutes(useCase: "iOS.App."+ride!.rideType!+".AllRoutes.RideUpdateView", rideId: ride!.rideId, startLatitude: ride!.startLatitude, startLongitude: ride!.startLongitude, endLatitude: ride!.endLatitude!, endLongitude: ride!.endLongitude!, weightedRoutes: false, routeReceiver: listener)
        }
    }
    
    func prepareVehicle(){
        guard let ride = ride as? RiderRide else {
            return
        }
        vehicle = Vehicle(ownerId:  ride.userId, vehicleModel : ride.vehicleModel,vehicleType : ride.vehicleType!, registrationNumber : ride.vehicleNumber, capacity : ride.capacity, fare : ride.farePerKm, makeAndCategory : ride.makeAndCategory,additionalFacilities : ride.additionalFacilities, riderHasHelmet : ride.riderHasHelmet)
    }
    
    func updatePickUpAndDropPoint(matchedUser: MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?)
    {
        guard let ride = self.ride as? PassengerRide else { return }
        ride.points = matchedUser.points!
        ride.newFare = matchedUser.newFare
        ride.pickupAddress = matchedUser.pickupLocationAddress!
        ride.pickupLatitude = matchedUser.pickupLocationLatitude!
        ride.pickupLongitude = matchedUser.pickupLocationLongitude!
        ride.overLappingDistance = matchedUser.distance!
        ride.pickupTime = matchedUser.pickupTime!
        ride.dropAddress = matchedUser.dropLocationAddress!
        ride.dropLatitude = matchedUser.dropLocationLatitude!
        ride.dropLongitude = matchedUser.dropLocationLongitude!
        ride.dropTime = matchedUser.dropTime!
        ride.overLappingDistance = matchedUser.distance!
        ride.pickupNote = userPreferredPickupDrop?.note
        if userPreferredPickupDrop != nil {
            updateUserPreferredPickupDrop(userPreferredPickupDrop: userPreferredPickupDrop!)
        }
    }
    
    private func updateUserPreferredPickupDrop(userPreferredPickupDrop: UserPreferredPickupDrop) {
        UserRestClient.saveOrUpdateUserPreferredPickupDrop(userId: QRSessionManager.getInstance()?.getUserId(), userPreferredPickupDropJsonString: userPreferredPickupDrop.toJSONString(), viewContrller: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let userPreferredPickupDrop = Mapper<UserPreferredPickupDrop>().map(JSONObject: responseObject!["resultData"]) {
                    UserDataCache.getInstance()?.storeUserPreferredPickupDrops(userPreferredPickupDrop: userPreferredPickupDrop)
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
    
    func upadteEditedRide(fromAddrees: String?, toAddress: String?, viewController: UIViewController){
        if RideValidationUtils.validatePreconditionsForCreatingRide(ride: ride!, vehicle: vehicle, fromLocation: fromAddrees, toLocation: toAddress, viewController: viewController){
            return
        }
        let redundantRide = MyActiveRidesCache.singleCacheInstance?.checkForRedundancyOfRide(ride: ride!)
        if redundantRide != nil{
            RideValidationUtils.displayRedundentRideAlert(ride: redundantRide!, viewController: viewController)
            return
        }
        let duplicateRide = MyActiveRidesCache.singleCacheInstance?.checkForDuplicateRideOnSameDay(ride: ride!)
        
        if duplicateRide == nil{
            self.countinueUpdatingRide(ride: ride!, viewController: viewController)
        }else{
            displayDuplicatedRideForSameDayAlertDialog(newRide: ride!, duplicateRide: duplicateRide!, viewController: viewController)
        }
    }
    
    private func displayDuplicatedRideForSameDayAlertDialog( newRide : Ride,duplicateRide : Ride, viewController: UIViewController){
        MessageDisplay.displayErrorAlertWithAction(title: Strings.duplicate_ride_alert, isDismissViewRequired : true, message1: Strings.ride_duplication_alert_for_the_same_day, message2: nil, positiveActnTitle: Strings.reschedule_caps, negativeActionTitle : Strings.update_caps,linkButtonText: nil, viewController: viewController, handler: { (result) in
            if result == Strings.update_caps{
                self.countinueUpdatingRide(ride: newRide, viewController: viewController)
            }
            else if result == Strings.reschedule_caps{
                RescheduleRide(ride: duplicateRide, viewController: viewController,moveToRideView: true).rescheduleRide()
            }
        })
    }
    
    private func countinueUpdatingRide(ride: Ride?, viewController: UIViewController){
        if ride?.rideType == Ride.RIDER_RIDE{
            updateRiderRide(currentRide: ride, viewController: viewController)
        }else{
            updatePassengerRide(currentRide: ride, viewController: viewController)
        }
    }
    
    private func updateRiderRide(currentRide: Ride?, viewController: UIViewController) {
        guard let ride = currentRide, let vehicle = self.vehicle else { return }
        var route : RideRoute?
        if currentRideRoute != nil{
            route = currentRideRoute
        }
        QuickRideProgressSpinner.startSpinner()
        RiderRideRestClient.updateRiderRide(rideId: ride.rideId, startAddress: ride.startAddress, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endAddress: ride.endAddress, endLatitude: ride.endLatitude!, endLongitude: ride.endLongitude!, startTime: ride.startTime, vehicleNumber: vehicle.registrationNumber, vehicleModel: vehicle.vehicleModel, fare: vehicle.fare, vehicleMakeandCategory: vehicle.makeAndCategory, vehicleAdditionalFacilities: vehicle.additionalFacilities, riderHasHelmet: vehicle.riderHasHelmet , route: route, capacity: vehicle.capacity, vehicleType: vehicle.vehicleType!, vehicleId:  vehicle.vehicleId, allowRideMatchToJoinedGroups: ride.allowRideMatchToJoinedGroups, showMeToJoinedGroups: ride.showMeToJoinedGroups, vehicleImageURI: vehicle.imageURI, ViewController: viewController, completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let riderRideUpdate = Mapper<RiderRide>().map(JSONObject: responseObject!["resultData"])
                if riderRideUpdate != nil{
                    let existingRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: self.ride!.rideId)
                    if existingRide == nil{
                        return
                    }
                    var rescheduled = false
                    if existingRide!.startTime != riderRideUpdate?.startTime{
                        rescheduled = true
                    }
                    MyActiveRidesCache.getRidesCacheInstance()?.updateExistingRide(ride: riderRideUpdate!)
                    if rescheduled{
                        let rideStatus = RideStatus(rideId :riderRideUpdate!.rideId, userId:riderRideUpdate!.userId,  status : Ride.RIDE_STATUS_RESCHEDULED, rideType : Ride.RIDER_RIDE, scheduleTime : existingRide!.startTime , rescheduledTime :riderRideUpdate!.startTime)
                        MyActiveRidesCache.getRidesCacheInstance()?.rescheduleRide(rideStatus: rideStatus)
                    }
                    self.rideUdpateListener?.rideUpdated(ride: riderRideUpdate!)
                }
                viewController.navigationController?.popViewController(animated: false)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
    
    private func updatePassengerRide(currentRide: Ride?, viewController: UIViewController) {
        guard let ride = (currentRide as? PassengerRide) else { return }
        guard let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: ride.rideId) else { return }
        var pickupLatitude,pickupLongitude,pickupTime,dropLatitude,dropLongitude,dropTime : Double?
        var pickupAddress,dropAddress : String?
        if passengerRide.pickupLatitude != ride.pickupLatitude && passengerRide.pickupLongitude != ride.pickupLongitude{
            pickupAddress = ride.pickupAddress
            pickupLatitude = ride.pickupLatitude
            pickupLongitude = ride.pickupLongitude
            pickupTime = ride.pickupTime
        }
        if passengerRide.dropLatitude != ride.dropLatitude && passengerRide.dropLongitude != ride.dropLongitude{
            dropAddress = ride.dropAddress
            dropLatitude = ride.dropLatitude
            dropLongitude = ride.dropLongitude
            dropTime = ride.dropTime
        }
        var rescheduled = false
        if passengerRide.startTime != ride.startTime{
            rescheduled = true
        }
        var route : RideRoute?
        if currentRideRoute != nil{
            route = currentRideRoute
        }
        QuickRideProgressSpinner.startSpinner()
        PassengerRideServiceClient.updatePassengerRide(rideId: ride.rideId, startAddress: ride.startAddress, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endAddress: ride.endAddress, endLatitude: ride.endLatitude!, endLongitude: ride.endLongitude!, startTime: ride.startTime, noOfSeats: ride.noOfSeats, route: route, pickupAddress: pickupAddress,pickupLatitude: pickupLatitude,pickupLongitude: pickupLongitude,dropAddress: dropAddress,dropLatitude: dropLatitude,dropLongitude: dropLongitude,pickupTime: pickupTime,dropTime: dropTime,points : ride.points,overlapDistance: ride.overLappingDistance, allowRideMatchToJoinedGroups: ride.allowRideMatchToJoinedGroups, showMeToJoinedGroups: ride.showMeToJoinedGroups, pickupNote: ride.pickupNote,viewController: viewController, completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let passenegerRideUpdate = Mapper<PassengerRide>().map(JSONObject: responseObject!["resultData"])
                if passenegerRideUpdate != nil
                {
                    MyActiveRidesCache.getRidesCacheInstance()?.updateExistingRide(ride: passenegerRideUpdate!)
                    if rescheduled{
                        let rideStatus : RideStatus = RideStatus(rideId :passenegerRideUpdate!.rideId, userId:passenegerRideUpdate!.userId,  status : Ride.RIDE_STATUS_RESCHEDULED, rideType : Ride.PASSENGER_RIDE, scheduleTime : passengerRide.startTime , rescheduledTime :passenegerRideUpdate!.startTime)
                        MyActiveRidesCache.getRidesCacheInstance()?.rescheduleRide(rideStatus: rideStatus)
                    }
                    self.rideUdpateListener?.rideUpdated(ride: passenegerRideUpdate!)
                }
                viewController.navigationController?.popViewController(animated: false)
            }
            else
            {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)

            }
        })
    }
    func isPickupDropEditEnable() -> Bool {
        if let passenerRide = ride as? PassengerRide, passenerRide.status == Ride.RIDE_STATUS_SCHEDULED || passenerRide.status == Ride.RIDE_STATUS_DELAYED || passenerRide.status == Ride.RIDE_STATUS_STARTED{
            return true
        }
        return false
    }
}
