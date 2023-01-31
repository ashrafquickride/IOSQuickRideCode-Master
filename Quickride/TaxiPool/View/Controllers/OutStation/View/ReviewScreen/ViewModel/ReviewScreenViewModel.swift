//
//  ReviewScreenViewModel.swift
//  Quickride
//
//  Created by Ashutos on 19/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct fareDetailsOutStatioonTaxi {
    var key: String?
    var value: String?
    init(key: String?,value: String?) {
        self.key = key
        self.value = value
    }
}

class ReviewScreenViewModel {
    var fareForVehicleClass: FareForVehicleClass?
    var selectedTaxiIndex: Int?
    var journeytype: String?
    var endTime: Double?
    var estimateFareData = [fareDetailsOutStatioonTaxi]()
    var selectedOptionTabIndex = 1
    var isFromLiveRide = false
    var startLocation: String?
    var endLocation: String?
    var startlocation: Location?
    var endlocation: Location?
    var startTime: Double?
    var detailedEstimateFare: DetailedEstimateFare?
    var rideType = TaxiPoolConstants.TRIP_TYPE_OUTSTATION
    var userSelectedTime: Double?
    var isTaxiDetailsFetchingFromServer = true
    var userCouponCode: UserCouponCode?
    var isRequiredToShowInfo = true
    var paymentMode: String?
    var taxiAllocationEngineConfig: TaxiAllocationEngineConfig?
    var advaceAmountPercentageForOutstation = 20
    var selectedRouteId: Double?
    var refRequestId : Double?
    var commuteContactNo: String?
    var commutePassengerName: String?

    static let TOLL_CHARGES = "Toll Charges"
    static let DISTANCE_BASED_FARE = "Base KM Fare"
    static let NIGHT_CHARGES = "Night time allowance"
    static let PARKING_CHARGES = "Parking Charges"
    static let STATE_TAX_CHARGES = "State Tax Charges"
    static let INTERCITY_CHARGES = "Inter State Tax Charges"
    static let SERVICE_CHARGES = "GST"
    static let DRIVER_ALLOWANCE = "Driver Allowance"
    static let EXTRA_KM_FARE = "Extra KM Fare"
    static let EXTRA_TIME_FARE = "Extra Time Fare"
    static let MIN_KM_FARE = "Min KM Fare"
    static let EXTRA_HOUR_FARE = "Extra Hour Fare"
    static let ADVANCE_AMOUNT = "Advance Paid"
    static let RIDE_FARE = "Ride Fare"
    static let ADDITIONAL_DISTANCE_FARE = "Additional Distance Fare"
    static let BASE_FARE = "Base Fare"
    static let PICKUP_FEE = "Pickup Convenience Fee"
    static let Convenience_Fee = "Convenience Fee"
    static let Discount = "Discount"
    static let DurationFare = "Duration Fare"
    static let PLATFORM_FEE_WITH_TAX = "Platform fee with taxes"

    init(fareForVehiceClass: FareForVehicleClass,selectedTaxiIndex: Int?,journeytype: String?,endTime: Double?,isFromLiveRide: Bool,startLocation: Location?,endLocation: Location?, startTime: Double?,selectedRouteId: Double?, refRequestId : Double?, commuteContactNo: String?, commutePassengerName: String?) {
        self.fareForVehicleClass = fareForVehiceClass
        self.selectedTaxiIndex = selectedTaxiIndex
        self.journeytype = journeytype
        self.endTime = endTime
        self.isFromLiveRide = isFromLiveRide
        self.startlocation = startLocation
        self.endlocation = endLocation
        self.startTime = startTime
        self.selectedRouteId = selectedRouteId
        self.refRequestId = refRequestId
        self.advaceAmountPercentageForOutstation = ConfigurationCache.getInstance()?.getClientConfiguration()?.outStationTaxiAdvancePaymentPercentage ?? 20
        self.commuteContactNo = commuteContactNo
        self.commutePassengerName = commutePassengerName
    }

    func getFareBrakeUpData() {
        estimateFareData.removeAll()
        if fareForVehicleClass?.minMeteredFare != 0 {
            let key = ReviewScreenViewModel.DISTANCE_BASED_FARE
            var basefare = 0.0
            if let baseFare = fareForVehicleClass?.baseFare {
                basefare = baseFare
            }
            var value = "₹\(Int(fareForVehicleClass?.minMeteredFare ?? 0.0 + basefare))"
            if fareForVehicleClass?.minMeteredFare != fareForVehicleClass?.maxMeteredFare{
               value = "₹\(Int(fareForVehicleClass?.minMeteredFare ?? 0.0 + basefare)) - ₹\(Int(fareForVehicleClass?.maxMeteredFare ?? 0.0 + basefare))"
            }
            let distanceBasedFare = fareDetailsOutStatioonTaxi(key: key, value: value)
            estimateFareData.append(distanceBasedFare)
        }
        if fareForVehicleClass?.driverBata != 0 {
            let driverAllowance = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.DRIVER_ALLOWANCE, value: "₹\(fareForVehicleClass?.driverBata?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(driverAllowance)
        }
        if fareForVehicleClass?.nightCharges != 0 {
            let nightCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.NIGHT_CHARGES, value: "₹\(fareForVehicleClass?.nightCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(nightCharges)
        }
        if fareForVehicleClass?.tollCharges != 0 {
            let parkingCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.TOLL_CHARGES, value: "₹\(fareForVehicleClass?.tollCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(parkingCharges)
        }

        if fareForVehicleClass?.interStateCharges != 0 {
            let stateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.STATE_TAX_CHARGES, value: "₹\(fareForVehicleClass?.interStateCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(stateTaxCharges)
        }

        if fareForVehicleClass?.minGst != 0 {
            var key = ""
            if fareForVehicleClass?.minGst == fareForVehicleClass?.maxGst {
                key = "₹\(fareForVehicleClass?.minGst?.roundToPlaces(places: 1) ?? 0.0)"
            }else{
                key = "₹\(fareForVehicleClass?.minGst?.roundToPlaces(places: 1) ?? 0.0) - ₹\(fareForVehicleClass?.maxGst?.roundToPlaces(places: 1) ?? 0.0)"
            }
            let serviceTax = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.SERVICE_CHARGES, value: key)
            estimateFareData.append(serviceTax)
        }
        
        var minPlatformFeeWithTax = (fareForVehicleClass?.minPlatformFee ?? 0) + (fareForVehicleClass?.minPlatformFeeTax ?? 0)
        var maxPlatformFeeWithTax = (fareForVehicleClass?.maxPlatformFee ?? 0) + (fareForVehicleClass?.maxPlatformFeeTax ?? 0)

        if minPlatformFeeWithTax != 0 || maxPlatformFeeWithTax != 0 {
            if minPlatformFeeWithTax == maxPlatformFeeWithTax {
                let platformFeeWithTax = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PLATFORM_FEE_WITH_TAX, value: "₹\(maxPlatformFeeWithTax.roundToPlaces(places: 1) )")
                estimateFareData.append(platformFeeWithTax)
            } else {
                let platformFeeWithTax = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PLATFORM_FEE_WITH_TAX, value: "₹\(minPlatformFeeWithTax.roundToPlaces(places: 1) )" + " - " +  "₹\(maxPlatformFeeWithTax.roundToPlaces(places: 1) )")
                estimateFareData.append(platformFeeWithTax)
            }

        }
    }

    func getDataForFacilitiesAndInclusionAndExclusion() -> [TaxiTnCData]{
        if selectedOptionTabIndex == 0{
            return fareForVehicleClass?.taxiTnCSummary?.inclusions ?? []
        }else if selectedOptionTabIndex == 1{
            return fareForVehicleClass?.taxiTnCSummary?.exclusions ?? []
        }else if selectedOptionTabIndex == 2{
            return fareForVehicleClass?.taxiTnCSummary?.facilities ?? []
        }else {
            return fareForVehicleClass?.taxiTnCSummary?.extras ?? []
        }
    }

    func verifyAppliedPromoCode(promoCode: String,handler: @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.applyUserCoupon(userId: UserDataCache.getInstance()?.userId ?? "", appliedCoupon: promoCode, viewController: nil, handler: handler)
    }
    func checkUserHasInSufficieantAmountToBook() -> Bool{
        
        guard let userDataCache = UserDataCache.getInstance(), let linkedWalletBalance =  userDataCache.getDefaultLinkedWallet()?.balance, let accountBalance = UserDataCache.getInstance()?.userAccount?.balance, let minTotalFare = fareForVehicleClass?.minTotalFare else {
            return false
        }
        let totalBalance = linkedWalletBalance + accountBalance
        if rideType == TaxiPoolConstants.TRIP_TYPE_LOCAL{
            return totalBalance < minTotalFare
        }else{
            let requiredAmount = minTotalFare*Double(advaceAmountPercentageForOutstation)/100
            return  totalBalance < requiredAmount
        }
    }
}
