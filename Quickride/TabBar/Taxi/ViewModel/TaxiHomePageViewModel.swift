//
//  TaxiHomePageViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 03/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import ObjectMapper

class TaxiHomePageViewModel {

    var currentLocation: Location?
    var pickupLocation: Location?
    var dropLocation: Location?
    var selectedRideType = TaxiPoolConstants.TRIP_TYPE_LOCAL
    var routeId: Double?
    var isRequiredToGetLocationInfoForLatLng = false
    var taxiRideInvoice: TaxiRideInvoice?
    var recentCompletedTaxiRide: TaxiRidePassenger?
    var isRequiredToShowRatingCard = false
    var selectedOptionIndex = 0
    var rentalPackageEstimates: [RentalPackageEstimate]?
    var previousRentalLocationSearched: Location?
    var partnerRecentLocationInfo: [PartnerRecentLocationInfo]?

    // behalf booking
    var behalfBookingPhoneNumber: String?
    var behalfBookingName: String?
    var isRequiredToClearBehalfBookingData = true
    var isCheckedForBehalfBooking = false

    func isStartAndEndValid() ->Bool{
        if pickupLocation?.latitude != 0 && pickupLocation?.longitude != 0 && dropLocation?.latitude != 0 && dropLocation?.longitude != 0 && pickupLocation?.shortAddress?.isEmpty == false && dropLocation?.shortAddress?.isEmpty == false {
            return true
        }
        return false
    }

    func isStartAndEndAddressAreSame() -> Bool {
        AppDelegate.getAppDelegate().log.debug("isStartAndEndAddressAreSame()")
        guard let pickUp = pickupLocation, let drop = dropLocation else {
            return false
        }
        let startPoint = CLLocation(latitude: pickUp.latitude, longitude: pickUp.longitude)
        let endPoint = CLLocation(latitude: drop.latitude, longitude: drop.longitude)
        return startPoint.distance(from: endPoint) <= MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES
    }

    func getCompletedTaxiTripData(complitionHandler: @escaping (_ result: Bool) -> ()) {
        let closedTaxiRides = MyActiveTaxiRideCache.getInstance().getClosedTaxiRidesFromCache()
        var completedTaxiTrips = closedTaxiRides.filter {
            $0.status == TaxiRidePassenger.STATUS_COMPLETED
        }
        completedTaxiTrips.sort(by: { $0.startTimeMs! > $1.startTimeMs! })
        if !completedTaxiTrips.isEmpty {
            getFeedBack(taxiRide: completedTaxiTrips[0], complitionHandler: complitionHandler)
        }
    }

    func getFeedBack(taxiRide: TaxiRidePassenger, complitionHandler: @escaping (_ result: Bool) -> ()) {
        self.recentCompletedTaxiRide = taxiRide
        TaxiPoolRestClient.getTaxiRideFeedBack(taxiId: StringUtils.getStringFromDouble(decimalNumber: taxiRide.id), taxiGroupId: StringUtils.getStringFromDouble(decimalNumber: taxiRide.taxiGroupId)) { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if Mapper<TaxiRideFeedback>().map(JSONObject: responseObject!["resultData"]) == nil {
                    self?.getTaxiTripInvoice(taxiPassengerRide: taxiRide) { [weak self] (taxiRideInvoice) in
                        if let taxiInvoice = taxiRideInvoice {
                            self?.taxiRideInvoice = taxiInvoice
                            self?.isRequiredToShowRatingCard = true
                            complitionHandler(true)
                        }
                    }
                }
            }
        }
    }

    func getTaxiTripInvoice(taxiPassengerRide: TaxiRidePassenger?, completionHandler: @escaping (_ taxiRideInvoice: TaxiRideInvoice?) -> ()) {
        if let id = taxiPassengerRide?.id, id != 0 {
            TaxiPoolRestClient.getTaxiPoolInvoice(refId: id) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let taxiRideInvoice = Mapper<TaxiRideInvoice>().map(JSONObject: responseObject!["resultData"])
                    completionHandler(taxiRideInvoice)
                }
            }
        }
    }

    func getRentalPackages(complitionHandler: @escaping (_ responseError: ResponseError?, _ error: NSError?) -> ()) {
        if previousRentalLocationSearched == pickupLocation {
            complitionHandler(nil, nil)
        }
        let userId = UserDataCache.getCurrentUserId()
        TaxiPoolRestClient.getRentalPackages(userId: userId, startAddress: pickupLocation?.address ?? "", startLatitude: pickupLocation?.latitude ?? 0, startLongitude: pickupLocation?.longitude ?? 0, startCity: pickupLocation?.city ?? "", startTime: nil) { (responseObject, error) in
            TaxiUtils.sendTaxiSearchedEvent(taxiRidePassengerId: 0, tripType: TaxiPoolConstants.TRIP_TYPE_RENTAL, fromAddress: self.pickupLocation?.address, toAddress: nil, startTime: 0)
            let result = RestResponseParser<RentalPackageConfig>().parseArray(responseObject: responseObject, error: error)
            if let rentalEstimates = result.0 {
                var dict = [String: RentalPackageEstimate]()

                for item in rentalEstimates {
                    guard let pkgDistance = item.pkgDistanceInKm, let pkgDuration = item.pkgDurationInMins else {
                        continue
                    }
                    let key = "\(pkgDistance) : \(pkgDuration)"
                    if let fromDict = dict[key] {
                        fromDict.rentalPackageConfigList.append(item)
                    } else {
                        let rentalEstimate = RentalPackageEstimate(packageDistance: pkgDistance, packageDuration: pkgDuration)
                        rentalEstimate.rentalPackageConfigList.append(item)
                        dict[key] = rentalEstimate
                    }
                }
                self.rentalPackageEstimates = Array(dict.values)
                self.rentalPackageEstimates?.sort(by: sortMessge)

                func sortMessge(first: RentalPackageEstimate, second: RentalPackageEstimate) -> Bool {
                    return (first.packageDistance < second.packageDistance)
                }
            }
            self.previousRentalLocationSearched = self.pickupLocation
            complitionHandler(result.1, result.2)
        }
    }

    func getNearbyTaxi(location : Location,complitionHandler: @escaping(_ responseError: ResponseError?,_ error: NSError?)-> ()){
        TaxiPoolRestClient.getNearbyTaxi(startLatitude: location.latitude, startLongitude: location.longitude, taxiType: nil , maxNoOfTaxiToShow: 5, maxDistance: 5){ (responseObject, error) in
            let result = RestResponseParser<PartnerRecentLocationInfo>().parseArray(responseObject: responseObject, error: error)
            if  result.1 != nil || result.2 != nil {
                complitionHandler(result.1, result.2)
                return
            }
            if let partnerRecentLocationInfo = result.0{
                self.partnerRecentLocationInfo = partnerRecentLocationInfo
                complitionHandler(nil,nil)
            }
        }
    }
}
