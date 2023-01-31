//
//  InviteRiderHandler.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 07/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import GoogleMaps
import UIKit
typealias inviteCompletionHandler = (_ error : ResponseError?,_ error : NSError?) -> Void

class InviteRiderHandler {

    var passengerRide : PassengerRide
    var selectedRiders : [MatchedRider]
    var viewController  : UIViewController
    var invitedRidersCount = 0
    var displaySpinner = true
    var matchedRiders = [MatchedRider]()
    var selectedIndex:String?
    var helmetRequired = false
    var handler: inviteCompletionHandler?

    init(passengerRide : PassengerRide,selectedRiders : [MatchedRider],displaySpinner : Bool,selectedIndex:String?,viewController : UIViewController){
        self.selectedRiders = selectedRiders
        self.passengerRide = passengerRide
        self.viewController = viewController
        self.displaySpinner = displaySpinner
        self.selectedIndex = selectedIndex
    }

    var accountUtils: AccountUtils?
    func inviteSelectedRiders(inviteHandler : @escaping inviteCompletionHandler){
        self.handler = inviteHandler
        AppDelegate.getAppDelegate().log.debug("")
        accountUtils = AccountUtils()
        accountUtils?.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: viewController, handler: {(result) in
            if result == .success{
                if self.isHelmetRequired(){
                    self.displayHelmetAlert(handler: inviteHandler)
                }else{
                    self.continueInvite(isHelmetRequired: false, handler: inviteHandler)
                }
            } else if result == .addPayment{
                self.showPaymentDrawer()
            }else {
                inviteHandler(ResponseError(userMessage: Strings.failed_to_send_request),nil)
            }
        })
    }
    func displayHelmetAlert(handler : @escaping inviteCompletionHandler)
    {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.helmet_required_alert, message2: nil, positiveActnTitle: Strings.helmet_positive_action, negativeActionTitle: Strings.helmet_negative_action, linkButtonText: nil, viewController: nil, handler: { (result) in
            if result == Strings.helmet_positive_action{
                self.continueInvite(isHelmetRequired: false, handler: handler)
            }else if result == Strings.helmet_negative_action {
                self.continueInvite(isHelmetRequired: true, handler: handler)
            } else {
                handler(QuickRideErrors.helmetNotAvailableResponseError, nil)
            }
        })
    }

    func isHelmetRequired()->Bool{
        for matchedRider in selectedRiders
        {
            if matchedRider.riderHasHelmet
            {
                return true
            }
        }
        return false
    }
    func continueInvite(isHelmetRequired: Bool ,handler : @escaping inviteCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("")

        for matchedRider in selectedRiders{
            self.invitedRidersCount += 1
            matchedRiders.append(matchedRider)
            if displaySpinner{
                QuickRideProgressSpinner.startSpinner()
            }

            self.completeInvite(matchedUser: matchedRider, helmetRequired: isHelmetRequired, handler: handler)
        }
    }

    func completeInvite(matchedUser : MatchedRider,helmetRequired: Bool,handler : @escaping inviteCompletionHandler){

        self.helmetRequired = helmetRequired
        if passengerRide.rideType == TaxiPoolConstants.Taxi{
            TaxiSharingRestClient.inviteRideGiver(taxiRideId: passengerRide.rideId, passengerId: passengerRide.userId, noOfSeats: passengerRide.noOfSeats, matchedUsers: matchedRiders.toJSONString()!, paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type, passengerRequiresHelmet: helmetRequired) { (responseObject, error) -> Void in
                self.handleInviteResponce(responseObject: responseObject, error: error,helmetRequired: helmetRequired, handler: handler, matchedUser: matchedUser)
            }
        }else{
            sendInvitationToRiders(paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? "", completionHandler: { (responseObject, error) -> Void in
                self.handleInviteResponce(responseObject: responseObject, error: error,helmetRequired: helmetRequired, handler: handler, matchedUser: matchedUser)
            })
        }
    }

    private func sendInvitationToRiders(paymentType: String, completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        let currentFilterStatus = RideViewUtils.getSortAndFilterData(rideId: passengerRide.rideId, rideType: passengerRide.rideType ?? "")
        self.invitedRidersCount += 1
        RideMatcherServiceClient.sendInvitationToRiders(rideId: passengerRide.rideId, passengerId: passengerRide.userId, noOfSeats: passengerRide.noOfSeats, matchedUsers: matchedRiders.toJSONString()!,isFromPreferredRider: passengerRide.riderRideId != 0, paymentType: paymentType, invitePosition: selectedIndex, currentSortFilterStatus: currentFilterStatus, passengerRequiresHelmet: helmetRequired, viewController: viewController, completionHandler: { (responseObject, error) -> Void in
            completionHandler(responseObject,error)
        })
    }

    private func handleInviteResponce(responseObject: NSDictionary?,error: NSError?,helmetRequired: Bool,handler : @escaping inviteCompletionHandler,matchedUser: MatchedRider){
        if self.displaySpinner{
            QuickRideProgressSpinner.stopSpinner()
        }
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            let response = Mapper<RideInviteResponse>().mapArray(JSONObject: responseObject!["resultData"])
            if let rideInvitesResponse = response, !rideInvitesResponse.isEmpty{
                self.saveUserBasicInfoForSucceededInvites(rideInvitesResponse: rideInvitesResponse)
                if self.selectedRiders.count == 1{
                    if rideInvitesResponse[0].success {
                        handler(nil, nil)
                        if self.displaySpinner{
                            let successMessage : String?
                            if matchedUser.name == nil{
                                successMessage = Strings.invite_sent_to_selected_user
                            }else{
                                successMessage = String(format: Strings.invite_sent_to_selected_riders, matchedUser.name!)
                            }
                            UIApplication.shared.keyWindow?.makeToast(successMessage ?? "", point: CGPoint(x: self.viewController.view.frame.size.width/2, y: self.viewController.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                        }
                    }else if let error = rideInvitesResponse[0].error{

                        if RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE == error.errorCode ||
                            RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE == error.errorCode ||
                            RideValidationUtils.REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR == error.errorCode ||
                            RideValidationUtils.REQUIRED_POINTS_MORE_THAN_PROMO_CODE_ERROR == error.errorCode ||
                            RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR == error.errorCode {
                            self.handlePaymentFailureResponse(error: error)
                        }else {
                            RideManagementUtils.handleRiderInviteFailedException(errorResponse: error, viewController: self.viewController, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                                self.completeInvite(matchedUser: matchedUser, helmetRequired: helmetRequired, handler: handler)
                            })
                            handler(error,nil)
                        }
                    }
                }else{
                    self.handleMultipleInvitesMessageDisplay(rideInvitesResponse: rideInvitesResponse,helmetRequired: helmetRequired,handler: handler,matchedUser: matchedUser)
                }
            }

        }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
            let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
            if let error = error, error.errorCode == RideValidationUtils.PAY_TO_REQUEST_RIDE_ERROR, let extraInfo = error.extraInfo, !extraInfo.isEmpty{
                var rideId = passengerRide.rideId
                if passengerRide.rideType == TaxiPoolConstants.Taxi{
                    rideId = extraInfo["passengerRideId"] as? Double ?? 0
                }
                if extraInfo["PaymentLinkData"] != nil {
                    self.handlePaymentFailureResponse(error: error)
                }else {
                    AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: rideId) {(result) in
                        if result == Strings.success {
                            handler(nil,nil)
                        } else{
                            handler(error,nil)
                        }
                    }
                }
            } else if error != nil {
                handler(error,nil)
                guard let error = error else { return }
                if RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE == error.errorCode ||
                    RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE == error.errorCode ||
                    RideValidationUtils.REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR == error.errorCode ||
                    RideValidationUtils.REQUIRED_POINTS_MORE_THAN_PROMO_CODE_ERROR == error.errorCode ||
                    RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR == error.errorCode {
                    self.handlePaymentFailureResponse(error: error)
                }else {
                    RideManagementUtils.handleRiderInviteFailedException(errorResponse: error, viewController: self.viewController, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.completeInvite(matchedUser: matchedUser, helmetRequired: helmetRequired, handler: handler)
                    })
                }
            } else {
                handler(error,nil)
                ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: self.viewController)
            }
        }else{
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            handler(nil,error)
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

    func saveUserBasicInfoForSucceededInvites(rideInvitesResponse : [RideInviteResponse]){
        for rideInviteResponse in rideInvitesResponse{
            if rideInviteResponse.success && rideInviteResponse.rideInvite!.riderId != 0{

                let matchedRidersDictionary = self.getMatchedRidersDictionary(selectedUsers: self.matchedRiders)
                let matchedRider = matchedRidersDictionary[rideInviteResponse.rideInvite!.riderId]
                if matchedRider != nil && matchedRider!.name != nil && matchedRider!.gender != nil {
                     let userBasicInfo  = UserBasicInfo(userId : matchedRider!.userid!, gender : matchedRider!.gender,userName : matchedRider!.name!, imageUri : matchedRider!.imageURI,  companyName : matchedRider!.companyName, rating : Float(matchedRider!.rating!), noOfReviews : matchedRider!.noOfReviews, callSupport : matchedRider!.callSupport, verificationStatus : matchedRider!.verificationStatus)
                    UserDataCache.getInstance()?.saveUserBasicInfo(userBasicInfo: userBasicInfo)

                    RideInviteCache.getInstance().saveNewInvitation(rideInvitation: rideInviteResponse.rideInvite!)
                }
            }

        }
    }
    func handleMultipleInvitesMessageDisplay(rideInvitesResponse : [RideInviteResponse],helmetRequired: Bool,handler : @escaping inviteCompletionHandler,matchedUser: MatchedRider){
        var count = 0
        for i in 0..<rideInvitesResponse.count{
            if rideInvitesResponse[i].error != nil && rideInvitesResponse[i].error!.errorCode == RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE{
                count += 1
            }
        }
        if count > 1{
            RideManagementUtils.handleRiderInviteFailedException(errorResponse: rideInvitesResponse[0].error!, viewController: self.viewController, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                self.completeInvite(matchedUser: matchedUser, helmetRequired: helmetRequired, handler: handler)
            })
            return
        }
        let multiInviteVC = (UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "MultipleInvitesStatusController") as! MultipleInvitesStatusController)

        multiInviteVC.initializeDataBeforePresenting(rideInvites: rideInvitesResponse, matchedUsers: self.matchedRiders, viewController: self.viewController)
        self.viewController.navigationController?.view.addSubview(multiInviteVC.view!)
        self.viewController.navigationController?.addChild(multiInviteVC)
    }

    func getMatchedRidersDictionary(selectedUsers : [MatchedRider]) -> [Double : MatchedRider]{
        var matchedRidersDictionary = [Double : MatchedRider]()
        for passenger in selectedUsers {
            matchedRidersDictionary[passenger.userid!] = passenger
        }
        return matchedRidersDictionary
    }

    func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: true) {(data) in
            if data == .ccdcSelected {
                    self.sendInvitationToRiders(paymentType: TaxiRidePassenger.PAYMENT_MODE_PAYMENT_LINK){ responseObject,error in
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
                webViewController.successUrl = urlcomps2?.url
                webViewController.initializeDataBeforePresenting(titleString: "Payment", url: urlcomps1?.url){ completed in
                    if completed {
                        if let handler = self.handler {
                            handler(nil,nil)
                        }
                    }
                }
                self.viewController.navigationController?.pushViewController(webViewController, animated: false)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
}
