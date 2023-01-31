//
//  TaxiHelpViewModel.swift
//  Quickride
//
//  Created by HK on 18/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class TaxiHelpViewModel {
    
    var taxiHelpFaqCategory = [TaxiHelpFaqCategory]()
    var tripStatus: String?
    var tripType: String?
    var sharing: String?
    var isfromTaxiLiveRide =  false
    
    init(tripStatus: String?,tripType: String?,sharing: String?,isfromTaxiLiveRide: Bool) {
        self.tripStatus = tripStatus
        self.tripType = tripType
        self.sharing = sharing
        self.isfromTaxiLiveRide = isfromTaxiLiveRide
    }
    init() {}
    
    func filterTaxiHelpFaqs(taxiHelpAllFaqs: [TaxiHelpFaqCategory]) -> [TaxiHelpFaqCategory]{
        var filterdHelpFaqs = [TaxiHelpFaqCategory]()
        for faqElement in taxiHelpAllFaqs{
            var filteredFaqs = [TaxiHelpFaq]()
            for faq in faqElement.faqList{
                if (tripStatus == nil || faq.statusApplicable.isEmpty || (tripStatus != nil && !faq.statusApplicable.isEmpty && faq.statusApplicable.contains(tripStatus!))) && (sharing == nil || faq.sharing.isEmpty || (sharing != nil && !faq.sharing.isEmpty && faq.sharing.contains(sharing!))) && (tripType == nil || faq.tripTypeApplicable.isEmpty || (tripType != nil && !faq.tripTypeApplicable.isEmpty) && faq.tripTypeApplicable.contains(tripType!)){
                    filteredFaqs.append(faq)
                }
            }
            if !filteredFaqs.isEmpty{
                faqElement.faqList = filteredFaqs
                filteredFaqs.removeAll()
                filterdHelpFaqs.append(faqElement)
            }
        }
        return filterdHelpFaqs
    }
}
