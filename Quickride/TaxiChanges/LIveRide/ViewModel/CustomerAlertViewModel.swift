//
//  CustomerAlertViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

typealias customerReasonsCompletionHandler = (_ customerReason :String?, _ type: String?) -> Void

class CustomerAlertViewModel {
    
    var customerReasonsList = [String]()
    var selectedIndex = -1
    var customerReason: String?
    var customerReasonsCompletionHandler: customerReasonsCompletionHandler?
    var riskType: String?
    var isTaxiStarted: Bool?
    var rideRiskAssessment: [RideRiskAssessment]?
    var taxiRidePassenger: TaxiRidePassengerDetails?
    var taxiGroupId: Double?
    
    init(){
        
    }
    
    
    init(taxiGroupId: Double, rideRiskAssessment: [RideRiskAssessment]){
        self.taxiGroupId = taxiGroupId
        self.rideRiskAssessment = rideRiskAssessment
    }
    
    
    init(taxiRidePassenger: TaxiRidePassengerDetails?, isTaxiStarted: Bool?, completionHandler: customerReasonsCompletionHandler?){
        self.taxiRidePassenger = taxiRidePassenger
        self.customerReasonsCompletionHandler = completionHandler
        self.isTaxiStarted = isTaxiStarted
    }
    
    
    func prepareCustomerReasons(){
        if isTaxiStarted == true {
            self.customerReasonsList = Strings.customer_Reasons_for_after_riskride
        } else {
            self.customerReasonsList = Strings.customer_Reasons_for_before_riskride
        }
    }
    
    func getResloveRiskReasons(complition: @escaping(_ result: Bool)->()){
        TaxiSharingRestClient.getCustomerResolveRisk(taxiGroupId: self.taxiGroupId ?? 0) { (responseObject,error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                
                let result = RestResponseParser<RideRiskAssessment>().parseArray(responseObject: responseObject, error: error)
                self.rideRiskAssessment = result.0
                complition(true)
            }
        }
    }
    
    func customerResolveRiskResons(rideRiskAssessment: RideRiskAssessment, complition: @escaping(_ result: Bool)->()){
        let jsondata : String = Mapper().toJSONString(rideRiskAssessment , prettyPrint: true)!
        TaxiSharingRestClient.sendResolveRiskSolved(resolveRisk: jsondata){ (responseObject,error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                complition(true)
            }
            complition(false)
        }
    }
}


