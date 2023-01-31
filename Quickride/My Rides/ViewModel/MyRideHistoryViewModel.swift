//
//  MyRideHistoryViewModel.swift
//  Quickride
//
//  Created by Bandish Kumar on 26/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol CancelledRideReport{
    func receivedCancelRideReport(ride: Ride,rideCancellationReport: [RideCancellationReport])
}

protocol MyRideHistoryViewModelDelgate: class {
    func receiveClosedRides()
    func receiveError(responseObject: NSDictionary?,error : NSError?)
}

class MyRideHistoryViewModel {
    //MARK: Properties
    var closedRidesHashTable = [(key: String, value: [Ride])]()
    var dropDownDataList: [String] = []
    weak var delegate: MyRideHistoryViewModelDelgate?
    private var taxiRideHandler : ((_ responseError: ResponseError?, _ error: NSError?) -> Void)?
    //MARK: Methods
    func registerForClosedRideDetails() {
        MyClosedRidesCache.getClosedRidesCacheInstance().getClosedRides(myRidesCacheListener: self)
    }
    
    func createHashTableForClosedRides(rides: [Ride]) -> [(key: String, value: [Ride])] {
        for ride in rides {
            let datefromString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)
            ride.rideDate = datefromString ?? ""
        }
        let datesArray = rides.compactMap { $0.rideDate } // return array of date
        var ridesDict = [String: [Ride]]() // required result
        datesArray.forEach {
            let dateKey = $0
            let filterRides = rides.filter { $0.rideDate == dateKey }
            ridesDict[$0] = filterRides
        }
        return sortRideDataBaseOnStartTime(rides: ridesDict)
    }
    
    func sortRideDataBaseOnStartTime(rides: [String: [Ride]]) -> [(key: String, value: [Ride])] {
        let formatter = DateFormatter()
        formatter.dateFormat = DateUtils.DATE_FORMAT_dd_MM_yyyy
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let sortedActiveRidesDict = rides.sorted {
            formatter.date(from: $0.key)?.compare(formatter.date(from: $1.key ) ?? Date()) != .orderedAscending
        }
        return sortedActiveRidesDict
    }
    func getRideCancellationReport(userId: String, ride: Ride,viewController: UIViewController, delegate: CancelledRideReport){
       QuickRideProgressSpinner.startSpinner()
        BillRestClient.getRideCancellationReport(userId: userId, rideId: ride.rideId, rideType: ride.rideType ?? "", targetViewController: viewController, completionHandler:  {(responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
               let rideCancellationReport = Mapper<RideCancellationReport>().mapArray(JSONObject: responseObject!["resultData"]) ?? [RideCancellationReport]()
                delegate.receivedCancelRideReport(ride: ride,rideCancellationReport: rideCancellationReport)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
}
//MARK: MyRidesCacheListener
extension MyRideHistoryViewModel: MyRidesCacheListener {
    func receivedActiveRides(activeRiderRides: [Double : RiderRide], activePassengerRides: [Double : PassengerRide]) {}
    func receiveActiveRegularRides(regularRiderRides: [Double : RegularRiderRide], regularPassengerRides: [Double : RegularPassengerRide]) {}
    func receiveRideDetailInfo(rideDetailInfo: RideDetailInfo) {}
    func onRetrievalFailure(responseError: ResponseError?, error: NSError?) {}
    
    func receiveClosedRides(closedRiderRides: [Double : RiderRide], closedPassengerRides: [Double : PassengerRide]) {
        QuickRideProgressSpinner.stopSpinner()
        var closedRides: [Ride] = []
        closedRidesHashTable.removeAll()
        for rider in closedRiderRides{
            closedRides.append(rider.1)
        }
        for passenger in closedPassengerRides{
            closedRides.append(passenger.1)
        }
        if closedRides.count > 0 {
            closedRides.sort(by: { $0.startTime > $1.startTime})
            closedRidesHashTable  = createHashTableForClosedRides(rides: closedRides)
        }
        delegate?.receiveClosedRides()
    }
}
//MARK: RideObjectUdpateListener - when ride will edit then RideUpdateViewController will listen to this protocol
extension MyRideHistoryViewModel: RideObjectUdpateListener {
    func rideUpdated(ride: Ride) {
        registerForClosedRideDetails()
    }
}

//MARK: RideActionDelegate
extension MyRideHistoryViewModel: RideActionDelegate {
    func rideArchived(ride: Ride) {
        registerForClosedRideDetails()
    }
    func handleFreezeRide(freezeRide: Bool) {}
    func handleEditRoute() {}
}

