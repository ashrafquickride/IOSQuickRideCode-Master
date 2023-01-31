//
//  TaxiRideDetailsCache.swift
//  Quickride
//
//  Created by Ashutos on 28/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol CarpoolPassengerDataReceiver {
    func receivedCarpoolPassengerList(carpoolMatches: [MatchingTaxiPassenger])
    func carpoolMatchesRetrivalFailed(responseObject :NSDictionary?,error : NSError?)
}
class TaxiRideDetailsCache {
    
    private static var singleInstance : TaxiRideDetailsCache?
    private var taxiDetailsCache = [Double: TaxiRidePassengerDetails]()
    private var taxiLocationUpdate = [Double: RideParticipantLocation]()
    private var outStationTaxiFareDetails = [Double : PassengerFareBreakUp]()
    private var rentalStopPointListForRides = [Double:[RentalTaxiRideStopPoint]]()
    
    private init() {}
    
    static func getInstance() -> TaxiRideDetailsCache {
        if singleInstance == nil{
            singleInstance = TaxiRideDetailsCache()
        }
        return singleInstance!
    }
    
    func updateTaxiRidePassengerStatus(taxiRidePassengerUpdate: TaxiPassengerStatusUpdate) {
        if let taxiRidePassenger = MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: taxiRidePassengerUpdate.taxiRidePassengerId) {
            getTaxiDetailsFromServer(rideId: taxiRidePassenger.id!) { (restResponse) in
                if restResponse.result != nil{
                    NotificationCenter.default.post(name: .taxiRideStatusReceived, object: nil)
                }
            }
        }else if let taxiRidePassengerId = getTaxiRidePassengerId(taxiRideGroupId: taxiRidePassengerUpdate.taxiRideGroupId){
            getTaxiDetailsFromServer(rideId: taxiRidePassengerId) { (restResponse) in
                if restResponse.result != nil{
                    NotificationCenter.default.post(name: .taxiRideStatusReceived, object: nil)
                }
            }
        }
       
    }
    
    func updateTaxiRideGroupStatus(taxiRideGroupId : Double) {
        if let taxiRidePassengerId = getTaxiRidePassengerId(taxiRideGroupId: taxiRideGroupId){
            getTaxiDetailsFromServer(rideId: taxiRidePassengerId) { (restResponse) in
                if restResponse.result != nil{
                    NotificationCenter.default.post(name: .taxiRideStatusReceived, object: nil)
                }
            }
        
        }
    }
    
    func updateTaxiGroupSuggestionStatus(taxiRideGroupSuggestionUpdate: TaxiRideGroupSuggestionUpdate){
        SharedPreferenceHelper.storeTaxiRideGroupSuggestionUpdate(taxiGroupId: Double(taxiRideGroupSuggestionUpdate.id) ,taxiUpdateSuggestion: taxiRideGroupSuggestionUpdate)
        NotificationCenter.default.post(name: .receivedMaximumFareDriversAvailableSuggestion, object: nil)
    }
    
    func getTaxiRidePassengerId( taxiRideGroupId : Double) -> Double?{
        for taxiRidePassengerDetails in taxiDetailsCache.values {
            if let groupId = taxiRidePassengerDetails.taxiRideGroup?.id ,groupId == taxiRideGroupId{
                return taxiRidePassengerDetails.taxiRidePassenger!.id
            }
        }
        return nil
    }
    
    func getTaxiRideDetailsFromCache(rideId: Double, handler : @escaping (_ response : RestResponse<TaxiRidePassengerDetails>) -> Void) {
        if let taxiRidePassengerDetails = taxiDetailsCache[rideId] {
            handler(RestResponse<TaxiRidePassengerDetails>(result: taxiRidePassengerDetails))
        }else{
            getTaxiDetailsFromServer(rideId: rideId, handler: handler)
        }
    }
    
    func updateTaxiRideDetails(rideId: Double,taxiRidePassengerDetails: TaxiRidePassengerDetails){
        taxiDetailsCache[rideId] = taxiRidePassengerDetails
        MyActiveTaxiRideCache.getInstance().updateTaxiPassengerRideInList(taxiId: rideId, taxiRidePassenger: taxiRidePassengerDetails.taxiRidePassenger!)
    }
    
    func setTaxiRideDetailsToCache(rideId: Double,taxiRidePassengerDetails : TaxiRidePassengerDetails) {
        taxiDetailsCache[rideId] = taxiRidePassengerDetails
    }
    func clearTaxiRidePassengerDetails(rideId: Double) {
        taxiDetailsCache[rideId] = nil
    }
    
   func getTaxiDetailsFromServer(rideId: Double,  handler : @escaping (_ response : RestResponse<TaxiRidePassengerDetails>) -> Void) {
        TaxiPoolRestClient.getTaxiDetailsFromServer(rideId: rideId) { (responseObject, error) in
            let response = RestResponse<TaxiRidePassengerDetails>(responseObject: responseObject, error: error)
            if let taxiRidePassengerDetails = response.result{
                self.taxiDetailsCache[rideId] = taxiRidePassengerDetails
            }
            handler(response)
        }
    }
    
    func updateTaxiLocation(taxiGroupId : Double, rideParticipantLocation : RideParticipantLocation){
        AppDelegate.getAppDelegate().log.debug("Ride participant location \(String(describing: rideParticipantLocation)) Last ride participant location \(String(describing: getLocationUpdateForTaxi(taxiGroupId: taxiGroupId)))")
        guard let lastLocTime = getLocationUpdateForTaxi(taxiGroupId: taxiGroupId)?.lastUpdateTime else {
            taxiLocationUpdate[taxiGroupId] = rideParticipantLocation
            return
        }
        if let lastUpdateTime = rideParticipantLocation.lastUpdateTime,lastUpdateTime > lastLocTime{
            taxiLocationUpdate[taxiGroupId] = rideParticipantLocation
        }
    }
    
    func getLocationUpdateForTaxi(taxiGroupId: Double) -> RideParticipantLocation?{
        return taxiLocationUpdate[taxiGroupId]
    }
    
    func storeOutStationTaxiFareDetails(taxiRideId: Double, outstationTaxiFareDetails : PassengerFareBreakUp){
        outStationTaxiFareDetails[taxiRideId] = outstationTaxiFareDetails
    }
    func getOutStationTaxiFareDetails(taxiRideId: Double) -> PassengerFareBreakUp?{
        return outStationTaxiFareDetails[taxiRideId]
    }
    func getAllRentalStopPoints(taxiGroupId: Double,  handler : @escaping (_ response : [RentalTaxiRideStopPoint]?, ResponseError?, NSError?) -> Void) {
        if let stopPoints = self.rentalStopPointListForRides[taxiGroupId] {
            return handler(stopPoints,nil,nil)
        }
         TaxiPoolRestClient.getAllRentalTaxiRideStopPoint(taxiGroupId: taxiGroupId) { (responseObject, error) in
             let result = RestResponseParser<RentalTaxiRideStopPoint>().parseArray(responseObject: responseObject, error: error)
             if let rentalStopPoints = result.0{
                 self.rentalStopPointListForRides[taxiGroupId] = rentalStopPoints
                 
             }
             handler(result.0,result.1,result.2)
         }
     }
    func storeAllRentalStopPoints(taxiGroupId: Double, rentalStopPointListForRides : [RentalTaxiRideStopPoint]){
        self.rentalStopPointListForRides[taxiGroupId] = rentalStopPointListForRides
    }
}

extension NSNotification.Name {
    static let taxiLocationUpdate = Notification.Name("taxiLocationUpdate")
    static let cancelInstantTrip = Notification.Name("cancelInstantTrip")
    static let scheduleInstantRideLater = Notification.Name("scheduleInstantRideLater")
    static let taxiFareUpadted = Notification.Name("taxiFareUpadted")
    static let upadteTaxiStartTime = Notification.Name("upadteTaxiStartTime")
    static let receivedMaximumFareDriversAvailableSuggestion = Notification.Name("receivedMaximumFareDriversAvailableSuggestion")
    static let payTaxiPendingBill = Notification.Name("payTaxiPendingBill")
    static let taxiBillClearedUpadteUI = Notification.Name("taxiBillClearedUpadteUI")
    static let taxiPeningPaymentFailed = Notification.Name("taxiPeningPaymentFailed")
    static let updateTaxiLiveRideUI = Notification.Name("updateTaxiLiveRideUI")
    static let recievedAddedCashPayments = Notification.Name("recievedAddedCashPayments")
    static let refreshOutStationFareSummary = Notification.Name("refreshOutStationFareSummary")
    static let showTaxiLiveRideNotification = Notification.Name("showTaxiLiveRideNotification")
    static let taxiTripUpdated = Notification.Name("taxiTripUpdated")
    static let passengerCashAdded = Notification.Name("passengerCashAdded")
    static let initiateUPIPayment = Notification.Name("initiateUPIPayment")
    static let showFareSummary = Notification.Name("showFareSummary")
    static let updatePaymentView = Notification.Name("updatePaymentView")
}
