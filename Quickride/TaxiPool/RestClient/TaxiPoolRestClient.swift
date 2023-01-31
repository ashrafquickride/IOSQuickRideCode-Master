//
//  TaxiPoolRestClient.swift
//  Quickride
//
//  Created by Ashutos on 5/6/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class TaxiPoolRestClient {
    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void

    static let baseUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath
    static let CREATE_NEW_TAXI_URL = "QRTaxiShareRide/createTaxiRideNew"
    static let JOIN_TAXI_SHARE_RIDE = "QRTaxiShareRide/joinTaxiRideNew"
    static let GET_MATCHED_TAXI_LIST = "QRTaxiShareRouteMatcher/matchingTaxiRides"
    static let GET_TAXI_RIDE_DETAIL_INFO = "QRRide/taxiShareRideDetailInfo"
    static let GET_DRIVER_DETAILS = "QRTaxiShareRide/taxiDetails"
    static let LOCATION_UPDATE_TAXI_POOL = "QRTaxiShareRide/taxiLocation"
    static let RIDE_PARTICIPANT_UPDATE = "QRTaxiShareRide/participant"
    static let TAXI_RIDE_DETAILS = "/QRTaxiShareRide/taxiShareInfoForInvoice"
    static let POTENTIAL_CO_RIDERS = "/QRTaxiShareRouteMatcher/findProbablePassengers"
    static let MATCHED_TAXI = "/QRTaxiShareRouteMatcher/matchedTaxi"
    static let CREATE_OR_JOIN_TAXIPOOL = "/QRTaxiShareRide/createOrJoin"
    static let FEED_BACK_TAXIPOOL = "/QRTaxiShareRide/feedback"
    static let GET_TAXI_SHARE_MIN_MAX_FARE_INFO = "QRTaxiShareRide/taxiShareMinMaxFareInfo"
    static let FIND_BEST_MATCH_TAXI = "QRTaxiShareRouteMatcher/bestMatchedShareTaxi"
    static let UNJOIN_UPI_CANCEL = "/QRTaxiShareRide/unJoinFromTaxiRide"
    static let UPDATE_TAXI_TRIP = "/taxi/booking/update"
    static let CHANGE_TAXI_DRIVER = "/taxi/booking/changeDriver"
    //MARK: TaxiInvite
    static let TAXI_INVITE = "QRTaxiInvite"
    static let TAXI_INVITE_ACCEPT = "QRTaxiInvite/accept"
    static let TAXI_INVITE_REJECT = "QRTaxiInvite/reject"
    static let GET_ALL_INVITES_FOR_RIDE = "QRTaxiInvite/ride"
    static let CANCEL_AN_INVITE = "QRTaxiInvite/cancel"
    //MARK: OUTSTATION
    static let OUTSTATION_AVAILABILITY = "/QROutstationTaxi/checkTaxiAvailability"
    static let OUTSTATION_JOINED_DATA = "/QROutstationTaxi/outstationTaxi/info"
    static let GET_FARE_FOR_VEHICLE = "/taxi/fare/fixedFareId"
    static let TAXI_BOOKING_UPDATE_PAYMENT = "/taxi/booking/update/paymenttype"

    //MARK: RENTAL
    static let  RENTAL_TAXI_PACKAGE = "/rental/taxi"
    static let RENTAL_TAXI_BOOKING = "/rental/taxi/booking"
    static let RENTAL_STOP_POINTS = "/rental/taxi/all/stoppoint"
    static let RENTAL_ADD_NEXT_STOPOVER = "/rental/taxi/add/nextstopover"
    static let TAXI_ARROUND_LOCATION = "/taxi/around/location"
    static let TAXI_ADDITIONAL_PAYMENT = "/taxi/additional/payment"
    static let TAXI_BOOKING = "/taxi/booking"


    static func getMatchingCardList(id: String,userId: String,distance: String, viewController : UIViewController?,completionHandler : @escaping responseJSONCompletionHandler) {

        let url =  AppConfiguration.routeServerUrl + AppConfiguration.serverPort + AppConfiguration.routeServerPath + GET_MATCHED_TAXI_LIST
        var params = [String : String]()
        params[TaxiShareRide.FLD_TAXI_RIDE_ID] = id
        params[TaxiShareRide.FLD_USER_ID] = userId
        params[TaxiShareRide.FLD_TAXI_DISTANCE] = distance

        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }

    static func createNewTaxiPool(passengerRideId: String, shareType: String,taxiBookingType: String,paymentType : String?,userId : String,tripType: String?,journeyType: String? ,toTime: Double?,carType: String?,percentageAmount: Int?, viewController : UIViewController?,completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + CREATE_NEW_TAXI_URL
        var params = [String : String]()
        params[TaxiShareRide.FLD_PASSENGER_RIDE_ID] = passengerRideId
        params[TaxiShareRide.FLD_SHARE_TYPE] = shareType
        params[TaxiShareRide.FLD_TAXI_BOOKING_TYPE] = taxiBookingType
        params[TaxiShareRide.FLD_PAYMENT_TYPE] = paymentType
        params[TaxiShareRide.FLD_USER_ID] = userId
        if tripType != nil {
            params[TaxiShareRide.FLD_TRIP_TYPE] = tripType
        }
        if journeyType != nil {
            params[TaxiShareRide.FLD_JOURNEY_TYPE] = journeyType
        }
        if let toTime = toTime {
            params[TaxiShareRide.FLD_TO_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: toTime))
        }
        if carType != nil {
            params[TaxiShareRide.FLD_CAR_TYPE] = carType
        }
        if let percentageAmount = percentageAmount {
            params[TaxiShareRide.FLD_PERCENTAGE] = String(percentageAmount)
        }
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }

    static func joinedTaxiRide(id: String, userId: String,passengerRideId: String,paymentType: String?,taxiInviteId:String?, viewController : UIViewController?,completionHandler : @escaping responseJSONCompletionHandler) {

        let url =  baseUrl + JOIN_TAXI_SHARE_RIDE
        var params = [String : String]()
        params[TaxiShareRide.FLD_TAXI_RIDE_ID] = id
        params[TaxiShareRide.FLD_USER_ID] = userId
        params[TaxiShareRide.FLD_PASSENGER_RIDE_ID] = passengerRideId
        params[TaxiShareRide.FLD_PAYMENT_TYPE] = paymentType
        if let taxiInviteId = taxiInviteId {
            params[TaxiShareRide.FLD_TAXI_INVITE_ID] = taxiInviteId
        }

        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }

    static func rideTaxiDetailInfo(id: String, userId: String,passengerRideId: String, completionHandler : @escaping responseJSONCompletionHandler) {

        let url =  baseUrl + GET_TAXI_RIDE_DETAIL_INFO
        var params = [String : String]()
        params[TaxiShareRide.FLD_TAXI_RIDE_ID] = id
        params[TaxiShareRide.FLD_USER_ID] = userId
        params[TaxiShareRide.FLD_PASSENGER_RIDE_ID] = passengerRideId

        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func getLocationUpdateForTaxiPool(id: String, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + LOCATION_UPDATE_TAXI_POOL
        var params = [String : String]()
        params[TaxiShareRide.FLD_TAXI_RIDE_ID] = id
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func getTaxiShareRide(id: Double, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + TAXI_RIDE_DETAILS
        var params = [String : String]()
        params[TaxiShareRide.FLD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiShareRide.FLD_TAXI_RIDE_ID_ANALYTICS] = StringUtils.getStringFromDouble(decimalNumber: id)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: Rating TaxiPool
    static func getTaxiPoolRating(taxiRideId:Double ,completionHandler : @escaping responseJSONCompletionHandler) {
        let url = baseUrl + FEED_BACK_TAXIPOOL
        var params = [String : String]()
        params[TaxiShareRide.FLD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiShareRide.FLD_TAXI_RIDE_ID_ANALYTICS] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func saveTaxiPoolRating(taxiRideId: Double,noOfRating: Double, feedback: String?,completionHandler : @escaping responseJSONCompletionHandler ) {
        let url = baseUrl + FEED_BACK_TAXIPOOL
        var params = [String : String]()
        params[TaxiShareRide.FLD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiShareRide.FLD_TAXI_RIDE_ID_ANALYTICS] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        params[TaxiShareRide.FLD_TAXI_NO_OF_RATING] = StringUtils.getStringFromDouble(decimalNumber: noOfRating)
        if let feedback = feedback {
            params[TaxiShareRide.FLD_TAXI_FEEDBACK] = feedback
        }
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    //MARK: Analytics Notification
    static func getMatchedShareTaxiForAnalyticsNotification(passengerRideId: Double,taxiRideId: Double?, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  AppConfiguration.routeServerUrl + AppConfiguration.serverPort + AppConfiguration.routeServerPath + MATCHED_TAXI
        var params = [String : String]()
        params[TaxiShareRide.FLD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiShareRide.FLD_PASSENGER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[TaxiShareRide.FLD_TAXI_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)

        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func createOrJoinTaxiRide(passengerRideId: Double,taxiRideId: Double?,shareType: String, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + CREATE_OR_JOIN_TAXIPOOL
        var params = [String : String]()
        if taxiRideId != nil {
            params[TaxiShareRide.FLD_TAXI_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        }
        params[TaxiShareRide.FLD_PASSENGER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[TaxiShareRide.FLD_SHARE_TYPE] = shareType
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getPotentialCoRiders(passengerRideId: Double,taxiRideId: Double?,filterPassengerRideId: Double, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  AppConfiguration.routeServerUrl + AppConfiguration.serverPort + AppConfiguration.routeServerPath + POTENTIAL_CO_RIDERS
        var params = [String : String]()
        params[TaxiShareRide.FLD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiShareRide.FLD_PASSENGER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[TaxiShareRide.FLD_FILTER_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: filterPassengerRideId)
        if taxiRideId != nil {
            params[TaxiShareRide.FLD_TAXI_RIDE_ID_ANALYTICS] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        }
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    //MARK: TaxiPoolHomePage
    static func getMinMaxFareForTaxiPool(taxiStartLat: Double,taxiStartLng: Double,taxiEndLat: Double,taxiEndLng: Double, distance: Double,durationInMins: Double, routeId: Double,taxiStartTime: Double,completionHandler : @escaping responseJSONCompletionHandler) {
        let url = baseUrl + GET_TAXI_SHARE_MIN_MAX_FARE_INFO
        var params = [String : String]()
        params[TaxiShareRide.FLD_TAXI_RIDE_PASS_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiShareRide.FLD_TAXI_START_LAT] = String(taxiStartLat)
        params[TaxiShareRide.FLD_TAXI_START_LNG] = String(taxiStartLng)
        params[TaxiShareRide.FLD_TAXI_END_LAT] = String(taxiEndLat)
        params[TaxiShareRide.FLD_TAXI_END_LNG] =  String(taxiEndLng)
        params[Ride.FLD_DISTANCE] = String(distance)
        params[TaxiShareRide.FLD_DURATION_IN_MIN] = StringUtils.getStringFromDouble(decimalNumber: durationInMins)
        params[Ride.FLD_ROUTE_ID] = StringUtils.getStringFromDouble(decimalNumber: routeId)
        params[Ride.FLD_NO_OF_SEATS] = "1"
        params[TaxiShareRide.FLD_TAXI_START_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: taxiStartTime))
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func findBestMatchForTaxiPool(startLatitude: Double,startLongitude: Double,endLatitude: Double, endLongitude: Double,startTime: Double,shareType: String,completionHandler : @escaping responseJSONCompletionHandler) {
        let url = AppConfiguration.routeServerUrl + AppConfiguration.serverPort + AppConfiguration.routeServerPath + FIND_BEST_MATCH_TAXI
        var params = [String : String]()
        params[Ride.FLD_USERID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude)
        params[Ride.FLD_ENDLONGITUDE] =  String(endLongitude)
        params[Ride.FLD_NO_OF_SEATS] = "1"
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime))
        params[TaxiShareRide.FLD_SHARE_TYPE] = shareType
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    //MARK: InvitePassenger
    static func invitePassengerTaxiPool(taxiInviteEntity: String,completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + TAXI_INVITE
        var params = [String : String]()
        params[TaxiShareRide.FLD_TAXIINVITE] = taxiInviteEntity
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    //Accept An invite
    static func acceptInvite(inviteId: Double,completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + TAXI_INVITE_ACCEPT
        var params = [String : String]()
        params[TaxiShareRide.FLD_INVITEID] = StringUtils.getStringFromDouble(decimalNumber: inviteId)
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    //Reject An invite
    static func rejectInvite(inviteId: String,completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + TAXI_INVITE_REJECT
        var params = [String : String]()
        params[TaxiShareRide.FLD_INVITEID] = inviteId
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func cancelInvite(inviteId: String,completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + CANCEL_AN_INVITE
        var params = [String : String]()
        params[TaxiShareRide.FLD_INVITEID] = inviteId
        params[TaxiShareRide.FLD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getAllTaxiInvitesForTheRide(rideId: Double,completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + GET_ALL_INVITES_FOR_RIDE
        var params = [String : String]()
        params[Ride.FLD_RIDEID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_RIDETYPE] = Ride.PASSENGER_RIDE
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }



    static func unJoinInCaseOfUPICancel(taxiRideId: Double,passengerRideId: Double,cancelPassengerRide: Bool, completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  baseUrl + UNJOIN_UPI_CANCEL
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        params[TaxiShareRide.FLD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiShareRide.FLD_PASSENGER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[TaxiShareRide.FLD_CANCELLATION_REMARK] = TaxiShareRide.UPI_CANCEL_REASON
        params[TaxiShareRide.FLD_CANCEL_PASSENGER_RIDE] = String(cancelPassengerRide)
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
}

//MARK: New taxipool data
extension TaxiPoolRestClient {

    static let newBaseURL = AppConfiguration.taxiDemandServerUrlIp + AppConfiguration.TD_serverPort + "/taxidemandserver/rest"
    static let GET_TAXI_FARE = "/taxi/fare"
    static let BOOK_TAXI = "/taxi/booking"
    static let GET_ACTIVE_RIDES = "​/taxi​/booking​/activeTaxiRides"
    static let GET_CLOSED_RIDES = "/taxi/booking/closedTaxiRides"
    static let GET_TAXI_DETAILS = "/taxi/booking/taxiRidePassenger/details"
    static let GETTING_TAXI_INVOICE_PATH = "/taxiRideInvoice/invoice/refId"
    static let TAXI_RIDE_FEEDBACK_PATH = "/taxi/ride/feedback"
    static let CANCEL_RIDE_TAXI_RIDE = "/taxi/booking/cancel"
    static let GET_CANCEL_RIDE_INVOICE = "/taxi/ride/cancellation/passenger"
    static let TAXI_RIDE_LOCATION_PATH = "/taxi/booking/taxiLocation"
    static let SEND_INVOICE_TO_PASSENGER = "/taxiRideInvoice/sendInvoice"
    static let RESCHEDULE_TAXI_RIDE = "/taxi/booking/reschedule"
    static let UPADTE_TAXI_FARE = "/taxi/booking/update/fare"
    static let CLEAR_TAXI_PENDING_BILL = "/taxi/booking/pay/bill"
    static let GET_TAXI_PENDING_BILL = "/taxi/booking/passengerPaymentDetails"
    static let TAXI_EMERGENCY_PATH = "/taxi/Alert"

    //OutStation
    static let ADD_PAYMNET_ON_THE_WAY = "/taxi/additional/payment"
    static let GET_TRIP_PAYMNET_DETAILS = "/taxi/additional/payment/trip"
    static let UPDATE_PAYMENT_STATUS_ADDED_BY_DRIVER = "/taxi/fare/details/update/driver/payment/status"
    static let GET_FARE_BREAK_UP_DURING_TRIP = "/taxi/fare/details/passenger"
    static let GET_FARE_BREAK_UP_FOR_TRIP_REPORT = "/taxi/fare/details/limited"
    static let GET_MAX_CANCELLATION_FEE = "/taxi/booking/max/cancellation"
    static let GET_TAXI_PAYMENT_LINK = "/taxi/fare/details/create/paymentLink"
    static let GET_PAYMENT_FARETYPE = "/taxi/additional/payment/customer/faretype"
    static let TAXI_BOOKING_UPDATE_COMMUTE = "/taxi/booking/update/commute"


    //MARK: New TaxiPool Data Apis
    static func getAvailableTaxiDetails(startTime: Double?,expectedEndTime: Double?,startAddress : String?, startLatitude: Double,startLongitude: Double,endLatitude: Double, endLongitude: Double,endAddress : String?, journeyType : String?,routeId: Double?,completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  newBaseURL + GET_TAXI_FARE
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        if let time = startTime{
            params[TaxiRidePassenger.FIELD_START_TIME] = StringUtils.getStringFromDouble(decimalNumber: time)
        }
        if let startAddress = startAddress {
            params[TaxiRidePassenger.FIELD_START_ADDRESS] = startAddress
        }
        if startLatitude != TaxiRidePassenger.UNKNOWN_LAT{
            params[TaxiRidePassenger.FIELD_START_LAT] = String(startLatitude)
            params[TaxiRidePassenger.FIELD_START_LNG] = String(startLongitude)
        }

        if let endAddress = endAddress {
            params[TaxiRidePassenger.FIELD_END_ADDRESS] = endAddress
        }
        if endLatitude != TaxiRidePassenger.UNKNOWN_LAT{
            params[TaxiRidePassenger.FIELD_END_LAT] = String(endLatitude)
            params[TaxiRidePassenger.FIELD_END_LNG] =  String(endLongitude)
        }

        if let expectedEndTime = expectedEndTime {
            params[TaxiRidePassenger.FIELD_EXPECTED_END_TIME] = StringUtils.getStringFromDouble(decimalNumber: expectedEndTime)
        }
        if let journeyType = journeyType {
            params[TaxiRidePassenger.FIELD_JOURNEY_TYPE] = journeyType
        }
        if let routeId = routeId , routeId > 0 {
            params[TaxiRidePassenger.FIELD_SELECTED_ROUTE_ID] = StringUtils.getStringFromDouble(decimalNumber: routeId)
        }
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func bookNewTaxi(startTime: Double,expectedEndTime: Double?,startAddress : String, startLatitude: Double,startLongitude: Double,endLatitude: Double, endLongitude: Double,endAddress : String,tripType: String, journeyType : String?,vehicleCategory: String,taxiType: String,routeId: Double?,maxFare: Double?,advPaymentPercent: Int?,paymentType: String?,fixedfareID: String,shareType: String, refRequestId : Double?,enablePayLater: Bool,couponCode: String?,startCity: String?,startState: String?,endCity: String?,endState: String?, paymentMode: String?,taxiGroupId: Double?,refInviteId: String?,commuteContactNo: String?, commutePassengerName: String?, completionHandler : @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + BOOK_TAXI

        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRidePassenger.FIELD_CREATED_BY] = UserDataCache.getInstance()?.getUserName()
        params[TaxiRidePassenger.FIELD_ORIGINATING_APP] = "QuickRide iOS"
        params[TaxiRidePassenger.FIELD_START_TIME] = StringUtils.getStringFromDouble(decimalNumber: startTime)
        params[TaxiRidePassenger.FIELD_START_ADDRESS] = startAddress
        params[TaxiRidePassenger.FIELD_START_LAT] = String(startLatitude)
        params[TaxiRidePassenger.FIELD_START_LNG] = String(startLongitude)
        params[TaxiRidePassenger.FIELD_END_ADDRESS] = String(endAddress)
        params[TaxiRidePassenger.FIELD_END_LAT] = String(endLatitude)
        params[TaxiRidePassenger.FIELD_END_LNG] =  String(endLongitude)
        params[TaxiRidePassenger.FIELD_NO_OF_SEATS] = "1"
        params[TaxiRidePassenger.FIELD_TAXI_VEHICLE_CATEGORY] = vehicleCategory
        params[TaxiRidePassenger.FIELD_TAXI_TYPE] = taxiType
        params[TaxiRidePassenger.FIELD_TRIP_TYPE] = tripType
        params[TaxiRidePassenger.FIELD_PAYMENT_TYPE] = paymentType
        params[TaxiRidePassenger.FIELD_FIXED_FARE_ID] = fixedfareID
        params[TaxiRidePassenger.FIELD_SHARE_TYPE] = shareType
        params[TaxiRidePassenger.FIELD_ENABLE_PAYLATER] = String(enablePayLater)
        if let maxFare = maxFare {
            params[TaxiRidePassenger.FIELD_MAX_FARE] = StringUtils.getStringFromDouble(decimalNumber: maxFare)
        }
        if let refRequestId = refRequestId {
            params[TaxiRidePassenger.FIELD_REF_REQUEST_ID] = StringUtils.getStringFromDouble(decimalNumber: refRequestId)
        }

        if let contactNumber = UserDataCache.getInstance()?.currentUser?.contactNo {
            params[TaxiRidePassenger.FIELD_CONTACT_NO] = StringUtils.getStringFromDouble(decimalNumber: contactNumber)
        }
        if let maxFare = maxFare {
            params[TaxiRidePassenger.FIELD_MAX_FARE] = String(maxFare)
        }
        if let expectedEndTime = expectedEndTime {
            params[TaxiRidePassenger.FIELD_EXPECTED_END_TIME] = StringUtils.getStringFromDouble(decimalNumber: expectedEndTime)
        }
        if let journeyType = journeyType {
            params[TaxiRidePassenger.FIELD_JOURNEY_TYPE] = journeyType
        }
        if let routeId = routeId {
            params[TaxiRidePassenger.FIELD_SELECTED_ROUTE_ID] = StringUtils.getStringFromDouble(decimalNumber: routeId)
        }
        if let advPaymentPercent = advPaymentPercent {
            params[TaxiRidePassenger.FIELD_ADVANCE_PAYMENT_PERCENTAGE] = String(advPaymentPercent)
        }
        if let code = couponCode, !code.isEmpty{
            params[TaxiRidePassenger.FIELD_COUPON_CODE] = code
        }
        if let city = startCity{
            params[TaxiRidePassenger.START_CITY] = city
        }
        if let state = startState{
            params[TaxiRidePassenger.START_STATE] = state
        }
        if let city = endCity{
            params[TaxiRidePassenger.END_CITY] = city
        }
        if let state = endState{
            params[TaxiRidePassenger.END_STATE] = state
        }
        if let paymentMode = paymentMode{
            params[TaxiRidePassenger.FIELD_PAYMENT_MODE] = paymentMode
        }
        if let id = taxiGroupId {
            params[TaxiRidePassenger.FIELD_TAXI_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: id)
        }
        if let inviteId = refInviteId {
            params[TaxiRidePassenger.REF_INVITED_ID] = String(inviteId)
        }
        if let commuteContactNo = commuteContactNo {
            params[TaxiRidePassenger.FIELD_COMMUTE_CONTACT_NO] = commuteContactNo
        }
        if let commutePassengerName = commutePassengerName {
            params[TaxiRidePassenger.FIELD_COMMUTE_PASSENGER_NAME] = commutePassengerName
        }
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    //MARK: Get Active rides
    static func getActiveTaxiRides(completionHandler : @escaping responseJSONCompletionHandler) {
        let userId = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        let url = newBaseURL + "/taxi/booking/activeTaxiRides?userId=\(userId)"
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: [:], handler: completionHandler)
    }
    //MARK: Get closed rides
    static func getClosedTaxiRides(completionHandler : @escaping responseJSONCompletionHandler) {
        let url =  newBaseURL + GET_CLOSED_RIDES
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: GettaxiDetails
    static func getTaxiDetailsFromServer(rideId: Double,completionHandler : @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + GET_TAXI_DETAILS
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: Invoice
    static func getTaxiPoolInvoice(refId: Double,completionHandler: @escaping responseJSONCompletionHandler) {
        AppDelegate.getAppDelegate().log.debug("getTaxiBill()")
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + GETTING_TAXI_INVOICE_PATH
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRidePassenger.FIELD_REF_ID] = StringUtils.getStringFromDouble(decimalNumber: refId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: GetRating
    static func getTaxiRideFeedBack(taxiId: String, taxiGroupId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + TAXI_RIDE_FEEDBACK_PATH
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRideFeedback.FIELD_TAXI_RIDE_ID] = taxiId
        params[TaxiRideFeedback.FIELD_TAXI_GROUP_ID] = taxiGroupId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    //MARK: Save Rating
    static func postTaxiRideFeedBack(noOfRating: Double,feedBack: String?,taxiId: Double, taxiGroupId: Double,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + TAXI_RIDE_FEEDBACK_PATH
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRideFeedback.FIELD_TAXI_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiId)
        params[TaxiRideFeedback.FIELD_TAXI_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        params[TaxiRideFeedback.FIELD_RATING] = StringUtils.getStringFromDouble(decimalNumber: noOfRating)
        if let feedBack = feedBack {
            params[TaxiRideFeedback.FIELD_FEEDBACK] = feedBack
        }
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    //MARK: CancelRide
    static func cancelTaxiRide(taxiId: Double, cancellationReason: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + CANCEL_RIDE_TAXI_RIDE
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiId)
        params[TaxiRidePassenger.FIELD_TAXI_UNJOIN_REASON] = cancellationReason
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    //MARK: Cancel trip invoice details
    static func getCancelTripInvoice(taxiRideId: Double,userId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + GET_CANCEL_RIDE_INVOICE
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = userId
        params[TaxiRidePassenger.FIELD_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    //MARK: Location Update
    static func getLocationUpdate(taxiGroupId: Double,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + TAXI_RIDE_LOCATION_PATH
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_TAXI_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: send invoice
    static func sendInvoiceToPassengerMail(taxiInvoiceId: Double,userId:Double,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + SEND_INVOICE_TO_PASSENGER
        var params = [String: String]()
        params[TaxiRideInvoice.invoiceId] = StringUtils.getStringFromDouble(decimalNumber: taxiInvoiceId)
        params[TaxiRideInvoice.userId] = StringUtils.getStringFromDouble(decimalNumber: userId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: Fare for vehicel class
    static func getFareForVehicle(fixedFareId: Double,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + GET_FARE_FOR_VEHICLE
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_FIXED_FARE_ID] = StringUtils.getStringFromDouble(decimalNumber: fixedFareId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: Reschedule taxi ride
    static func rescheduleTaxiRide(userId: String,taxiRidePassengerId: Double,startTime: Double,fixedFareId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + RESCHEDULE_TAXI_RIDE
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = userId
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params[TaxiRidePassenger.FIELD_START_TIME] = StringUtils.getStringFromDouble(decimalNumber: startTime)
            params[TaxiRidePassenger.FIELD_FIXED_FARE_ID] = fixedFareId
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    //MARK: Reschedule taxi ride
    static func updateTaxiFare(userId: String,taxiRidePassengerId: Double,fixedFareId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + UPADTE_TAXI_FARE
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = userId
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params[TaxiRidePassenger.FIELD_FIXED_FARE_ID] = fixedFareId
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    //MARK: pay pending bill
    static func clearTaxPendingiBill(taxiRidePassengerId: Double,userId: String,paymentType: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + CLEAR_TAXI_PENDING_BILL
        var params = [String: String]()
        params[TaxiRideInvoice.userId] = userId
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params[TaxiRidePassenger.FIELD_PAYMENT_TYPE] = paymentType
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    //MARK: get pending taxi bill
    static func getTaxiPendingBill(id: Double,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + GET_TAXI_PENDING_BILL
        var params = [String: String]()
        params["id"] = StringUtils.getStringFromDouble(decimalNumber: id)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: TaxiEmergency
    static func initiateTaxiEmergency(type: String,userId: String,payload: String,rideTrackUrl: String,acknowledgedBy: String, completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + TAXI_EMERGENCY_PATH
        var params = [String: String]()
        params["type"] = type
        params["userId"] = userId
        params["payload"] = payload
        params["acknowledgedBy"] = acknowledgedBy
        params["rideTrackUrl"] = rideTrackUrl
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    //MARK: TaxiUpate
    static func updateTaxiTrip(startTime: Double?,expectedEndTime: Double?,endLatitude: Double?, endLongitude: Double?,endAddress : String?,fixedfareID: String?,taxiRidePassengerId: Double,startLatitude: Double?,startLongitude: Double?,startAddress: String?,pickupNote:String?,selectedRouteId: Double?, completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + UPDATE_TAXI_TRIP
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        if let startTime = startTime{
           params[TaxiRidePassenger.FIELD_START_TIME] = StringUtils.getStringFromDouble(decimalNumber: startTime)
        }
        if let expectedEndTime = expectedEndTime {
            params[TaxiRidePassenger.FIELD_EXPECTED_END_TIME] = StringUtils.getStringFromDouble(decimalNumber: expectedEndTime)
        }
        if let lat = endLatitude,let lng = endLongitude,let address = endAddress{
            params[TaxiRidePassenger.FIELD_END_ADDRESS] = String(address)
            params[TaxiRidePassenger.FIELD_END_LAT] = String(lat)
            params[TaxiRidePassenger.FIELD_END_LNG] =  String(lng)
        }
        if let lat = startLatitude,let lng = startLongitude,let address = startAddress{
            params[TaxiRidePassenger.FIELD_START_LAT] = String(lat)
            params[TaxiRidePassenger.FIELD_START_LNG] = String(lng)
            params[TaxiRidePassenger.FIELD_START_ADDRESS] = address
        }
        if let note = pickupNote{
            params[TaxiRidePassenger.FIELD_PICKUP_NOTE] = note
        }
        if let fixedfareID = fixedfareID {
            params[TaxiRidePassenger.FIELD_FIXED_FARE_ID] = fixedfareID
        }

        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        if let routeId = selectedRouteId{
        params[TaxiRidePassenger.FIELD_SELECTED_ROUTE_ID] = StringUtils.getStringFromDouble(decimalNumber: routeId)
        }
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func addAdditionalPaymentOntheWay(taxiGroupId: Double,customerId: String,amount: String,paymentType: String,fareType: String,description: String, completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + ADD_PAYMNET_ON_THE_WAY
        var params = [String: String]()
        params[TaxiUserAdditionalPaymentDetails.FIELD_TAXI_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        params[TaxiUserAdditionalPaymentDetails.FIELD_CUSTOMER_ID] = customerId
        params[TaxiUserAdditionalPaymentDetails.FIELD_AMOUNT] = amount
        params[TaxiUserAdditionalPaymentDetails.FIELD_PAYMENT_TYPE] = paymentType
        params[TaxiUserAdditionalPaymentDetails.FIELD_FARE_TYPE] = fareType
        params[TaxiUserAdditionalPaymentDetails.FIELD_DESCRIPTION] = description
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func getAdditionalPaymentDetails(taxiGroupId: Double,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + GET_TRIP_PAYMNET_DETAILS
        var params = [String: String]()
        params[TaxiUserAdditionalPaymentDetails.FIELD_TAXI_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        params[TaxiUserAdditionalPaymentDetails.FIELD_CUSTOMER_ID] = UserDataCache.getInstance()?.userId ?? ""
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    static func updateAddedPaymentStatus(id: String,customerId: String,status: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + UPDATE_PAYMENT_STATUS_ADDED_BY_DRIVER
        var params = [String: String]()
        params[TaxiUserAdditionalPaymentDetails.FIELD_ID] = id
        params[TaxiUserAdditionalPaymentDetails.FIELD_CUSTOMER_ID] = customerId
        params[TaxiUserAdditionalPaymentDetails.FIELD_STATUS] = status
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func getFareBreakUpDuringTrip(taxiRideId: Double,userId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + GET_FARE_BREAK_UP_DURING_TRIP
        var params = [String: String]()
        params[TaxiUserAdditionalPaymentDetails.FIELD_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        params[TaxiRidePassenger.FIELD_USER_ID] = userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    static func getFareBreakUpForTripReport(taxiRideId: Double,userId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + GET_FARE_BREAK_UP_FOR_TRIP_REPORT
        var params = [String: String]()
        params[TaxiUserAdditionalPaymentDetails.FIELD_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        params[TaxiRidePassenger.FIELD_USER_ID] = userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    static func getMaxCancellationFee(taxiRideId: Double,userId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + GET_MAX_CANCELLATION_FEE
        var params = [String: String]()
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRideId)
        params[TaxiRidePassenger.FIELD_USER_ID] = userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    //MARK: Change Driver
    static func changeTaxiDriver(driverChangeReason : String, taxiGroupId: Double,taxiRidePassengerId: Double,customerId: Double,status : String, completionHandler : @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + CHANGE_TAXI_DRIVER
        var params = [String: String]()
        params[TaxiRidePassenger.DRIVER_CHANGE_REASON] = driverChangeReason
        params[TaxiRidePassenger.FIELD_TAXI_GROUP_ID ] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        params[TaxiRidePassenger.FIELD_CUSTOMER_ID ] = StringUtils.getStringFromDouble(decimalNumber: customerId)
        params[TaxiRidePassenger.FIELD_STATUS ] = status
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
}
//MARK: Driver
extension TaxiPoolRestClient {
    static let  DRIVER_BOOKING_ENDPOINT = "/driver/booking"

    static func bookDriver(startTime: Double,startAddress : String, startLatitude: Double,startLongitude: Double,endLatitude: Double, endLongitude: Double,endAddress : String,vehicleType: String,journeyType: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = newBaseURL + DRIVER_BOOKING_ENDPOINT
        var params = [String: String]()
        params["customerId"] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        if let contactNumber = UserDataCache.getInstance()?.currentUser?.contactNo {
            params["customerContactNo"] = StringUtils.getStringFromDouble(decimalNumber: contactNumber)
            params["customerName"] = UserDataCache.getInstance()?.currentUser?.userName
        }
        params[TaxiRidePassenger.FIELD_START_TIME] = StringUtils.getStringFromDouble(decimalNumber: startTime)
        params[TaxiRidePassenger.FIELD_START_ADDRESS] = startAddress
        params[TaxiRidePassenger.FIELD_START_LAT] = String(startLatitude)
        params[TaxiRidePassenger.FIELD_START_LNG] = String(startLongitude)
        params[TaxiRidePassenger.FIELD_END_ADDRESS] = String(endAddress)
        params[TaxiRidePassenger.FIELD_END_LAT] = String(endLatitude)
        params[TaxiRidePassenger.FIELD_END_LNG] =  String(endLongitude)
        params["vehicleType"] = vehicleType
        params["journeyType"] = journeyType
        params["paymentRequired"] = String(true)
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func getRentalPackages(userId: Double, startAddress : String, startLatitude: Double,startLongitude: Double,startCity: String?, startTime: Double?, completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.RENTAL_TAXI_PACKAGE
        params[TaxiRidePassenger.FIELD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params[TaxiRidePassenger.FIELD_START_ADDRESS] = startAddress
        params[TaxiRidePassenger.FIELD_START_LAT] = String(startLatitude)
        params[TaxiRidePassenger.FIELD_START_LNG] = String(startLongitude)
        if let startCity = startCity {
            params[TaxiRidePassenger.FIELD_START_CITY] = startCity
        }
        if let startTime = startTime {
            params[TaxiRidePassenger.FIELD_START_TIME] = StringUtils.getStringFromDouble(decimalNumber: startTime)
        }
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }

    static func bookRentalTaxi(startTime: Double,startAddress : String, startLatitude: Double, startLongitude: Double, startCity: String?, rentalPackageId: Int,taxiVehicleCategory: String?,paymentType: String? ,paymentMode:String? , enablePayLater: Bool,commuteContactNo: String?, commutePassengerName: String?, completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.RENTAL_TAXI_BOOKING
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRidePassenger.FIELD_CREATED_BY] = UserDataCache.getInstance()?.getUserName()
        params[TaxiRidePassenger.FIELD_ORIGINATING_APP] = "QuickRide iOS"
        params[TaxiRidePassenger.FIELD_START_TIME] = StringUtils.getStringFromDouble(decimalNumber: startTime)
        params[TaxiRidePassenger.FIELD_START_ADDRESS] = startAddress
        params[TaxiRidePassenger.FIELD_START_LAT] = String(startLatitude)
        params[TaxiRidePassenger.FIELD_START_LNG] = String(startLongitude)
        params[TaxiRidePassenger.FIELD_START_CITY] = startCity
        params[TaxiRidePassenger.FIELD_PAYMENT_TYPE] = paymentType
        params[TaxiRidePassenger.FIELD_PAYMENT_MODE] = paymentMode
        params[TaxiRidePassenger.FIELD_RENTAL_PACKAGE_ID] = String(rentalPackageId)
        params[TaxiRidePassenger.FIELD_ENABLE_PAYLATER] = String(enablePayLater)
        if let taxiVehicleCategory = taxiVehicleCategory {
            params[TaxiRidePassenger.FIELD_TAXI_VEHICLE_CATEGORY] = taxiVehicleCategory
        }
        if let commuteContactNo = commuteContactNo {
            params[TaxiRidePassenger.FIELD_COMMUTE_CONTACT_NO] = commuteContactNo
        }
        if let commutePassengerName = commutePassengerName {
            params[TaxiRidePassenger.FIELD_COMMUTE_PASSENGER_NAME] = commutePassengerName
        }
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getAllRentalTaxiRideStopPoint(taxiGroupId: Double,completionHandler: @escaping responseJSONCompletionHandler) {
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.RENTAL_STOP_POINTS
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRidePassenger.FIELD_TAXI_GROUP_ID ] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    static func changePaymentMethod(taxiRideId: String, userId: String,paymentType: String,paymentMode:String, completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        let url = newBaseURL + TAXI_BOOKING_UPDATE_PAYMENT
        params[TaxiRidePassenger.FIELD_USER_ID] = userId
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = taxiRideId
        params[TaxiRidePassenger.FIELD_PAYMENT_TYPE] = paymentType
        params[TaxiRidePassenger.FIELD_PAYMENT_MODE] = paymentMode
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func addNextStopOverPoint(taxiRidePassengerId: Double?,startAddress : String?, startLatitude: Double?, startLongitude: Double?,stopPointAddress: String?,stopPointLat: Double?,stopPointLng: Double?, completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.RENTAL_ADD_NEXT_STOPOVER
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        if let startAddress = startAddress {
            params[TaxiRidePassenger.FIELD_START_ADDRESS] = startAddress
        }
        if let startLatitude = startLatitude {
            params[TaxiRidePassenger.FIELD_START_LAT] =  String(startLatitude)
        }
        if let startLongitude = startLongitude{
            params[TaxiRidePassenger.FIELD_START_LNG] = String(startLongitude)
        }
        params[TaxiRidePassenger.FIELD_STOP_POINT_ADDRESS] = stopPointAddress
        if let stopPointLat = stopPointLat{
            params[TaxiRidePassenger.FIELD_STOP_POINT_LAT] = String(stopPointLat)
        }
        if let stopPointLng = stopPointLng{
            params[TaxiRidePassenger.FIELD_STOP_POINT_LNG] = String(stopPointLng)
        }
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getNearbyTaxi(startLatitude: Double?, startLongitude: Double?, taxiType: String?, maxNoOfTaxiToShow: Int, maxDistance: Int, completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.TAXI_ARROUND_LOCATION
        params[TaxiRidePassenger.FIELD_USER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        if let startLatitude = startLatitude {
            params[TaxiRidePassenger.FIELD_LATITUDE] =  String(startLatitude)
        }
        if let startLongitude = startLongitude{
            params[TaxiRidePassenger.FIELD_LONGITUDE] = String(startLongitude)
        }
        params[TaxiRidePassenger.FIELD_MAX_RESULT] = String(maxNoOfTaxiToShow)
        params[TaxiRidePassenger.FIELD_MAX_DISTANCE] = String(maxDistance)
        if let taxiType = taxiType {
            params[TaxiRidePassenger.FIELD_TAXI_TYPE] = String(taxiType)
        }
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
        }
    static func confirmCashPaid(taxiGroupId: Double?, amount: Double?,fareType: String,description:String,completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
         let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.TAXI_ADDITIONAL_PAYMENT
        params[TaxiUserAdditionalPaymentDetails.FIELD_TAXI_GROUP_ID ] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        params[TaxiUserAdditionalPaymentDetails.FIELD_CUSTOMER_ID] = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        if let amount = amount {
            params[TaxiUserAdditionalPaymentDetails.FIELD_AMOUNT] = StringUtils.getStringFromDouble(decimalNumber: amount)
        }
        params[TaxiUserAdditionalPaymentDetails.FIELD_PAYMENT_TYPE] = TaxiRidePassenger.PAYMENT_MODE_CASH
        params[TaxiUserAdditionalPaymentDetails.FIELD_FARE_TYPE] = fareType
        params[TaxiUserAdditionalPaymentDetails.FIELD_DESCRIPTION] = description
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }

    static func getPaymentLinkForPayment(taxiRidePassengerId: Double,completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.GET_TAXI_PAYMENT_LINK
        params[TaxiRidePassenger.FIELD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber : UserDataCache.getCurrentUserId())
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    
    static func getTaxiRidePasssengerFromServer(taxiRidePassengerId: Double?,completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.TAXI_BOOKING
        params[TaxiRidePassenger.FIELD_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func getTaxiUserAdditionalPaymentDetailsOfCustomerBasedOnFareType(taxiGroupId: Double?,fareType: String,completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TaxiPoolRestClient.GET_PAYMENT_FARETYPE
        params[TaxiUserAdditionalPaymentDetails.FIELD_CUSTOMER_ID] = StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId())
        params[TaxiRidePassenger.FIELD_TAXI_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiGroupId)
        params[TaxiUserAdditionalPaymentDetails.FIELD_FARE_TYPE] = fareType
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func updateTaxiBehalfBookedContactDetails(taxiRidePassengerId: Double, commuteContactNo: String, commutePassengerName: String, completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = TaxiPoolRestClient.newBaseURL + TAXI_BOOKING_UPDATE_COMMUTE
        params[TaxiRidePassenger.FIELD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber : UserDataCache.getCurrentUserId())
        params[TaxiRidePassenger.FIELD_COMMUTE_CONTACT_NO] = commuteContactNo
        params[TaxiRidePassenger.FIELD_COMMUTE_PASSENGER_NAME] = commutePassengerName
        params[TaxiRidePassenger.FIELD_TAXI_RIDE_PASSENGER_ID] = StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
}
