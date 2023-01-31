//
//  MyRidesDetailViewModel.swift
//  Quickride
//
//  Created by Bandish Kumar on 29/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol MyRidesDetailViewModelDelegate: class {
    func receiveActiveRide()
    func receiveErrorForMyRides(responseError: ResponseError?, responseObject: NSDictionary?,error : NSError?)
}

class MyRidesDetailViewModel {
    
    var selectedRide: Ride?
    var regularRides: [RegularRide] = []
    var activeRidesHashTable = [String : [Ride]]()
    weak var rideModelDelegate: MyRidesDetailViewModelDelegate?
    var matchedUserDict = [Int: [MatchedUser]]()
    var priceWaiverNeedsToShow = false
    var overFlowMenuActionsList: [String] = []
    private var handler : ((_ responseError: ResponseError?, _ error: NSError?) -> Void)?
    static let TODAYS_RIDES = "TODAYS_RIDES"
    static let NOT_TODAYS_RIDES = "NOT_TODAYS_RIDES"
    
    func getRidePreference() -> RidePreferences {
        return UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences ?? RidePreferences()
    }
    
    func addListner() {
        MyActiveRidesCache.getRidesCacheInstance()?.addRideUpdateListener(listener: self,key: MyActiveRidesCache.MyRidesDetailViewController_key)
        MyRegularRidesCache.getInstance().addRideUpdateListener(rideId: 0, listener: self)
        if MyActiveRidesCache.RECURRING_RIDES_CREATED {
            MyActiveRidesCache.RECURRING_RIDES_CREATED = false
        }
        reloadRides()
    }
    
    func removeListner() {
        MyActiveRidesCache.getRidesCacheInstance()?.removeRideUpdateListener(key: MyActiveRidesCache.MyRidesDetailViewController_key)
        MyRegularRidesCache.singleInstance?.removeRideUpdateListenre(rideId: 0)
    }
    
    func reloadRides() {
        MyActiveRidesCache.getRidesCacheInstance()?.getActiveRides(listener: self)
        MyRegularRidesCache.getInstance().getRegularRides(listener: self)
    }
    
    func archiveToDate(date : NSDate?) {
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.archiveAllRides(date: date, userId: (QRSessionManager.getInstance()?.getUserId())!, viewController: nil, handler: { [weak self] (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                MyClosedRidesCache.getClosedRidesCacheInstance().clearArchiveRides(date: date)
                self?.reloadRides()
            } else {
                self?.rideModelDelegate?.receiveErrorForMyRides(responseError: nil, responseObject: responseObject, error: error)
            }
        })
    }
    
    func createHashTableForActiveRides(rides: [Ride]) -> [String : [Ride]] {
        let todaysDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getCurrentTimeInMillis(), timeFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)
        var todaysRidesList = [Ride]()
        var notTodaysRidesList = [Ride]()
        let sortedRides = rides.sorted{($0.startTime < $1.startTime)}
        for ride in sortedRides {
            let datefromString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)
            if todaysDate == datefromString {
                todaysRidesList.append(ride)
            }else {
                notTodaysRidesList.append(ride)
            }
        }
        if todaysRidesList.count > 0 {
            activeRidesHashTable[MyRidesDetailViewModel.TODAYS_RIDES] = todaysRidesList
        }
        if notTodaysRidesList.count > 0 {
            activeRidesHashTable[MyRidesDetailViewModel.NOT_TODAYS_RIDES] = notTodaysRidesList
        }
        return activeRidesHashTable
    }
}
//MARK: MyRidesCacheListener
extension MyRidesDetailViewModel: MyRidesCacheListener {

    func receivedActiveRides(activeRiderRides: [Double : RiderRide], activePassengerRides: [Double : PassengerRide]) {
        var activeRides: [Ride] = []
        activeRidesHashTable.removeAll()
        for rider in activeRiderRides{
            activeRides.append(rider.1)
        }
        for passenger in activePassengerRides{
            if passenger.value.status != TaxiShareRide.RIDE_STATUS_PENDING_TAXI_JOIN {
                activeRides.append(passenger.1)
            }
        }
        
            activeRides.sort(by: { $0.startTime < $1.startTime})
            activeRidesHashTable  = createHashTableForActiveRides(rides: activeRides)
        rideModelDelegate?.receiveActiveRide()
        QuickRideProgressSpinner.stopSpinner()
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    func receiveActiveRegularRides(regularRiderRides: [Double : RegularRiderRide], regularPassengerRides: [Double : RegularPassengerRide]) {
        QuickRideProgressSpinner.stopSpinner()
        regularRides.removeAll()
        for rider in regularRiderRides{
            regularRides.append(rider.1)
        }
        for passenger in regularPassengerRides{
            regularRides.append(passenger.1)
        }
        if regularRides.count > 0 {
            regularRides.sort(by: { $0.startTime < $1.startTime})
        }
    }
    
    func receiveClosedRides(closedRiderRides: [Double : RiderRide], closedPassengerRides: [Double : PassengerRide]) {}
    func receiveRideDetailInfo(rideDetailInfo: RideDetailInfo) { }
    
    func onRetrievalFailure(responseError: ResponseError?, error: NSError?) {
        QuickRideProgressSpinner.stopSpinner()
        if let _ = responseError {
            rideModelDelegate?.receiveErrorForMyRides(responseError: responseError, responseObject: nil, error: nil)
        } else if let error = error {
            rideModelDelegate?.receiveErrorForMyRides(responseError: nil, responseObject: nil, error: error)
        }
    }
}
//MARK: RideUpdateListener : When User will Edit the ride then this protocol keep track of that
extension MyRidesDetailViewModel: RideUpdateListener {
    func participantStatusUpdated(rideStatus: RideStatus) {
        reloadRides()
    }
    
    func participantRideRescheduled(rideStatus: RideStatus) {
        reloadRides()
    }
    func participantUpdated(rideParticipant: RideParticipant) {}
    func refreshRideView() { }
    func handleUnfreezeRide() {
        reloadRides()
    }
}
//MARK: RegularRideUpdateListener
extension MyRidesDetailViewModel: RegularRideUpdateListener { }
//MARK: RideActionDelegate
extension MyRidesDetailViewModel: RideActionDelegate {
    func rideArchived(ride: Ride) {
        reloadRides()
    }
    
    func handleFreezeRide(freezeRide: Bool) {
        reloadRides()
    }
    
    func handleEditRoute() {}
}
//MARK: RideActionComplete
extension MyRidesDetailViewModel {
    func rideActionCompleted(status: String) {
        reloadRides()
    }
    func rideActionFailed(status: String, error: ResponseError?) {
        rideModelDelegate?.receiveErrorForMyRides(responseError: error, responseObject: nil, error: nil)
    }
}

//MARK: RouteSelectionDelegate
extension MyRidesDetailViewModel: RouteSelectionDelegate {
    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.updateRideRoute(rideId: selectedRide!.rideId, rideType: selectedRide!.rideType!, rideRoute: route, viewController: nil) { [weak self] (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let updatedRoute = Mapper<RideRoute>().map(JSONString: responseObject!["resultData"] as! String)
                
                if updatedRoute != nil{
                    MyActiveRidesCache.getRidesCacheInstance()?.updateRideRoute(rideRoute: updatedRoute!, rideId: self?.selectedRide!.rideId ?? 0, rideType: self?.selectedRide!.rideType ?? "")
                }
            }else{
                self?.rideModelDelegate?.receiveErrorForMyRides(responseError: nil, responseObject: responseObject, error: error)
            }
        }
    }
    
    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {}
}
//MARK: RideObjectUdpateListener - when ride will edit then RideUpdateViewController will listen to this protocol
extension MyRidesDetailViewModel: RideObjectUdpateListener {
    func rideUpdated(ride: Ride) {
        reloadRides()
    }
}
