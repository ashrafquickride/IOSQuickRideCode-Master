//
//  BillRestClient.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/9/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

public class BillRestClient {
  
  public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  public typealias responseStringCompletionHandler = (_ responseObject: String?, _ error: NSError?) -> Void
  
  static let passengerBillGeneratorForDebitTransaction = "QRPassengerRide/debitBill"
  static let riderBillForGeneratorCreditTransaction = "QRRiderRide/riderBill"
  static let requestPendingBillFromPassengerPath = "/QRPendingInvoice/pendingBill/request"
  static let RIDE_CANCELLATION_REPORT = "/QRCompensation/rideCancellationReport/ride"
  static let RIDE_CANCELLATION_INVOICE = "/QRInvoice/invoice/compensation"
  static let RIDE_CANCELLATION_WALLET_TRANSACTION = "/Wallet//walletTxns/ride"
  static let RIDER_RIDE_TRIP_REPORT = "/QRRiderRide/rider/tripReport"
  static let WALLET_RIDE_PAYMENTS =  "/Wallet/ride/payments"
    
  public static func getPassengerBill(id : String,userId : String, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getPassengerBill()")
    let getPassengerBillUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AppConfiguration.userPassengerBillGenerator
    var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = id
        params[Ride.FLD_USERID] = userId

      HttpUtils.getJSONRequestWithBody(url: getPassengerBillUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
    
    public static func getPassengerRideBillingDetails(id : String,userId : String, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getPassengerRideBillingDetails()")
        let getPassengerBillUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AppConfiguration.RIDE_BILLING_DETAILS
        var params : [String : String] = [String : String]()
            params[Ride.FLD_PASSENGERRIDEID] = id
            params[Ride.FLD_USERID] = userId
        
        HttpUtils.getJSONRequestWithBody(url: getPassengerBillUrl, targetViewController: nil , params: params, handler: completionHandler)
    }
  
  public static func getRiderBill(id : String,time : String,startAddress : String,endAddress : String,userId : String, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("getRiderBill()")
    let getRiderBillUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + AppConfiguration.userRiderBillGenerator
    var params :[String : String] = [String : String]()
        params[Ride.FLD_ID] = id
        params[Ride.FLD_ACTUALENDTIME] = time
        params[Ride.FLD_STARTADDRESS] = startAddress
        params[Ride.FLD_ENDADDRESS] = endAddress
        params[Ride.FLD_USERID] = userId
     HttpUtils.getJSONRequestWithBody(url: getRiderBillUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
    
    public static func getRiderRideBillingDetails(id : String,userId : String, completionHandler: @escaping responseJSONCompletionHandler){
        let getRiderBillUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AppConfiguration.RIDER_RIDE_BILLING_DETAILS
        var params : [String : String] = [String : String]()
            params[Ride.FLD_ID] = id
            params[Ride.FLD_USERID] = userId
        HttpUtils.getJSONRequestWithBody(url: getRiderBillUrl, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    public static func getRiderRideBill(riderId: String,id: String,completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getRiderRideBill()")
        let getRiderBillUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + RIDER_RIDE_TRIP_REPORT
        var params :[String : String] = [String : String]()
        params[Ride.FLD_ID] = id
        params[Ride.FLD_RIDERID] = riderId
        HttpUtils.getJSONRequestWithBody(url: getRiderBillUrl, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    public static func getPassengerBillForDebitTranscation(userId : String, passengerRideId : Double, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        let getPassengerBillUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + BillRestClient.passengerBillGeneratorForDebitTransaction
        var params : [String : String] = [String : String]()
        params[Ride.FLD_USERID] = userId
        params[AccountTransaction.SOURCEREFERENCEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId) 
        
        HttpUtils.getJSONRequestWithBody(url: getPassengerBillUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
    }
    
    public static func getRiderBillForCreditTransaction(userId: String, riderRideId: Double, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        let getRiderBillUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + BillRestClient.riderBillForGeneratorCreditTransaction
        var params : [String : String] = [String : String]()
        params[Ride.FLD_USERID] = userId
        params[AccountTransaction.SOURCEREFERENCEID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        
        HttpUtils.getJSONRequestWithBody(url: getRiderBillUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
    }
    
    static func requestPendingBillFromPassenger(userId : String,billId : Double?, targetViewController: UIViewController, completionHandler: @escaping responseJSONCompletionHandler){
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + requestPendingBillFromPassengerPath
        var params : [String : String] = [String : String]()
        params[Ride.FLD_USERID] = userId
        params[Bill.bill_id] = StringUtils.getStringFromDouble(decimalNumber: billId)
        
        HttpUtils.putRequestWithBody(url: url, targetViewController: targetViewController, handler: completionHandler, body: params)
        
    }
    public static func getRideCancellationReport(userId: String, rideId: Double, rideType: String,targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
           let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + BillRestClient.RIDE_CANCELLATION_REPORT
           var params : [String : String] = [String : String]()
           params[Ride.FLD_USERID] = userId
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
           params[Ride.FLD_RIDETYPE] = rideType
           HttpUtils.getJSONRequestWithBody(url: url, targetViewController: targetViewController, params: params, handler: completionHandler)
       }
    public static func getRideCancellationInvoice(userId: String, rideId: Double, rideType: String, completionHandler: @escaping responseJSONCompletionHandler){
           let getRiderBillUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + BillRestClient.RIDE_CANCELLATION_INVOICE
           var params : [String : String] = [String : String]()
           params[Ride.FLD_USERID] = userId
           params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
           params[Ride.FLD_RIDETYPE] = rideType
           HttpUtils.getJSONRequestWithBody(url: getRiderBillUrl, targetViewController: nil, params: params, handler: completionHandler)
       }
    public static func getRideCancellationWalletTransaction(userId: String, passengerRideId: Double, completionHandler: @escaping responseJSONCompletionHandler){
           let getRiderBillUrl = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + BillRestClient.RIDE_CANCELLATION_WALLET_TRANSACTION
           var params : [String : String] = [String : String]()
           params[Ride.FLD_USERID] = userId
           params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
           HttpUtils.getJSONRequestWithBody(url: getRiderBillUrl, targetViewController: nil, params: params, handler: completionHandler)
       }
    
    public static func getRidePaymentDetails(userId: Double, rideId: Double, includeCaptureReleaseTxn: Bool, sourceApplication: String, completionHandler: @escaping responseJSONCompletionHandler){
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + BillRestClient.WALLET_RIDE_PAYMENTS
        var params : [String : String] = [String : String]()
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params[Ride.FLD_RIDEID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_INCLUDE_CAPTURE_RELEASE_TXN] = String(includeCaptureReleaseTxn)
        params[Ride.FLD_SOURCE_APK] = sourceApplication
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
}
