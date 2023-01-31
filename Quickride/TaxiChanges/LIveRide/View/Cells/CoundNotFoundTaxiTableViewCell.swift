//
//  CoundNotFoundTaxiTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/06/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit


class CoundNotFoundTaxiTableViewCell: UITableViewCell {
    
    var taxiridePassengerDetails: TaxiRidePassengerDetails?
    var fareForVehicleClass: FareForVehicleClass?
    var taxiRideUpdateSuggestion: TaxiRideGroupSuggestionUpdate?
    var isFromRental: Bool?
    
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var retryTextBtn: UILabel!
    
    func initialiseView(taxiridePassenger: TaxiRidePassengerDetails?, isFromRental: Bool) {
        self.taxiridePassengerDetails = taxiridePassenger
        self.isFromRental = isFromRental
        if isFromRental == true {
            retryBtn.isHidden = true
            retryTextBtn.isHidden = true
        }
        
        guard let taxiRidePassenger = self.taxiridePassengerDetails?.taxiRidePassenger else { return }
        TaxiUtils.getAvailableVehicleClass(startTime: taxiRidePassenger.pickupTimeMs ?? 0, startAddress: taxiRidePassenger.startAddress, startLatitude: taxiRidePassenger.startLat!, startLongitude: taxiRidePassenger.startLng!, endLatitude: taxiRidePassenger.endLat!, endLongitude: taxiRidePassenger.endLng!, endAddress: taxiRidePassenger.endAddress, journeyType: taxiRidePassenger.journeyType!, routeId: taxiRidePassenger.routeId) {[weak self] detailedEstimatedFare, responseError, error in
            
            if let detailedEstimatedFare = detailedEstimatedFare, let fareForVehicleClass = TaxiUtils.checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: detailedEstimatedFare, taxiVehicleCategory: taxiRidePassenger.taxiVehicleCategory!) {
                
                self?.fareForVehicleClass = fareForVehicleClass
            }else{
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
            }
        }
    }
    
    
    func rescheduleTaxiRide(fixedFareId: String){
        TaxiPoolRestClient.rescheduleTaxiRide(userId: UserDataCache.getInstance()?.userId ?? "", taxiRidePassengerId: taxiridePassengerDetails?.taxiRidePassenger?.id ?? 0, startTime: DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: 20), fixedFareId: fixedFareId ){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject!["result"] as! String == "SUCCESS"{
                let result = RestResponseParser<TaxiRidePassengerDetails>().parse(responseObject: responseObject, error: error)
                if let taxiRidePassengerDetails = result.0 {
                    self.taxiridePassengerDetails?.taxiRidePassenger = taxiRidePassengerDetails.taxiRidePassenger
                    guard let taxiridePassengerDetails = self.taxiridePassengerDetails else {
                        return
                    }
                    
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self.taxiridePassengerDetails?.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: taxiridePassengerDetails)
                    NotificationCenter.default.post(name: .upadteTaxiStartTime, object: nil)
                    self.parentViewController?.navigationController?.popViewController(animated: false)
                    
                }
            }
        }
    }
    
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        rescheduleTaxiRide(fixedFareId: fareForVehicleClass?.fixedFareId ?? " ")
    }
    
    
    
    
    
}
