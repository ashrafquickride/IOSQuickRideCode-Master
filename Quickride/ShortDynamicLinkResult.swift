//
//  ShortDynamicLinkResult.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 03/05/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class ShortDynamicLinkResult :NSObject, Mappable{
    
    var shortLink : String?
    var previewLink : String?
    var status : String?
    var error : ShortDynamicLinkError?
    override init() {
        
    }
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        self.shortLink <- map["shortLink"]
        self.previewLink <- map["previewLink"]
        self.error <- map["error"]
    }
    public override var description: String {
        return "shortLink: \(String(describing: self.shortLink))," + "previewLink: \(String(describing: self.previewLink))," + "status: \(String(describing: self.status))," + "error: \(String(describing: self.error)),"
    }
    
}
class ShortDynamicLinkError:NSObject, Mappable {
    var code : String?
    var message : String?
    var status : String?
    
    public required init?(map: Map) {
        
    }
    public func mapping(map: Map) {
        self.code <- map["code"]
        self.message <- map["message"]
        self.status <- map["status"]
    }
    public override var description: String {
        return "code: \(String(describing: self.code))," + "message: \(String(describing: self.message))," + "status: \(String(describing: self.status)),"
    }
}
