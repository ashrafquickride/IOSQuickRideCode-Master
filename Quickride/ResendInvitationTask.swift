//
//  ResendInvitationTask.swift
//  Quickride
//
//  Created by QuickRideMac on 16/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol OnInvitedUserCallBack{
    func inviteSuccess()
}

class ResendInvitationTask {
    
    var inviteUserCallBack : OnInvitedUserCallBack
    var invitedUser : UserBasicInfo?
    var rideInvitation : RideInvitation?
    var viewController : UIViewController?
    
  init(rideInvitation : RideInvitation, viewController : UIViewController,  invitedUser : UserBasicInfo, inviteUserCallBack : OnInvitedUserCallBack) {
        self.viewController = viewController
        self.rideInvitation = rideInvitation
        self.inviteUserCallBack = inviteUserCallBack
        self.invitedUser = invitedUser
    }
    var accountUtils :  AccountUtils?
    func inviteUser(){
        accountUtils = AccountUtils()
        accountUtils?.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: viewController, handler: {(result) in
            if result == .success {
                if Ride.RIDER_RIDE == self.rideInvitation!.rideType{
                    QuickRideProgressSpinner.startSpinner()
                    RideMatcherServiceClient.sendRiderInvitationToPassenger(riderRideId: self.rideInvitation!.rideId, riderId: self.rideInvitation!.riderId
                        , passengerRideId: self.rideInvitation!.passenegerRideId, passengerId: self.rideInvitation!.passengerId, pickupAddress: self.rideInvitation!.pickupAddress, pickupLatitude: self.rideInvitation!.pickupLatitude, pickupLongitude: self.rideInvitation!.pickupLongitude, pickupTime: self.rideInvitation!.pickupTime, dropAddress: self.rideInvitation!.dropAddress, dropLatitude: self.rideInvitation!.dropLatitude, dropLongitude: self.rideInvitation!.dropLongitude, dropTime: self.rideInvitation!.dropTime, matchingDistance: self.rideInvitation!.matchedDistance, points: self.rideInvitation!.points,newFare: self.rideInvitation!.newFare,fareChange: (self.rideInvitation?.newFare != -1), noOfSeats: self.rideInvitation!.noOfSeats, pickUpTimeRecalculationRequired: self.rideInvitation!.pickupTimeRecalculationRequired,  handler: { (responseObject, error) in
                            QuickRideProgressSpinner.stopSpinner()
                            self.handlerResponse(responseObject: responseObject,error:error)
                    })
                }else{
                    self.sendPassengerInvitationToRider(paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? "") { (responseObject, error) in
                        self.handlerResponse(responseObject: responseObject,error:error)
                    }
                }
            } else if result == .addPayment {
                self.showPaymentDrawer()
            }else {
                UIApplication.shared.keyWindow?.makeToast( Strings.failed_to_send_invite)
            }
        })
    }
    
    private func sendPassengerInvitationToRider(paymentType: String, handler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        QuickRideProgressSpinner.startSpinner()
        RideMatcherServiceClient.sendPassengerInvitationToRider(riderRideId: self.rideInvitation!.rideId, riderId: self.rideInvitation!.riderId, passengerRideId: self.rideInvitation!.passenegerRideId, passengerId: self.rideInvitation!.passengerId, pickupAddress: self.rideInvitation!.pickupAddress, pickupLatitude: self.rideInvitation!.pickupLatitude, pickupLongitude: self.rideInvitation!.pickupLongitude, pickupTime: self.rideInvitation!.pickupTime, dropAddress: self.rideInvitation!.dropAddress, dropLatitude: self.rideInvitation!.dropLatitude, dropLongitude: self.rideInvitation!.dropLongitude, dropTime: self.rideInvitation!.dropTime, matchingDistance: self.rideInvitation!.matchedDistance, points: Int(self.rideInvitation!.riderPoints),newFare: self.rideInvitation!.newRiderFare,fareChange: (self.rideInvitation?.newRiderFare != -1), noOfSeats: self.rideInvitation!.noOfSeats, paymentType: paymentType, viewController: self.viewController, handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            handler(responseObject, error)
        })
    }
    
    func handlerResponse(responseObject: NSDictionary?, error: NSError?){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            rideInvitation = Mapper<RideInvitation>().map(JSONObject: responseObject!["resultData"])
            if let rideInvitation = rideInvitation {
                RideInviteCache.getInstance().saveNewInvitation(rideInvitation: rideInvitation)
            }
            inviteUserCallBack.inviteSuccess()
        }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
            let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
            if let error = error, error.errorCode == RideValidationUtils.PAY_TO_REQUEST_RIDE_ERROR, let extraInfo = error.extraInfo, !extraInfo.isEmpty{
                if extraInfo["PaymentLinkData"] != nil{
                    self.handlePaymentFailureResponse(error: error)
                }else {
                    AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: self.rideInvitation!.passenegerRideId, handler: nil)
                }
            }else if let error = error,
                     RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE == error.errorCode ||
                        RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE == error.errorCode ||
                        RideValidationUtils.REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR == error.errorCode ||
                        RideValidationUtils.REQUIRED_POINTS_MORE_THAN_PROMO_CODE_ERROR == error.errorCode ||
                        RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR == error.errorCode {
                self.handlePaymentFailureResponse(error: error)
            }else {
                RideManagementUtils.handleRiderInviteFailedException(errorResponse: error!,viewController: self.viewController!, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                    self.inviteUser()
                })
            }
        }
        else{
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
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
    
    func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: true ) {(data) in
            if data == .ccdcSelected {
                self.sendPassengerInvitationToRider(paymentType: TaxiRidePassenger.PAYMENT_MODE_PAYMENT_LINK){ responseObject,error in
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
                webViewController.initializeDataBeforePresenting(titleString: "Payment", url: urlcomps1?.url){ completed in
                    if completed {
                        self.inviteUserCallBack.inviteSuccess()
                    }
                }
                webViewController.successUrl = urlcomps2?.url
                self.viewController?.navigationController?.pushViewController(webViewController, animated: false)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
}
