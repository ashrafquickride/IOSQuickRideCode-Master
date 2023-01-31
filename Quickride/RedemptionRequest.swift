//
//  RedemptionRequest.swift
//  Quickride
//
//  Created by QuickRideMac on 12/31/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RedemptionRequest :NSObject, Mappable{
    var id : Double?
    var userId : Double?
    var txnId : String?
    var status : String?
    var amount : Double?
    var requestedTime : Double?
    var reason : String?
    var type : String?
    var processedTime : Double?
    static let REDEMPTION_REQUEST_STATUS_OPEN = "OPEN"
    static let REDEMPTION_REQUEST_STATUS_REVIEW = "REVIEW"
    static let REDEMPTION_REQUEST_STATUS_REJECTED = "REJECTED"
    static let REDEMPTION_REQUEST_STATUS_APPROVED = "APPROVED"
    static let REDEMPTION_REQUEST_STATUS_PROCESSED = "PROCESSED"
    static let REDEMPTION_REQUEST_STATUS_PENDING = "PENDING"
    static let REDEMPTION_REQUEST_STATUS_FAILED = "FAILED"
    static let REDEMPTION_REQUEST_STATUS_CANCELLED = "CANCELLED"
    static let REDEMPTION_REQUEST_STATUS_UNKNOWN = "UNKNOWN"
    static let REDEMPTION_REQUEST_STATUS_TO_BE_CANCELLED = "TO_BE_CANCELLED"
    static let REDEMPTION_REQUEST_STATUS_INITIATED = "INTIATED"
    static let REDEMPTION_REQUEST_STATUS_PROBABLE_SUCCESS = "PROBABLE_SUCCESS"
    
    static let USERID = "userId"
    static let ID = "id"
    static let STATUS = "status"
    static let AMOUNT = "amount"
    static let TXNID = "txnid"
    static let REQUESTED_TIME = "requestedTime"
    static let TYPE = "type"
    static let REASON = "reason"
    static let PROCESSEDTIME = "processedTime"
    static let REDEMPTION_TYPE_PAYTM = "PAYTM"
    static let REDEMPTION_TYPE_PAYTM_FUEL = "PAYTM FUEL"
    static let REDEMPTION_TYPE_HP_CARD = "HP"
    static let REDEMPTION_TYPE_SHELL_CARD = "SHELL"
    static let REDEMPTION_TYPE_IO_CARD = "IO"
    static let REDEMPTION_TYPE_PETRO_CARD = "PETRO"
    static let REDEMPTION_TYPE_TMW = "TMW"
    static let REDEMPTION_TYPE_PEACH = "PEACH"
    static let REDEMPTION_TYPE_AMAZONPAY = "AMAZON PAY GIFT CARD"
    static let REDEMPTION_TYPE_SODEXO = "SODEXO FUEL CARD"
    static let REDEMPTION_TYPE_HP_PAY = "HP PAY"
    static let REDEMPTION_TYPE_IOCL = "IOCL"
    static let REDEMPTION_TYPE_BANK_TRANSFER = "BANK_TRANSFER"
    
    static let iocl_toll_free = "1800228888";
    static let iocl_email = "help@xtrarewards.com";

    init(id : Double, userId : Double, txnId : String, status : String, amount : Double, requestedTime : Double, reason : String,type : String, processedTime : Double) {
        self.id = id
        self.userId = userId
        self.txnId = txnId
        self.status = status
        self.amount = amount
        self.requestedTime = requestedTime
        self.reason = reason
        self.type = type
        self.processedTime = processedTime
    }
    required init(map:Map){
        
    }
    func mapping(map: Map) {
        id <- map[RedemptionRequest.ID]
        userId <- map[RedemptionRequest.USERID]
        txnId <- map[RedemptionRequest.TXNID]
        status <- map[RedemptionRequest.STATUS]
        amount <- map[RedemptionRequest.AMOUNT]
        requestedTime <- map[RedemptionRequest.REQUESTED_TIME]
        reason <- map[RedemptionRequest.REASON]
        type <- map[RedemptionRequest.TYPE]
        processedTime <- map[RedemptionRequest.PROCESSEDTIME]
    }
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params[RedemptionRequest.USERID] = StringUtils.getStringFromDouble(decimalNumber : self.userId)
        params[RedemptionRequest.TXNID] = self.txnId
        params[RedemptionRequest.STATUS] =  self.status
        params[RedemptionRequest.AMOUNT] =  String(describing: self.amount)
        params[RedemptionRequest.REQUESTED_TIME] =  StringUtils.getStringFromDouble(decimalNumber : self.requestedTime)
        params[RedemptionRequest.REASON] =  self.reason
        params[RedemptionRequest.ID] =  StringUtils.getStringFromDouble(decimalNumber : self.id)
        params[RedemptionRequest.TYPE] =  self.type
        params[RedemptionRequest.PROCESSEDTIME] = StringUtils.getStringFromDouble(decimalNumber : self.processedTime)
        return params
    }
    static func getAmountAfterRemovingServiceFeeForPaytm(points : Int, serviceFee : Int) -> Int {
         return Int(Float(points) * Float(1 - Float(serviceFee)/100))
    }
    static func getAmountAfterRemovingGateWayChargesForRechargePoints(points : Int, gateWayCharges : Float) -> Int {
        return Int(Float(points) - (Float(points) * (gateWayCharges/100)))
    }
    
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " txnId: \(String(describing: self.txnId))," + " status: \(String(describing: self.status))," + " amount: \(String(describing: self.amount)),"
            + "requestedTime: \(String(describing: self.requestedTime))," + "reason: \(String(describing: self.reason))," + "type: \(String(describing: self.type))," + "processedTime: \(String(describing: self.processedTime)),"
    }
}
