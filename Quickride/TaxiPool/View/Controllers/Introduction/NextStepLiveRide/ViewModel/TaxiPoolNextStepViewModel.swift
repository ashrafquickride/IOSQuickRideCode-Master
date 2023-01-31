//
//  TaxiPoolNextStepViewModel.swift
//  Quickride
//
//  Created by Ashutos on 9/23/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class TaxiPoolNextStepViewModel {
    var taxiRidePassengerDetails: TaxiRidePassengerDetails?
    var taxiShareHeaders = [String]()
    var taxiShareSubTitles = [String]()
    var exsclusiveHeader = [Strings.exclusive_taxi_booked,Strings.taxi_alloted,Strings.taxi_started]
    var sharingHeaders = [Strings.taxi_joined,Strings.taxi_confirmed,Strings.taxi_alloted,Strings.taxi_started]
    var exclusiveSubTitle = ["", Strings.taxi_exsclusive_allot_subtitle,Strings.exclusive_taxi_started_sub]
    var sharingSubTitle = ["","",Strings.driver_details,Strings.taxi_started_sub]
    
    init(taxiRidePassengerDetails: TaxiRidePassengerDetails?) {
        self.taxiRidePassengerDetails = taxiRidePassengerDetails
    }
    
    func getNumberOfCells() -> Int {
        guard let taxiRidePassengerDetails = taxiRidePassengerDetails else { return 0 }
        taxiShareHeaders = []
        if taxiRidePassengerDetails.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            taxiShareHeaders = exsclusiveHeader
            taxiShareSubTitles = exclusiveSubTitle
        }else{
            taxiShareHeaders = sharingHeaders
            taxiShareSubTitles = sharingSubTitle
        }
        return taxiShareHeaders.count
    }
    
}
