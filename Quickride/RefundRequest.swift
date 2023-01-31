//
//  RefundRequest.swift
//  Quickride
//
//  Created by Vinutha on 08/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RefundRequest: Mappable{
    
    var refId: String? // PassengerRidIId
    var sourceRefId: String?// riderIdRideId
    var invoiceId = 0
    var fromUserId = 0
    var fromUserName: String?
    var toUserId = 0
    var reason: String?
    var rejectReason: String?
    var points = 0.0
    var status: String?
    var requestTime = 0.0
    var approvedTime = 0.0
    var rejectedTime = 0.0
    
    static let REQUEST_STATUS_OPEN = "OPEN"
    static let REQUEST_STATUS_APPROVED = "APPROVED"
    static let REQUEST_STATUS_REJECTED = "REJECTED"
    static let REQUEST_STATUS_INPROGRESS = "INPROGRESS"
    
    static let REFUND_REQUEST_OPEN_ERROR = 1406
    static let REFUND_REQUEST_REJECTED_ERROR = 1405
    
    static let remindAgain = "remindAgain"
    static let reason = "reason"
    static let invoiceId = "invoiceId"
    
    init?(map: Map) {
        
    }
    init(refId: String?,sourceRefId: String?,invoiceId: Int,fromUserId: Int,fromUserName: String?,toUserId: Int,reason: String?,points: Int,requestTime: Double) {
        self.refId = refId
        self.sourceRefId = sourceRefId
        self.invoiceId = invoiceId
        self.fromUserId = fromUserId
        self.fromUserName = fromUserName
        self.toUserId = toUserId
        self.reason = reason
        self.points = Double(points)
        self.requestTime = requestTime
    }
    mutating func mapping(map: Map){
        refId <- map["refId"]
        sourceRefId <- map["sourceRefId"]
        invoiceId <- map["invoiceId"]
        fromUserId <- map["fromUserId"]
        fromUserName <- map["fromUserName"]
        toUserId <- map["toUserId"]
        reason <- map["reason"]
        rejectReason <- map["rejectReason"]
        points <- map["points"]
        status <- map["status"]
        requestTime <- map["requestTime"]
        approvedTime <- map["approvedTime"]
        rejectedTime <- map["rejectedTime"]
    }
    
    public var description: String {
        return "refId: \(String(describing: self.refId))," + "sourceRefId: \(String(describing: self.sourceRefId))," + "invoiceId: \(String(describing: self.invoiceId))," + "fromUserId: \(String(describing: self.fromUserId))," + "fromUserName: \(String(describing: self.fromUserName))," + "toUserId: \(String(describing: self.toUserId))," + "reason: \(String(describing: self.reason))," + "rejectReason: \(String(describing: self.rejectReason))," + "points: \(String(describing: self.points))," + "status: \(String(describing: self.status))," + "requestTime: \(String(describing: self.requestTime))," + "approvedTime: \(String(describing: self.approvedTime))," + "rejectedTime: \(String(describing: self.rejectedTime)),"
        
    }
}
