//
//  TaxipoolLocationSelectionViewModel.swift
//  Quickride
//
//  Created by HK on 23/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxipoolLocationSelectionViewModel {
    
    var matchedTaxiRideGroup: MatchedTaxiRideGroup?
    var fromLocation: Location?
    var toLocation: Location?
    var handler: taxipoolLocationSelectionComplitionHandler?
    
    init() {}
    init(matchedTaxiRideGroup: MatchedTaxiRideGroup,handler: @escaping taxipoolLocationSelectionComplitionHandler) {
        self.matchedTaxiRideGroup = matchedTaxiRideGroup
        fromLocation = Location(latitude: matchedTaxiRideGroup.startLat, longitude: matchedTaxiRideGroup.startLng, shortAddress: matchedTaxiRideGroup.startAddress)
        toLocation = Location(latitude: matchedTaxiRideGroup.endLat, longitude: matchedTaxiRideGroup.endLng, shortAddress: matchedTaxiRideGroup.endAddress)
        self.handler = handler
    }
    
    func getMatchedTaxiGroupForSelectedLocation(complitionHandler: @escaping( _ matchedTaxiRideGroup: MatchedTaxiRideGroup?, _ responseObject: NSDictionary?,_ error: NSError?) -> ()){
        TaxiSharingRestClient.getInviteByContactTaxiPoolerDetails(taxiGroupId: matchedTaxiRideGroup?.taxiRideGroupId ?? 0, startTime: matchedTaxiRideGroup?.startTimeMs ?? 0, startLat: fromLocation?.latitude ?? 0, startLng: fromLocation?.longitude ?? 0, endLat: toLocation?.latitude ?? 0, endLng: toLocation?.longitude ?? 0, noOfSeats: 1, reqToSetAddress: true){(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let matchedTaxiRideGroup = Mapper<MatchedTaxiRideGroup>().map(JSONObject: responseObject!["resultData"]){
                    complitionHandler(matchedTaxiRideGroup,nil,nil)
                }
            }else{
                complitionHandler(nil,responseObject,error)
            }
        }
    }
}
