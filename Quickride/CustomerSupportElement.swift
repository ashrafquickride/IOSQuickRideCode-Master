//
//  CustomerSupportElement.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 17/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class CustomerSupportElement : NSObject, Mappable{
    required init?(map: Map) {
        
    }
    

    var title : String?
    var message : String?
    var suggestion : String?
    var resolution : String?
    var input : String?
    var link : String?
    var customerSupportElement : [CustomerSupportElement]?
    override init() {
        
    }
    init(title : String? , message : String? , suggestion : String? , resolution : String? , input : String? , link: String?, customerSupportElement : [CustomerSupportElement]?) {
        self.title = title
        self.suggestion = suggestion
        self.resolution = resolution
        self.input = input
        self.link = link
        self.message = message
        self.customerSupportElement = customerSupportElement
    }
    
    public func mapping(map: Map) {
        
        title <- map["tittle"]
        suggestion <- map["suggesion"]
        resolution <- map["resolution"]
        input <- map["input"]
        link <- map["link"]
        message <- map["message"]
        customerSupportElement <- map["customerSupportElement"]
    }
    
    public override var description: String {
        return "title: \(String(describing: self.title))," + "message: \(String(describing: self.message))," + " suggestion: \(String(describing: self.suggestion))," + " resolution: \(String(describing: self.resolution))," + " input: \(String(describing: self.input)),"
            + " link: \(String(describing: self.link)),"
    }
}
