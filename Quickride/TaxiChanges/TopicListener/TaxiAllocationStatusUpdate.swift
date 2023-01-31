//
//  TaxiAllocationStatusUpdate.swift
//  Quickride
//
//  Created by Rajesab on 03/10/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class TaxiAllocationStatusUpdate: TopicListener {
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("Taxi ride allocation status update \(String(describing: messageObject))")
        if let taxiRideAllocationStatusUpdate = Mapper<TaxiRideAllocationStatusUpdate>().map(JSONString: messageObject as! String){
            if taxiRideAllocationStatusUpdate.status == TaxiRideAllocationStatusUpdate.STATUS_ALLOCATION_STARTED, let taxiRidePassengerId = taxiRideAllocationStatusUpdate.taxiRidePassengerId  {
                SharedPreferenceHelper.storeTaxiDriverAllocationStatus(taxiRidePassengerId: taxiRidePassengerId, isAllocationStarted: true)
                NotificationCenter.default.post(name: .taxiDriverAllocationStatusChanged, object: nil, userInfo: nil)
                return
            }
            SharedPreferenceHelper.storeTaxiDriverAllocationStatus(taxiRidePassengerId: taxiRideAllocationStatusUpdate.taxiRidePassengerId ?? 0, isAllocationStarted: nil)
        }
    }
}

struct TaxiRideAllocationStatusUpdate: Mappable {
    var taxiRidePassengerId: Double?
    var status: String?
    static let STATUS_ALLOCATION_STARTED = "AllocationStarted"
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        taxiRidePassengerId <- map["taxiRidePassengerId"]
        status <- map["status"]
    }
    public var description: String {
        return "taxiRidePassengerId: \(String(describing: self.taxiRidePassengerId))," + "status: \(String(describing: self.status)),"
    }
 }
