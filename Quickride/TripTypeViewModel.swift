//
//  TripTypeViewModel.swift
//  Quickride
//
//  Created by Rajesab on 24/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias handleTaxiBookingForSomeOneHandler = (_ contactName: String?, _ contactNumber: String?) -> Void

class  TripTypeViewModel {
    
    var completionHandler: handleTaxiBookingForSomeOneHandler?
    var behalfBookingContactDetailsList = [TaxiBehalfBookingContactDetails]()
    var selectedIndex: Int?
    
    init(){
        
    }
    
    init(behalfBookingName: String?, behalfBookingPhoneNumber: String?,  completionHandler : handleTaxiBookingForSomeOneHandler?){
        self.completionHandler = completionHandler
        self.behalfBookingContactDetailsList = SharedPreferenceHelper.getBehalfBookingContactDetails()
        if behalfBookingPhoneNumber != nil {
            self.selectedIndex = 0
        }
    }
}
struct TaxiBehalfBookingContactDetails: Mappable {
    var behalfBookingName: String?
    var behalfBookingPhoneNumber: String?
    init(behalfBookingName: String, behalfBookingPhoneNumber: String){
        self.behalfBookingName = behalfBookingName
        self.behalfBookingPhoneNumber = behalfBookingPhoneNumber
    }
    
    init?(map: Map) {
        
    }

    mutating func mapping(map: Map) {
        self.behalfBookingName <- map["behalfBookingName"]
        self.behalfBookingPhoneNumber <- map["behalfBookingPhoneNumber"]
    }
}
