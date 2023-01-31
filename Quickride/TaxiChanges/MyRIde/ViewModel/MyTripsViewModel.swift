//
//  MyTripsViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class MyTripsViewModel{
    
    var activeTrips = [(key: String, value: [TaxiRidePassenger])]()
    
    func createHashTableForActiveRides(){
        var activeTaxiRides = MyActiveTaxiRideCache.getInstance().getActiveTaxiRides()
        activeTaxiRides.sort(by: { $0.startTimeMs ?? 0 < $1.startTimeMs ?? 0})
        for taxiTrip in activeTaxiRides {
            let datefromString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiTrip.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)
            taxiTrip.rideDate = datefromString ?? ""
        }
        let datesArray = activeTaxiRides.compactMap { $0.rideDate } // return array of date
        var ridesDict = [String: [TaxiRidePassenger]]() // required result
        datesArray.forEach {
            let dateKey = $0
            let filterRides = activeTaxiRides.filter { $0.rideDate == dateKey }
            ridesDict[$0] = filterRides
        }
        sortRideDataBaseOnStartTime(rides: ridesDict)
    }
    
    func sortRideDataBaseOnStartTime(rides: [String: [TaxiRidePassenger]]){
        let formatter = DateFormatter()
        formatter.dateFormat = DateUtils.DATE_FORMAT_dd_MM_yyyy
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let sortedActiveRidesDict = rides.sorted {
            formatter.date(from: $0.key)?.compare(formatter.date(from: $1.key ) ?? Date()) != .orderedDescending
        }
        print(sortedActiveRidesDict)
        activeTrips = sortedActiveRidesDict
    }
}
