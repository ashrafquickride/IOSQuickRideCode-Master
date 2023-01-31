//
//  RideCancelActionProxy.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 05/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class RideCancelActionProxy {

  typealias CancelRideInformationComepletionHandler = (_ compensation : [Compensation]) -> Void
  typealias CancelRideComepletionHandler = () -> Void
  typealias unjoinRideCompletionHandler = (_ reponseError: ResponseError?, _ error: NSError?) -> Void
  public typealias cancelRidesInBulkCompletionHandler = (_ success: Bool) -> Void
    static let USER_ROLE_CHANGED = "User role changed"

    static func cancelRide(ride :Ride, cancelReason : String?,isWaveOff: Bool,viewController : UIViewController,handler: @escaping CancelRideComepletionHandler){
        AppDelegate.getAppDelegate().log.debug("cancelRide()")
        if ride.rideType == Ride.RIDER_RIDE{
            cancelRiderRide(ride: ride, cancelReason: cancelReason, isWaveOff: isWaveOff,viewController: viewController,handler: handler)
        }else{
            cancelPassengerRide(ride: ride, cancelReason: cancelReason, isWaveOff: isWaveOff,viewController: viewController,handler: handler)
        }

    }

    static func getCancelRideInformation(ride :Ride,cancelReason: String,uiViewController : UIViewController,completionhandler : @escaping CancelRideInformationComepletionHandler){
        AppDelegate.getAppDelegate().log.debug("getCancelRideInformation()")
        if isPenaltyApplicable(ride: ride) == false{
            completionhandler([Compensation]())
            return
        }
        var compensations = [Compensation]()
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.getEstimatedPenaltyForRideCancellation(rideId: ride.rideId, rideType: ride.rideType!, userId: ride.userId, startTime: getRideLogicalStartTime(ride: ride),cancelReason: cancelReason) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                QuickRideProgressSpinner.stopSpinner()
                compensations = Mapper<Compensation>().mapArray(JSONObject: responseObject!["resultData"]) ?? [Compensation]()
                completionhandler(compensations)
            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: uiViewController, handler: nil)
            }
        }
    }

    private static func cancelRiderRide(ride : Ride,cancelReason : String?, isWaveOff: Bool,viewController:UIViewController,handler: @escaping CancelRideComepletionHandler){
        
        QuickRideProgressSpinner.startSpinner()
        AppDelegate.getAppDelegate().log.debug("cancelRiderRide()")
        let rideStatus : RideStatus = RideStatus(rideId: ride.rideId,userId: ride.userId,status: Ride.RIDE_STATUS_CANCELLED,rideType: ride.rideType!)
        RiderRideRestClient.cancelRide(rideId: ride.rideId, userId: ride.userId,cancelReason: cancelReason, isWaveOff: isWaveOff, targetViewController: viewController) { (responseObject, error) -> Void in
            
            QuickRideProgressSpinner.stopSpinner()
            
            if responseObject == nil{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }else if responseObject!["result"] as! String == "FAILURE"{
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: viewController,handler: nil)
                handler()
                return
            }else if responseObject!["result"] as! String == "SUCCESS"{
                MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: rideStatus)
                ClearRideDataAsync().completeRiderRide(rideStatus: rideStatus)
                handler()
                if cancelReason != RideCancelActionProxy.USER_ROLE_CHANGED{
                    moveToCancelledReport(ride: ride, viewController: viewController)
                }
            }
        }
    }

  private static func cancelPassengerRide(ride : Ride,cancelReason : String?,isWaveOff: Bool,viewController : UIViewController,handler: @escaping CancelRideComepletionHandler){

    QuickRideProgressSpinner.startSpinner()

    AppDelegate.getAppDelegate().log.debug("cancelPassengerRide()")

    let rideStatus : RideStatus = RideStatus(rideId: ride.rideId,userId: ride.userId,status: Ride.RIDE_STATUS_CANCELLED,rideType: ride.rideType!,joinedRideId: (ride as! PassengerRide).riderRideId,joinedRideStatus: nil)

    PassengerRideServiceClient.cancelPassengerRide(rideId: ride.rideId, userId: ride.userId,cancelReason : cancelReason, isWaveOff: isWaveOff, targetViewController: viewController) { (responseObject, error) -> Void in
        QuickRideProgressSpinner.stopSpinner()
        if let status = responseObject?["result"] as? String, status == "SUCCESS"{
          MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: rideStatus)
          ClearRideDataAsync().completePassengerRide(rideStatus: rideStatus)
          handler()
          if cancelReason != RideCancelActionProxy.USER_ROLE_CHANGED{
              moveToCancelledReport(ride: ride, viewController: viewController)
          }
        }else{
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
        }
    }
  }

  private static func excludeRiderFromParticipantList( riderId : Double , rideParticipants :[RideParticipant])->[RideParticipant]{
    AppDelegate.getAppDelegate().log.debug("excludeRiderFromParticipantList() \(riderId)")
    var participantsOfRide = rideParticipants
    for index in 0...rideParticipants.count-1 {
      if rideParticipants[index].rider == true{
        participantsOfRide.remove(at: index)
        break
      }
    }
    return participantsOfRide
  }

  private  static func isPenaltyApplicable(ride :Ride) -> Bool{
    AppDelegate.getAppDelegate().log.debug("isPenaltyApplicable()")
    var isPenaltyApplicable :Bool = true
    if let passengerRide = ride as? PassengerRide,passengerRide.riderRideId == 0{
      isPenaltyApplicable = false
    }else if let riderRide = ride as? RiderRide,riderRide.noOfPassengers == 0{
      isPenaltyApplicable = false
    }
    return isPenaltyApplicable
  }

  private  static func getRideLogicalStartTime(ride :Ride) -> Double{
    AppDelegate.getAppDelegate().log.debug("getRideLogicalStartTime()")
    if ride.rideType == Ride.RIDER_RIDE{
      return ride.startTime
    }else{
      return (ride as! PassengerRide).pickupTime
    }
  }
    static func unjoinParticipant(riderRideId : Double,passengerRIdeId : Double,passengerUserId : Double, rideType : String,cancelReason : String?,isWaveOff: Bool, viewController : UIViewController, completionHandler: @escaping RideCancelActionProxy.unjoinRideCompletionHandler){

        QuickRideProgressSpinner.startSpinner()

      AppDelegate.getAppDelegate().log.debug("unjoinParticipant() \(riderRideId) \(passengerRIdeId) \(passengerUserId) \(rideType)")

        RideServicesClient.unjoinRideParticipantFromRide(riderRideId: riderRideId, passengerRideId: passengerRIdeId, rideType: rideType,rideCancelReason:cancelReason,isWaveOff: isWaveOff, viewController: viewController) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if let status = responseObject?["result"] as? String, status   == "SUCCESS"{
                let rideStatus : RideStatus = RideStatus(rideId: passengerRIdeId,userId: passengerUserId,status: Ride.RIDE_STATUS_REQUESTED,rideType: Ride.PASSENGER_RIDE,joinedRideId: riderRideId,joinedRideStatus: nil)
                if passengerUserId == Double((QRSessionManager.getInstance()?.getUserId())!)!{
                    MyActiveRidesCache.singleCacheInstance?.updateRideStatus(newRideStatus: rideStatus)
                }else{
                    MyActiveRidesCache.singleCacheInstance?.updateRideParticipantStatusAndNotify(rideStatus: rideStatus)
                }
                completionHandler(nil,nil)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
               completionHandler(nil, error)
            }
        }
    }

    static func cancelAllRidesInBulk(riderRides: [RiderRide], passengerRides: [PassengerRide], viewController: UIViewController?,handler:  @escaping RideCancelActionProxy.cancelRidesInBulkCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("cancelRidesInBulk()")
        var rideCancelResponseError : ResponseError?
        var rideCancelerror : NSError?
        var passengerRideStatusList = [RideStatus]()
        var riderRideStatusList = [RideStatus]()
        var riderRideIds = [Double]()
        var passengerRideIds = [Double]()
        for ride in riderRides{
            riderRideIds.append(ride.rideId)
            let rideStatus : RideStatus = RideStatus(rideId: ride.rideId,userId: ride.userId,status: Ride.RIDE_STATUS_CANCELLED,rideType: ride.rideType!)
            riderRideStatusList.append(rideStatus)
        }
        for ride in passengerRides{
            passengerRideIds.append(ride.rideId)
            let rideStatus : RideStatus = RideStatus(rideId: ride.rideId,userId: ride.userId,status: Ride.RIDE_STATUS_CANCELLED,rideType: ride.rideType!)
            passengerRideStatusList.append(rideStatus)
        }
        guard let riderRideId = try? JSONSerialization.data(withJSONObject: riderRideIds, options: []) else {
            return
        }
        let riderRideIdsInString = String(data: riderRideId, encoding: String.Encoding.utf8)
        guard let passengerRideId = try? JSONSerialization.data(withJSONObject: passengerRideIds, options: []) else {
            return
        }
        let passengerRideIdsInString = String(data: passengerRideId, encoding: String.Encoding.utf8)

        let queue = DispatchQueue.main
        let group = DispatchGroup()
        group.enter()
        queue.async(group: group) {
            if riderRideIdsInString != nil
            {
                RiderRideRestClient.cancelRiderRidesBulk(rideIds: riderRideIdsInString, userId: QRSessionManager.getInstance()!.getUserId(), targetViewController: viewController) { (responseObject, error) in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        for rideStatus in riderRideStatusList{
                            MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: rideStatus)
                            ClearRideDataAsync().completeRiderRide(rideStatus: rideStatus)
                        }
                    }
                    else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                        let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        rideCancelResponseError = responseError
                    }
                    else{
                        rideCancelerror = error
                    }
                    group.leave()
                }
            }else{
                group.leave()
            }
        }
        group.enter()
        queue.async(group: group) {
            if passengerRideIdsInString != nil
            {
                PassengerRideServiceClient.cancelPassengerRidesBulk(rideIds: passengerRideIdsInString, userId: QRSessionManager.getInstance()!.getUserId(), targetViewController: viewController) { (responseObject, error) in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        for rideStatus in passengerRideStatusList{
                            MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: rideStatus)
                            ClearRideDataAsync().completeRiderRide(rideStatus: rideStatus)
                        }
                    }
                    else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                        let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        rideCancelResponseError = responseError
                    }
                    else{
                        rideCancelerror = error
                    }
                    group.leave()
                }
            }else{
                group.leave()
            }
        }
        group.notify(queue: queue) {
            if rideCancelResponseError != nil || rideCancelerror != nil{
                handler(false)
            }
            else{
                handler(true)
            }
        }
    }

    static func moveToCancelledReport(ride: Ride,viewController: UIViewController?){
        QuickRideProgressSpinner.startSpinner()
        BillRestClient.getRideCancellationReport(userId: UserDataCache.getInstance()?.userId ?? "", rideId: ride.rideId, rideType: ride.rideType ?? "", targetViewController: viewController, completionHandler:  {(responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
               let rideCancellationReport = Mapper<RideCancellationReport>().mapArray(JSONObject: responseObject!["resultData"]) ?? [RideCancellationReport]()
                let cancelRideBillViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CancelRideBillViewController") as! CancelRideBillViewController
                cancelRideBillViewController.initializeCancelRideRepoet(ride: ride, rideCancellationReport: rideCancellationReport)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: cancelRideBillViewController, animated: false)
            }
        })
    }
}
