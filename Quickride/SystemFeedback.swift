//
//  SystemFeedback.swift
//  Quickride
//
//  Created by Anki on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SystemFeedback:NSObject,Mappable{
    
    var id:Double?
    var feedbackby:Double?
    var feedbacktime:NSDate?
    var rating:Float?
    var extraInfo: String?
    
    static let FLD_FEEDBACK_BY = "feedbackby"
    static let FLD_FEEDBACK_TIME = "feedbacktime"
    static let FLD_EXTRA_INFO = "extrainfo"
    static let FLD_RATING = "rating"
    
    required init(map:Map){
        
    }
    
    func mapping(map:Map){
        id <- map["id"]
        feedbackby <- map["feedbackby"]
        feedbacktime <- map["feedbacktime"]
        rating <- map["rating"]
        extraInfo <- map["extrainfo"]
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "feedbackby: \(String(describing: self.feedbackby))," + " feedbacktime: \( String(describing: self.feedbacktime))," + " rating: \(String(describing: self.rating))," + " extrainfo: \(String(describing: self.extraInfo)),"
    }
}
