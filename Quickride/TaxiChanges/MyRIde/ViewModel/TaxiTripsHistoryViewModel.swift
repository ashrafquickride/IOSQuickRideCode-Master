//
//  TaxiTripsHistoryViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 05/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiTripsHistoryViewModel{
    
    //MARK: Properties
    var closedTripsHashTable = [(key: String, value: [TaxiRidePassenger])]()
    
    func createHashTableForClosedRides(){
        let closedTaxiRides = MyActiveTaxiRideCache.getInstance().getClosedTaxiRidesFromCache()
        for taxiRidePassenger in closedTaxiRides {
            let datefromString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassenger.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)
            taxiRidePassenger.rideDate = datefromString ?? ""
        }
        let datesArray = closedTaxiRides.compactMap { $0.rideDate } // return array of date
        var ridesDict = [String: [TaxiRidePassenger]]() // required result
        datesArray.forEach {
            let dateKey = $0
            let filterRides = closedTaxiRides.filter { $0.rideDate == dateKey }
            ridesDict[$0] = filterRides
        }
        sortRideDataBaseOnStartTime(rides: ridesDict)
    }
    
    func sortRideDataBaseOnStartTime(rides: [String: [TaxiRidePassenger]]){
        let formatter = DateFormatter()
        formatter.dateFormat = DateUtils.DATE_FORMAT_dd_MM_yyyy
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let sortedActiveRidesDict = rides.sorted {
            formatter.date(from: $0.key)?.compare(formatter.date(from: $1.key ) ?? Date()) != .orderedAscending
        }
        closedTripsHashTable = sortedActiveRidesDict
    }
    
    func getTaxiTripInvoice(taxiPassengerRide: TaxiRidePassenger?,completionHandler: @escaping(_ taxiRideInvoice: TaxiRideInvoice?)->()) {
        if let id = taxiPassengerRide?.id, id != 0 {
            QuickRideProgressSpinner.startSpinner()
            TaxiPoolRestClient.getTaxiPoolInvoice(refId: id) {(responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let taxiRideInvoice = Mapper<TaxiRideInvoice>().map(JSONObject: responseObject!["resultData"])
                    completionHandler(taxiRideInvoice)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                }
            }
        }
    }
    func getCanceTaxiTripInvoice(taxiPassengerRide: TaxiRidePassenger?,completionHandler: @escaping(_ cancelTaxiRideInvoice: [CancelTaxiRideInvoice]?)->()) {
        if let id = taxiPassengerRide?.id, id != 0 {
            QuickRideProgressSpinner.startSpinner()
            TaxiPoolRestClient.getCancelTripInvoice(taxiRideId: id , userId: UserDataCache.getInstance()?.userId ?? "") {  (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let cancelTaxiRideInvoice = Mapper<CancelTaxiRideInvoice>().mapArray(JSONObject: responseObject!["resultData"])
                    completionHandler(cancelTaxiRideInvoice)
                }else{
                    completionHandler(nil)
                }
            }
        }
    }
}
