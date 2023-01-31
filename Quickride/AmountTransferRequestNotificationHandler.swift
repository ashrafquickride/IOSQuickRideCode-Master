//
//  AmountTransferRequestNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 11/08/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias transferRequestCompletionHandler = () -> Void


class AmountTransferRequestNotificationHandler: NotificationHandler {
    
    var userNotification : UserNotification?
    var viewController : UIViewController?

 
  override func handleTap(userNotification clientNotification : UserNotification,viewController : UIViewController?){
    handleNeutralAction(userNotification: clientNotification, viewController: viewController)

  }
  override func handlePositiveAction(userNotification:UserNotification,viewController : UIViewController?) {
    self.userNotification = userNotification
    self.viewController = viewController
    let amountTransferRequest = Mapper<AmountTransferRequest>().map(JSONString: userNotification.msgObjectJson!)
    if amountTransferRequest == nil{
      
      return
    }
    let userAccount = UserDataCache.getInstance()?.userAccount
    if userAccount == nil
    {
      MessageDisplay.displayAlert(messageString: Strings.account_invalid,viewController: ViewControllerUtils.getCenterViewController(),handler: nil)
        return
    }
    let transferableAmount = userAccount!.balance! - userAccount!.reserved!
    if(amountTransferRequest!.amount > transferableAmount)
    {
      if(transferableAmount == 0)
      {
        MessageDisplay.displayAlert(messageString: Strings.no_balance,viewController: ViewControllerUtils.getCenterViewController(),handler: nil)
      }else
      {
        MessageDisplay.displayAlert(messageString: "\(Strings.you_can_transfer_only)  (\(Strings.max) : \(StringUtils.getStringFromDouble(decimalNumber : transferableAmount))) \(Strings.points)" ,viewController: ViewControllerUtils.getCenterViewController(),handler: nil)
      }
      return
    }
    doSendTransfer(amountTransferRequest: amountTransferRequest!)
    
  }
  
  func doSendTransfer(amountTransferRequest : AmountTransferRequest)  {
    
    var params : [String : String] = [String : String]()
    params[Account.TRANSFER_USER] = StringUtils.getStringFromDouble(decimalNumber: amountTransferRequest.requestorId)
    params[Account.TRANSFEREE_USER] = StringUtils.getStringFromDouble(decimalNumber: amountTransferRequest.senderContactNo)
    params[Account.POINTS] = StringUtils.getStringFromDouble(decimalNumber:amountTransferRequest.amount)
    params[Account.TRANSFER_USER] = StringUtils.getStringFromDouble(decimalNumber: amountTransferRequest.senderId)
    params[Account.TRANSFEREE_USER] = StringUtils.getStringFromDouble(decimalNumber: amountTransferRequest.requestorContactNo)
    params[Account.POINTS] = StringUtils.getStringFromDouble(decimalNumber: amountTransferRequest.amount)
    params[Account.REASON] = amountTransferRequest.reason
    params[Account.TRANSFEREE_NAME] = amountTransferRequest.requestorName
    QuickRideProgressSpinner.startSpinner()
    AccountRestClient.handleTransferRequest(body: params, targetViewController: ViewControllerUtils.getCenterViewController(),completionHandler: { (responseObject, error) -> Void in
      QuickRideProgressSpinner.stopSpinner()
      self.handleTransferResponse(responseObject: responseObject, error: error)
    })
  }
  
  func handleTransferResponse(responseObject: NSDictionary?, error: NSError?) {
    AppDelegate.getAppDelegate().log.debug("handleTransferResponse()")
    
    if responseObject != nil {
      if responseObject!["result"]! as! String == "SUCCESS"{
        
        UserDataCache.getInstance()?.refreshAccountInformationInCache()
        super.handlePositiveAction(userNotification: self.userNotification!, viewController: self.viewController)
      }
      else if responseObject!["result"]! as! String == "FAILURE"{
        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
        if responseError?.errorCode == AccountException.ACCOUNT_DOESNOT_EXIST{
          MessageDisplay.displayAlert(messageString: Strings.not_registered,  viewController: ViewControllerUtils.getCenterViewController(),handler: nil)
        }
        else if responseError?.errorCode == AccountException.USER_CAN_DO_ONE_TRANSFER_PER_DAY_ERROR{
          var clientConfiguration  = ConfigurationCache.getInstance()?.getClientConfiguration()
          if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
          }
          let maxTransactionPerDays : Int = clientConfiguration!.maxTransferTransactionsPerDay
          MessageDisplay.displayAlert(messageString: "You can do only \(maxTransactionPerDays) transactions in a day",  viewController: ViewControllerUtils.getCenterViewController(),handler: nil)
        }
      }
    }else {
      ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
        
    }
  }
  
  override func handleNegativeAction(userNotification: UserNotification,viewController:UIViewController? ) {
  
    
    let amountTransferRequest = Mapper<AmountTransferRequest>().map(JSONString: userNotification.msgObjectJson!)
    if amountTransferRequest == nil{
     super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
      return
    }
    let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
    rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.reason_for_rejecting_request, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: ViewControllerUtils.getCenterViewController(), rideType: nil) { (text, result) in
      if result == Strings.confirm_caps
      {
        AccountRestClient.requestReject(requestorUserId: amountTransferRequest!.requestorId, senderContactNo: StringUtils.getStringFromDouble(decimalNumber: amountTransferRequest!.senderId), reason: text, isTransfer: true, passengerRideId: nil, viewController: ViewControllerUtils.getCenterViewController(), handler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
            }
        })
      }
    }
  }
  
  override func handleNeutralAction(userNotification : UserNotification, viewController : UIViewController?) {
    super.handleNeutralAction(userNotification: userNotification, viewController: viewController)
    let amountTransferRequest = Mapper<AmountTransferRequest>().map(JSONString: userNotification.msgObjectJson!)
    if amountTransferRequest == nil{
      //TODO : ERROR to convey
      return
    }
    let transferVC = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransferViewController") as! TransferViewController
      transferVC.initializeDataBeforePresenting(amountTransferRequest: amountTransferRequest, isFromMissingPayment: nil, transferRequestCompletionHandler: {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    })
    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: transferVC, animated: false)
  }
  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
    return Strings.ACCEPT
  }
  override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    AppDelegate.getAppDelegate().log.debug("getNegativeActionNameWhenApplicable()")
    return Strings.REJECT
  }
  override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    AppDelegate.getAppDelegate().log.debug("getNeutralActionNameWhenApplicable()")
    return Strings.VIEW
  }
  
}
