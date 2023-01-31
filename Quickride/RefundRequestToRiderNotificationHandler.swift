//
//  RefundRequestToRiderNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 12/08/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RefundRequestToRiderNotificationHandler: NotificationHandler {
  
  override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
    
  }
  override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
    
    if userNotification.msgObjectJson == nil || userNotification.msgObjectJson!.isEmpty{
      super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
      return
    }
    let refundNotification = Mapper<RefundNotification>().map(JSONString: userNotification.msgObjectJson!)
    if refundNotification == nil{
      super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
      return
    }
    QuickRideProgressSpinner.startSpinner()
    AccountRestClient.riderRefundToPassenger(accountTransactionId: Double(refundNotification!.accountId ?? ""), points: refundNotification!.points ?? "", rideId: Double(refundNotification?.passengerRideId ?? ""), invoiceId: refundNotification?.invoiceId, viewController: viewController) { (responseObject, error) in
      QuickRideProgressSpinner.stopSpinner()
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
        UIApplication.shared.keyWindow?.makeToast( Strings.refund_successful)
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
      }else{
        ErrorProcessUtils.handleError(responseObject : responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
      }
    }
  }
  override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {

    
    let refundNotification = Mapper<RefundNotification>().map(JSONString: userNotification.msgObjectJson!)
    if refundNotification == nil{
      super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
      return
    }
    
    
    let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
    rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.reason_for_rejecting_refund, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: ViewControllerUtils.getCenterViewController(), rideType: nil) { (text, result) in
      if result == Strings.confirm_caps
      {
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.requestReject(requestorUserId: userNotification.sendFrom, senderContactNo: StringUtils.getStringFromDouble(decimalNumber: userNotification.sendTo), reason: text, isTransfer: false, passengerRideId: refundNotification?.passengerRideId, viewController: ViewControllerUtils.getCenterViewController(), handler: { (responseObject, error) in
          QuickRideProgressSpinner.stopSpinner()
          if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
          }else{
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
          }
        })
      }
    }
    
  }
  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    return Strings.refund
  }
  override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    return Strings.REJECT
  }
  
}
