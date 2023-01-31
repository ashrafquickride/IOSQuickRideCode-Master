//
//  QuickShareUtils.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickShareUtils{
    
    static func checkDistnaceInMeterOrKm(distance: Double) -> String{
        if distance < 1.0{
            let dist = (distance*1000)
            return StringUtils.getStringFromDouble(decimalNumber: dist) + "m"
        }else{
            return "\(distance) Km"
        }
    }
    static func getDifferenceBetweenTwoDatesInDays(date1 : NSDate?,date2 : NSDate?)->Int{
        AppDelegate.getAppDelegate().log.debug("getDifferenceBetweenTwoDatesInDays() \(String(describing: date1)) \(String(describing: date2))")
        if date1 == nil || date2 == nil{
            return 0
        }
        let days = Int((date1!.timeIntervalSince1970 - date2!.timeIntervalSince1970)/(60*60*24))
        let hours = Int(date1!.timeIntervalSince1970 - date2!.timeIntervalSince1970)%(60*60*24)
        if hours > 0{
            return days
        }else{
            return days
        }
    }
}
