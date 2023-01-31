//
//  RideCancellationAndUnJoinViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 22/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol RideUnjoinEstimationDelegate {
    func unJoinEstimation()
}
protocol RideCancelEstimationDelegate {
    func handleSuccessResponse()
}
protocol RideCancelledOrUnjoinedDelegate {
    func showWaviedOffScreen()
    func rideCancelledBefeoreJoiningOrFeeNotApplied()
}

class RideCancellationAndUnJoinViewModel{
    
    //Variables
    var compensations = [Compensation]()
    var isWaveOffCompensationAvailable = false
    var rideParticipants : [RideParticipant]?
    var rideType : String?
    var isFromCancelRide = false
    var ride: Ride?
    var vehicleType: String?
    var rideUpdateListener: RideObjectUdpateListener?
    var reasons = [String]()
    var rideCancellationCompletionHandler : rideCancellationCompletionHandler?
    var selectedIndex = -1
    var isCallOptionEnable = false
    var isChatOptionEnable = false
    //Unjoin
    var riderRideId : Double?
    var unjoiningUserRideId : Double?
    var unjoiningUserId : Double?
    var unjoiningUserRideType : String?
    
    func initailiseData(rideParticipants : [RideParticipant]?,rideType: String?,isFromCancelRide: Bool,ride: Ride?,vehicelType: String?, rideUpdateListener: RideObjectUdpateListener?, completionHandler : rideCancellationCompletionHandler?) {
        self.rideParticipants = rideParticipants
        self.rideCancellationCompletionHandler = completionHandler
        self.rideType = rideType
        self.isFromCancelRide = isFromCancelRide
        self.ride = ride
        self.vehicleType = vehicelType
        self.rideUpdateListener = rideUpdateListener
    }
    
    func initialiseUnjoinData(rideParticipants : [RideParticipant]?,rideType: String?,ride: Ride?,riderRideId : Double,unjoiningUserRideId : Double,unjoiningUserId : Double, unjoiningUserRideType : String?, completionHandler : rideCancellationCompletionHandler?) {
        self.rideParticipants = rideParticipants
        self.rideCancellationCompletionHandler = completionHandler
        self.rideType = rideType
        self.ride = ride
        self.riderRideId = riderRideId
        self.unjoiningUserRideId = unjoiningUserRideId
        self.unjoiningUserId = unjoiningUserId
        self.unjoiningUserRideType = unjoiningUserRideType
    }
    func checkCallAndChatOptionAvailable(){
        guard let participants = rideParticipants else { return }
        if rideType == Ride.RIDER_RIDE{
            if !isFromCancelRide{
                for participant in participants{
                    if !participant.rider,participant.enableChatAndCall,participant.callSupport != UserProfile.SUPPORT_CALL_NEVER{
                        isCallOptionEnable = true
                        isChatOptionEnable = true
                        break
                    }
                }
            }
        }else{
            for participant in participants{
                if participant.rider, participant.enableChatAndCall == true, participant.callSupport != UserProfile.SUPPORT_CALL_NEVER{
                    isCallOptionEnable = true
                    isChatOptionEnable = true
                    break
                }
            }
        }
    }
    func getCallErrorMessage() -> String?{
        guard let participants = rideParticipants else { return nil}
        if rideType == Ride.RIDER_RIDE{
            if !isFromCancelRide{
                for participant in participants{
                    if !participant.rider,!participant.enableChatAndCall{
                        return Strings.chat_and_call_disable_msg
                    }else if !participant.rider, participant.callSupport == UserProfile.SUPPORT_CALL_NEVER{
                        return Strings.no_call_please_msg
                    }
                }
                return nil
            }
        }else{
            for participant in participants{
                if participant.rider,
                    !participant.enableChatAndCall{
                   return Strings.chat_and_call_disable_msg
                }else if participant.callSupport == UserProfile.SUPPORT_CALL_NEVER{
                    return Strings.no_call_please_msg
                }
            }
            return nil
        }
        return nil
    }
    
    func getChatErrorMessage() -> String?{
        guard let participants = rideParticipants else { return nil}
        if rideType == Ride.RIDER_RIDE{
            if !isFromCancelRide{
                for participant in participants{
                    if !participant.rider,!participant.enableChatAndCall{
                        return Strings.chat_and_call_disable_msg
                    }
                }
                return nil
            }
            return nil
        }else{
            for participant in participants{
                if participant.rider,!participant.enableChatAndCall{
                    return Strings.chat_and_call_disable_msg
                }
            }
            return nil
        }
    }
    
    func getOppositeUser() -> RideParticipant?{
        guard let participants = rideParticipants else { return nil}
        if rideType == Ride.RIDER_RIDE{
            for participant in participants{
                if !participant.rider{
                   return participant
                }
            }
        }else{
            for participant in participants{
                if participant.rider{
                    return participant
                }
            }
        }
        return nil
    }
    
    func assignReasonsBasedOnRideStatus(){
        if isFromCancelRide{
            if rideType == Ride.RIDER_RIDE && rideParticipants?.isEmpty == false{
                if ride?.status == Ride.RIDE_STATUS_STARTED{
                   reasons = [Strings.im_going_late,Strings.im_going_early,Strings.sorry_My_plan_changed,Strings.other]
                    if rideParticipants?.count ?? 0 <= 2{
                        reasons.insert(Strings.passenger_asked_to_cancel, at: reasons.count - 1)
                    }
                }else{
                    reasons = [Strings.im_not_going,Strings.im_going_late,Strings.im_going_early,Strings.sorry_My_plan_changed,Strings.passenger_asked_to_cancel,Strings.other]
                    if ride?.regularRideId != 0{
                        reasons.insert(Strings.im_not_going_these_days, at: reasons.count - 2)
                    }
                }
            }else if rideType == Ride.PASSENGER_RIDE && rideParticipants?.isEmpty == false{
                reasons = [Strings.my_plan_changed,Strings.ride_giver_getting_late,Strings.rider_crossed_pick_up_point,Strings.ride_giver_not_reachable,Strings.ride_giver_changed_plan,Strings.want_better_match,Strings.price_is_high, Strings.other]
                if vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                    reasons.insert(Strings.cancelling_as_bike_ride, at: 2)
                }else if rideParticipants?.count ?? 0 >= 4{
                    reasons.insert(Strings.ride_over_crowded_now, at: reasons.count - 2)
                }
            }else if rideType == Ride.RIDER_RIDE {
                reasons = [Strings.im_not_going,Strings.im_going_late,Strings.im_going_early,Strings.no_good_matches_found,Strings.sorry_My_plan_changed,Strings.other]
                if ride?.regularRideId != 0{
                    reasons.insert(Strings.im_not_going_these_days, at: reasons.count - 1)
                }
            }else if rideType == Ride.PASSENGER_RIDE{
                reasons = [Strings.im_not_going,Strings.im_going_late,Strings.im_going_early, Strings.no_good_matches_found, Strings.other]
                if ride?.regularRideId != 0{
                    reasons.insert(Strings.im_not_going_these_days, at: reasons.count - 1)
                }
            }
        }else{
            if rideType == Ride.RIDER_RIDE && rideParticipants?.isEmpty == false{
                reasons = Strings.rider_unJoining
                if vehicleType == Vehicle.VEHICLE_TYPE_CAR && rideParticipants?.count ?? 0 > 2{
                  reasons.insert(Strings.my_car_is_full, at: 0)
                }
            }else if rideType == Ride.PASSENGER_RIDE && rideParticipants?.isEmpty == false{
                reasons = Strings.passenger_unJoining
                if rideParticipants?.count ?? 0 >= 4{
                    reasons.insert(Strings.ride_over_crowded_now, at: reasons.count - 2)
                }
            }
            
        }
    }
    
    func filterRideParticipants(){
        guard let participants = rideParticipants else { return }
        rideParticipants?.removeAll()
        for participant in participants{
            if isFromCancelRide{
                if StringUtils.getStringFromDouble(decimalNumber: participant.userId) != UserDataCache.getInstance()?.userId && participant.hasOverlappingRoute{
                    rideParticipants?.append(participant)
                }
            }else{
                if rideType == Ride.RIDER_RIDE{
                    if participant.userId == unjoiningUserId ?? 0{
                        rideParticipants?.append(participant)
                        break
                    }
                }else{
                    if participant.rider{
                        rideParticipants?.append(participant)
                        break
                    }
                }
            }
        }
    }
    
    
    func getRideUnjoinEstimation(unjoinReason: String,viewController : UIViewController,delegate: RideUnjoinEstimationDelegate){
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.getEstimatedPenaltyForRideUnjoin(rideId: unjoiningUserRideId ?? 0, rideType: unjoiningUserRideType ?? "",reason: unjoinReason, viewController : viewController ) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let compensation = Mapper<Compensation>().map(JSONObject: responseObject!["resultData"])
                if let comp = compensation{
                   self.compensations.append(comp)
                }
                delegate.unJoinEstimation()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    func getRideCancelEstimation(ride :Ride,cancelReason: String,uiViewController : UIViewController,delegate: RideCancelEstimationDelegate){
        RideCancelActionProxy.getCancelRideInformation(ride: self.ride!, cancelReason: cancelReason, uiViewController: uiViewController, completionhandler: { (compensation) -> Void in
            self.compensations = compensation
            self.filterSysemWaveOffFromCompensionList()
            delegate.handleSuccessResponse()
        })
    }
    
    func filterSysemWaveOffFromCompensionList(){
        for (index,compension) in compensations.enumerated(){
            if compension.isSystemWaveOff{
                isWaveOffCompensationAvailable = true
                compensations.remove(at: index)
            }
        }
    }
    func cancelRide(cancelReason: String,viewController : UIViewController, delegate: RideCancelledOrUnjoinedDelegate){
        guard let rideObj = ride else { return }
        RideCancelActionProxy.cancelRide(ride: rideObj, cancelReason: cancelReason,isWaveOff: false, viewController: viewController, handler: {
            if self.isWaveOffCompensationAvailable{
                delegate.showWaviedOffScreen()
            }else{
                delegate.rideCancelledBefeoreJoiningOrFeeNotApplied()
            }
        })
    }
    
    
    func unJoinRide(unjoinReason: String,viewController : UIViewController,delegate: RideCancelledOrUnjoinedDelegate){
        RideCancelActionProxy.unjoinParticipant(riderRideId: riderRideId ?? 0, passengerRIdeId: unjoiningUserRideId ?? 0, passengerUserId: unjoiningUserId ?? 0, rideType: unjoiningUserRideType ?? "", cancelReason : unjoinReason,isWaveOff: false, viewController: viewController, completionHandler: {_,_ in
            if !self.compensations.isEmpty && self.compensations[0].isSystemWaveOff{
                delegate.showWaviedOffScreen()
            }else{
               delegate.rideCancelledBefeoreJoiningOrFeeNotApplied()
            }
        })
    }
}
