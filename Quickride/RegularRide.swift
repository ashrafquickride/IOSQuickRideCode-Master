//
//  RegularRide.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
public class RegularRide: Ride{
    
    var fromDate : Double = 0.0
    var toDate : Double?
    var sunday : String?
    var monday : String?
    var tuesday : String?
    var wednesday : String?
    var thursday : String?
    var friday : String?
    var saturday : String?
    var dayType : String = Ride.ALL_DAYS
    
     let FLD_DATE_TYPE = "dateType"
    var isRecurringRideRequiredFrom: String?
    
    override init() {
        super.init()
    }
   init(regularRide: RegularRide) {
    super.init(ride: regularRide)
    self.fromDate = regularRide.fromDate
    self.toDate = regularRide.toDate
    self.sunday  = regularRide.sunday
    self.monday = regularRide.monday
    self.tuesday = regularRide.tuesday
    self.wednesday = regularRide.wednesday
    self.thursday = regularRide.thursday
    self.friday = regularRide.friday
    self.saturday = regularRide.saturday

  }
    init(userId : Double, userName : String, startAddress : String, startLatitude : Double, startLongitude : Double, endAddress : String, endLatitude : Double, endLongitude : Double, dayType : String, startTime : Double, fromDate : Double, toDate : Double?, sunday : String?, monday : String?, tuesday : String?, wednesday : String?, thursday : String?, friday : String?, saturday : String?, rideType : String) {
        super.init()
        self.userId = userId
        self.userName = userName
        self.startAddress = startAddress
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endAddress = endAddress
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
        self.dayType = dayType
        self.startTime = startTime
        if fromDate != 0{
            self.fromDate = fromDate
        }
        if toDate != nil{
            self.toDate = toDate!
        }
        
        if sunday != nil{
            self.sunday = sunday!
        }
        if monday != nil{
            self.monday = monday!
        }
        
        if tuesday != nil{
            self.tuesday = tuesday!
        }
        if wednesday != nil{
            self.wednesday = wednesday!
        }
        if thursday != nil{
            self.thursday = thursday!
        }
        if friday != nil{
            self.friday = friday!
        }
        if saturday != nil{
            self.saturday = saturday!
        }
        self.rideType = rideType
    }
    override init(ride: Ride) {
        super.init(ride: ride)
    }

    required  public init?(_ map: Map) {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.fromDate <- map["fromDate"]
        self.toDate  <- map["toDate"]
        self.sunday <- map["sunday"]
        self.monday <- map["monday"]
        self.tuesday <- map["tuesday"]
        self.wednesday <- map["wednesday"]
        self.thursday <- map["thursday"]
        self.friday <- map["friday"]
        self.saturday <- map["saturday"]
        self.dayType <- map["dateType"]
    }
    func getParams() ->[String : String]{
        var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params[User.FLD_NAME] = userName
        params[Ride.FLD_STARTADDRESS] = startAddress
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        
        params[Ride.FLD_ENDADDRESS] = endAddress
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude!)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude!)
        params[FLD_DATE_TYPE] = dayType
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime))

        if fromDate != 0{
            params[Ride.FLD_FROM_DATE] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: fromDate))
        }
        if toDate != nil{
            params[Ride.FLD_TO_DATE] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: toDate!))
        }
        if sunday != nil{
            params[Ride.FLD_SUNDAY] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: DateUtils.getTimeStampFromString(dateString: sunday, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), timeFormat: DateUtils.TIME_FORMAT_HHmm)
        }
        if monday != nil{
            params[Ride.FLD_MONDAY] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: DateUtils.getTimeStampFromString(dateString: monday, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), timeFormat: DateUtils.TIME_FORMAT_HHmm)
        }
        
        if tuesday != nil{
            params[Ride.FLD_TUESDAY] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: DateUtils.getTimeStampFromString(dateString: tuesday, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), timeFormat: DateUtils.TIME_FORMAT_HHmm)
        }
        if wednesday != nil{
            params[Ride.FLD_WEDNESDAY] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: DateUtils.getTimeStampFromString(dateString: wednesday, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), timeFormat: DateUtils.TIME_FORMAT_HHmm)
        }
        if thursday != nil{
            params[Ride.FLD_THURSDAY] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: DateUtils.getTimeStampFromString(dateString: thursday, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), timeFormat: DateUtils.TIME_FORMAT_HHmm)
        }
        if friday != nil{
            params[Ride.FLD_FRIDAY] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: DateUtils.getTimeStampFromString(dateString: friday, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), timeFormat: DateUtils.TIME_FORMAT_HHmm)
        }
        if saturday != nil{
            params[Ride.FLD_SATURDAY] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: DateUtils.getTimeStampFromString(dateString: saturday, dateFormat: DateUtils.DATE_FORMAT_HH_mm_ss)!), timeFormat: DateUtils.TIME_FORMAT_HHmm)
        }
        return params
    }
}
