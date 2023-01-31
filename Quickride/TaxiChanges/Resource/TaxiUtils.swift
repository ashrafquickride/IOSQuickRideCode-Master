//
//  TaxiUtils.swift
//  Quickride
//
//  Created by QR Mac 1 on 01/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps

class TaxiUtils{
    
    func getWhyQRTaxiMessageAndImage(timeDiff: Int) -> (String,String,String){
        switch timeDiff {
        case 0...19:
            let message = "Fares are lower and consistent. No surge like 2x, 3x."
            return (message,"taxi_instant5","Why Quick Ride Taxi")
        case 19...39:
            let message = "Going to airport, outstation or an important meeting. You can book taxi in advance for ontime pickup and have peace of mind."
            return (message,"taxi_instant3","Why Quick Ride Taxi")
        case 39...59:
            let message = "With Quick Ride you get 5% flat off on outstation taxi booking. Assured good quality vehicles and great drivers."
            return (message,"taxi_instant2","Why Quick Ride Taxi")
        case 59...79:
            let message = "Taxipool can save you upto 40%. Predefined route with max 20% route deviation."
            return (message,"taxi_instant4","Why Quick Ride Taxi")
        case 79...99:
            let message = "One stop for all your commutes. Local, Airport and Outstation. Carpool / Auto/ Taxi/ Taxipool all in one app."
            return (message,"taxi_instant6","Why Quick Ride")
        case 99...119:
            let message = "With same fare, driver gets 50% more income due to lower commission charged by Quick Ride. Happy drivers lead to better customer service."
            return (message,"taxi_instant1","Why Quick Ride Taxi")
        case 119...139:
            let message = "Refer your friends and colleagues and get upto ₹50 on each referral."
            return (message,"taxi_instant7","Why Quick Ride Taxi")
        default:
            let message = "Refer your friends and colleagues and get upto ₹50 on each referral."
            return (message,"taxi_instant7","Refer & Earn")
        }
    }
    
    func getWhyQRAutoMessageAndImage(timeDiff: Int) -> (String,String,String){
        switch timeDiff {
        case 0...19:
            let message = "Hire at tap of a button. No more hassle to hire auto"
            return (message,"auto_instant1","Why Quick Ride Auto")
        case 19...39:
            let message = "Low cost. Pay exactly as per meter. No hidden charges, no surge"
            return (message,"auto_instant2","Why Quick Ride Auto")
        case 39...59:
            let message = "Schedule in advance and get auto ontime at doorstep"
            return (message,"auto_instant3","Why Quick Ride Auto")
        case 59...79:
            let message = "Safe, quick, comfortable and low cost commute"
            return (message,"auto_instant4","Why Quick Ride Auto")
        default:
            let message = "Safe, quick, comfortable and low cost commute"
            return (message,"auto_instant4","Why Quick Ride Auto")
        }
    }
    
    static func getTaxiTypeIcon(taxiType: String?) -> UIImage?{
        if taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE{
            return UIImage(named: "bike_taxi_pool")
        }else if taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
            return UIImage(named: "Auto_icon")
        }else{
            return UIImage(named: "taxi")
        }
    }
    static func getDistanceString(distance: Double) -> String {
        if distance > 1{
            var convertDistance = distance
            let roundTodecimalTwoPoints = convertDistance.roundToPlaces(places: 1)
            return "\(roundTodecimalTwoPoints) \(Strings.KM)"
        } else {
            let roundTodecimalTwoPoints = Int(distance*1000)
            return "\(roundTodecimalTwoPoints) \(Strings.meter)"
        }
    }
    
    static func getTaxiPoints( detailedEstimatedFare : DetailedEstimateFare,taxiType: String) -> Double{
        var minFare = 0.0
        let fareForTaxis = detailedEstimatedFare.fareForTaxis
        for estimatedFare in fareForTaxis {
            if estimatedFare.taxiType == taxiType{
                for fareForVehicle in estimatedFare.fares {
                    if minFare == 0 || minFare > fareForVehicle.minTotalFare!{
                        minFare = fareForVehicle.minTotalFare!
                    }
                }
                break
            }
        }
        return minFare;
    }
    static func getAvailableVehicleClass(startTime: Double,startAddress : String?, startLatitude: Double,startLongitude: Double,endLatitude: Double, endLongitude: Double,endAddress : String?,journeyType: String, routeId: Double?, handler: @escaping(_ result: DetailedEstimateFare?, _ responseError : ResponseError?, _ error: NSError?)->()){
        TaxiPoolRestClient.getAvailableTaxiDetails(startTime: startTime, expectedEndTime: nil, startAddress: startAddress, startLatitude: startLatitude , startLongitude: startLongitude , endLatitude: endLatitude , endLongitude: endLongitude, endAddress: endAddress ,journeyType: journeyType,routeId: routeId) { (responseObject, error) in
            
            let result = RestResponseParser<DetailedEstimateFare>().parse(responseObject: responseObject, error: error)
            if let detailedEstimateFare = result.0,let responseError = checkErrorInEstimateFare(detailedEstimateFares: detailedEstimateFare){
                
                return handler(nil,responseError,nil)
            }else{
                return handler(result.0,result.1,result.2)
            }
        }
    }
    
    static func getRentalPackage(startLat: Double, startLng: Double, startAddress: String,startCity: String?,taxiVehicleCategory: String,distance: Double, startTime: Double, complitionHandler: @escaping(_ package: RentalPackageConfig?, _ responseError: ResponseError?,_ error: NSError?)-> ()){
      
        let userId = UserDataCache.getCurrentUserId()
        TaxiPoolRestClient.getRentalPackages(userId: userId, startAddress: startAddress, startLatitude: startLat, startLongitude: startLng, startCity: startCity, startTime: startTime) { (responseObject, error) in
            TaxiUtils.sendTaxiSearchedEvent(taxiRidePassengerId: 0, tripType: TaxiPoolConstants.TRIP_TYPE_RENTAL, fromAddress: startAddress, toAddress: nil, startTime: startTime)
                let result = RestResponseParser<RentalPackageConfig>().parseArray(responseObject: responseObject, error: error)
            
            if let configs = result.0 {
                for config in configs {
                    if config.vehicleClass == taxiVehicleCategory && Int(distance) == config.pkgDistanceInKm {
                        return complitionHandler(config,nil,nil)
                    }
                }
            }
            return complitionHandler(nil,result.1,result.2)
            
        }
    }
    
    static func checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: DetailedEstimateFare?, taxiVehicleCategory : String) -> FareForVehicleClass?{
        var fareForVehicleData: FareForVehicleClass?
        for detailedEstimateFare in detailedEstimateFares?.fareForTaxis ?? []{
            for fareForVehicleClass in detailedEstimateFare.fares{
                if fareForVehicleClass.vehicleClass == taxiVehicleCategory{
                    fareForVehicleData = fareForVehicleClass
                    break
                }
            }
        }
        return fareForVehicleData
    }
    static func checkErrorInEstimateFare(detailedEstimateFares: DetailedEstimateFare) -> ResponseError?{
        if detailedEstimateFares.error != nil {
            return detailedEstimateFares.error
        }
        if !detailedEstimateFares.serviceableArea{
            return ResponseError(userMessage: "Service not avaiable in these Locations, Kindly please recheck your location and try again")
        }
        return nil
    }
    static func displayFareToConfirm(currentFare : Double, newFare: Double, handler: @escaping actionComplitionHandler){
        if currentFare >= newFare {
            handler(true)
            return
        }
        let taxiBookingFareConfirmationViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiBookingFareConfirmationViewController") as! TaxiBookingFareConfirmationViewController
        taxiBookingFareConfirmationViewController.initialiseData(tripFare: newFare,complition: handler)
        ViewControllerUtils.addSubView(viewControllerToDisplay: taxiBookingFareConfirmationViewController)
        
    }
    static func getDurationDisplay( duration: Int) -> String{
        if duration <= 59 {
            return String(duration)+" min"
        }else if duration%60 == 0{
            return String(duration/60)+" hr"
        }else{
            return String(duration/60)+" hr "+String(duration%60)+" min"
        }
    }
    
    static func getSequenceAlphabetFor(index: Int) -> String{
        let charArray : [Character] = ["A","B","C","D","E","F","G","I","J","K","L","M","N","0","P","Q","R","S","T","U","V","W","X","Y","Z"]
        if index < 25 {
            return String(charArray[index])
        }else{
            return String(charArray[index%25])
        }
    }
    
    static func getNearbyTaxiMarkers(partnerRecentLocationInfo: PartnerRecentLocationInfo, viewMap: GMSMapView ) -> GMSMarker {
        let taxiMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: partnerRecentLocationInfo.latitude!, longitude: partnerRecentLocationInfo.longitude!))
        taxiMarker.map = viewMap
        taxiMarker.zIndex = 15
        taxiMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        taxiMarker.isFlat = true
        taxiMarker.isTappable = true
        if let bearing = partnerRecentLocationInfo.bearing {
            taxiMarker.rotation = bearing
        }
        taxiMarker.icon = ImageUtils.RBResizeImage(image: UIImage(named: TaxiUtils.getImageForVehicleType(vehicleClass: partnerRecentLocationInfo.vehicleClass)) ?? UIImage(), targetSize: CGSize(width: 40,height: 40))
        return taxiMarker
    }
    
    static func getImageForVehicleType(vehicleClass: String?) -> String {
        if vehicleClass == TaxiPoolConstants.TAXI_TYPE_BIKE{
            return "bike_top"
        }else if vehicleClass == TaxiPoolConstants.TAXI_TYPE_AUTO{
            return "Auto_tracking"
        }else{
            return "exclusive_taxi_tracking"
        }
    }
    
    static func getTaxiTripStatus(taxiRidePassengerDetails: TaxiRidePassengerDetails) -> String {
        if let taxiRideGroup = taxiRidePassengerDetails.taxiRideGroup {
            if taxiRidePassengerDetails.taxiRidePassenger?.status == TaxiRidePassenger.STATUS_DRIVER_REACHED_PICKUP {
                return Strings.driver_reached
            }else if TaxiRideGroup.STATUS_ALLOTTED == taxiRideGroup.status || TaxiRideGroup.STATUS_RE_ALLOTTED == taxiRideGroup.status {
                return Strings.driver_alloted
            } else if TaxiRideGroup.STATUS_STARTED == taxiRideGroup.status {
                return Strings.ride_started
            } else if TaxiRideGroup.STATUS_DELAYED == taxiRideGroup.status {
                if taxiRidePassengerDetails.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO {
                    return "Auto Delayed"
                } else if taxiRidePassengerDetails.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE {
                    return "Bike Delayed"
                } else {
                    return Strings.taxi_delayed
                }
            } else if TaxiRideGroup.BOOKING_STATUS_IN_PROGRESS == taxiRideGroup.bookingStatus || TaxiRideGroup.BOOKING_STATUS_SUCCESS == taxiRideGroup.status {
                return Strings.taxi_allotment_process;
            } else if TaxiRideGroup.STATUS_CONFIRMED == taxiRideGroup.status || TaxiRideGroup.STATUS_OPEN == taxiRideGroup.status || TaxiRideGroup.STATUS_FROZEN == taxiRideGroup.status || taxiRideGroup.availableSeats == 0 {
                if isAllocationStarted(taxiRidePassengerDetails: taxiRidePassengerDetails) {
                    if taxiRidePassengerDetails.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO {
                        return "Finding nearby Auto"
                    } else if taxiRidePassengerDetails.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE {
                        return "Finding nearby Bike"
                    } else {
                        return "Finding nearby Taxi"
                    }
                }else {
                    if taxiRidePassengerDetails.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO {
                        return "Auto Booked"
                    } else if taxiRidePassengerDetails.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE {
                        return "Bike Booked"
                    } else {
                        return "Taxi Booked"
                    }
                }
            }else {
                return taxiRideGroup.status!
            }
        }
        return "";
    }
    
    static func isAllocationStarted(taxiRidePassengerDetails: TaxiRidePassengerDetails) -> Bool {
        if isTaxiAllotted(taxiRidePassengerDetails: taxiRidePassengerDetails){
            return false
        }
        let timeDifference = DateUtils.getDifferenceBetweenTwoDatesInMins(time1 : NSDate().getTimeStamp(), time2 : taxiRidePassengerDetails.taxiRidePassenger?.pickupTimeMs ?? 0)
        if timeDifference <= 20 || SharedPreferenceHelper.getTaxiDriverAllocationStatus(taxiRidePassengerId: taxiRidePassengerDetails.taxiRidePassenger?.id ?? 0) {
            return true
        }
        return false
    }

   static func isAllocationDelayed(taxiRidePassengerDetails: TaxiRidePassengerDetails) -> Bool {
       if isTaxiAllotted(taxiRidePassengerDetails: taxiRidePassengerDetails){
           return false
       }
       if taxiRidePassengerDetails.taxiRidePassenger?.pickupTimeMs ?? 0 < NSDate().getTimeStamp() {
            return true
        }
         return false
    }
    
    static func isTaxiAllotted(taxiRidePassengerDetails: TaxiRidePassengerDetails) -> Bool {
        guard let taxiRideGroup = taxiRidePassengerDetails.taxiRideGroup else {
            return false
        }
        return TaxiRideGroup.STATUS_ALLOTTED == taxiRideGroup.status ||
        TaxiRideGroup.STATUS_RE_ALLOTTED == taxiRideGroup.status ||
        TaxiRideGroup.STATUS_DELAYED == taxiRideGroup.status ||
        TaxiRideGroup.STATUS_STARTED == taxiRideGroup.status ||
        TaxiRidePassenger.STATUS_DRIVER_EN_ROUTE_PICKUP == taxiRidePassengerDetails.taxiRidePassenger?.status
        
    }
    
    static func sendCancelEvent(taxiRidePassenger: TaxiRidePassenger?, cancelReason: String?){
        
        var params = [String : String]()
        if let  taxiRidePassenger = taxiRidePassenger  {
            params["taxiPassengerId"] = String(taxiRidePassenger.id ?? 0)
            params["tripType"] = taxiRidePassenger.tripType
            params["shareType"] = taxiRidePassenger.shareType
            params["fromAddress"] = taxiRidePassenger.startAddress ?? ""
            params["toAddress"] = taxiRidePassenger.endAddress ?? ""
            params["startTime"] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassenger.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_YYYY_MM_DD_HH_SS)
            params["userId"] = String(UserDataCache.getCurrentUserId())
            params["paymentMode"] = taxiRidePassenger.paymentMode
            params["paymentType"] = taxiRidePassenger.paymentType
        }
        if let cancelReason = cancelReason{
            params["reason"] = cancelReason
        }
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.qrTaxiCancelled, params: params, uniqueField: User.FLD_USER_ID)
    }
    static func sendTaxiBookedEvent(taxiRidePassenger: TaxiRidePassenger?,routeCategory : String?){
        
        var params = [String : String]()
        if let  taxiRidePassenger = taxiRidePassenger  {
            params["taxiPassengerId"] = String(taxiRidePassenger.id ?? 0)
            params["tripType"] = taxiRidePassenger.tripType ?? ""
            params["shareType"] = taxiRidePassenger.shareType ?? ""
            params["fromAddress"] = taxiRidePassenger.startAddress ?? ""
            params["toAddress"] = taxiRidePassenger.endAddress ?? ""
            params["startTime"] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassenger.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_YYYY_MM_DD_HH_SS)
            params["userId"] = String(UserDataCache.getCurrentUserId())
            params["paymentMode"] = taxiRidePassenger.paymentMode
            params["paymentType"] = taxiRidePassenger.paymentType
        }
        if let routeCategory = routeCategory {
            params["routeCategory"] = routeCategory
        }
        
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.qrTaxiBooked, params: params, uniqueField: User.FLD_USER_ID)
        
    }
    static func sendTaxiSearchedEvent(taxiRidePassengerId : Double,tripType : String,fromAddress: String?,toAddress: String?,startTime: Double){
        var params = [String: String]()
        params["tripType"] = tripType
        params["fromAddress"] = fromAddress ?? ""
        params["toAddress"] = toAddress ?? ""
        if startTime > 0 {
            params["startTime"] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: startTime, timeFormat: DateUtils.DATE_FORMAT_D_MMM_YYYY_h_mm_a)
        }
        params["userId"] = String(UserDataCache.getCurrentUserId())
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.qrTaxiSearched, params: params, uniqueField: User.FLD_USER_ID)
        if tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.qrTaxiOutstationSearched, params: params, uniqueField: User.FLD_USER_ID)
        }
        if tripType == TaxiPoolConstants.TRIP_TYPE_RENTAL{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.qrTaxiRentalSelected, params: params, uniqueField: User.FLD_USER_ID)
        }
    }
    
    static func sendTaxiCompletedEvent(taxiRidePassenger: TaxiRidePassenger?){
        
        var params = [String : String]()
        if let  taxiRidePassenger = taxiRidePassenger  {
            params["taxiPassengerId"] = String(taxiRidePassenger.id ?? 0)
            params["tripType"] = taxiRidePassenger.tripType ?? ""
            params["shareType"] = taxiRidePassenger.shareType ?? ""
            params["fromAddress"] = taxiRidePassenger.startAddress ?? ""
            params["toAddress"] = taxiRidePassenger.endAddress ?? ""
            params["startTime"] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassenger.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_YYYY_MM_DD_HH_SS)
            params["userId"] = String(UserDataCache.getCurrentUserId())
            params["paymentMode"] = taxiRidePassenger.paymentMode
            params["paymentType"] = taxiRidePassenger.paymentType
        }
        
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.qrTaxiRideEnd, params: params, uniqueField: User.FLD_USER_ID)
    }
    
}
