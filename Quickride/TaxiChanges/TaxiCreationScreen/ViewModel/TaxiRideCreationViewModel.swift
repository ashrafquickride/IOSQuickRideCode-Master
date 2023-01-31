//
//  TaxiRideCreationViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 03/02/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

class TaxiRideCreationViewModel {
    var startLocation: Location?
    var endLocation: Location?
    var selectedRouteId = -1.0
    var distance = 0.0
    var MAP_ZOOM : Float = 15
    var rideType = TaxiPoolConstants.TRIP_TYPE_LOCAL
    var isRoundTrip: Bool = false
    var startTime = NSDate().getTimeStamp()
    var endTime: Double?
    var detailedEstimateFare: DetailedEstimateFare?
    var fareForVehicleDetail = [FareForVehicleClass]()
    var isTaxiDetailsFetchingFromServer = true
    var selectedTaxiTypeIndex = 0
    var isFromDropTime = false
    var advaceAmountPercentageForOutstation = 0
    var refRequestId : Double?
    var userCouponCode: UserCouponCode?
    var isFromScheduleReturnRide = false
    var userSelectedTime: Double? // User selcted time from picker using for getting available taxi
    var isRequiredToShowAnimationForTime = false
    var routePaths = [RideRoute]()
    var paymentMode: String?

    // rental
    var selectedOptionIndex = 0
    var selectedRentalPackage: RentalPackageEstimate?
    var rentalPackageEstimates: [RentalPackageEstimate]?
    var selectedRentalPackageIndex = 0
    var rentalPackageId: Int?
    var previousRentalLocationSearched: Location?
    var selectedVehicleIndex: Int = 0
    var taxiVehicleCategory: String?
    var partnerRecentLocationInfo: [PartnerRecentLocationInfo]?
    var isRequiredToReloadData = false

    // behalf booking
    var commuteContactNo: String?
    var commutePassengerName: String?
    var isCheckedForBehalfBooking = false

    init(startLocation: Location?, endLocation: Location?, selectedRouteId: Double,rideType: String,journeyType : String?, commuteContactNo: String?, commutePassengerName: String?){
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.selectedRouteId = selectedRouteId
        self.commuteContactNo = commuteContactNo
        self.commutePassengerName = commutePassengerName
        if selectedRouteId != -1 , let prefRoutes = UserDataCache.getInstance()?.getUserPreferredRoutes(){
            let prefRoute = prefRoutes.first { element in
                element.routeId == selectedRouteId
            }
            if let route = prefRoute?.rideRoute {
                routePaths.removeAll()
                routePaths.append(route)
            }
        }
        self.rideType = rideType
        self.isRoundTrip = journeyType == TaxiPoolConstants.JOURNEY_TYPE_ROUND_TRIP ? true : false
        selectedOptionIndex = 0
    }
    init() {

    }
    init(startLocation: Location?, selectedRentalPackage: RentalPackageEstimate?, rentalPackageEstimates: [RentalPackageEstimate]?, commuteContactNo: String?, commutePassengerName: String?) {
        self.startLocation = startLocation
        self.selectedRentalPackage = selectedRentalPackage
        self.rentalPackageEstimates = rentalPackageEstimates
        self.commuteContactNo = commuteContactNo
        self.commutePassengerName = commutePassengerName
        if let index = rentalPackageEstimates?.firstIndex(where: {$0.packageDistance == selectedRentalPackage?.packageDistance && $0.packageDuration == selectedRentalPackage?.packageDuration}) {
            self.selectedRentalPackageIndex = index
            rentalPackageId = rentalPackageEstimates?[index].rentalPackageConfigList[0].id
            taxiVehicleCategory = rentalPackageEstimates?[index].rentalPackageConfigList[0].vehicleClass
        }
        isTaxiDetailsFetchingFromServer = false
        selectedOptionIndex = 1
    }


    init(passengerRide : PassengerRide) {
        startLocation =  Location(latitude: passengerRide.startLatitude,longitude: passengerRide.startLongitude,shortAddress: passengerRide.startAddress)
        endLocation = Location(latitude: passengerRide.endLatitude!,longitude: passengerRide.endLongitude!,shortAddress: passengerRide.endAddress)

        if let clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration(), passengerRide.distance! > clientConfiguration.minDistanceForInterCityRide{
            rideType = TaxiPoolConstants.TRIP_TYPE_OUTSTATION
            let pickupTime = passengerRide.startTime
            let minPickupTime = LocationClientUtils.getMinPickupTimeAcceptedForTaxi(tripType: rideType, fromLatitude: startLocation?.latitude ?? 0 , fromLongitude: startLocation?.longitude ?? 0)
            startTime = pickupTime < minPickupTime ? minPickupTime : pickupTime
            endTime = getMinDropTimeAcceptedForOutstationTaxi()
            isRoundTrip = true
        }else{
            rideType = TaxiPoolConstants.TRIP_TYPE_LOCAL
            let pickupTime = passengerRide.startTime
            if let startLocation = startLocation, let endLocation = endLocation {
                let minPickupTime = LocationClientUtils.getMinPickupTimeAcceptedForTaxi(tripType: rideType, fromLatitude: startLocation.latitude , fromLongitude: startLocation.longitude)
            startTime = pickupTime < minPickupTime ? minPickupTime : pickupTime
            }
        }

        selectedRouteId = passengerRide.routeId ?? -1
        refRequestId = passengerRide.rideId
        selectedOptionIndex = 0
    }
    init(taxiRidePassenger: TaxiRidePassenger) {
        isFromScheduleReturnRide = true
        endLocation =  Location(latitude: taxiRidePassenger.startLat ?? 0,longitude: taxiRidePassenger.startLng ?? 0,shortAddress: taxiRidePassenger.startAddress)
        startLocation = Location(latitude: taxiRidePassenger.endLat ?? 0,longitude: taxiRidePassenger.endLng!,shortAddress: taxiRidePassenger.endAddress)
        rideType = taxiRidePassenger.tripType ?? TaxiPoolConstants.TRIP_TYPE_LOCAL
        if taxiRidePassenger.journeyType == TaxiRidePassenger.ROUND_TRIP{
            isRoundTrip = true
        }
        let timeDifferenceForReturnRideInMins = taxiRidePassenger.tripType == TaxiRidePassenger.OUTSTATION ? 24*60 : 8*60
        let pickupTime = taxiRidePassenger.actualEndTimeMs ?? 0 > 0 ? taxiRidePassenger.actualEndTimeMs : taxiRidePassenger.expectedEndTimeMs

        if taxiRidePassenger.distance! > ConfigurationCache.getObjectClientConfiguration().minDistanceForInterCityRide{

            startTime = DateUtils.addMinutesToTimeStamp(time: pickupTime ?? NSDate().getTimeStamp(), minutesToAdd: timeDifferenceForReturnRideInMins)
            endTime = DateUtils.addMinutesToTimeStamp(time: startTime, minutesToAdd: 24*60)
        }else{
            startTime = DateUtils.addMinutesToTimeStamp(time: pickupTime ?? NSDate().getTimeStamp(), minutesToAdd: timeDifferenceForReturnRideInMins)
        }
        selectedOptionIndex = 0
    }

    func getAvailableTaxiData(routeId: Double?, wayPoints: String?, handler : @escaping (_ responseError: ResponseError?, _ error: NSError?) -> Void) {
        var estimateEndTime: Double?
        var journeyType: String?
        if rideType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            if isRoundTrip {
                journeyType = TaxiPoolConstants.JOURNEY_TYPE_ROUND_TRIP
            }else{
                journeyType = TaxiPoolConstants.JOURNEY_TYPE_ONE_WAY
            }
            if isRoundTrip {
                estimateEndTime = endTime
            }
        }
        guard let startLocation = startLocation, let endLocation = endLocation else{
            return
        }
        
        TaxiPoolRestClient.getAvailableTaxiDetails(startTime: userSelectedTime, expectedEndTime: estimateEndTime, startAddress: startLocation.shortAddress ?? "", startLatitude: startLocation.latitude , startLongitude: startLocation.longitude , endLatitude: endLocation.latitude , endLongitude: endLocation.longitude, endAddress: endLocation.shortAddress ?? "",journeyType: journeyType,routeId: routeId) { [weak self] (responseObject, error) in
            guard let self = self else {return}
            self.isTaxiDetailsFetchingFromServer = false
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {

                self.detailedEstimateFare = Mapper<DetailedEstimateFare>().map(JSONObject: responseObject!["resultData"])
                if let tripType = self.detailedEstimateFare?.tripType{
                    self.rideType = tripType
                }
                if let availableTime = self.detailedEstimateFare?.startTime{
                    self.startTime = availableTime
                }
                TaxiUtils.sendTaxiSearchedEvent(taxiRidePassengerId: 0, tripType: self.rideType, fromAddress: startLocation.shortAddress, toAddress: endLocation.shortAddress, startTime: self.userSelectedTime ?? 0)
                self.fareForVehicleDetail = self.getfareForVehicleDetails()

                if routeId == nil || self.routePaths.isEmpty {
                    var rideRoute = [Double : RideRoute]()
                    if let fare = self.detailedEstimateFare?.fareForTaxis, !fare.isEmpty, !fare[0].fares.isEmpty,let fareforVehicle = self.detailedEstimateFare?.fareForTaxis[0].fares[0],
                       let routeIdStr = fareforVehicle.routeId, let routeId = Double(routeIdStr), routeId != 0,
                       let polyline = fareforVehicle.overviewPolyline {
                        let route = RideRoute(routeId: routeId, overviewPolyline: polyline, distance: fareforVehicle.distance , duration: Double(fareforVehicle.timeDuration ), waypoints: wayPoints, routeType: nil, fromLatitude: startLocation.latitude, fromLongitude: startLocation.longitude, toLatitude: endLocation.latitude, toLongitude: endLocation.longitude)
                        rideRoute[routeId] = route
                    }
                    if let alternativeRoutes = self.detailedEstimateFare?.alternativeRoutes, alternativeRoutes.count > 0 {
                        for route in alternativeRoutes{
                            if let routeId = route.routeId {
                                rideRoute[routeId] = route

                            }
                        }
                    }
                    self.routePaths = Array(rideRoute.values)

                }

                handler(nil,nil)
            } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                handler(responseError,error)
            }else{
                handler(nil,error)
            }
        }
    }

    private func getfareForVehicleDetails() -> [FareForVehicleClass] {
        var fareForVehicleData = [FareForVehicleClass]()
        for data in detailedEstimateFare?.fareForTaxis ?? [] {
            for fareForTaxisData in data.fares {
                fareForVehicleData.append(fareForTaxisData)
            }
        }
        let vehicleClass = [TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_HATCH_BACK,
                            TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SEDAN,
                            TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_ANY,
                            TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV,
                            TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_CROSS_OVER,
                            TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_TT,
                            TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_BIKE,
                            TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_AUTO]
        var sortedVehicleList = [FareForVehicleClass]()
        for vehicle in vehicleClass{
            if let index = fareForVehicleData.index(where: { $0.vehicleClass == vehicle }){
                sortedVehicleList.append(fareForVehicleData[index])
                fareForVehicleData.remove(at: index)
            }
        }
        sortedVehicleList.append(contentsOf: fareForVehicleData)
        return sortedVehicleList
    }

    func setStartTime() {
          startTime = LocationClientUtils.getMinPickupTimeAcceptedForTaxi(tripType: rideType, fromLatitude: startLocation?.latitude ?? 0 , fromLongitude: startLocation?.longitude ?? 0)
    }

    func getMinDropTimeAcceptedForOutstationTaxi() -> Double {
        if let dropTime = endTime {
            return DateUtils.addMinutesToTimeStamp(time: dropTime, minutesToAdd: 24*60 )
        }else{
            return DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: 24*60)
        }
    }

    func validateInputsForTaxiBooking() -> String?  {

        if startLocation == nil || startLocation!.latitude == 0 || startLocation!.longitude == 0 {
            return "Please select Pickup address"
        }
        if endLocation == nil || endLocation!.latitude == 0 || endLocation!.longitude == 0 {
            return "Please select Drop address"
        }
        if rideType == nil || rideType.isEmpty {
            return "Please confirm trip type, Local/Out station"
        }
        if TaxiPoolConstants.TRIP_TYPE_LOCAL == rideType {
            if startTime == 0 {
                return "Please confirm pickup time"
            }
        } else if TaxiPoolConstants.TRIP_TYPE_OUTSTATION == rideType {

            if isRoundTrip {
                if startTime == 0 || endTime == 0{
                    return "Please confirm journey  time";
                }

            } else {
                if startTime == 0{
                    return "Please confirm pickup time"
                }
            }
        }
        if fareForVehicleDetail.isEmpty {
            return "Taxi is not avaialble for your route"
        }
        return nil
    }
    func verifyAppliedPromoCode(promoCode: String,handler: @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.applyUserCoupon(userId: UserDataCache.getInstance()?.userId ?? "", appliedCoupon: promoCode, viewController: nil, handler: handler)
    }

    func checkCityAndStateExistanceElseGetFromGeocoder(){
        if startLocation?.city == nil || startLocation?.state == nil {
            let location = CLLocationCoordinate2D(latitude: startLocation?.latitude ?? 0, longitude: startLocation?.longitude ?? 0)
            LocationCache.getCacheInstance().getLoactionInfoForLatLngFromCacheAndGeoCoder(coordinate: location) { (location,error) -> Void in
                if let loc =  location{
                    self.startLocation?.city =  loc.city
                    self.startLocation?.state = loc.state
                }
            }
        }

        if endLocation?.city == nil || endLocation?.state == nil{
            let location = CLLocationCoordinate2D(latitude: endLocation?.latitude ?? 0, longitude: endLocation?.longitude ?? 0)
            LocationCache.getCacheInstance().getLoactionInfoForLatLngFromCacheAndGeoCoder(coordinate: location) { (location,error) -> Void in
                if let loc =  location{
                    self.endLocation?.city =  loc.city
                    self.endLocation?.state = loc.state
                }
            }
        }
    }
    func validatePickUpTimeAndUpdate(startTimeInMs: Double?) -> Bool{
        if let time = startTimeInMs, time != 0, DateUtils.getDifferenceBetweenTwoDatesInMins(time1: time, time2: self.startTime) > 1 {
            self.startTime = time
            return true
        }
        return false
    }

    func checkUserHasInSufficieantAmountToBook() -> Bool{
        var minTotalFare = 0.0
        if selectedOptionIndex == 1{
            minTotalFare = Double(selectedRentalPackage?.rentalPackageConfigList[selectedTaxiTypeIndex].pkgFare ?? 0)
        }else{
            minTotalFare = fareForVehicleDetail[selectedTaxiTypeIndex].minTotalFare ?? 0
        }
        let linkedWalletBalance = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.balance
        let accountBalance = UserDataCache.getInstance()?.userAccount?.balance
        if rideType == TaxiPoolConstants.TRIP_TYPE_LOCAL{
            return ((linkedWalletBalance ?? 0) + (accountBalance ?? 0)) < minTotalFare
        }else{
            let estimateFare = minTotalFare
            let requiredAmount = estimateFare*Double(advaceAmountPercentageForOutstation)/100
            return ((linkedWalletBalance ?? 0) + (accountBalance ?? 0)) < requiredAmount
        }
    }
    func handleUserPreferredRoute(complition: @escaping(_ result: Bool)->()) {
        if startLocation != nil && startLocation?.latitude != 0 && startLocation?.longitude != 0 && endLocation != nil && endLocation?.latitude != 0 && endLocation?.longitude != 0 {
            let userPreferredRoute = UserDataCache.getInstance()?.getUserPreferredRoute(startLatitude: startLocation!.latitude, startLongitude: startLocation!.longitude, endLatitude: endLocation!.latitude, endLongitude: endLocation!.longitude)

            if userPreferredRoute != nil
            {
                if let route = userPreferredRoute!.rideRoute{
                    routePaths.append(route)
                    self.selectedRouteId = route.routeId ?? -1
                    MyRoutesCache.getInstance()?.saveUserRoute(route: route, key: nil)

                }else{
                    getRideRouteUsingPreferredRoute(userPrefRoute: userPreferredRoute!, complition: complition)
                }
            }
        }
    }
    func getRideRouteUsingPreferredRoute(userPrefRoute : UserPreferredRoute, complition: @escaping(_ result: Bool)->()){
        MyRoutesCache.getInstance()?.getUserRoute(routeId: userPrefRoute.routeId!,startLatitude: userPrefRoute.fromLatitude ?? 0, startLongitude: userPrefRoute.fromLongitude ?? 0, endLatitude: userPrefRoute.toLatitude ?? 0, endLongitude: userPrefRoute.toLongitude ?? 0, waypoints: userPrefRoute.rideRoute?.waypoints, overviewPolyline: userPrefRoute.rideRoute?.overviewPolyline, travelMode: Ride.DRIVING, useCase: "iOS.App."+("Passenger")+".GetRoute.RideCreationView",handler: { (route) in
            self.routePaths.append(route)
            self.selectedRouteId = route.routeId ?? -1
            userPrefRoute.rideRoute = route
            UserDataCache.getInstance()?.updateUserPreferredRoute(userPreferredRoute: userPrefRoute)
            complition(true)
        })
    }
    func getSelectedRoute() -> RideRoute?{

        for route in routePaths {

            if route.routeId == selectedRouteId{
                return route
            }
        }
        if routePaths.count > 0{
            return routePaths[0]
        }
        return nil
    }



    func getButtonTitleBasedOnVehicle(index: Int) -> String{
        if fareForVehicleDetail[index].vehicleClass == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_ANY{
            return "SHARING"
        }else{
            return fareForVehicleDetail[index].vehicleClass?.uppercased() ?? ""
        }
    }
    func getRentalPackages(complitionHandler: @escaping(_ responseError: ResponseError?,_ error: NSError?)-> ()){
        if previousRentalLocationSearched == startLocation {
            complitionHandler(nil,nil)
        }
        let userId = UserDataCache.getCurrentUserId()
        TaxiPoolRestClient.getRentalPackages(userId: userId, startAddress: startLocation?.address ?? "", startLatitude: startLocation?.latitude ?? 0, startLongitude: startLocation?.longitude ?? 0, startCity: startLocation?.city ?? "", startTime: startTime) { (responseObject, error) in
            TaxiUtils.sendTaxiSearchedEvent(taxiRidePassengerId: 0, tripType: TaxiPoolConstants.TRIP_TYPE_RENTAL, fromAddress: self.startLocation?.address, toAddress: nil, startTime: self.startTime)
                let result = RestResponseParser<RentalPackageConfig>().parseArray(responseObject: responseObject, error: error)
            if let rentalEstimates = result.0 {
                var dict = [String: RentalPackageEstimate]()

                for item in rentalEstimates {
                    guard let pkgDistance = item.pkgDistanceInKm, let pkgDuration = item.pkgDurationInMins else {
                        continue
                    }
                    let key = "\(pkgDistance) : \(pkgDuration)"
                    if let fromDict = dict[key]{
                        fromDict.rentalPackageConfigList.append(item)
                    }else{
                        let rentalEstimate = RentalPackageEstimate(packageDistance: pkgDistance, packageDuration: pkgDuration)
                        rentalEstimate.rentalPackageConfigList.append(item)
                        dict[key] = rentalEstimate
                    }
                }
                self.rentalPackageEstimates = Array(dict.values)
                self.rentalPackageEstimates?.sort(by: sortMessge )
                func sortMessge(first: RentalPackageEstimate, second: RentalPackageEstimate) -> Bool {
                    return (first.packageDistance < second.packageDistance)
                }
            }
            self.previousRentalLocationSearched = self.startLocation
            complitionHandler(result.1,result.2)
        }
    }

    func bookRentalTaxi(createTaxiHandler : @escaping(_ taxiPassengerDetails: TaxiRidePassengerDetails? ,_ responseError: ResponseError?,_ error: NSError? )-> ()){
        TaxiPoolRestClient.bookRentalTaxi(startTime: startTime, startAddress: startLocation?.address ?? "", startLatitude: startLocation?.latitude ?? 0, startLongitude: startLocation?.longitude ?? 0, startCity: startLocation?.city, rentalPackageId: rentalPackageId ?? 0,taxiVehicleCategory: taxiVehicleCategory, paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type, paymentMode: paymentMode, enablePayLater: true, commuteContactNo: commuteContactNo, commutePassengerName: commutePassengerName ) {(responseObject, error) in
            let responseResult = RestResponseParser<TaxiRidePassengerDetails>().parse(responseObject: responseObject, error: error)
            if responseResult.0 != nil {
                let taxiPassengerDetails = responseResult.0
                if taxiPassengerDetails?.exception?.error?.errorCode == TaxiDemandManagementException.PAYMENT_REQUIRED_BEFORE_JOIN_TAXI, let extraInfo = taxiPassengerDetails?.exception?.error?.extraInfo, !extraInfo.isEmpty{
                    AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: nil){ (result) in
                        if result == Strings.success {
                            TaxiUtils.sendTaxiBookedEvent(taxiRidePassenger: taxiPassengerDetails?.taxiRidePassenger,routeCategory: taxiPassengerDetails?.taxiRideGroup?.routeCategory)
                            createTaxiHandler(taxiPassengerDetails, responseResult.1 , responseResult.2 )
                        }else{
                            self.cancelTaxiRide(taxiRidePassenger: taxiPassengerDetails?.taxiRidePassenger, createTaxiHandler: createTaxiHandler)
                        }
                    }
                }else{
                    TaxiUtils.sendTaxiBookedEvent(taxiRidePassenger: taxiPassengerDetails?.taxiRidePassenger,routeCategory: taxiPassengerDetails?.taxiRideGroup?.routeCategory)
                    createTaxiHandler(taxiPassengerDetails,nil,nil)
                }
            } else if let error = responseResult.1 {
                createTaxiHandler(nil,error,nil)
            } else {
                ErrorProcessUtils.handleResponseError(responseError: responseResult.1, error: responseResult.2, viewController: nil)
            }
        }
    }
    private func cancelTaxiRide(taxiRidePassenger: TaxiRidePassenger?,createTaxiHandler : @escaping(_ taxiPassengerDetails: TaxiRidePassengerDetails? ,_ responseError: ResponseError?,_ error: NSError? )-> ()){
        guard let taxiRidePassenger = taxiRidePassenger else {return}
        TaxiPoolRestClient.cancelTaxiRide(taxiId: taxiRidePassenger.id ?? 0, cancellationReason: "Payment cancelled by user") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                TaxiUtils.sendCancelEvent(taxiRidePassenger: taxiRidePassenger, cancelReason:  "Payment cancelled by user")
                UIApplication.shared.keyWindow?.makeToast(Strings.payment_failed)
                createTaxiHandler(nil,nil,nil)
            }else{
                createTaxiHandler(nil,nil,nil)
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
    func getNoOfTolls() -> Int {
        if let detailEstimatedFare = self.detailedEstimateFare, !detailEstimatedFare.fareForTaxis.isEmpty,
           !detailEstimatedFare.fareForTaxis[0].fares.isEmpty,
           let tollsInfo = detailEstimatedFare.fareForTaxis[0].fares[0].appliedTollsForTaxiTrip, let noOfTolls = Mapper<AppliedTollsForTheTaxiTrip>().mapArray(JSONString: tollsInfo) {
            return noOfTolls.count
        }
        return 0
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

    func checkIsRequiredToReloadDataAndUpdate(){
        if startLocation != nil && endLocation != nil && routePaths.count == 0 {
            isRequiredToReloadData = true
        }
    }
}
