//
//  TaxiPoolLiveRideViewModel.swift
//  Quickride
//
//  Created by Ashutos on 25/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import Foundation
import ObjectMapper
import CoreLocation
import Polyline
import ObjectMapper

class TaxiPoolLiveRideViewModel {
    var taxiRidePassengerDetails: TaxiRidePassengerDetails?
    //MARK: OfferList
    var finalOfferList: [Offer] = []
    var taxiRideID: Double?
    var timer : Timer?
    var taxiRideUpdateSuggestion: TaxiRideGroupSuggestionUpdate?
    var rescheduleTimeGap = 11 //min
    var selectedTabIndex = 0
    var outstationTaxiFareDetails: PassengerFareBreakUp?
    var driverCancelledInfoShown = false
    var etaResponse: ETAResponse?
    var linkedWalletBalance: LinkedWalletBalance?
    var isRequiredToShowFareSummary = false
    var isRequiredToShowInfo = false
    var selectedOptionTabIndex = 0
    var carpoolMatchesForTaxipool = [MatchingTaxiPassenger]()
    var estimateFareData = [fareDetailsOutStatioonTaxi]()
    var taxipoolOutgoingInvitations = [TaxiPoolInvite]()
    var carpoolDrivers = [MatchedRider]()
    var paymentMode: String?
    var taxiRidePassenger: TaxiRidePassenger?
    var partnerRecentLocationInfo: [PartnerRecentLocationInfo]?
    var isrequiredtoshowCancelview = false
    var isrequiredtoshowFareView = false
    var taxiAllocationEngineConfig: TaxiAllocationEngineConfig?
    var fareForVehicleClass: FareForVehicleClass?
    var  allowtedtime = 0
    var showDateDataList = [Bool]()
    var isRequiredToScrollDownRentaStopPointList = true
    var rideRiskAssessment: [RideRiskAssessment]?
    var wayPoints = [Location]()

    var isRequiredToInitiatePayment: Bool?

    // Rental
    var rentalStopPointList: [RentalTaxiRideStopPoint]?
    var currentSpeed = 0.0

    init(taxiRideID: Double) {
        self.taxiRideID = taxiRideID
    }

    init(taxiRideID: Double, isRequiredToInitiatePayment: Bool?){
        self.taxiRideID = taxiRideID
        self.isRequiredToInitiatePayment = isRequiredToInitiatePayment
    }

    init() {}

    func getRidedateAndTime() -> String{
        let rideDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A) ?? ""
         return rideDate
    }

    func gettaxiRidePassengerDetails(handler : @escaping (_ responseError: ResponseError?, _ error: NSError?) -> Void) {
        TaxiRideDetailsCache.getInstance().getTaxiRideDetailsFromCache(rideId: self.taxiRideID ?? 0.0) { (restResponse) in
            if restResponse.result != nil {
                self.taxiRidePassengerDetails = restResponse.result
                self.paymentMode = self.taxiRidePassengerDetails?.taxiRidePassenger?.paymentMode
                self.getWayPointsOfRoute()
                handler(nil,nil)
            }else {
                handler(restResponse.responseError,restResponse.error)
            }
        }

    }

    func getTaxiRideFromServer(handler : @escaping (_ responseError: ResponseError?, _ error: NSError?) -> Void){ //Using only when user tap on refersh ride getting new from server
        TaxiRideDetailsCache.getInstance().getTaxiDetailsFromServer(rideId: taxiRideID ?? 0.0) { (restResponse) in
            if restResponse.result != nil {
                self.taxiRidePassengerDetails = restResponse.result
                self.getWayPointsOfRoute()
                handler(nil,nil)
            }else {
                handler(restResponse.responseError,restResponse.error)
            }
        }
    }

    func getBillAndUpdate(handler: @escaping(_ response: RestResponse<TaxiRideInvoice>) -> Void ) {
        if let id = taxiRidePassengerDetails?.taxiRidePassenger?.id, id != 0 {
            TaxiPoolRestClient.getTaxiPoolInvoice(refId: id) { (responseObject, error) in
                let response = RestResponse<TaxiRideInvoice>(responseObject: responseObject, error: error)
                if response.result?.couponCode != nil{ // After complition of trip if user applied any coupon code we have to refersh in home page
                    SharedPreferenceHelper.setTaxiOfferCoupon(coupon: nil)
                    RideManagementUtils.getSystemCouponsForReferralAndRole(viewController: nil)
                }
                handler(response)
            }
        }
    }

    func getCancelTaxiRideInvoice(taxiRideId: Double,completionHandler: @escaping(_ cancelTaxiRideInvoice: [CancelTaxiRideInvoice]?)->()){
        QuickRideProgressSpinner.startSpinner()
        TaxiPoolRestClient.getCancelTripInvoice(taxiRideId: taxiRideId, userId: UserDataCache.getInstance()?.userId ?? "") {  (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let cancelTaxiRideInvoice = Mapper<CancelTaxiRideInvoice>().mapArray(JSONObject: responseObject!["resultData"])
                completionHandler(cancelTaxiRideInvoice)
            }else{
                completionHandler(nil)
            }
        }
    }

    func cancelTaxiRide(taxiId: Double, cancellationReason: String, complition: @escaping(_ result: Bool)->()) {
        QuickRideProgressSpinner.startSpinner()
        TaxiPoolRestClient.cancelTaxiRide(taxiId: taxiId, cancellationReason: cancellationReason) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                TaxiUtils.sendCancelEvent(taxiRidePassenger: self.taxiRidePassengerDetails?.taxiRidePassenger, cancelReason: cancellationReason)
                self.updateTaxiRideCacheOnCancelOrComplete()
                complition(true)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                complition(false)
            }
        }
    }



    func getFareforVehicleClass(taxiridePassengerDetails: TaxiRidePassengerDetails?, complition: @escaping(_ result: Bool)->()){
    self.taxiRidePassengerDetails = taxiridePassengerDetails
        guard let taxiRidePassenger = taxiridePassengerDetails?.taxiRidePassenger else { return }
    TaxiUtils.getAvailableVehicleClass(startTime: taxiRidePassenger.pickupTimeMs ?? 0, startAddress: taxiRidePassenger.startAddress, startLatitude: taxiRidePassenger.startLat!, startLongitude: taxiRidePassenger.startLng!, endLatitude: taxiRidePassenger.endLat!, endLongitude: taxiRidePassenger.endLng!, endAddress: taxiRidePassenger.endAddress, journeyType: taxiRidePassenger.journeyType!, routeId: taxiRidePassenger.routeId) {[weak self] detailedEstimatedFare, responseError, error in

        if let detailedEstimatedFare = detailedEstimatedFare, let fareForVehicleClass = TaxiUtils.checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: detailedEstimatedFare, taxiVehicleCategory: taxiRidePassenger.taxiVehicleCategory!) {

            self?.fareForVehicleClass = fareForVehicleClass
            complition(true)
        }else{
            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
        }
    }

    }

    func toRescheduleTaxitime(complition: @escaping(_ result: Bool)->()) {
        TaxiPoolRestClient.rescheduleTaxiRide(userId: UserDataCache.getInstance()?.userId ?? "", taxiRidePassengerId: taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0, startTime: DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: 20), fixedFareId: fareForVehicleClass?.fixedFareId ?? "" ){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject!["result"] as! String == "SUCCESS"{
                let result = RestResponseParser<TaxiRidePassengerDetails>().parse(responseObject: responseObject, error: error)
                if let taxiRidePassengerInformation = result.0 {
                    self.taxiRidePassengerDetails?.taxiRidePassenger = taxiRidePassengerInformation.taxiRidePassenger
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self.taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: taxiRidePassengerInformation)

                    NotificationCenter.default.post(name: .upadteTaxiStartTime, object: nil)
                    complition(true)
                }
            }
        }
    }


    func rentalRescheduleTaxitime(taxiridePassengerDetails: TaxiRidePassengerDetails?, complition: @escaping(_ result: Bool)->()){
        guard let taxiRidePassengerId = taxiridePassengerDetails?.taxiRidePassenger?.id else { return }
        TaxiPoolRestClient.updateTaxiTrip(startTime: DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: 20), expectedEndTime: nil, endLatitude: nil, endLongitude: nil, endAddress: nil, fixedfareID: nil, taxiRidePassengerId: taxiRidePassengerId, startLatitude: nil, startLongitude: nil, startAddress: nil, pickupNote: nil, selectedRouteId: nil) { (responseObject, error) in
            let result = RestResponseParser<TaxiRidePassengerDetails>().parse(responseObject: responseObject, error: error)
            if let taxiRidePassengerDetails = result.0{
                self.taxiRidePassengerDetails = taxiRidePassengerDetails
                TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: taxiRidePassengerId, taxiRidePassengerDetails: taxiRidePassengerDetails)
                var userInfo = [String : Any]()
                userInfo["taxiRidePassengerDetails"] = taxiRidePassengerDetails
                NotificationCenter.default.post(name: .taxiTripUpdated, object: nil)
                complition(true)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }

    func  getAvailableDriverDetailsTime(complition: @escaping(_ response: Bool)->()){

        TaxiSharingRestClient.getDriverDetailsShareTime(longitude: taxiRidePassengerDetails?.taxiRidePassenger?.startLng ?? 0, latitude: taxiRidePassengerDetails?.taxiRidePassenger?.startLat ?? 0){ (responseObject,error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let result = RestResponseParser<TaxiAllocationEngineConfig>().parse(responseObject: responseObject, error: error)
                if  result.1 != nil || result.2 != nil {
                    complition(false)
                    return
                }
                if let taxiAllocationEngineConfig = result.0{
                    self.getallocationTime()
                    self.taxiAllocationEngineConfig = taxiAllocationEngineConfig
                    complition(true)
                }

            }
        }
    }

     func getTotalFareOfTrip() -> Double{
        var totalFare = outstationTaxiFareDetails?.initialFare ?? 0
        guard let taxiTripExtraFareDetails = outstationTaxiFareDetails?.taxiTripExtraFareDetails else { return totalFare }
        for driverExtraFareDetails in taxiTripExtraFareDetails {
            if driverExtraFareDetails.status != TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
                totalFare += driverExtraFareDetails.amount
            }
        }
        return totalFare
    }


    func getallocationTime() -> Int {
        guard let taxiAllocationEngineConfig = taxiAllocationEngineConfig, let taxiRideGroup = taxiRidePassengerDetails?.taxiRideGroup else {
            return 0
        }

        var allocationStartTime = 0
        if TaxiPoolConstants.ROUTE_CATEGORY_CITY_TO_AIRPORT == taxiRideGroup.routeCategory {
            allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeTripStartToTriggerAllocationForC2ATrip ?? 0
        } else if TaxiPoolConstants.ROUTE_CATEGORY_AIRPORT_TO_CITY == taxiRideGroup.routeCategory {
            allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeTripStartToTriggerAllocationForA2CTrip ?? 0
        } else if TaxiPoolConstants.TRIP_TYPE_LOCAL == taxiRideGroup.tripType {

            if TaxiPoolConstants.TAXI_TYPE_AUTO == taxiRideGroup.taxiType {
                if taxiRideGroup.distance ?? 0 <= 10.0 {
                    allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeAutoTripStartToTriggerAllocationForUpto10Km ?? 0
                } else if taxiRideGroup.distance ?? 0 >= 10.0 && taxiRideGroup.distance ?? 0 <= 20.0 {
                    allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeAutoTripStartToTriggerAllocationFor10To20Km ?? 0

                } else if taxiRideGroup.distance ?? 0 >= 20.0 && taxiRideGroup.distance ?? 0 <= 35.0  {
                    allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeAutoTripStartToTriggerAllocationFor20To35Km ?? 0
                } else {
                    allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeAutoTripStartToTriggerAllocationForAbove35Km ?? 0
                }
            } else if TaxiPoolConstants.TAXI_TYPE_BIKE == taxiRideGroup.taxiType {
                if taxiRideGroup.distance ?? 0 <= 10.0 {
                    allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeBikeTripStartToTriggerAllocationForUpto10Km ?? 0
                } else if taxiRideGroup.distance ?? 0 >= 10.0 && taxiRideGroup.distance ?? 0 <= 20.0 {
                    allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeBikeTripStartToTriggerAllocationFor10To20Km ?? 0

                } else if taxiRideGroup.distance ?? 0 >= 20.0 && taxiRideGroup.distance ?? 0 <= 35.0 {
                    allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeBikeTripStartToTriggerAllocationFor20To35Km ?? 0
                } else {
                    allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeBikeTripStartToTriggerAllocationForAbove35Km ?? 0
                }
            } else {
                if TaxiPoolConstants.TAXI_TYPE_CAR == taxiRideGroup.taxiType {
                    if taxiRideGroup.distance ?? 0 <= 10.0 {
                        allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeTripStartToTriggerAllocationForUpto10KmTrip ?? 0
                    } else if taxiRideGroup.distance ?? 0 >= 10.0 && taxiRideGroup.distance ?? 0 <= 20.0 {
                        allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeTripStartToTriggerAllocationFor10To20KmTrip ?? 0

                    } else if taxiRideGroup.distance ?? 0 >= 20.0 && taxiRideGroup.distance ?? 0 <= 35.0 {
                        allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeTripStartToTriggerAllocationFor20To35KmTrip ?? 0
                    } else {
                        allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeBikeTripStartToTriggerAllocationForAbove35Km ?? 0
                    }
                }
            }

        } else if TaxiPoolConstants.TRIP_TYPE_OUTSTATION == taxiRideGroup.tripType {
            if TaxiPoolConstants.TAXI_TYPE_AUTO == taxiRideGroup.taxiType {
                allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeAutoTripStartToTriggerAllocationForOutstation ?? 0
            } else if TaxiPoolConstants.TAXI_TYPE_BIKE == taxiRideGroup.taxiType {
                allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeBikeTripStartToTriggerAllocationForOutstation ?? 0
            } else {
                allocationStartTime = taxiAllocationEngineConfig.thresholdTimeBeforeTripStartToTriggerAllocationForOutstationTrip ?? 0
            }
        }
        if allocationStartTime > 5{
            allocationStartTime = allocationStartTime - 5
        }
        return allocationStartTime

    }

    var stopRefresh = false
    func startRefreshTaxiRideLocation(isRefreshClicked: Bool) {
        stopRefresh = false
        refreshTaxiRideLocation(isRefreshClicked: isRefreshClicked)
    }

    func stopRefreshTaxiRideLocation() {
        stopRefresh = true
    }


    private func refreshTaxiRideLocation(isRefreshClicked: Bool = false) {
        if stopRefresh {
            return
        }
        guard let taxiRidePassenger = getTaxiRidePassenger(), let taxiGroup = getTaxiRideGroup() else {
            return
        }
        let diffInMillis = taxiRidePassenger.pickupTimeMs! - NSDate().getTimeStamp()

        if diffInMillis > 20 * 60 * 1000 && taxiGroup.partnerId < 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+10) {
                self.refreshTaxiRideLocation()
            }
            return
        }
        if isTaxiLocationUpdateExpired() || isRefreshClicked {
            getTaxiLocationFromServer()
        }

        DispatchQueue.main.asyncAfter(deadline: .now()+10) {
            self.refreshTaxiRideLocation()
        }
    }
    private func isTaxiLocationUpdateExpired() -> Bool{
        guard  let taxiGroup = getTaxiRideGroup() else {
            return false
        }
        guard let taxiLocation = TaxiRideDetailsCache.getInstance().getLocationUpdateForTaxi(taxiGroupId: taxiGroup.id!) else {
            return true
        }
        if  taxiLocation.lastUpdateTime == nil || taxiLocation.lastUpdateTime == 0 {
            return true
        }
        return NSDate().getTimeStamp() - taxiLocation.lastUpdateTime!  > 10*1000
    }
    private func getTaxiLocationFromServer() {
        guard  let taxiGroupId = getTaxiRideGroup()?.id else {
            return
        }
        TaxiPoolRestClient.getLocationUpdate(taxiGroupId: taxiGroupId) {  (responseObject, error) in
            AppDelegate.getAppDelegate().log.debug("Taxi location updates through api resoponse - \(responseObject) Error - \(error)")
            if let rideParticipantLocation = RestResponse<RideParticipantLocation>(responseObject: responseObject, error: error).result{

                if let prev = TaxiRideDetailsCache.getInstance().getLocationUpdateForTaxi(taxiGroupId: taxiGroupId) {

                    self.currentSpeed =  self.calculateSpeed(prev: prev, current: rideParticipantLocation)
                }
                TaxiRideDetailsCache.getInstance().updateTaxiLocation(taxiGroupId: taxiGroupId, rideParticipantLocation: rideParticipantLocation)
                NotificationCenter.default.post(name: .taxiLocationUpdate, object: nil)
            }
        }
    }

    private func calculateSpeed(prev: RideParticipantLocation, current : RideParticipantLocation) -> Double {
        let distance = CLLocation(latitude: prev.latitude!, longitude: prev.longitude!).distance(from: CLLocation(latitude: current.latitude!, longitude: current.longitude!))
        let timeDiffInMills = current.lastUpdateTime! - prev.lastUpdateTime!
        if distance <= 0 || timeDiffInMills <= 0 {
            return self.currentSpeed
        }
        let mps = distance*1000/timeDiffInMills
        return mps*3.6
    }

    func updateTaxiRideCacheOnCancelOrComplete() {
        guard let taxiRidePassenger = taxiRidePassengerDetails?.taxiRidePassenger else { return }
        MyActiveTaxiRideCache.getInstance().removeRideFromActiveTaxiCache(taxiId: taxiRidePassenger.id ?? 0.0)
        MyActiveTaxiRideCache.getInstance().addNewClosedTaxiRides(taxiRidePassenger: taxiRidePassenger)
        TaxiRideDetailsCache.getInstance().clearTaxiRidePassengerDetails(rideId: taxiRidePassenger.id ?? 0.0)

    }
    func checkCurrentTripIsInstantOrNot() -> Bool{
        if taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() != TaxiPoolConstants.SHARE_TYPE_ANY_SHARING && DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs, time2: NSDate().getTimeStamp()) < 10,!isTaxiAllotted(){
            return true
        }else{
            return false
        }
    }

    func checkInstantRideIsNotImmediate() -> Bool{
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs, time2: NSDate().getTimeStamp()) < clientConfiguration.taxiPoolInstantBookingThresholdTimeInMins{
            return true
        }else{
            return false
        }
    }

    func isRequiredToShowInstantRideCancellation() -> Bool{
        var creationTimeMs = 0.0
        if let taxiUpdate = taxiRideUpdateSuggestion,taxiUpdate.isSuggestionShowed{
            creationTimeMs = Double(taxiUpdate.updatedTimeMs)
        }else{
            creationTimeMs = taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs ?? 0
        }
        let timeDiff = DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: NSDate().getTimeStamp(), time2: creationTimeMs)
        if timeDiff > 2 {

            return true
        }else{
            return false
        }
    }


    func getInstantRideStatus() -> (String,String){
        var creationTimeMs = 0.0
        if let taxiUpdate = taxiRideUpdateSuggestion,taxiUpdate.isSuggestionShowed{
            creationTimeMs = Double(taxiUpdate.updatedTimeMs)
        }else{
            creationTimeMs = taxiRidePassengerDetails?.taxiRidePassenger?.creationTimeMs ?? 0
        }
        let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInSecs(time1: NSDate().getTimeStamp(), time2: creationTimeMs)
        if taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
            return instantAutoAllotmnetStatusMessageAndIcon(timeDiff: timeDiff)
        }else{
            return instantTaxiAllotmnetStatusMessageAndIcon(timeDiff: timeDiff)
        }
    }

    func instantTaxiAllotmnetStatusMessageAndIcon(timeDiff: Int) -> (String,String){
        switch timeDiff{
        case 0...19:
            return ("Booking taxi for you...","booking_taxi")
        case 19...39:
            return ("Matching nearby drivers...","matching_drivers")
        case 39...59:
            return ("Filtering best rated driver...","best_rated_driver")
        case 59...79:
            return ("Waiting for driver to confirm...","waiting_for_driver")
        case 79...99:
            return ("Usually it doesn't take this long! Please wait","icon_loader")
        case 99...119:
            return ("Almost done! Hang on...","booking_taxi")
        case 119...139:
            return ("Waiting for driver to confirm...","waiting_for_driver")
        default:
            return ("Waiting for driver to confirm...","waiting_for_driver")
        }
    }

    func instantAutoAllotmnetStatusMessageAndIcon(timeDiff: Int) -> (String,String){
        switch timeDiff{
        case 0...19:
            return ("Booking taxi for you...","Auto_icon")
        case 19...39:
            return ("Matching nearby drivers...","current_location")
        case 39...59:
            return ("Filtering best rated driver...","rating_Star")
        case 59...79:
            return ("Waiting for driver to confirm...","icon_loader")
        default:
            return ("Waiting for driver to confirm...","icon_loader")
        }
    }

    func rescheduleTaxiRide(startTime: Double,fixedFareId: String,complition: @escaping(_ result: Bool)->()){
        guard let taxiRidePassengerId = taxiRidePassengerDetails?.taxiRidePassenger?.id else { return }
        TaxiPoolRestClient.rescheduleTaxiRide(userId: UserDataCache.getInstance()?.userId ?? "", taxiRidePassengerId: taxiRidePassengerId, startTime: startTime, fixedFareId: fixedFareId) { (responseObject, error) in
            let result = RestResponseParser<TaxiRidePassengerDetails>().parse(responseObject: responseObject, error: error)
            if let taxiRidePassengerDetails = result.0 {
                self.taxiRidePassengerDetails?.taxiRidePassenger = taxiRidePassengerDetails.taxiRidePassenger
                complition(true)
            }else{
                complition(false)
            }
        }
    }
    func rescheduleRentalTaxiRide(startTime: Double,complition: @escaping(_ result: Bool)->()){
        guard let taxiRidePassengerId = taxiRidePassengerDetails?.taxiRidePassenger?.id else { return }
        TaxiPoolRestClient.updateTaxiTrip(startTime: startTime, expectedEndTime: nil, endLatitude: nil, endLongitude: nil, endAddress: nil, fixedfareID: nil, taxiRidePassengerId: taxiRidePassengerId, startLatitude: nil, startLongitude: nil, startAddress: nil, pickupNote: nil, selectedRouteId: nil) { (responseObject, error) in
            let result = RestResponseParser<TaxiRidePassengerDetails>().parse(responseObject: responseObject, error: error)
            if let taxiRidePassengerDetails = result.0{
                self.taxiRidePassengerDetails = taxiRidePassengerDetails
                TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: taxiRidePassengerId, taxiRidePassengerDetails: taxiRidePassengerDetails)
                var userInfo = [String : Any]()
                userInfo["taxiRidePassengerDetails"] = taxiRidePassengerDetails
                NotificationCenter.default.post(name: .taxiTripUpdated, object: nil)

                complition(true)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    func updateTaxiTrip(endLatitude: Double?, endLongitude: Double?,endAddress : String?,taxiRidePassengerId: Double,startLatitude: Double?,startLongitude: Double?,startAddress: String?,pickupNote:String?,selectedRouteId: Double?,fixedFareId: String, complition: @escaping(_ result: Bool)->()){
        guard let orignalTaxiRide = MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: taxiRidePassengerId) else { return  }
        var startLocation = Location()
        var endLocation = Location()
        if isLocationChanged(orignalLat: orignalTaxiRide.startLat, orignalLng: orignalTaxiRide.startLng, editedLat: startLatitude, editedLng: startLongitude) {
            startLocation = Location(latitude: startLatitude ?? 0, longitude: startLongitude ?? 0, shortAddress: startAddress)
        }
        if isLocationChanged(orignalLat: orignalTaxiRide.endLat, orignalLng: orignalTaxiRide.endLng, editedLat: endLatitude, editedLng: endLongitude){
            endLocation = Location(latitude: endLatitude ?? 0, longitude: endLongitude ?? 0, shortAddress: endAddress)
        }
        TaxiPoolRestClient.updateTaxiTrip(startTime: nil,expectedEndTime: nil, endLatitude: endLocation.latitude, endLongitude: endLocation.longitude, endAddress: endLocation.shortAddress, fixedfareID: fixedFareId, taxiRidePassengerId: taxiRidePassengerId,startLatitude: startLocation.latitude ,startLongitude: startLocation.longitude,startAddress: startLocation.shortAddress ,pickupNote: pickupNote, selectedRouteId: selectedRouteId) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let response = RestResponse<TaxiRidePassengerDetails>(responseObject: responseObject, error: error)
                if let taxiRidePassengerDetails = response.result{
                    self.taxiRidePassengerDetails = taxiRidePassengerDetails
                    self.getWayPointsOfRoute()
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: taxiRidePassengerId, taxiRidePassengerDetails: taxiRidePassengerDetails)
                    var userInfo = [String : Any]()
                    userInfo["taxiRidePassengerDetails"] = taxiRidePassengerDetails
                    NotificationCenter.default.post(name: .taxiTripUpdated, object: nil)
                }
                complition(true)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }

    func updateTaxiFare(viewcontroller: UIViewController, complition: @escaping(_ result: Bool)->()){
        guard let taxiRidePassengerId = taxiRidePassengerDetails?.taxiRidePassenger?.id else { return complition(false) }
        TaxiPoolRestClient.updateTaxiFare(userId: UserDataCache.getInstance()?.userId ?? "", taxiRidePassengerId: taxiRidePassengerId, fixedFareId: taxiRideUpdateSuggestion?.fixedFareId ?? "") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.taxiRideUpdateSuggestion?.isSuggestionShowed = true
                self.taxiRideUpdateSuggestion?.updatedTimeMs = Int(NSDate().getTimeStamp())
                SharedPreferenceHelper.storeTaxiRideGroupSuggestionUpdate(taxiGroupId: self.taxiRidePassengerDetails?.taxiRidePassenger?.taxiGroupId ?? 0,taxiUpdateSuggestion: self.taxiRideUpdateSuggestion)
                self.taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs = NSDate().getTimeStamp()
                complition(true)
                NotificationCenter.default.post(name: .taxiFareUpadted, object: nil)
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                complition(false)
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if error != nil {
                    RideManagementUtils.handleRiderInviteFailedException(errorResponse: error!, viewController: viewcontroller, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.updateTaxiFare(viewcontroller: viewcontroller, complition: complition)
                    })
                } else{
                    ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: viewcontroller)
                    complition(false)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewcontroller, handler: nil)
                complition(false)
            }
        }
    }


    func isTaxiFareChangeSuggestionReceived() -> TaxiRideGroupSuggestionUpdate?{
        if let taxiRideGroupSuggestionUpdate = taxiRideUpdateSuggestion,!taxiRideGroupSuggestionUpdate.isSuggestionShowed{
            return taxiRideGroupSuggestionUpdate
        }else if let taxiRideGroupSuggestionUpdate = SharedPreferenceHelper.getTaxiRideGroupSuggestionUpdate(taxiGroupId: taxiRidePassengerDetails?.taxiRidePassenger?.taxiGroupId ?? 0),!taxiRideGroupSuggestionUpdate.isSuggestionShowed{
            taxiRideUpdateSuggestion = taxiRideGroupSuggestionUpdate
            return taxiRideGroupSuggestionUpdate
        }else{
            return nil
        }
    }
    func payTaxiBill(hanler: @escaping TaxiPoolRestClient.responseJSONCompletionHandler){
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        TaxiPoolRestClient.clearTaxPendingiBill(taxiRidePassengerId: taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0,userId: UserDataCache.getInstance()?.userId ?? "",paymentType: linkedWallet?.type ?? "", completionHandler: hanler)
    }
    func getOutstationFareSummaryDetails(){
       outstationTaxiFareDetails = TaxiRideDetailsCache.getInstance().getOutStationTaxiFareDetails(taxiRideId: taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0)
        showDateDataList.removeAll()
        if let ridePaymentDetails = outstationTaxiFareDetails?.ridePaymentDetails {
            for _ in ridePaymentDetails {
                showDateDataList.append(false)
            }
        }
        TaxiPoolRestClient.getFareBreakUpDuringTrip(taxiRideId: taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0,userId: UserDataCache.getInstance()?.userId ?? "") { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self?.outstationTaxiFareDetails = Mapper<PassengerFareBreakUp>().map(JSONObject: responseObject!["resultData"])
                if let taxiRideId = self?.taxiRidePassengerDetails?.taxiRidePassenger?.id,let outstationDetails = self?.outstationTaxiFareDetails{
                    TaxiRideDetailsCache.getInstance().storeOutStationTaxiFareDetails(taxiRideId: taxiRideId, outstationTaxiFareDetails: outstationDetails)
                }
                NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil)
                NotificationCenter.default.post(name: .updatePaymentView, object: nil)
                self?.showDateDataList.removeAll()
                if let ridePaymentDetails = self?.outstationTaxiFareDetails?.ridePaymentDetails {
                    for _ in ridePaymentDetails {
                        self?.showDateDataList.append(false)
                    }
                }
            }
        }
    }

    func getBalanceOfLinkedWallet(complitionHandler: @escaping(_ isFetchedBalance: Bool) -> ()){
        guard let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() else { return }
        if linkedWallet.type != AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE && linkedWallet.type != AccountTransaction.TRANSACTION_WALLET_TYPE_UPI && linkedWallet.type != AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY && linkedWallet.type != AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL { // Balance will not there in these wallet case
            AccountRestClient.getLinkedWalletBalancesOfUser(userId: UserDataCache.getInstance()?.userId ?? "", types: linkedWallet.type ?? "",viewController: nil, handler: { [weak self] (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let linkedWalletBalances = Mapper<LinkedWalletBalance>().mapArray(JSONObject: responseObject!["resultData"]) ?? []
                    if let linkedWalletBalance = linkedWalletBalances.first(where: {$0.type == linkedWallet.type}) {
                        self?.linkedWalletBalance = linkedWalletBalance
                        complitionHandler(true)
                    }
                }else{
                    complitionHandler(false)
                }
            })
        }
    }

    func initiateUPIPayment(paymentInfo: [String: Any]){
        var totalAmount: String?
        if let totalAmountToPay = paymentInfo[ResponseError.TOTAL_PENDING] as? Double, totalAmountToPay != 0 {
            totalAmount = String(totalAmountToPay)
        }
        var orderId: String?
        if paymentInfo.keys.contains("OrderId"){
            orderId = paymentInfo["OrderId"] as? String
        }
        if let amount = totalAmount,let id = orderId,let walletType = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type{
            QuickRideProgressSpinner.startSpinner()
            AccountRestClient.initiateUPIPayment(userId: QRSessionManager.getInstance()?.getUserId(), orderId: id, amount: amount, paymentType: walletType) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                    var userInfo = [String : String]()
                    userInfo["orderId"] = id
                    userInfo["amount"] = amount
                    NotificationCenter.default.post(name: .initiateUPIPayment, object: self, userInfo: userInfo)
                } else {
                    var userInfo = [String : Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
                }

            }
        }
    }
    func updateSharingToExclusive(allocateTaxiIfPoolNotConfirmed: Bool,fixedFareId: String?,complitionHandler: @escaping(_ isSaved: Bool) -> ()){
        TaxiSharingRestClient.updateSharingToExclusive(taxiRidePassengerId: taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0, allocateTaxiIfPoolNotConfirmed: allocateTaxiIfPoolNotConfirmed, fixedFareId: fixedFareId) { [weak self](responseObject, error) in
            if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                if let taxiRideDetails = Mapper<TaxiRidePassengerDetails>().map(JSONObject: responseObject!["resultData"]){
                    self?.taxiRidePassengerDetails = taxiRideDetails
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: taxiRideDetails.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: taxiRideDetails)
                    NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil)
                }
                complitionHandler(true)
            } else {
                complitionHandler(false)
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }

        }
    }
    func updatePoolMyTaxi(allocateTaxiIfPoolNotConfirmed: Bool,complitionHandler: @escaping(_ isSaved: Bool) -> ()){
        TaxiSharingRestClient.updateExclusiveToSharing(taxiRidePassengerId: taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0, allocateTaxiIfPoolNotConfirmed: allocateTaxiIfPoolNotConfirmed) { [weak self](responseObject, error) in
            if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                if let taxiRideDetails = Mapper<TaxiRidePassengerDetails>().map(JSONObject: responseObject!["resultData"]){
                    self?.taxiRidePassengerDetails = taxiRideDetails
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: taxiRideDetails.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: taxiRideDetails)
                    NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil)
                }
                complitionHandler(true)
            } else {
                complitionHandler(false)
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }


    func sendCustomerReason(customerReason: String, taxiRideGroupId: Double, taxiRidePassengerId: Double, raisedByRefId: Double, type: String, raisedUserType: String) {
        QuickRideProgressSpinner.startSpinner()
        let rideRiskAssessment = RideRiskAssessment(type: type, description: customerReason, taxiRideGroupId: taxiRideGroupId, taxiRidePassengerId: taxiRidePassengerId, raisedBy: UserDataCache.getInstance()?.currentUser?.userName ?? "", raisedByRefId: raisedByRefId, raisedUserType: raisedUserType)

        let jsondata : String = Mapper().toJSONString(rideRiskAssessment , prettyPrint: true)!

        TaxiSharingRestClient.sendRiskyRide(createRideRiskInJson: jsondata) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast(Strings.informed_to_Quickride_support)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }



    func getFareBrakeUpData() {
        guard var finalFareDetails = outstationTaxiFareDetails?.finalFareDetails else { return }
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

        if finalFareDetails.nightCharges != 0 {
            let nightCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.NIGHT_CHARGES, value: "₹\(finalFareDetails.nightCharges.roundToPlaces(places: 1) )")
            estimateFareData.append(nightCharges)
        }

        if outstationTaxiFareDetails?.finalFareDetails?.extraPickUpCharges != 0{
            let extraPickupFee = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PICKUP_FEE, value: "₹\(outstationTaxiFareDetails?.finalFareDetails?.extraPickUpCharges.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(extraPickupFee)
        }

        var convenienceFee = finalFareDetails.scheduleConvenienceFee + finalFareDetails.scheduleConvenienceFeeTax
        if convenienceFee != 0{
            let convenience = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.Convenience_Fee, value: "₹\(convenienceFee.roundToPlaces(places: 1) )")
            estimateFareData.append(convenience)
        }
        var rideFare = (finalFareDetails.distanceBasedFare) + (finalFareDetails.driverAllowance) + (finalFareDetails.nightCharges) + (finalFareDetails.baseFare) + convenienceFee + (finalFareDetails.extraPickUpCharges) + (finalFareDetails.durationBasedFare)
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

   func getCashPaymentDetails(taxiUserAdditionalPaymentDetails: TaxiUserAdditionalPaymentDetails?) -> (String,String,Bool){
        let amount = "- " + String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiUserAdditionalPaymentDetails?.amount)])
        let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(taxiUserAdditionalPaymentDetails?.creationDateMs ?? 0), timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A) ?? ""
        let title = "Cash paid - " + date
        var isRequiredToShowDisputed = false
        if taxiUserAdditionalPaymentDetails?.status == TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
            isRequiredToShowDisputed = true
        }
        return (title,amount,isRequiredToShowDisputed)
    }



}

extension TaxiPoolLiveRideViewModel {//MARK: Offer
    func getOffers() {
        var filterList = [Offer]()
        if let offers = ConfigurationCache.getInstance()?.offersList {
            for offer in offers {
                if offer.displayType == Strings.displaytype_both && (offer.targetDevice == Strings.targetdevice_all || offer.targetDevice == Strings.targetdevice_ios) && offer.offerScreenImageUri != nil && offer.offerScreenImageUri!.isEmpty == false {
                    filterList.append(offer)
                }
            }
            if !filterList.isEmpty {
                updateOfferAsPerPreferedRole(filterOfferList: filterList)
            }
        }
    }

    private func updateOfferAsPerPreferedRole(filterOfferList : [Offer]) {
        var finalOfferList = [Offer]()
        for offer in filterOfferList {
            let userProfile = UserDataCache.getInstance()!.getLoggedInUserProfile()
            if userProfile != nil && (UserProfile.PREFERRED_ROLE_PASSENGER == userProfile!.roleAtSignup && offer.targetRole == Strings.targetrole_passenger) || (UserProfile.PREFERRED_ROLE_RIDER == userProfile!.roleAtSignup && offer.targetRole == Strings.targetrole_rider) {
                finalOfferList.append(offer)
            } else if offer.targetRole == Strings.targetrole_both {
                finalOfferList.append(offer)
            }
        }
        if !finalOfferList.isEmpty {
            let sortedOfferList = finalOfferList.sorted(by: { $0.validUpto > $1.validUpto}).shuffled()
            getFinalOfferList(offerList: sortedOfferList)
        }
    }

    private func getFinalOfferList(offerList: [Offer]) {
        if offerList.count <= 5{
            self.finalOfferList = offerList
        }else{
            self.finalOfferList = Array(offerList[0..<5])
        }
    }

    func getTaxiRidePassenger() -> TaxiRidePassenger? {
        if taxiRidePassengerDetails == nil {
            return MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: taxiRideID ?? 0)
        }
        return taxiRidePassengerDetails?.taxiRidePassenger
    }

    func getTaxiRideGroup() -> TaxiRideGroup? {
        return taxiRidePassengerDetails?.taxiRideGroup
    }

    func isTaxiAllotted() -> Bool{
        guard let taxiRidePassengerDetails = taxiRidePassengerDetails else {
            return false
        }
        return TaxiUtils.isTaxiAllotted(taxiRidePassengerDetails: taxiRidePassengerDetails)
    }

    func isTaxiPending() -> Bool{
        guard let  taxiRideGroup = getTaxiRideGroup() else {
            return true
        }
        return TaxiRideGroup.STATUS_OPEN == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_FROZEN == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_CONFIRMED == taxiRideGroup.status
    }

    func isTaxiStarted() -> Bool{
         guard let taxiRidePassenger = getTaxiRidePassenger() else {
            return false
        }
        return TaxiRidePassenger.STATUS_STARTED == taxiRidePassenger.status
    }

    func isTaxiReached() -> Bool{

        guard let taxiRidePassenger = getTaxiRidePassenger() else {
            return false;
        }
        return TaxiRidePassenger.STATUS_DRIVER_REACHED_PICKUP == taxiRidePassenger.status
    }

    func isPaymentPending() -> Bool {
        guard let error = taxiRidePassengerDetails?.exception?.error else {
            return false
        }
        return error.errorCode == TaxiDemandManagementException.PAYMENT_REQUIRED_BEFORE_JOIN_TAXI
    }

    func isTaxiConfirmed() -> Bool{
        guard let taxiRideGroup = getTaxiRideGroup() else {
            return false
        }
        return TaxiRideGroup.STATUS_CONFIRMED == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_FROZEN == taxiRideGroup.status
    }
    func isSharingEnabled() -> Bool{
        guard let taxiRidePassenger = taxiRidePassengerDetails?.taxiRidePassenger else { return  false}
        let instantTaxiLocations = ConfigurationCache.getObjectClientConfiguration().instantTaxiEnabledLocations
        for enableLocation in instantTaxiLocations{
            if let location = enableLocation.location , enableLocation.tripType ==  taxiRidePassenger.tripType, LocationClientUtils.getDistance(fromLatitude: location.lat, fromLongitude: location.lng, toLatitude: taxiRidePassenger.startLat ?? 0, toLongitude: taxiRidePassenger.startLng ?? 0)/1000 < location.radius{
                return enableLocation.enableTaxiSharing
            }
        }
        return false
    }

    func getVehicleTypeForEtaService( vehicleType : String?) -> String{
        guard let type = vehicleType else {
            return "Car"
        }
        switch type {
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_BIKE:
            return "Bike"
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_AUTO:
            return "Auto"
        default:
            return "Car"
        }
    }
    func chandePaymentMode(paymentType: String){
        TaxiPoolRestClient.changePaymentMethod(taxiRideId: StringUtils.getStringFromDouble(decimalNumber: taxiRideID), userId: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId()), paymentType: paymentType, paymentMode: paymentMode ?? TaxiRidePassenger.PAYMENT_MODE_ONLINE) {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let taxiRidePassenger = Mapper<TaxiRidePassenger>().map(JSONObject: responseObject!["resultData"])
                self.taxiRidePassengerDetails?.taxiRidePassenger = taxiRidePassenger
                if let taxiRidePassengerDetail = self.taxiRidePassengerDetails {
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self.taxiRideID ?? 0, taxiRidePassengerDetails: taxiRidePassengerDetail)
                    NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }

    }

    func getDataForFacilitiesAndInclusionAndExclusion() -> [TaxiTnCData]?{
        if selectedOptionTabIndex == 0{
            return outstationTaxiFareDetails?.fareForVehicleClass?.taxiTnCSummary?.inclusions ?? []
        }else if selectedOptionTabIndex == 1{
            return outstationTaxiFareDetails?.fareForVehicleClass?.taxiTnCSummary?.exclusions ?? []
        }else if selectedOptionTabIndex == 2{
            return outstationTaxiFareDetails?.fareForVehicleClass?.taxiTnCSummary?.facilities ?? []
        }else {
            return outstationTaxiFareDetails?.fareForVehicleClass?.taxiTnCSummary?.extras ?? []
        }
    }

    func getJoinedMemebersOfTaxiPool() -> [TaxiRidePassengerBasicInfo]{

        guard let taxiRidePassengers = taxiRidePassengerDetails?.otherPassengersInfo, let currentUser = UserDataCache.sharedInstance?.currentUser,let userProfile = UserDataCache.sharedInstance?.userProfile else {
            return [TaxiRidePassengerBasicInfo]()
        }
        var taxiRidePassengerBasicInfos = [TaxiRidePassengerBasicInfo]()
        var taxiRidePassengerBasicInfo =  TaxiRidePassengerBasicInfo()

        taxiRidePassengerBasicInfo.userName = currentUser.userName
        taxiRidePassengerBasicInfo.userId = currentUser.phoneNumber
        taxiRidePassengerBasicInfo.imageURI = userProfile.imageURI
        taxiRidePassengerBasicInfo.gender = currentUser.gender
        taxiRidePassengerBasicInfos.append(taxiRidePassengerBasicInfo)
        taxiRidePassengerBasicInfos.append(contentsOf: taxiRidePassengers)
        return taxiRidePassengerBasicInfos
    }
     func noOfPassengersInTrip() -> Int{
        guard let noOfPassengers = taxiRidePassengerDetails?.taxiRideGroup?.noOfPassengers else {
            return 0
        }
        return noOfPassengers
    }
    func getMinPickupTimeAcceptedForTaxi(tripType: String) -> Double {

        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        let instantTaxiLocations = clientConfiguration.instantTaxiEnabledLocations
        if  let startLat = taxiRidePassengerDetails?.taxiRidePassenger?.startLat, startLat != 0 , let startLng = taxiRidePassengerDetails?.taxiRidePassenger?.startLng, startLng != 0, let endLat = taxiRidePassengerDetails?.taxiRidePassenger?.endLat, endLat != 0 , let endLng = taxiRidePassengerDetails?.taxiRidePassenger?.endLng , endLng != 0 , !instantTaxiLocations.isEmpty{
            for enableLocation in clientConfiguration.instantTaxiEnabledLocations{
                if let location = enableLocation.location , enableLocation.tripType == tripType, LocationClientUtils.getDistance(fromLatitude: startLat, fromLongitude: startLng, toLatitude: endLat, toLongitude: endLng)/1000 < location.radius{
                    return DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: enableLocation.advanceTimeInMinsForBookingToBeAllowed)
                }
            }
        }
        return DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: clientConfiguration.taxiPoolInstantBookingThresholdTimeInMins)
    }
    func getAllRentalStopPoints(handler : @escaping(_ responseError: ResponseError?,_ error: NSError? )-> ()) {
        guard let taxiRidePassenger = getTaxiRidePassenger(), taxiRidePassenger.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL, let taxiGroupId = taxiRidePassenger.taxiGroupId else {
            handler(nil,nil)
            return
        }
        TaxiRideDetailsCache.getInstance().getAllRentalStopPoints(taxiGroupId: taxiGroupId) { response, responseError, error in
            if let rentalStopPoints = response{
                self.rentalStopPointList = rentalStopPoints;
                NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil)
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

    func addNewRentalStopPoints( startAddress : String?, startLatitude: Double?, startLongitude: Double?,endAddress: String,endlat: Double,endlng: Double, handler : @escaping(_ responseError: ResponseError?,_ error: NSError?) -> ()) {
        TaxiPoolRestClient.addNextStopOverPoint(taxiRidePassengerId: taxiRidePassengerDetails?.taxiRidePassenger?.id, startAddress : startAddress, startLatitude: startLatitude, startLongitude: startLongitude, stopPointAddress: endAddress, stopPointLat: endlat, stopPointLng: endlng) {(responseObject, error) in
            let result = RestResponseParser<RentalTaxiRideStopPoint>().parseArray(responseObject: responseObject, error: error)
            if let rentalStopPoints = result.0{
                self.rentalStopPointList = rentalStopPoints
                if let taxiGroupId = self.taxiRidePassengerDetails?.taxiRidePassenger?.taxiGroupId {
                    TaxiRideDetailsCache.getInstance().storeAllRentalStopPoints(taxiGroupId: taxiGroupId, rentalStopPointListForRides: rentalStopPoints)
                }
                NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil)
            }
            handler(result.1,result.2)
        }
    }

    func getResloveRiskReasons(taxiGroupId: Double){
        TaxiSharingRestClient.getCustomerResolveRisk(taxiGroupId: taxiGroupId) { (responseObject,error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let result = RestResponseParser<RideRiskAssessment>().parseArray(responseObject: responseObject, error: error)
                self.rideRiskAssessment = result.0
            }
        }
    }

    func isRentalTrip() -> Bool{
        if taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL{
            return true
        } else {
            return false
        }
    }
    func isOutstationTrip() -> Bool {
        if taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiRidePassenger.OUTSTATION {
            return true
        } else {
            return false
        }
    }
    func isLocalTrip() -> Bool {
        if taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiRidePassenger.LOCAL_TAXI {
            return true
        } else {
            return false
        }
    }
    func getNearbyTaxi(location : Location,taxiType: String?,complitionHandler: @escaping(_ responseError: ResponseError?,_ error: NSError?)-> ()){
        TaxiPoolRestClient.getNearbyTaxi(startLatitude: location.latitude, startLongitude: location.longitude, taxiType: taxiType, maxNoOfTaxiToShow: 5, maxDistance: 5){ (responseObject, error) in
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

    func isAllocationStarted() -> Bool {
        guard let taxiRidePassengerDetails = taxiRidePassengerDetails else {
            return false
        }
        return TaxiUtils.isAllocationStarted(taxiRidePassengerDetails: taxiRidePassengerDetails)
    }

    func isAllocationDelayed() -> Bool {
        guard let taxiRidePassengerDetails = taxiRidePassengerDetails else {
            return false
        }
        return TaxiUtils.isAllocationDelayed(taxiRidePassengerDetails: taxiRidePassengerDetails)
    }

    func isRequiredToShowTaxiBookedForOther() -> Bool{
        guard !isTaxiStarted() else { return false }
        if let forCommuteUser = taxiRidePassengerDetails?.taxiRidePassenger?.forCommuteUser, forCommuteUser {
            return true
        }
        return false
    }

    func updateTaxiBehalfBookedContactDetails( commuteContactNo: String, commutePassengerName: String, complitionHandler: @escaping(_ responseError: ResponseError?,_ error: NSError?)-> ()){
        guard let taxiRidePassengerId = taxiRidePassengerDetails?.taxiRidePassenger?.id else {
            return
        }
        TaxiPoolRestClient.updateTaxiBehalfBookedContactDetails(taxiRidePassengerId: taxiRidePassengerId, commuteContactNo: commuteContactNo, commutePassengerName: commutePassengerName){ (responseObject, error) in
            let result = RestResponseParser<TaxiRidePassengerDetails>().parse(responseObject: responseObject, error: error)
            if let taxiRidePassengerDetails = result.0 {
                self.taxiRidePassengerDetails = taxiRidePassengerDetails
                complitionHandler(nil,nil)
                return
            }
            complitionHandler(result.1,result.2)
        }
     }
    func getWayPointsOfRoute() {
        if let waypoints = taxiRidePassengerDetails?.taxiRidePassenger?.wayPoints,
           let wayPoints = Mapper<Location>().mapArray(JSONString: waypoints) {
            self.wayPoints = wayPoints
        }else {
            self.wayPoints.removeAll()
        }
    }

    func viaPointRemoved(index : Int){
        if index >= wayPoints.count {
            return
        }
        wayPoints.remove(at: index)
    }
    
    func isLocationChanged(orignalLat: Double?, orignalLng: Double?, editedLat: Double?, editedLng: Double?) -> Bool{
        return editedLat != orignalLat || editedLng != orignalLng
    }


}
