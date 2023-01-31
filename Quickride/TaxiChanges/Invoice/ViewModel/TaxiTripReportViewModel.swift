//
//  TaxiTripReportViewModel.swift
//  Quickride
//
//  Created by HK on 27/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation
import Polyline

class TaxiTripReportViewModel{
    
    var taxiRideInvoice: TaxiRideInvoice?
    var taxiRide: TaxiRidePassenger?
    var taxiRideFeedBack: TaxiRideFeedback?
    var isFeedBackLoaded = false
    var rating = 0.0
    var outstationTaxiFareDetails: PassengerFareBreakUp?
    var cancelTaxiRideInvoices = [CancelTaxiRideInvoice]()
    var estimateFareData = [fareDetailsOutStatioonTaxi]()
    var isrequiredtoshowFareView = false
    
    // Rental
    var rentalStopPointList: [RentalTaxiRideStopPoint]?
    
    init(taxiRideInvoice: TaxiRideInvoice?,taxiRide: TaxiRidePassenger?,cancelTaxiRideInvoice: [CancelTaxiRideInvoice]) {
        self.taxiRideInvoice = taxiRideInvoice
        self.taxiRide = taxiRide
        self.cancelTaxiRideInvoices = cancelTaxiRideInvoice
    }
    
    init() {}
    func getFeedBack(complitionHandler: @escaping(_ result: Bool)-> ()) {
        if let taxiRideInvoice = taxiRideInvoice,  let taxiGroupId = taxiRideInvoice.sourceRefId,let taxiRideId = taxiRideInvoice.refId {
            TaxiPoolRestClient.getTaxiRideFeedBack(taxiId: taxiRideId, taxiGroupId: taxiGroupId) { [weak self] (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self?.taxiRideFeedBack = Mapper<TaxiRideFeedback>().map(JSONObject: responseObject!["resultData"])
                    self?.isFeedBackLoaded = true
                    complitionHandler(true)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                    complitionHandler(false)
                }
            }
        }
    }
    
    //MARK: SendInvoice
    func sendInvoiceToPassenger() {
        let userProfile = UserDataCache.getInstance()?.userProfile
        NotificationCenter.default.post(name: .startSpinner, object: nil)
        TaxiPoolRestClient.sendInvoiceToPassengerMail(taxiInvoiceId: taxiRideInvoice?.id ?? 0, userId: taxiRideInvoice?.fromUserId ?? 0, completionHandler: { (responseObject, error) in
            NotificationCenter.default.post(name: .stopSpinner, object: nil)
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast(String(format: Strings.invoice_sent_to_communication_mail, userProfile?.emailForCommunication ?? ""))
            }else{
                var userInfo = [String: Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        })
    }
    func getExtraChargesAddedByDriverAndPassenger(complitionHandler: @escaping(_ result: Bool)-> ()){
        TaxiPoolRestClient.getFareBreakUpForTripReport(taxiRideId: taxiRide?.id ?? 0, userId: UserDataCache.getInstance()?.userId ?? "") {  (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let outstationTaxiFareDetails = Mapper<PassengerFareBreakUp>().map(JSONObject: responseObject!["resultData"]){
                    self.outstationTaxiFareDetails = outstationTaxiFareDetails
                    complitionHandler(true)
                }
            }
        }
    }
    
    func getAllRentalStopPoints(handler : @escaping(_ responseError: ResponseError?,_ error: NSError? )-> ()) {
        TaxiRideDetailsCache.getInstance().getAllRentalStopPoints(taxiGroupId: taxiRide?.taxiGroupId ?? 0) { response, responseError, error in
            if let rentalStopPoints = response{
                self.rentalStopPointList = rentalStopPoints;
            }
            handler(responseError,error)
        }
    }
    
    func getRentalPolyline() -> String?{
        guard let rentalStopPoints = rentalStopPointList, !rentalStopPoints.isEmpty else {
            return nil
        }
        var totalCoordinates = [CLLocationCoordinate2D]()
        for item in rentalStopPoints {
            if let polyline = item.actualTravelledPath, !polyline.isEmpty, let coordinates = LocationClientUtils.decodePolylineAndReturnLatlng(polyline), item != rentalStopPoints.last{
                totalCoordinates.append(contentsOf: coordinates)
            }
        }
        if let polyline = rentalStopPoints.last?.scheduledTravelledPath, !polyline.isEmpty, let coordinates = LocationClientUtils.decodePolylineAndReturnLatlng(polyline){
            totalCoordinates.append(contentsOf: coordinates)
        }
        if !totalCoordinates.isEmpty{
            return encodeCoordinates(totalCoordinates)
        }
        return nil

    }
    
    
   func getFareBrakeUpDataForRental(){
        estimateFareData.removeAll()
        guard var estimateData = taxiRideInvoice else { return }
        if estimateData.baseKmFare != 0 {
            let key = ReviewScreenViewModel.BASE_FARE
            let baseFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(estimateData.baseFare?.roundToPlaces(places: 2) ?? 0.0)")
            estimateFareData.append(baseFare)
        }
        
        if estimateData.extraTravelledKm != 0{
            let key = ReviewScreenViewModel.EXTRA_KM_FARE + " - \(estimateData.extraTravelledKm?.roundToPlaces(places: 1) ?? 0.0) km"
            let extraKmFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(estimateData.extraTravelledFare?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(extraKmFare)
        }
        
        if estimateData.extraTravelTimeFare != 0 {
            let key = ReviewScreenViewModel.EXTRA_TIME_FARE + " - \(estimateData.extraTravelTime?.roundToPlaces(places: 1) ?? 0.0) min"
            let extraTravelTimeFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(Int(estimateData.extraTravelTimeFare ?? 0.0))")
            estimateFareData.append(extraTravelTimeFare)
        }
        if estimateData.couponDiscount != 0{
            let discount = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.Discount, value: "- ₹\(estimateData.couponDiscount)")
            estimateFareData.append(discount)
        }
        if estimateData.extraPickUpCharges != 0{
            let extraPickupFee = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PICKUP_FEE, value: "₹\(estimateData.extraPickUpCharges.roundToPlaces(places: 1) )")
            estimateFareData.append(extraPickupFee)
        }
        
        let extraAmount = (estimateData.extraTravelledFare ?? 0) + (estimateData.extraTravelTimeFare ?? 0)
        var value = (estimateData.baseFare ?? 0) + (estimateData.driverAllowance ?? 0) + extraAmount
        value += estimateData.extraPickUpCharges
        value -= estimateData.couponDiscount
        
        let ridefare = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.RIDE_FARE, value: "₹\(value.roundToPlaces(places: 1) )")
        estimateFareData.append(ridefare)
        
        if estimateData.tax != 0 {
            let serviceTax = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.SERVICE_CHARGES, value: "₹\(estimateData.tax?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(serviceTax)
        }
        var platformFeeWithTax = estimateData.platformFee + estimateData.platformFeeTax
        if platformFeeWithTax > 0 {
            let key = "₹\(platformFeeWithTax.roundToPlaces(places: 1))"
            let platformFeeWithTaxes = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PLATFORM_FEE_WITH_TAX, value: key)
            estimateFareData.append(platformFeeWithTaxes)
        }

        if estimateData.tollCharges != 0 {
            let parkingCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.TOLL_CHARGES, value: "₹\(estimateData.tollCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(parkingCharges)
        }
        
        if estimateData.nightCharges != 0 {
            let nightCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.NIGHT_CHARGES, value: "₹\(estimateData.nightCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(nightCharges)
        }
        
        if estimateData.stateTaxCharges != 0 {
            let stateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.STATE_TAX_CHARGES, value: "₹\(estimateData.stateTaxCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(stateTaxCharges)
        }
        if estimateData.interStateTaxCharges != 0 {
            let interStateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.INTERCITY_CHARGES, value: "₹\(estimateData.interStateTaxCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(interStateTaxCharges)
        }
        
        if estimateData.amount != 0 {
            let totalVendorFare = fareDetailsOutStatioonTaxi(key: "Total Fare", value: "₹\(Int(estimateData.amount ?? 0.0))")
            estimateFareData.append(totalVendorFare)
        }
    }
    
    func getFareBrakeUpData() {
        estimateFareData.removeAll()
        guard var estimateData = taxiRideInvoice else { return }
        
        if estimateData.distanceBasedFare != 0 && estimateData.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            let key = ReviewScreenViewModel.DISTANCE_BASED_FARE
            let distanceBasedFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(estimateData.distanceBasedFare?.roundToPlaces(places: 2) ?? 0.0)")
            estimateFareData.append(distanceBasedFare)
        }
        if estimateData.driverAllowance != 0 {
            let driverAllowance = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.DRIVER_ALLOWANCE, value: "₹\(estimateData.driverAllowance?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(driverAllowance)
        }
        
        if estimateData.extraTravelledFare != 0{
            let key = ReviewScreenViewModel.EXTRA_KM_FARE + " - ₹\(estimateData.extraKmFare?.roundToPlaces(places: 1) ?? 0.0)"
            let extraKmFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(estimateData.extraTravelledFare?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(extraKmFare)
        }
        if estimateData.couponDiscount != 0{
            let discount = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.Discount, value: "- ₹\(estimateData.couponDiscount)")
            estimateFareData.append(discount)
        }
        
        if estimateData.extraPickUpCharges != 0{
            let extraPickupFee = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PICKUP_FEE, value: "₹\(estimateData.extraPickUpCharges.roundToPlaces(places: 1) )")
            estimateFareData.append(extraPickupFee)
        }
        
        var tripFare = 0.0
        var convenienceFee = estimateData.scheduleConvenienceFee + estimateData.scheduleConvenienceFeeTax
        if estimateData.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            tripFare = (estimateData.distanceBasedFare ?? 0) + (estimateData.driverAllowance ?? 0) + (estimateData.extraTravelledFare ?? 0)
            tripFare += (estimateData.extraPickUpCharges )
            tripFare -= (estimateData.couponDiscount )
        }else {
            tripFare = (estimateData.netAmountPaid ?? 0) - convenienceFee - estimateData.extraPickUpCharges - (estimateData.tollCharges ?? 0)
        }
        
        if convenienceFee != 0{
            let convenience = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.Convenience_Fee, value: "₹\(convenienceFee.roundToPlaces(places: 1) )")
            estimateFareData.append(convenience)
        }
        
        if tripFare > 0 {
            let ridefare = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.RIDE_FARE, value: "₹\(tripFare.roundToPlaces(places: 1) )")
            estimateFareData.append(ridefare)
        }
        
        if estimateData.tax != 0 {
            let serviceTax = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.SERVICE_CHARGES, value: "₹\(estimateData.tax?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(serviceTax)
        }
        var platformFeeWithTax = estimateData.platformFee + estimateData.platformFeeTax
        if platformFeeWithTax > 0 {
            let key = "₹\(platformFeeWithTax.roundToPlaces(places: 1))"
            let platformFeeWithTaxes = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PLATFORM_FEE_WITH_TAX, value: key)
            estimateFareData.append(platformFeeWithTaxes)
        }
        if estimateData.tollCharges != 0 {
            let parkingCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.TOLL_CHARGES, value: "₹\(estimateData.tollCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(parkingCharges)
        }
        
        if estimateData.nightCharges != 0 {
            let nightCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.NIGHT_CHARGES, value: "₹\(estimateData.nightCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(nightCharges)
        }
        
        if estimateData.stateTaxCharges != 0 {
            let stateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.STATE_TAX_CHARGES, value: "₹\(estimateData.stateTaxCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(stateTaxCharges)
        }
        if estimateData.interStateTaxCharges != 0 {
            let interStateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.INTERCITY_CHARGES, value: "₹\(estimateData.interStateTaxCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(interStateTaxCharges)
        }
        
        if estimateData.amount != 0 {
            let totalVendorFare = fareDetailsOutStatioonTaxi(key: "Total Fare", value: "₹\(Int(estimateData.amount ?? 0.0))")
            estimateFareData.append(totalVendorFare)
        }
    }
}
