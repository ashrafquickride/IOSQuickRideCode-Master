//
//  JoinPassengerToRideHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 14/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

protocol RideInvitationActionCompletionListener
{
    func rideInviteAcceptCompleted(rideInvitationId : Double)
    func rideInviteRejectCompleted(rideInvitation : RideInvitation)
    func rideInviteActionFailed(rideInvitationId : Double, responseError: ResponseError?,error:NSError?, isNotificationRemovable : Bool)
    func rideInviteActionCancelled()
}

class JoinPassengerToRideHandler {

    var viewController : UIViewController?
    var riderRideId : Double
    var riderId : Double
    var passengerRideId : Double
    var passengerId : Double
    var rideType : String?
    var pickupAddress : String?
    var pickupLatitude : Double
    var pickupLongitude : Double
    var pickupTime : Double?
    var dropAddress : String?
    var dropLatitude : Double
    var dropLongitude : Double
    var dropTime : Double?
    var matchingDistance : Double
    var points : Double
    var newFare : Double = -1
    var noOfSeats : Int = 1
    var rideInvitationId : Double

    var invitingUserName : String?
    var invitingUserId : Double?
    var displayPointsConfirmationAlert : Bool
    var listener : RideInvitationActionCompletionListener?
    var joinCompleted = false
    var riderHasHelmet = false
    var pickupTimeRecalculationRequired = true
    var passengerRouteMatchPercentage = 0
    var riderRouteMatchPercentage = 0
    var moderatorId: String?

    init( viewController : UIViewController?,riderRideId : Double,riderId : Double,passengerRideId : Double,passengerId : Double,rideType : String?,pickupAddress : String?,pickupLatitude : Double,pickupLongitude : Double,pickupTime : Double?,dropAddress : String?,dropLatitude : Double,dropLongitude : Double,dropTime : Double?,matchingDistance : Double,points : Double,newFare : Double,noOfSeats : Int ,rideInvitationId : Double, invitingUserName : String,invitingUserId : Double,displayPointsConfirmationAlert : Bool,riderHasHelmet : Bool,pickupTimeRecalculationRequired : Bool,passengerRouteMatchPercentage : Int,riderRouteMatchPercentage : Int, moderatorId: String?, listener : RideInvitationActionCompletionListener?){

        self.viewController = viewController
        self.riderRideId = riderRideId
        self.riderId = riderId
        self.passengerRideId = passengerRideId
        self.rideType = rideType
        self.passengerId = passengerId
        self.pickupAddress = pickupAddress
        self.pickupLatitude = pickupLatitude
        self.pickupLongitude = pickupLongitude
        self.pickupTime = pickupTime
        self.dropAddress = dropAddress
        self.dropLatitude = dropLatitude
        self.dropLongitude = dropLongitude
        self.dropTime = dropTime
        self.matchingDistance = matchingDistance
        self.points = points
        self.newFare = newFare
        self.noOfSeats = noOfSeats
        self.rideInvitationId = rideInvitationId
        self.invitingUserName = invitingUserName
        self.invitingUserId = invitingUserId
        self.riderHasHelmet = riderHasHelmet
        self.pickupTimeRecalculationRequired = pickupTimeRecalculationRequired
        self.listener = listener
        self.displayPointsConfirmationAlert = displayPointsConfirmationAlert
        self.passengerRouteMatchPercentage = passengerRouteMatchPercentage
        self.riderRouteMatchPercentage = riderRouteMatchPercentage
        self.moderatorId = moderatorId
    }
    var accountUtils: AccountUtils?
    func joinPassengerToRide(invitation: RideInvitation){
        AppDelegate.getAppDelegate().log.debug("joinPassengerToRide()")
        accountUtils = AccountUtils()
        accountUtils?.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: viewController, handler: {(result) in
            if result == .success{
                if self.riderId == UserDataCache.getInstance()?.currentUser?.phoneNumber {
                    let riderRide =  MyActiveRidesCache.getRidesCacheInstance()?.activeRiderRides![self.riderRideId]
                    if riderRide != nil && riderRide!.availableSeats <= 0{
                        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: String(format: Strings.reusing_seats_message, arguments: [String(riderRide!.capacity)]), message2: nil, positiveActnTitle: Strings.ACCEPT_CAPS, negativeActionTitle: Strings.cancel_caps, linkButtonText: nil, viewController: self.viewController, handler: { (result) in
                            if result == Strings.ACCEPT_CAPS{
                                self.continueJoinAfterAvailableSeatsValidation()
                            } else {
                                self.listener?.rideInviteActionCancelled()
                            }
                        })
                    }else{
                        self.ValidationHelMetRequired(invitation: invitation)
                    }
                }else{
                    if self.riderHasHelmet {
                        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.helmet_required_alert, message2: nil, positiveActnTitle: Strings.helmet_positive_action, negativeActionTitle: Strings.helmet_negative_action, linkButtonText: nil, viewController: nil, handler: { (result) in
                            if result == Strings.helmet_positive_action{
                                self.continueJoinAfterAvailableSeatsValidation()
                            } else if result == Strings.helmet_negative_action{
                                self.passengerRejectRiderInvite(invitation: invitation)
                            }
                        })
                        return
                    } else {
                        //HelMetPOPUP
                        self.ValidationHelMetRequired(invitation: invitation)
                    }
                }
            } else if result == .addPayment {
                self.showPaymentDrawer()
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.failed_to_accept_request)
            }
        })
    }

    private func ValidationHelMetRequired(invitation: RideInvitation) {
        if invitation.passengerRequiresHelmet {
            self.helmetPopUp(invitation: invitation)
        } else {
            self.continueJoinAfterAvailableSeatsValidation()
        }
    }

    private func passengerRejectRiderInvite(invitation: RideInvitation) {
        let passengerRejectRiderInvitationTask = PassengerRejectRiderInvitationTask(rideInvitation: invitation, viewController: self.viewController, rideRejectReason: Strings.passenger_cancel_no_helmet, rideInvitationActionCompletionListener: self.listener)
        passengerRejectRiderInvitationTask.rejectRiderInvitation()
    }

    private func riderRejectPassengerInvite(invitation: RideInvitation) {
        let riderRejectPassengerInvitationTask = RiderRejectPassengerInvitationTask(rideInvitation: invitation, moderatorId: nil, viewController: self.viewController, rideRejectReason: Strings.rider_cancel_no_helmet, rideInvitationActionCompletionListener: self.listener)
        riderRejectPassengerInvitationTask.rejectPassengerInvitation()
    }

    private func helmetPopUp(invitation: RideInvitation) {
        let helmetPOPUpVC = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HelmetPopUpViewController") as! HelmetPopUpViewController
        helmetPOPUpVC.initialiseData { (result) in
            if result {
                self.continueJoinAfterAvailableSeatsValidation()
            } else if !result{
                self.riderRejectPassengerInvite(invitation: invitation)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: helmetPOPUpVC)
    }
    func continueJoinAfterAvailableSeatsValidation(){
        if displayPointsConfirmationAlert {
            if newFare != -1 && ((invitingUserId == passengerId && newFare < points) || (invitingUserId == riderId && newFare > points)){
                MessageDisplay.displayErrorAlertWithAction(title: String(format: Strings.fare_change_confirm_title, arguments: [invitingUserName!]), isDismissViewRequired: true, message1: String(format: Strings.fare_change_confirm_message, arguments: [StringUtils.getPointsInDecimal(points: newFare),StringUtils.getPointsInDecimal(points: points)]), message2: nil, positiveActnTitle: Strings.ACCEPT_CAPS, negativeActionTitle: Strings.reject_caps, linkButtonText: nil, viewController: nil, handler: { (result) in
                    if result == Strings.ACCEPT_CAPS{
                        self.continueJoin(paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? "")
                    } else {
                        self.listener?.rideInviteActionCancelled()
                    }
                })
            }
            else{
                continueJoin(paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? "")
            }
        }else{
            continueJoin(paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? "")
        }
    }
    func continueJoin(paymentType: String){
        QuickRideProgressSpinner.startSpinner()
        self.completeJoin(paymentType: paymentType){ responseObject,error in
            self.handleadPassengerToRiderRideResponse(responseObject: responseObject, error: error)
        }
    }
    func completeJoin(paymentType: String, completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("completeJoin()")
        if joinCompleted {
            return
        }
        joinCompleted = true
        if viewController == nil{
            viewController = ViewControllerUtils.getCenterViewController()
        }
        RideMatcherServiceClient.addPassengerToRiderRide(riderRideId: riderRideId, riderId: riderId, passengerRideId: passengerRideId,  passengerId: passengerId, pickupAddress: self.pickupAddress, pickupLatitude: pickupLatitude, pickupLongitude: pickupLongitude, pickupTime: pickupTime, dropAddress: self.dropAddress, dropLatitude: dropLatitude, dropLongitude: dropLongitude, dropTime: dropTime, matchingDistance: matchingDistance, points: points.roundToPlaces(places: 2),newFare : newFare.roundToPlaces(places: 2),fareChange: (newFare > -1), noOfSeats: noOfSeats, rideInvitationId: rideInvitationId, pickupTimeRecalculationRequired: pickupTimeRecalculationRequired, passengerRouteMatchPercentage : passengerRouteMatchPercentage,riderRouteMatchPercentage : riderRouteMatchPercentage, rideType: rideType, paymentType: paymentType, moderatorId: moderatorId, viewController: viewController!) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            completionHandler(responseObject, error)
        }
    }


    private func handleadPassengerToRiderRideResponse(responseObject: NSDictionary?,error: NSError?){
        if(responseObject != nil){
            if (responseObject!["result"] as! String == "SUCCESS"){
                self.listener?.rideInviteAcceptCompleted(rideInvitationId: self.rideInvitationId)
                self.checkRideTypeAndHandleEvent()
            }else if (responseObject!["result"] as! String == "FAILURE"){
                let errorResponse = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                if let errorResponse = errorResponse, errorResponse.errorCode == RideValidationUtils.PAY_TO_REQUEST_RIDE_ERROR, let extraInfo = errorResponse.extraInfo, !extraInfo.isEmpty{
                    self.listener?.rideInviteActionFailed(rideInvitationId: self.rideInvitationId,  responseError: errorResponse, error: nil, isNotificationRemovable: false)
                    if extraInfo["PaymentLinkData"] != nil {
                        self.handlePaymentFailureResponse(error: errorResponse)
                    }else {
                        AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: self.passengerRideId, handler: nil)
                    }
                } else if StringUtils.getStringFromDouble(decimalNumber: self.passengerId) == QRSessionManager.getInstance()?.getUserId(){
                    if let errorResponse = errorResponse,
                       RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE == errorResponse.errorCode ||
                        RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE == errorResponse.errorCode ||
                        RideValidationUtils.REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR == errorResponse.errorCode ||
                        RideValidationUtils.REQUIRED_POINTS_MORE_THAN_PROMO_CODE_ERROR == errorResponse.errorCode ||
                        RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR == errorResponse.errorCode {
                        self.handlePaymentFailureResponse(error: errorResponse)
                    }else {
                        RideManagementUtils.handleRiderInviteFailedException(errorResponse: errorResponse!, viewController: self.viewController!, addMoneyOrWalletLinkedComlitionHanler: nil)
                        self.listener?.rideInviteActionFailed(rideInvitationId: self.rideInvitationId, responseError: errorResponse, error: nil, isNotificationRemovable: false)
                    }

                }else if StringUtils.getStringFromDouble(decimalNumber: self.riderId) == QRSessionManager.getInstance()?.getUserId(){

                    if RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE == errorResponse?.errorCode
                        || RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE == errorResponse?.errorCode ||
                        RideValidationUtils.TRYING_TO_BOOK_TWO_SEATS_FOR_FREE_RIDE_ERROR == errorResponse!.errorCode ||
                        RideValidationUtils.NOT_VERIFIED_USER_USING_FREE_RIDE_ERROR == errorResponse!.errorCode ||
                        RideValidationUtils.REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR == errorResponse?.errorCode || RideValidationUtils.LAZYPAY_EXPIRED_ERROR == errorResponse!.errorCode || RideValidationUtils.SIMPL_PAYMENT_ERROR == errorResponse!.errorCode || RideValidationUtils.SIMPL_PAYMENT_INSUFFICIENT_CREDIT == errorResponse!.errorCode || RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR == errorResponse!.errorCode
                    {
                        MessageDisplay.displayAlert(messageString: Strings.passenger_dont_have_balance, viewController: self.viewController!, handler: nil)
                        self.listener?.rideInviteActionFailed(rideInvitationId: self.rideInvitationId, responseError: errorResponse, error: nil, isNotificationRemovable: false)

                    }else if RideValidationUtils.PASSENGER_ALREADY_JOINED_THIS_RIDE == errorResponse?.errorCode  || RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE == errorResponse?.errorCode || RideValidationUtils.INSUFFICIENT_SEATS_ERROR == errorResponse?.errorCode
                    {
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                        self.listener?.rideInviteActionFailed(rideInvitationId: self.rideInvitationId, responseError: errorResponse, error: nil, isNotificationRemovable: true)
                    }
                    else
                    {
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                        self.listener?.rideInviteActionFailed(rideInvitationId: self.rideInvitationId, responseError: errorResponse, error: nil, isNotificationRemovable: false)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                    self.listener?.rideInviteActionFailed(rideInvitationId: self.rideInvitationId, responseError: errorResponse, error: nil, isNotificationRemovable: false)
                }
            }
        }else{
            ErrorProcessUtils.handleError(responseObject: responseObject
                                          , error: error, viewController: self.viewController, handler: nil)
            self.listener?.rideInviteActionFailed(rideInvitationId: self.rideInvitationId, responseError: nil, error: error, isNotificationRemovable: false)

        }
    }

    private func checkRideTypeAndHandleEvent() {
        //inviteid, userId,requesteduserId, match percentage for rider, match percentage for passenger, timedifference
        if self.rideType == Ride.PASSENGER_RIDE {
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.RIDER_ACCEPTED_PASSENGER, params: ["inviteId" : rideInvitationId,"userId": QRSessionManager.getInstance()?.getUserId() ?? "","requesteduserId": invitingUserId ?? "","match percentage for rider": riderRouteMatchPercentage,"match percentage for passenger":passengerRouteMatchPercentage], uniqueField: "inviteId")
        } else {
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.PASSENGER_ACCEPTED_RIDER, params: ["inviteId" : rideInvitationId,"userId": QRSessionManager.getInstance()?.getUserId() ?? "","requesteduserId": invitingUserId ?? ""], uniqueField: "inviteId")
        }

    }

    func handlePaymentFailureResponse(error: ResponseError){
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if linkedWallet == nil {
            showPaymentDrawer()
        }else if error.errorCode == RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR  {
            showPaymentDrawer()
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
            displayAddMoneyView(errorMessage: error.userMessage ?? "")
        }
    }

    func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: true) {(data) in
            if data == .ccdcSelected {
                self.joinCompleted = false
                self.completeJoin(paymentType: TaxiRidePassenger.PAYMENT_MODE_PAYMENT_LINK){ responseObject,error in
                    if (responseObject!["result"] as! String == "FAILURE"){
                        let result = RestResponseParser<ResponseError>().parse(responseObject: responseObject, error: error)
                        if let responseError = result.1{
                            self.displayWebView(responseError: responseError)
                        }
                    }
                }
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }

    func displayAddMoneyView(errorMessage: String){
        let addMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
        addMoneyViewController.initializeView(errorMsg: errorMessage){ (result) in
            if result == .changePayment {
                self.showPaymentDrawer()
            }
        }
        addMoneyViewController.modalPresentationStyle = .overFullScreen
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: addMoneyViewController, animated: true, completion: nil)
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func displayWebView(responseError: ResponseError){
        let extraInfo = responseError.extraInfo
        let controlName = self.convertToDictionary(text: extraInfo?["PaymentLinkData"] as! String)
        if let linkUrl = controlName?["paymentLink"], let successURL = controlName?["redirectionUrl"] {
            let queryItems1 = URLQueryItem(name: "&isMobile", value: "true")
            var urlcomps1 = URLComponents(string :  linkUrl as! String)
            urlcomps1?.queryItems = [queryItems1]

            let queryItems2 = URLQueryItem(name: "&isMobile", value: "true")
            var urlcomps2 = URLComponents(string :  successURL as! String)
            urlcomps2?.queryItems = [queryItems2]
            if urlcomps1?.url != nil {
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.initializeDataBeforePresenting(titleString: "Payment", url: urlcomps1?.url){ completed in
                    if completed {
                        self.listener?.rideInviteAcceptCompleted(rideInvitationId: self.rideInvitationId)
                        self.checkRideTypeAndHandleEvent()
                    }
                }
                webViewController.successUrl = urlcomps2?.url
                ViewControllerUtils.displayViewController(currentViewController: self.viewController, viewControllerToBeDisplayed: webViewController, animated: true)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
}
