//
//  OfferImpressionHandler.swift
//  Quickride
//
//  Created by Ashutos on 25/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class OfferImpressionHandler {
    
    static let sharedInstance = OfferImpressionHandler()
    private var offerIdListToSave: [String] = []
    static let displayTime = "displayTime"
    static let clickTime = "clickTime"
    
    private init() { }
    
    func addOffersForImpressionSaving(offerIdString: String) {
        self.offerIdListToSave.append(offerIdString)
        if !offerIdListToSave.isEmpty && offerIdListToSave.count == 5 {
            saveOffersImpression()
        }
    }
    
    private func saveOffersImpression() {
        var temp = [String]()
        temp.append(contentsOf: offerIdListToSave)
        offerIdListToSave.removeAll()
        let offerIdString = temp.joined(separator: ",")
        UserRestClient.offerImpressionSaving(offerIds: offerIdString, inputType: OfferImpressionHandler.displayTime) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
            }
        }
    }
    
    func offerClicked(offerId: String) {
        UserRestClient.offerImpressionSaving(offerIds: offerId, inputType: OfferImpressionHandler.clickTime) { (responseObject, error) in 
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {}
        }
    }
}
