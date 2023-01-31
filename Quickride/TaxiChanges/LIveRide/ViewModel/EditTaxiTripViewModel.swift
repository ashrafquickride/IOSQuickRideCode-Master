//
//  EditTaxiTripViewModel.swift
//  Quickride
//
//  Created by HK on 02/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EditTaxiTripViewModel{
    
    var editTaxiTripComplitionHandler: editTaxiTripComplitionHandler?
    var taxiRide: TaxiRidePassenger?
    var routeId: Double?
    var isFromStartTime = true
    var isUpdateRequired = false
    
    init(taxiRide: TaxiRidePassenger,editTaxiTripComplitionHandler: @escaping editTaxiTripComplitionHandler) {
        self.taxiRide = taxiRide
        self.editTaxiTripComplitionHandler = editTaxiTripComplitionHandler
        
    }
    
    init() {}
    
    func updateTaxiTrip(fixedFareId: String){
        let taxiPassengerRide = MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: taxiRide?.id ?? 0)
        var startTimeMs: Double?
        if taxiPassengerRide?.startTimeMs != taxiRide?.startTimeMs, taxiRide?.status != TaxiRidePassenger.STATUS_STARTED {
            startTimeMs = taxiRide?.startTimeMs
        } else {
            startTimeMs = nil
        }
        var endTime: Double?
        if taxiPassengerRide?.dropTimeMs != taxiRide?.dropTimeMs {
            endTime = taxiRide?.dropTimeMs
        }
        var endLat: Double?
        var endLng: Double?
        var endAddress: String?
        if taxiPassengerRide?.endLat != taxiRide?.endLat && taxiPassengerRide?.endLng != taxiRide?.endLng{
            endLat = taxiRide?.endLat
            endLng = taxiRide?.endLng
            endAddress = taxiRide?.endAddress
        }
        TaxiPoolRestClient.updateTaxiTrip(startTime: startTimeMs,expectedEndTime: endTime, endLatitude: endLat, endLongitude: endLng, endAddress: endAddress, fixedfareID: fixedFareId, taxiRidePassengerId: taxiRide?.id ?? 0,startLatitude: nil,startLongitude: nil,startAddress: nil,pickupNote: nil, selectedRouteId: routeId ) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let response = RestResponse<TaxiRidePassengerDetails>(responseObject: responseObject, error: error)
                if let taxiRidePassengerDetails = response.result{
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self.taxiRide?.id ?? 0, taxiRidePassengerDetails: taxiRidePassengerDetails)
                    var userInfo = [String : Any]()
                    userInfo["taxiRidePassengerDetails"] = taxiRidePassengerDetails
                    NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil, userInfo: userInfo)
                }
                NotificationCenter.default.post(name: .stopSpinner, object: nil)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func getAvailableVehicleClass(complition: @escaping(_ result: FareForVehicleClass?)->()){
        guard let taxiRidePassenger = taxiRide else { return }
        TaxiPoolRestClient.getAvailableTaxiDetails(startTime: taxiRidePassenger.startTimeMs ?? 0, expectedEndTime: taxiRidePassenger.dropTimeMs, startAddress: taxiRidePassenger.startAddress ?? "", startLatitude: taxiRidePassenger.startLat ?? 0, startLongitude: taxiRidePassenger.startLng ?? 0 , endLatitude: taxiRidePassenger.endLat ?? 0 , endLongitude: taxiRidePassenger.endLng ?? 0, endAddress: taxiRidePassenger.endAddress ?? "",journeyType: taxiRidePassenger.journeyType,routeId: taxiRidePassenger.routeId) { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let detailedEstimateFare = Mapper<DetailedEstimateFare>().map(JSONObject: responseObject!["resultData"])
                let fareForVehicleData = self?.checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: detailedEstimateFare)
                TaxiUtils.sendTaxiSearchedEvent(taxiRidePassengerId: taxiRidePassenger.id ?? 0,tripType: taxiRidePassenger.tripType ?? "", fromAddress: taxiRidePassenger.startAddress, toAddress: taxiRidePassenger.endAddress, startTime: taxiRidePassenger.startTimeMs ?? 0)
                
                complition(fareForVehicleData)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: DetailedEstimateFare?) -> FareForVehicleClass?{
        var fareForVehicleData: FareForVehicleClass?
        for detailedEstimateFare in detailedEstimateFares?.fareForTaxis ?? []{
            for fareForVehicleClass in detailedEstimateFare.fares{
                if fareForVehicleClass.vehicleClass == taxiRide?.taxiVehicleCategory{
                    fareForVehicleData = fareForVehicleClass
                    break
                }
            }
        }
        return fareForVehicleData
    }
    
}
