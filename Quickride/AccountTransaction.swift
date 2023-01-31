//
//  File.swift
//  Quickride
//
//  Created by Anki on 12/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AccountTransaction:NSObject,Mappable{

    var transactionId : Double?
    var accountId : Double?
    var date : Double?
    var transactiontype : String?
    var value : Double?
    var desc : String?
    var sourceType : String?
    var sourceRefId : String?
    var refAccountId: String?
    var balance = 0.0
    var txnWallet : String?
    var imageURI: String?
    var gender: String?
    var userName: String?
    var walletSource: String?
    var sourceApp: String?

    static var ACCOUNT_TRANSACTION_TYPE_CREDIT:String = "Credit"
    static var ACCOUNT_TRANSACTION_TYPE_DEBIT:String = "Debit"
    static var ACCOUNT_TRANSACTION_TYPE_RESERVE:String = "Reserve"
    static var ACCOUNT_TRANSACTION_TYPE_RELEASE:String = "Release"

    static var ACCOUNT_TRANSACTION_SRC_TYPE_COMPENSATE:String = "Compensation"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_CANCEL_CREDIT = "CancelCredit"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_CANCEL_DEBIT = "CancelDebit"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_SPENT:String = "Spent"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_EARNED:String = "Earned"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_BONUS:String = "Bonus"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_PROMOTIONAL:String = "Promotional"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_RECHARGE:String = "Recharge"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_ENCASH:String = "Encash"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_RIDE_JOINED:String = "Joined Ride"
    static var ACCOUNT_TRANSACTION_SRC_TYPE_REFUND_CREDIT_EXTERNAL_WALLET = "RefundCreditExternalWallet"

    static let ACCOUNT_RECHARGE_SOURCE_PAYTM : String = "PAYTM"
    static let ACCOUNT_RECHARGE_SOURCE_RAZORPAY : String = "RAZORPAY"
    static let ACCOUNT_RECHARGE_SOURCE_FREECHARGE = "FREECHARGE"
    static let ACCOUNT_RECHARGE_SOURCE_MOBIKWIK = "MOBIQWIK"
    static let ACCOUNT_RECHARGE_SOURCE_AMAZON_PAY = "AMAZONPAY"
    static let TRANSACTION_WALLET_TYPE_INAPP = "INAPP"
    static let TRANSACTION_WALLET_TYPE_PAYTM = "PAYTM"
    static let TRANSACTION_WALLET_TYPE_TMW = "TMW"
    static let TRANSACTION_WALLET_TYPE_SIMPL = "SIMPL"
    static let TRANSACTION_WALLET_TYPE_LAZYPAY = "LAZYPAY"
    static let TRANSACTION_WALLET_TYPE_AMAZON_PAY = "AMAZONPAY"
    static let TRANSACTION_WALLET_TYPE_MOBIQWIK = "MOBIKWIK"
    static let TRANSACTION_WALLET_TYPE_UPI = "UPI"
    static let TRANSACTION_WALLET_TYPE_FREECHARGE = "FREECHARGE"
    static let TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE = "UPI_GPAY_IPHONE"
    static let TRANSACTION_WALLET_TYPE_UPI_GPAY_ANDROID = "UPI_GPAY"
    static let TRANSACTION_WALLET_TYPE_UPI_PHONEPE_ANDROID = "UPI_PHONEPE"
    static let TRANSACTION_WALLET_TYPE_CASH = "CASH"
    static let TRANSACTION_WALLET_PAYMENT_LINK = "PAYMENT_LINK"

    static var ID:String = "id";
    static var ACCOUNTID:String = "accountId";
    static var DATE:String = "date";
    static var TRANSACTIONTYPE:String = "transactiontype";
    static var VALUE:String = "value";
    static var DESCRIPTION:String = "description";
    static var SOURCETYPE:String = "sourceType";
    static var SOURCEREFERENCEID:String = "sourceRefId";
    static let WALLET_SOURCE_TYPE_REWARDS = "Rewards"
    static let WALLET_SOURCE_TYPE_PURCHASED = "Purchased"
    static let SOURCE_APP_TYPE_CARPOOL = "CARPOOL"
    static let SOURCE_APP_TYPE_TAXIPOOL = "TAXIPOOL"
    




    required init(map:Map){

    }

    func mapping(map:Map){
        transactionId <- map["id"]
        accountId <- map["accountId"]
        date <- map["date"]
        transactiontype <- map["transactiontype"]
        value <- map["value"]
        desc <- map["description"]
        sourceType <- map["sourceType"]
        sourceRefId <- map["sourceRefId"]
        refAccountId <- map["refAccountId"]
        balance <- map["balance"]
        txnWallet <- map["txnWallet"]
        imageURI <- map["imageURI"]
        gender <- map["gender"]
        userName <- map["userName"]
        walletSource <- map["walletSource"]
        sourceApp <- map["sourceApp"]
    }
    public override var description: String {
        return "transactionId: \(String(describing: self.transactionId))," + "accountId: \(String(describing: self.accountId))," + " date: \( String(describing: self.date))," + " transactiontype: \(String(describing: self.transactiontype))," + " value: \(String(describing: self.value)),"
        + " desc: \(String(describing: self.desc))," + "sourceType: \(String(describing: self.sourceType))," + "sourceRefId:\(String(describing: self.sourceRefId))," + "refAccountId:\(String(describing: self.refAccountId))," + "balance:\(String(describing: self.balance))," + "txnWallet:\(String(describing: self.txnWallet))," + "imageURI:\(String(describing: self.imageURI))," + "gender:\(String(describing: self.gender))," + "walletSource:\(String(describing: self.walletSource)),"
    }
}
