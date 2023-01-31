//
//  TaxiPoolInvitePasengerHandler.swift
//  Quickride
//
//  Created by Ashutos on 9/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias taxiPoolInviteCompletionHandler = (_ responcse: TaxiInviteEntity?,_ error : NSError?) -> Void

class TaxiPoolInvitePasengerHandler {
    var taxiInviteData: TaxiInviteEntity
    
    init(taxiInviteData: TaxiInviteEntity) {
        self.taxiInviteData = taxiInviteData
    }
    
    func invitePassenger(taxiInviteHandlerTaxiPool : @escaping taxiPoolInviteCompletionHandler) {
        guard let taxiPoolInviteEntityString = self.taxiInviteData.toJSONString() else { return }
        TaxiPoolRestClient.invitePassengerTaxiPool(taxiInviteEntity: taxiPoolInviteEntityString) { (responseObject, error) in
            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let taxiInviteEntity = Mapper<TaxiInviteEntity>().map(JSONObject: responseObject!["resultData"])
                taxiInviteHandlerTaxiPool(taxiInviteEntity,nil)
            }else{
                taxiInviteHandlerTaxiPool(nil,error)
            }
        }
    }
}
