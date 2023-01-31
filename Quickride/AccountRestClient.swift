//
//  AccountRestClient.swift
//  Quickride
//
//  Created by KNM Rao on 05/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AccountRestClient {
  
  // Mark: TypeAlias Definitions
  typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  
  
    static let REQUEST_POINTS_SERVICE_PATH = "/QRInternalWalletTransaction/requestTransfer"
    static let PASSENGER_REFUND_REQUEST_TO_RIDER = "/QRRefund/refund"
    static let PARTIAL_REFUND_TRANSACTION = "/QRRefund/transactions/refund"
    static let RIDER_REFUND_TO_PASSENGER = "/QRAccount/transactions/reverse"
    static let REDEMPTION_DETAILS = "/QRRedemption/transaction"
    static let REQUEST_REJECT_PATH = "/QRRefund/requestReject"
    static let VALIDATE_TMW_USER = "/QRRedemption/validateTMWUser"
    static let CREATE_PROBABLE_TMW_USER = "/QRRedemption/tmwuser"
    static let PEACH_PAYMENT_CHECKOUT_ID_PATH = "/QRAccount/checkoutId"
    static let PEACH_PAYMENT_STATUS_CHECKING_PATH = "/QRAccount/paymentStatus"
    static let PAYMENT_TYPE = "paymentType"
    static let RECHARGED_AMOUNT_SERVICE_PATH="/QRRedemption/rechargedamount";
    static let ACCOUNT_ID = "accountid";
    static let POINTS = "points";
    static let PEACH_PAYMENT_CALL_BACK_URL = "callbackurl"
    static let PEACH_PAYMENT_ORDER_ID = "orderid"
    static let FREECHARGE_CHECKSUM_PATH = "/QRAccount/frecharge/checksum"
    static let CANCEL_COMPENSATION_TRANSACTION_PATH = "/QRInvoice/cancelCompensation"
    static let PHONE = "phone"
    static let EMAIL = "email"
    static let LINK_PAYTM_PATH = "/QRLinkedWallet/link/paytm"
    static let VERIFY_OTP_FOR_LINKING_PAYTM_PATH = "/QRLinkedWallet/validate/otp/paytm"
    static let LINK_TMW_PATH = "/QRLinkedWallet/link/tmw"
    static let VERIFY_OTP_FOR_LINKING_TMW_PATH = "/QRLinkedWallet/validate/otp/tmw"
    static let LINKED_WALLET_BALANCES_PATH = "/QRLinkedWallet/multiple/balance"
    static let REMOVE_LINKED_WALLET_SERVICE_PATH = "/QRLinkedWallet/delete/type"
    static let COMMUTE_PASS_PATH = "/pass"
    static let RECHARGE_REFUND_PATH = "/QRAccount/recharge/refund"
    static let LINK_SIMPL_PATH = "/QRLinkedWallet/link/simpl"
    static let SET_SIMPL_DATA_PATH = "/QRLinkedWallet/simpl/sessionKey"
    static let LINK_AND_PROCESS_AMAZON_PAY_PATH = "/QRAccount/amazonpay/linkAmazonPayAndProcessCharge"
    static let GET_AMAZON_PAY_LINK_STATUS = "/QRAccount/amazonpay/getAmazonPayAccountstatus"
    static let PROCESS_CHARGE_AMAZON_PAY_PATH = "/QRAccount/amazonpay/amazonPayProcessCharge"
    static let GET_ASSURED_RIDE_INCENTIVE_PATH = "rideincentive"
    static let UPDATE_RIDE_INCENTIVE_DISPLAY_STATUS_PATH = "rideincentive/status/update"
    static let MONTHLY_REPORT_SERVICE_PATH = "/QRInvoiceQuery/generateReimbursementReport"
    static let LINK_LAZYPAY_PATH = "/QRLinkedWallet/link/lazyPay"
    static let VERIFY_OTP_FOR_LINKING_LAZYPAY_PATH = "/QRLinkedWallet/validate/otp/lazyPay"
    static let LAZYPAY_DISPLAY_ELIGIBILITY_PATH = "/QRLinkedWallet/eligibility/lazypay"
    static let LINK_AMAZON_PAY_PATH = "/QRLinkedWallet/link/amazonpay"
    static let ORDER_SODEXO_CARD_PATH = "/QRRedemption/orderSodexoCard"
    static let GET_CITY_STATE_PATH = "/QRStateCityPincodeMapping/getStateCity"
    static let MOBIKWIK_WALLET_LINK_SERVICE_PATH = "/QRLinkedWallet/link/mobikwik"
    static let MOBIKWIK_WALLET_OTP_VERIFY_SERVICE_PATH = "/QRLinkedWallet/validate/otp/mobikwik"
    static let LINK_UPI_PATH = "/QRLinkedWallet/link/upi"
    static let GET_PENDING_LINKED_WALLET_TRANSACTIONS_PATH = "/QRPendingInvoice/pendingLinkedWalletTxns"
    static let UPDATE_ORDER_ID_FOR_PENDING_TRANSACTION_PATH = "/QRLinkedWallet/linkedwalletTxns/paymentId"
    static let UPDATE_LINKED_WALLET_PENDING_TRANSACTION_STATUS_PATH = "/QRLinkedWallet/linkedwalletTxns/paid"
    static let FRECHARGE_WALLET_LINK_SERVICE_PATH = "/QRLinkedWallet/link/freecharge"
    static let FRECHARGE_WALLET_OTP_VERIFY_SERVICE_PATH = "/QRLinkedWallet/validate/otp/freecharge"
    static let SHELL_CARD_REGISTRATION = "/QRRedemption/shellRegistration"
    static let GET_MOBIQUICK_URL_TO_ADD_MONEY = "/QRLinkedWallet/url/loadBalance/mobikwik"
    static let GET_AMAZON_URL_TO_ADD_MONEY =  "/QRLinkedWallet/payUrl/loadBalance/amazonPay"
    static let GET_OPEN_LINKED_WALLET_TRANSACTIONS_PATH = "/QRPendingInvoice/openLinkedWalletTxns/ride"
    static let PENDING_LINKED_WALLET_TRANSACTIONS_PATH = "/QRPendingInvoice/pendingLinkedWalletTxns/ride"
    static let UPDATE_DEFAULT_LINKED_WALLET_SERVICE_PATH = "/QRLinkedWallet/updateDefault"
    static let GET_UPI_PAYMENT_STATUS_PATH = "/QRLinkedWallet/payment/status"
    static let INITIATE_UPI_PAYMENT_PATH = "/QRLinkedWallet/payment/initiate"
    static let CANCEL_UPI_PAYMENT_PATH = "/QRLinkedWallet/cancel/upi/payment"
    static let LINK_SIMPL_AT_SIGNUP = "/QRLinkedWallet/getToken/link/simpl"
    static let CHECK_HP_PAY_REGISTRATION_PATH = "/QRRedemption/hprefuel/checkRegistration"
    static let HP_PAY_REGISTRATION_PATH = "/QRRedemption/hprefuel/addCustomer"
    static let PENDING_REFUND_REQUESTS_PATH = "/QRRefund/refundRequests/open"
    static let CHECK_And_REGISTRATION_IOCL_PATH = "/QRRedemption/checkandRegisterIOCLCard"
    static let GET_PENDING_DUES_PATH = "/QRPendingDues/new"
    static let PAY_PENDING_DUES = "/QRPendingDues/processDue"
    static let BANK_TRANSFER = "/bank/account"
    static let CLEAR_ALL_PENDING_BILLS = "/QRPendingDues/initiate"
    static let PENDING_DUES_PAYMENT_LINK = "/QRPendingDues/paymentLink"
    
    // Mark: Function Definitions
  static func getAccountInfo(userId : String, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getAccountInfo() \(userId)")
    let getUserAccountDetailsUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.userAccountDetails
    var params : [String : String] = [String : String]()
    params[Account.FLD_ACCOUNT_ID] = userId
    HttpUtils.getJSONRequestWithBody(url: getUserAccountDetailsUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
    static func peachPaymentCheckoutRequest(amount : String, paymentType: String, callBackUrl : String, orderId : String, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("\(amount)")
        let getCheckOutIDUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.PEACH_PAYMENT_CHECKOUT_ID_PATH
        var params : [String : String] = [String : String]()
        params[AmountTransferRequest.FLD_AMOUNT] = amount
        params[AccountRestClient.PAYMENT_TYPE] = paymentType
        params[AccountRestClient.PEACH_PAYMENT_CALL_BACK_URL] = callBackUrl
        params[AccountRestClient.PEACH_PAYMENT_ORDER_ID] = orderId
        params[User.FLD_PHONE] = QRSessionManager.getInstance()!.getUserId()

        HttpUtils.postRequestWithBody(url: getCheckOutIDUrl, targetViewController: targetViewController, handler: completionHandler,body: params)
    }
    static func peachPaymentStatusCheckingRequest(accountId : String, checkoutId: String,targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("\(checkoutId)")
        let getPaymentStatusUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.PEACH_PAYMENT_STATUS_CHECKING_PATH
        var params : [String : String] = [String : String]()
        params[Account.FLD_ACCOUNT_ID] = accountId
        params[Account.ID] = checkoutId
        HttpUtils.postRequestWithBody(url: getPaymentStatusUrl, targetViewController: targetViewController, handler: completionHandler,body: params)
    }

  static func getEncashInformation(accountid : String, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler)
  {
    AppDelegate.getAppDelegate().log.debug("getEncashInformation() \(accountid)")
    let getEncashInformationUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.encashinformationgettingservicepath
    var params : [String : String] = [String : String]()
    params[Account.FLD_ACCOUNT_ID] = accountid
    HttpUtils.getJSONRequestWithBody(url: getEncashInformationUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
    static func validateTMWUser(contactNo : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("\(contactNo)")
        let validateTMWUser = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.VALIDATE_TMW_USER
        var params : [String : String] = [String : String]()
        params[User.CONTACT_NO] = contactNo
        HttpUtils.getJSONRequestWithBody(url: validateTMWUser, targetViewController: targetViewController, params : params,handler: completionHandler)
    }
    static func createProbableTMWUser(userId : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler)
{
    AppDelegate.getAppDelegate().log.debug("\(userId)")
    let createTMWUser = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.CREATE_PROBABLE_TMW_USER
    var params : [String : String] = [String : String]()
    params[RedemptionRequest.ID] = userId
    HttpUtils.putRequestWithBody(url: createTMWUser, targetViewController: targetViewController, handler: completionHandler,body: params)
    }

  static func getTransactionDetails(userId : Double, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getTransactionDetails() \(userId)")
    let getTransactionDetailsUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.userAccountTransactionDetails
    var params : [String : String] = [String : String]()
      params[Account.FLD_ACCOUNT_ID] =  StringUtils.getStringFromDouble(decimalNumber: userId)
    HttpUtils.getJSONRequestWithBody(url: getTransactionDetailsUrl, targetViewController: nil,params : params, handler: completionHandler)
  }
  
  
  static func getRefferalCode(phone : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getRefferalCode() \(phone)")
    let getrefferalCode = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userRefferalCode
    var params : [String : String] = [String : String]()
    params[User.FLD_PHONE] = phone
    HttpUtils.getJSONRequestWithBody(url: getrefferalCode, targetViewController: targetViewController, params : params,handler: completionHandler)
  }
  
  static func postRechaargePoints(body : [String : String],targetViewController: UIViewController, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("postRechaargePoints()")
    let postRechargeRequestUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.userAccountBalanceRecharge
    HttpUtils.postRequestWithBody(url: postRechargeRequestUrl, targetViewController: targetViewController, handler: completionHandler,body: body)
  }
  static func postEncashRequest(body : [String : String],targetViewController: UIViewController, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("postEncashRequest()")
    let putEncashRequestUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.userAccountEncash
    
    HttpUtils.postRequestWithBody(url: putEncashRequestUrl, targetViewController: targetViewController, handler: completionHandler,body: body)
  }
  static func handleTransferRequest(body : [String : String],targetViewController: UIViewController, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("handleransferRequest()")
    let putTransferRequestUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.userAccountTransfer
    
    HttpUtils.putRequestWithBody(url: putTransferRequestUrl, targetViewController: targetViewController, handler: completionHandler,body: body)
  }
  
  static func requestPoints(date : Double, reason : String?, points : Double, requestorUserId : Double, senderContactNo : Double, viewController : UIViewController?,completionHandler : @escaping responseJSONCompletionHandler)
  {
    var params = [String: String]()
    params[AmountTransferRequest.FLD_DATE] = StringUtils.getStringFromDouble(decimalNumber: date)
    params[AmountTransferRequest.FLD_DATE] = StringUtils.getStringFromDouble(decimalNumber: date)
    if reason != nil && reason!.isEmpty == false{
      params[AmountTransferRequest.FLD_REASON] = reason!
    }
    params[AmountTransferRequest.FLD_AMOUNT] = StringUtils.getStringFromDouble(decimalNumber: points)
    params[AmountTransferRequest.FLD_REQUESTORID] = StringUtils.getStringFromDouble(decimalNumber: requestorUserId)
    params[AmountTransferRequest.FLD_SENDERCONTACT] = StringUtils.getStringFromDouble(decimalNumber: senderContactNo)
    let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.REQUEST_POINTS_SERVICE_PATH
    
    HttpUtils.putRequestWithBody(url: url, targetViewController : viewController, handler: completionHandler, body: params)
  }
  
  
    static func sendRefundRequestToRider( userId : Double,points : String, passengerRideId : Double,riderId : Int,pickupAddress : String?,dropAddress : String?,pickupTime : Double?,viewController : UIViewController?,remindAgain: Bool,reason: String,completionHandler :  @escaping responseJSONCompletionHandler){
    var params = [String : String]()
    params[AccountTransaction.ACCOUNTID] =  StringUtils.getStringFromDouble(decimalNumber: userId)
    params[Ride.FLD_RIDERID] = String(riderId)
    params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
    params[AccountTransaction.VALUE] = points
    params[Ride.FLD_PICKUP_ADDRESS] = pickupAddress
    params[Ride.FLD_DROP_ADDRESS] = dropAddress
    params[Ride.FLD_PICKUP_TIME] = StringUtils.getStringFromDouble(decimalNumber: pickupTime)
    params[RefundRequest.remindAgain] = String(remindAgain)
    params[RefundRequest.reason] = reason
    let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.PASSENGER_REFUND_REQUEST_TO_RIDER
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
  }

    static func riderRefundToPassenger(accountTransactionId : Double?,points : String,rideId : Double?,invoiceId: String?,viewController : UIViewController?,completionHandler :  @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AccountTransaction.VALUE] = points
        params[AccountTransaction.ACCOUNTID] = StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId())
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[RefundRequest.invoiceId] = invoiceId
        
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.PARTIAL_REFUND_TRANSACTION
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
  
  static func cancelCompensationTransaction(accountTransactionId : Double,viewController : UIViewController?,completionHandler :  @escaping responseJSONCompletionHandler)
  {
    var params = [String : String]()
    params[AccountTransaction.ID] =  StringUtils.getStringFromDouble(decimalNumber:accountTransactionId)
    let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + CANCEL_COMPENSATION_TRANSACTION_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    
  }
   static func getPastRedemptions(accountid : String, viewController : UIViewController?, completionHandler :  @escaping responseJSONCompletionHandler)
    {
        var params = [String : String]()
        params[Account.FLD_ACCOUNT_ID] = accountid
         let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.REDEMPTION_DETAILS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
        
    }

    static func requestReject( requestorUserId : Double,senderContactNo : String, reason : String?, isTransfer : Bool,passengerRideId: String?,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
    var params = [String : String]()
    params[AmountTransferRequest.FLD_REQUESTORID] = StringUtils.getStringFromDouble(decimalNumber: requestorUserId)
    params[AmountTransferRequest.FLD_SENDERID] = senderContactNo
    params[AmountTransferRequest.IS_TRANSFER] = String(isTransfer)
    if reason != nil{
      params[AmountTransferRequest.REJECT_REASON] = reason
    }
        params[Ride.FLD_PASSENGERRIDEID] = passengerRideId
    let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.REQUEST_REJECT_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
  }
  
    static func getRechargePoints(userid : String, points : String, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[ACCOUNT_ID] = userid
        params[POINTS] = points
         let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.RECHARGED_AMOUNT_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func getChecksSumForFreeCharge(merchantRequest : FreeChargeRequest, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params["merchantRequest"] = merchantRequest.toJSONString()
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.FREECHARGE_CHECKSUM_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func linkPaytmAccountToQR(phone : String, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[PHONE] = phone
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINK_PAYTM_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func verifyOTPForLinkingPaytm(userId : String,mobileNo : String,otp : String,uuid : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params["mobileNo"] = mobileNo
        params["otp"] = otp
        params["uuid"] = uuid
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.VERIFY_OTP_FOR_LINKING_PAYTM_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func linkTMWAccountToQR(phone : String, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[PHONE] = phone
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINK_TMW_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func linkSIMPLAccountToQR(userId : Double, simplToken : String, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params["token"] = simplToken
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINK_SIMPL_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func verifyOTPForLinkingLazyPay(userId: String, mobileNo: String, otp: String, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.MOBILE_NO] = mobileNo
        params[Account.OTP] = otp
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.VERIFY_OTP_FOR_LINKING_LAZYPAY_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func linkLazyPayAccountToQR(phone : String, mobileNo: String, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[PHONE] = phone
        params[Account.MOBILE_NO] = mobileNo
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINK_LAZYPAY_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getLazyPayDisplayEligibility(userId: String, mobileNo: String, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
       var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.MOBILE_NO] = mobileNo
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LAZYPAY_DISPLAY_ELIGIBILITY_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func verifyOTPForLinkingTMW(userId : String,mobileNo : String,otp : String,transactionId : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params["mobileNo"] = mobileNo
        params["otp"] = otp
        params["transactionId"] = transactionId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.VERIFY_OTP_FOR_LINKING_TMW_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getLinkedWalletBalancesOfUser(userId : String,types: String,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params["types"] = types
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINKED_WALLET_BALANCES_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
        
    }
    
    static func removeLinkedWalletOfUser(userId : String,type: String?,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params["type"] = type
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.REMOVE_LINKED_WALLET_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func updateDefaultLinkedWallet(userId : String,type : String?,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[RedemptionRequest.USERID] = userId
        params[RedemptionRequest.TYPE] = type
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.UPDATE_DEFAULT_LINKED_WALLET_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getAvailableAndActivatedPasses(userId : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
         let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.COMMUTE_PASS_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }

    static func purchaseRidePass(passObject : RidePass,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.PASS] = passObject.toJSONString()
         let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.COMMUTE_PASS_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func refundRechargeAmount(transactionId : String, value: String?, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("\(transactionId)")
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.RECHARGE_REFUND_PATH
        var params : [String : String] = [String : String]()
        params[AccountTransaction.ID] = transactionId
        params[AccountTransaction.VALUE] = value
        HttpUtils.postRequestWithBody(url: url, targetViewController: targetViewController, handler: completionHandler,body: params)
    }
    
        
    static func setSimplData(userId : String,simplData : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.simplData] = simplData
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.SET_SIMPL_DATA_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func linkAmazonPayAndGetBalance(userId : String,codeVerifier : String,authCode : String,clientId : String,redirectUri : String,amount : String,orderId : String,channelIdentifier : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.codeVerifier] = codeVerifier
        params[Account.authCode] = authCode
        params[Account.clientId] = clientId
        params[Account.redirectUri] = redirectUri
        params[Account.amount] = amount
        params[Account.orderId] = orderId
        params[Account.channelIdentifier] = channelIdentifier
        params[Account.iosUser] = "true"
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINK_AND_PROCESS_AMAZON_PAY_PATH
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getAmazonPayAccountstatus(userId : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.GET_AMAZON_PAY_LINK_STATUS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func amazonPayProcessCharge(userId : String,codeVerifier : String,amount : String,orderId : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.codeVerifier] = codeVerifier
        params[Account.amount] = amount
        params[Account.orderId] = orderId
        params[Account.iosUser] = "true"
        
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.PROCESS_CHARGE_AMAZON_PAY_PATH
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getRideAsurredIncentiveIfApplicable(userId : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
       
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.GET_ASSURED_RIDE_INCENTIVE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func subscribeForRideAssuredIncentive(rideAssuredIncentiveData : RideAssuredIncentive,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[RideAssuredIncentive.RIDE_ASSURED_INCENTIVE] = rideAssuredIncentiveData.toJSONString()
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.GET_ASSURED_RIDE_INCENTIVE_PATH
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func updateRideAssuredIncentiveDisplayStatus(userId : String,status : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[RideAssuredIncentive.STATUS] = status
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.UPDATE_RIDE_INCENTIVE_DISPLAY_STATUS_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    static func getSodexoCard(firstName: String, lastName: String, mobileNo: String, emailId: String, userId: String, homeNo: String, streat: String, area: String, city: String, pinCode: String, state: String, viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.firstName] = firstName
        params[Account.lastName] = lastName
        params[Account.mobile] = mobileNo
        params[Account.email_id] = emailId
        params[Account.emp_code] = userId
        params[Account.addr_1] = homeNo
        params[Account.addr_2] = streat
        params[Account.addr_3] = area
        params[Account.pinCode] = pinCode
        params[Account.city] = city
        params[Account.state] = state
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.ORDER_SODEXO_CARD_PATH
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    static func getMonthlyReport(userId : String, fromDate: String, toDate: String, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.fromDate] = fromDate
        params[Account.toDate] = toDate
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.MONTHLY_REPORT_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func linkAmazonPayWallet(userId : String,codeVerifier : String,authCode : String,clientId : String,redirectUri : String, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.codeVerifier] = codeVerifier
        params[Account.authCode] = authCode
        params[Account.clientId] = clientId
        params[Account.redirectUri] = redirectUri
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINK_AMAZON_PAY_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    static func getStateAndCity(pinCode : String,viewController: UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.pinCode] = pinCode
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AccountRestClient.GET_CITY_STATE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func linkMobikwikWallet(userId : String,mobileNo : String, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[PHONE] = userId
        params[Account.MOBILE_NO] = mobileNo
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.MOBIKWIK_WALLET_LINK_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func verifyOTPForLinkingMobikwik(userId : String,mobileNo : String,otp : String,viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.MOBILE_NO] = mobileNo
        params[Account.OTP] = otp
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.MOBIKWIK_WALLET_OTP_VERIFY_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func linkUPIWallet(userId : String,mobileNo : Double?,email : String?,vpaAddress : String,type: String?, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.MOBILE_NO] = StringUtils.getStringFromDouble(decimalNumber: mobileNo)
        if email != nil{
           params[Account.email] = email
        }
        params[Account.vpaAddress] = vpaAddress
        params[Account.type] = type
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINK_UPI_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getPendingLinkedWalletTransactions(userId : String,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.GET_PENDING_LINKED_WALLET_TRANSACTIONS_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    
    static func updateOrderIdForPendingLinkedWalletTransaction(userId : String,txnIds : String,orderId : String,paymentType : String,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.txnIds] = txnIds
        params[Account.orderId] = orderId
        params["paymentType"] = paymentType

        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.UPDATE_ORDER_ID_FOR_PENDING_TRANSACTION_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
        
    }
    
    static func updateLinkedWalletOfUserAsSuccess(userId : String,orderId : String,paymentType : String,amount  : Double,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.orderId] = orderId
        params["paymentType"] = paymentType
        params["amount"] = String(amount)
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.UPDATE_LINKED_WALLET_PENDING_TRANSACTION_STATUS_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
        
    }
    
    static func linkFrechargeWallet(userId : String,mobileNo : String, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[PHONE] = userId
        params[Account.MOBILE_NO] = mobileNo
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.FRECHARGE_WALLET_LINK_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func verifyOTPForLinkingFrecharge(userId : String,mobileNo : String,otp : String,otpId: String?, viewController : UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.MOBILE_NO] = mobileNo
        params[Account.OTP] = otp
        params["otpId"] = otpId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.FRECHARGE_WALLET_OTP_VERIFY_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func registerShellCard(fuelCardRegistration : FuelCardRegistration, viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.SHELL_CARD_REGISTRATION
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: fuelCardRegistration.getParams())
    }
    static func getMobiquickURLToAddMoney(userId : String, amount: Double, viewController: UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.amount] = StringUtils.getStringFromDouble(decimalNumber: amount)
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.GET_MOBIQUICK_URL_TO_ADD_MONEY
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func getAmazonURLToAddMoney(userId : String, amount: Double, viewController: UIViewController,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[User.CLIENT_DEVICE_TYPE] = Strings.ios
        params[Account.amount] = StringUtils.getStringFromDouble(decimalNumber: amount)
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.GET_AMAZON_URL_TO_ADD_MONEY
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func getOpenLinkedWalletTransactions(userId : String,rideId : Double?,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Ride.FLD_RIDEID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.PENDING_LINKED_WALLET_TRANSACTIONS_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func getPaymentStatus(orderId: String?, handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.orderId] = orderId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.GET_UPI_PAYMENT_STATUS_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    
    static func initiateUPIPayment(userId: String?, orderId: String?, amount: String?, paymentType: String?, handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.orderId] = orderId
        params[Account.amount] = amount
        params[Account.type] = paymentType
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.INITIATE_UPI_PAYMENT_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    
    static func cancelUPIPayment(userId: String?, orderId: String?, handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[Account.orderId] = orderId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.CANCEL_UPI_PAYMENT_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    static func linkSIMPLAccountToQRInSignUp(userId: String?, handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.LINK_SIMPL_AT_SIGNUP
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    static func checkCurrentUserIsHpPayCustomer(userId: String,mobileNo: String,handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.mobile] = mobileNo
        params[User.FLD_PHONE] = userId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.CHECK_HP_PAY_REGISTRATION_PATH
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    static func registerHPPay(userId: String,mobileNo: String,salutation: String, firstName: String,lastName: String, dob: String, handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.mobile] = mobileNo
        params[User.FLD_PHONE] = userId
        params[Account.salutation] = salutation
        params[Account.firstName] = firstName
        params[Account.lastName] = lastName
        params[Account.dob] = dob
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.HP_PAY_REGISTRATION_PATH
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    static func getPendingRefundRequest(userId: String, handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.PENDING_REFUND_REQUESTS_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }

    static func checkAndRegisterForIOCLFuleCard(firstName: String, lastName: String?, newProfile: Bool,  userId: String, mobileNo: String,handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.firstName] = firstName
        params[Account.lastName] = lastName
        params[Account.newprofile] = String(newProfile)
        params[Account.mobile] = mobileNo
        params[Account.emp_code] = userId
        
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.CHECK_And_REGISTRATION_IOCL_PATH
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    static func getPendingDues(userId: String, handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.GET_PENDING_DUES_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    static func payPendingDues(userId : String,paymentType: String,dueId: Int, completionHandler : @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[PendingDue.paymentType] = paymentType
        params["id"] = String(dueId)
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.PAY_PENDING_DUES
        HttpUtils.putRequestWithBody(url: url, targetViewController: nil, handler: completionHandler,body: params)
    }
    static func getBankRegistrationDetails(userId: String, handler : @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + BANK_TRANSFER
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    static func registerForBankAccount(userBankInfo: UserBankAccountInfo,handler : @escaping responseJSONCompletionHandler) {
        let params = userBankInfo.getParamsMap()
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.BANK_TRANSFER
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    static func updateOrderIdToClearPendingBills(userId: String,dueIds: String,orderId: String,paymentType : String,handler: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Account.FLD_USER_ID] = userId
        params[PendingDue.dueIds] = dueIds
        params[Account.orderId] = orderId
        params[PendingDue.paymentType] = paymentType
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.CLEAR_ALL_PENDING_BILLS
        HttpUtils.putRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    
    static func getPaymentLinkForPayment( dueIds: String ,completionHandler: @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AccountRestClient.PENDING_DUES_PAYMENT_LINK
        params[TaxiRidePassenger.FIELD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber : UserDataCache.getCurrentUserId())
        params[PendingDue.dueIds] = dueIds
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    
}
