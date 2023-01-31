//
//  TaxiPoolCancelReasonViewModel.swift
//  Quickride
//
//  Created by Ashutos on 7/20/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias rideCancellationTaxiPoolCompletionHandler = (_ cancelReason :String?) -> Void

class TaxiPoolCancelReasonViewModel {
    
    var rideCancellationTaxiPoolCompletionHandler : rideCancellationTaxiPoolCompletionHandler?
    var cancelReasonList = [String]()
    var taxiRide: TaxiRidePassenger?
    var selectedIndex = -1
    var cancelReason: String?
    var isRequiredToShowFeeMayApplyView = true
    var maxCancellationFee = 0
    
    init(taxiRide: TaxiRidePassenger?,completionHandler : rideCancellationTaxiPoolCompletionHandler?) {
        rideCancellationTaxiPoolCompletionHandler = completionHandler
        self.taxiRide = taxiRide
    }
    
    func prepareCancellationReasons(){
        TaxiRideDetailsCache.getInstance().getTaxiRideDetailsFromCache(rideId: taxiRide?.id ?? 0) { (restResponse) in
            if let taxiRidePassengerDetails = restResponse.result{
                if self.taxiRide?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE{
                    if taxiRidePassengerDetails.isTaxiReached(){
                        self.cancelReasonList = Strings.taxi_Cancellation_After_Reached_pickup_Point
                    }else if taxiRidePassengerDetails.isTaxiAllotted(){
                        self.cancelReasonList = Strings.taxi_Cancellation_After_allocation
                    }else{
                        self.isRequiredToShowFeeMayApplyView = false
                        self.cancelReasonList = Strings.taxi_Cancellation_before_allocation
                        self.cancelReasonList.insert(String(format: Strings.not_yet_allocated, arguments: [self.taxiRide?.taxiType ?? ""]), at: 0)
                    }
                }else{
                    if taxiRidePassengerDetails.isTaxiReached(){
                        self.cancelReasonList = Strings.sharing_taxi_Cancellation_After_Reached_pickup_Point
                    }else if taxiRidePassengerDetails.isTaxiAllotted(){
                        self.cancelReasonList = [Strings.driver_refused_to_com_pickup, Strings.driver_asked_me_to_cancel, Strings.driver_not_reachable, Strings.driver_not_moving_towards_pickup_point, Strings.ETA_too_long, Strings.my_plan_changed, Strings.higher_fare, Strings.booked_another_companys_taxi, Strings.other_reason]
                    }else if taxiRidePassengerDetails.isTaxiConfirmed(){
                        self.cancelReasonList = Strings.sharing_taxi_cancellation_before_allocation
                    }else{
                        self.isRequiredToShowFeeMayApplyView = false
                        self.cancelReasonList = Strings.sharing_taxi_Cancellation_before_confirm
                    }
                }
                
            }
        }
    }
    func getMaxCancellationFee(handler: @escaping(_ result: Int)->()){
        TaxiPoolRestClient.getMaxCancellationFee(taxiRideId: taxiRide?.id ?? 0, userId: UserDataCache.getInstance()?.userId ?? ""){  (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let maxFee = responseObject!["resultData"] as? Int ?? 0
                handler(maxFee)
            }
        }
    }
}
