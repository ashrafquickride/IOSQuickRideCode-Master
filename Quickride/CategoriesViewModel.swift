//
//  CategoriesViewModel.swift
//  Quickride
//
//  Created by Halesh on 10/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CategoriesViewModel{
    
    var isFrom = BUY_PRODUCT
    var covidHome = false
    static let POST_PRODUCT = "POST_PRODUCT"
    static let REQUEST_PRODUCT = "REQUEST_PRODUCT"
    static let BUY_PRODUCT = "BUY_PRODUCT"
    static let PRODUCT_LIST = "PRODUCT_LIST"
    
    init(isFrom: String,covidHome : Bool) {
        self.isFrom = isFrom
        self.covidHome = covidHome
    }
    init() {
        
    }
    
}
