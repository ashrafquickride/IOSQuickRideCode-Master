//
//  UserVacation.swift
//  Quickride
//
//  Created by QuickRideMac on 4/12/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class UserVacation : NSObject, Mappable
{
    var id : Double?
    var userId : Double?
    var fromDate : Double?
    var toDate : Double?
    
    static let ID = "id"
    static let USER_ID = "userId"
    static let FROM_TIME = "fromTime"
    static let TO_TIME = "toTime"
    
    init(id : Double, userId : Double, fromDate : Double?, toDate : Double?) {
        self.id = id
        self.userId = userId
        self.fromDate = fromDate
        self.toDate = toDate
    }
    
    public required init?(map: Map) {
        
    }
    public func mapping(map: Map) {
        self.userId <- map["userId"]
        self.id <- map["id"]
        self.fromDate <- map["fromTime"]
        self.toDate <- map["toTime"]
        }
    
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["id"] = StringUtils.getStringFromDouble(decimalNumber: self.id!)
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber: self.userId)
        
        if self.fromDate != nil && self.toDate != nil{
            params["fromTime"] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: self.fromDate!))
            params["toTime"] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: self.toDate!))
        }else{
            params["fromTime"] = nil
            params["toTime"] = nil
        }
        return params
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " fromDate: \(String(describing: self.fromDate))," + " toDate: \(String(describing: self.toDate)),"
    }

}
