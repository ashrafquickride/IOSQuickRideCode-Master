//
//  TaxiTripPassengerFeedbackViewModel.swift
//  Quickride
//
//  Created by Rajesab on 30/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiTripPassengerFeedbackViewModel {
    var rating = 0.0
    var isFromNotification = false
    var taxiRideInvoice: TaxiRideInvoice?
    var taxiRidePassenger: TaxiRidePassenger?
    var taxiFeedBackNotification: TaxiFeedBackNotification?
    
    init(rating: Double?,taxiRideInvoice: TaxiRideInvoice? ,taxiRidePassenger: TaxiRidePassenger?){
        self.rating = rating ?? 0
        self.taxiRideInvoice = taxiRideInvoice
        self.taxiRidePassenger = taxiRidePassenger
    }
    init(rating: Double?,taxiFeedBackNotification: TaxiFeedBackNotification?, isFromNotification: Bool){
        self.rating = rating ?? 0
        self.taxiFeedBackNotification = taxiFeedBackNotification
        self.isFromNotification = isFromNotification
    }
    init() {}
    
    func submitRatingAndFeedBack(feedback: String?){
        if isFromNotification{
            saveRating(taxiId: Double(taxiFeedBackNotification?.taxiBookingId ?? "") ?? 0.0, taxiGroupId: Double(taxiFeedBackNotification?.taxiGroupId ?? "") ?? 0.0, feedback: feedback)
        } else {
            saveRating(taxiId: taxiRidePassenger?.id ?? 0, taxiGroupId: taxiRidePassenger?.taxiGroupId ?? 0, feedback: feedback)
        }
    }
    private func saveRating(taxiId: Double, taxiGroupId: Double, feedback: String?) {
        TaxiPoolRestClient.postTaxiRideFeedBack(noOfRating: rating, feedBack: feedback, taxiId: taxiId, taxiGroupId: taxiGroupId) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast( Strings.thanks_for_feedback)
                let taxiRideFeedback = Mapper<TaxiRideFeedback>().map(JSONObject: responseObject!["resultData"])
                var userInfo = [String: TaxiRideFeedback]()
                userInfo["taxiRideFeedback"] = taxiRideFeedback
                NotificationCenter.default.post(name: .ratingGivenForDriver, object: nil, userInfo: userInfo)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}

