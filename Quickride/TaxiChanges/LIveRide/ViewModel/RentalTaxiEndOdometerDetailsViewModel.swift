//
//  RentalTaxiEndOdometerDetailsViewModel.swift
//  Quickride
//
//  Created by Rajesab on 08/09/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RentalTaxiEndOdometerDetailsViewModel {

    var taxiRidePassengerDetails: TaxiRidePassengerDetails!
    var outstationTaxiFareDetails: PassengerFareBreakUp!
    var rentalTaxiOdometerDetails: RentalTaxiOdometerDetails!
    var estimateFareData = [fareDetailsOutStatioonTaxi]()
    var rentalPackageDistance: String?
    var rentalPackageDuration: String?
    var isrequiredtoshowFareView = false
    init(){
        
    }
    
    init(taxiRidePassengerDetails: TaxiRidePassengerDetails,outstationTaxiFareDetails: PassengerFareBreakUp,rentalTaxiOdometerDetails: RentalTaxiOdometerDetails){
        self.taxiRidePassengerDetails = taxiRidePassengerDetails
        self.outstationTaxiFareDetails = outstationTaxiFareDetails
        self.rentalTaxiOdometerDetails = rentalTaxiOdometerDetails
        self.rentalPackageDistance = String(format: Strings.distance_in_km, arguments: [(rentalTaxiOdometerDetails.kmsTravelled ?? "")])
        let tripDuration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1:  DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: 3) , time2: taxiRidePassengerDetails.taxiRidePassenger?.actualStartTimeMs)
        self.rentalPackageDuration = TaxiUtils.getDurationDisplay(duration: tripDuration)
    }
    
    func getFareBrakeUpData() {
        guard var finalFareDetails = outstationTaxiFareDetails.finalFareDetails else { return }
        estimateFareData.removeAll()
        
        if finalFareDetails.baseFare != 0{
            let distanceBasedFare = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.BASE_FARE, value: "₹\(finalFareDetails.baseFare)")
            estimateFareData.append(distanceBasedFare)
        }
        
        if finalFareDetails.distanceBasedFare != 0 {
            let distanceBasedFare = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.ADDITIONAL_DISTANCE_FARE, value: "₹\(finalFareDetails.distanceBasedFare.roundToPlaces(places: 1))")
            estimateFareData.append(distanceBasedFare)
        }
        
        if finalFareDetails.durationBasedFare != 0 {
            let durationBasedFare = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.DurationFare, value: "₹\(finalFareDetails.durationBasedFare.roundToPlaces(places: 1) )")
            estimateFareData.append(durationBasedFare)
        }
        
        if finalFareDetails.driverAllowance != 0 {
            let driverAllowance = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.DRIVER_ALLOWANCE, value: "₹\(finalFareDetails.driverAllowance.roundToPlaces(places: 1) )")
            estimateFareData.append(driverAllowance)
        }
        
        if finalFareDetails.extraTravelledKm != 0{
            let key = ReviewScreenViewModel.EXTRA_KM_FARE
            let extraKmFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(finalFareDetails.extraTravelledFare.roundToPlaces(places: 1) )")
            estimateFareData.append(extraKmFare)
        }
        
        if finalFareDetails.extraTimeFare != 0{
            let key = ReviewScreenViewModel.EXTRA_TIME_FARE
            let extraKmFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(finalFareDetails.extraTimeFare.roundToPlaces(places: 1) )")
            estimateFareData.append(extraKmFare)
        }
        
        if finalFareDetails.nightCharges != 0 {
            let nightCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.NIGHT_CHARGES, value: "₹\(finalFareDetails.nightCharges.roundToPlaces(places: 1) )")
            estimateFareData.append(nightCharges)
        }
        
        if outstationTaxiFareDetails.finalFareDetails?.extraPickUpCharges != 0{
            let extraPickupFee = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PICKUP_FEE, value: "₹\(outstationTaxiFareDetails.finalFareDetails?.extraPickUpCharges.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(extraPickupFee)
        }
        
        var convenienceFee = finalFareDetails.scheduleConvenienceFee + finalFareDetails.scheduleConvenienceFeeTax
        if convenienceFee != 0{
            let convenience = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.Convenience_Fee, value: "₹\(convenienceFee.roundToPlaces(places: 1) )")
            estimateFareData.append(convenience)
        }
        var rideFare = (finalFareDetails.distanceBasedFare) + (finalFareDetails.driverAllowance) + (finalFareDetails.nightCharges) + (finalFareDetails.baseFare) + convenienceFee + (finalFareDetails.extraPickUpCharges) + (finalFareDetails.durationBasedFare) + (finalFareDetails.extraTravelledFare) + (finalFareDetails.extraTimeFare)
        let nightCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.RIDE_FARE, value: "₹\(rideFare.roundToPlaces(places: 1))")
        estimateFareData.append(nightCharges)
        
        if finalFareDetails.tollCharges != 0 {
            let parkingCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.TOLL_CHARGES, value: "₹\(finalFareDetails.tollCharges.roundToPlaces(places: 1) )")
            estimateFareData.append(parkingCharges)
        }
        
        if finalFareDetails.parkingCharges != 0 {
            let parkingCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PARKING_CHARGES, value: "₹\(finalFareDetails.parkingCharges.roundToPlaces(places: 1) )")
            estimateFareData.append(parkingCharges)
        }

        if finalFareDetails.interStateTaxCharges != 0 {
            let stateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.STATE_TAX_CHARGES, value: "₹\(finalFareDetails.interStateTaxCharges.roundToPlaces(places: 1) )")
            estimateFareData.append(stateTaxCharges)
        }
        
        if finalFareDetails.serviceTax != 0 {
            let key = "₹\(finalFareDetails.serviceTax.roundToPlaces(places: 1))"
            let serviceTax = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.SERVICE_CHARGES, value: key)
            estimateFareData.append(serviceTax)
        }
        
        var platformFeeWithTax = finalFareDetails.platformFee + finalFareDetails.platformFeeTax
        if platformFeeWithTax > 0 {
            let key = "₹\(platformFeeWithTax.roundToPlaces(places: 1))"
            let platformFeeWithTaxes = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PLATFORM_FEE_WITH_TAX, value: key)
           estimateFareData.append(platformFeeWithTaxes)
        }
    }
    
}
