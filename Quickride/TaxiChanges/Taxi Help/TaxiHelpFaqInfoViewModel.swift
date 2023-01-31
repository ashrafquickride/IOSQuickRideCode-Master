//
//  TaxiHelpFaqInfoViewModel.swift
//  Quickride
//
//  Created by HK on 17/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class TaxiHelpFaqInfoViewModel {
    
    var taxiHelpFaqCategory = TaxiHelpFaqCategory()
    var faqsElements = [TaxiHelpFaq]()
    var isExpanded : [Int : Bool] = [Int: Bool]()
    
    init() {}
    
    init(taxiHelpFaqCategory: TaxiHelpFaqCategory) {
        self.taxiHelpFaqCategory = taxiHelpFaqCategory
        faqsElements = taxiHelpFaqCategory.faqList
    }
}
