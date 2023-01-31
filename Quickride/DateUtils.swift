//
//  DateUtils.swift
//  Quickride
//
//  Created by KNM Rao on 12/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class DateUtils{
    
    public static let TIME_FORMAT_HHmm = "HHmm"
    public static let TIME_FORMAT_hhmm_a = "hh:mm a"
    public static let TIME_FORMAT_hmm_a = "h:mm a"
    public static let TIME_FORMAT_a = "a"
    public static let TIME_FORMAT_hh_mm = "hh:mm"
    public static let TIME_FORMAT_HH = "HH"
    public static let DATE_FORMAT_dd_MMM_yy = "dd MMM yy"
    public static let DATE_FORMAT_dd_MMM = "dd-MMM"
    public static let DATE_FORMAT_EE = "EEE"
    public static let DATE_FORMAT_dd = "dd"
    public static let DATE_FORMAT_MMM = "MMM"
    public static let DATE_FORMAT_EEE_dd_MMM_yyyy = "EEE, dd MMM, yyyy"
    
    public static let DATE_FORMAT_dd_MMM_yyy = "dd MMM yyyy"
    public static let DATE_FORMAT_EEE_dd_MMM = "EEE, dd MMM"
    
    public static let DATE_FORMAT_dd_MM_yyyy = "dd-MM-yyyy"
    public static let DATE_FORMAT_yyyy_MM_dd_HH_mm_ss = "yyyyMMddHHmmss"
    public static let DATE_FORMAT_hh_mm_aaa_dd_mmm = "hh:mm a\ndd MMM"
    public static let DATE_FORMAT_dd_MMM_hh_mm_aaa = "EEE dd MMM 'at' hh:mm a"
    public static let DATE_FORMAT_dd_MMM_hh_mm_aa = "EEE dd MMM hh:mm a"
    public static let WR_DATE_FORMAT_dd_MMM_hh_mm_aaa = "dd MMM',' hh:mm a"
    public static let DATE_FORMAT_EEE_dd_hh_mm_aaa = "EEE dd 'at' hh:mm a"
    public static let DATE_FORMAT_EEE_dd_h_mm_aaa = "EEE dd', 'h:mm a"
    public static let DATE_FORMAT_HH_mm_ss = "HH:mm:ss"
    
    public static let DATE_FORMAT_ddMMyyyyHHmm = "ddMMyyyyHHmm"
    public static let DATE_FORMAT_EEE_dd_MMM_h_mm_a = "EEE', 'dd MMM', 'hh:mm a"
    public static let DATE_FORMAT_dd_MMM_H_mm = "dd-MMM hh:mm a"
    public static let DATE_FORMAT_dd_MMM_h_mm = "dd-MMM h:mm a"
    public static let DATE_FORMAT_d_MMM_H_mm = "d MMM h:mm a"
    public static let DATE_FORMAT_yyyy_MM_dd = "yyyy-MM-dd"
    public static let DATE_FORMAT_MMMM = "MMMM"
    public static let DATE_FORMAT_yyyy_MM_dd_HH_mm_ssX = "yyyy-MM-dd'T'HH:mm:ssX"
    public static let DATE_FORMAT_MMM_dd = "MMM dd"
    public static let DATE_FORMAT_EEE_YY = "EEE YY"
    public static let DATE_FORMAT_YYYY_MM_DD_HH_SS = "yyyy-MM-dd HH:mm:ss"
    public static let DATE_FORMAT_MMM_DD_YYYY = "MMM dd, yyyy hh:mm:ss a"
    public static let DATE_FORMAT_D_MM_HH_MM_A = "d MMM', 'h:mm a"
    public static let DATE_FORMAT_D_MM = "d MMM"
    public static let DATE_FORMAT_yyyy = "yyyy"
    public static let DATE_FORMAT_DD_MM_YYYY = "dd/MM/yyyy"
    public static let DATE_FORMAT_D_M_YYYY = "d/M/yyyy"
    public static let DATE_FORMAT_D_MMM_YYYY_h_mm_a = "d MMM yyyy','h:mm a"
    
    init(){
        
    }
    
    static func getExactDifferenceBetweenTwoDatesInMins(time1 : Double?,time2 : Double?)->Int{
        AppDelegate.getAppDelegate().log.debug("getExactDifferenceBetweenTwoDatesInMins() \(String(describing: time1)) \(String(describing: time2))")
        if time1 == nil || time2 == nil{
            return 0
        }
        return Int((time1! - time2!)/(1000*60))
    }
    static func getDifferenceBetweenTwoDatesInMins(time1 : Double?,time2 : Double?)->Int{
        if time1 == nil || time2 == nil{
            return 0
        }
        return abs(Int((time1! - time2!)/(1000*60)))
    }
    static func getDifferenceBetweenTwoDatesInSecs(time1 : Double?,time2 : Double?)->Int{
        if time1 == nil || time2 == nil{
            return 0
        }
        return abs(Int((time1! - time2!)/1000))
    }
    static func getDifferenceBetweenTwoDatesInDays(time1 : Double?,time2 : Double?)->Int{
        if time1 == nil || time2 == nil{
            return 0
        }
        let time = Int(time1! - time2!)
        return abs(time/1000*60*60*24)
    }
    static func getDifferenceBetweenTwoDatesInDays(date1 : NSDate?,date2 : NSDate?)->Int{
        AppDelegate.getAppDelegate().log.debug("getDifferenceBetweenTwoDatesInDays() \(String(describing: date1)) \(String(describing: date2))")
        if date1 == nil || date2 == nil{
            return 0
        }
        return Int((date1!.timeIntervalSince1970 - date2!.timeIntervalSince1970)/(60*60*24))
    }
    
    static func getExactDifferenceBetweenTwoDatesInDays(date1 : NSDate?,date2 : NSDate?)->Int{
        AppDelegate.getAppDelegate().log.debug("getDifferenceBetweenTwoDatesInDays() \(String(describing: date1)) \(String(describing: date2))")
        if date1 == nil || date2 == nil{
            return 0
        }
        let days = Int((date1!.timeIntervalSince1970 - date2!.timeIntervalSince1970)/(60*60*24))
        let hours = Int(date1!.timeIntervalSince1970 - date2!.timeIntervalSince1970)%(60*60*24)
        if hours > 0{
            return days+1
        }else{
            return days
        }
    }
    
    static func addMinutesToTimeStamp(time : Double, minutesToAdd : Int) -> Double{
        AppDelegate.getAppDelegate().log.debug("addMinutesToTimeStamp() \(time) \(minutesToAdd)")
        return time+Double(minutesToAdd*60*1000)
    }
    static func getCurrentTimeInMillis()->Double{
        return NSDate().timeIntervalSince1970*1000
    }
    
    
    static func getDateFromString(date : String?,dateFormat : String?) -> NSDate?{
        AppDelegate.getAppDelegate().log.debug("getDateFromString() \(String(describing: date)) \(String(describing: dateFormat))")
        if date == nil || dateFormat == nil{
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat
        if let passedDate = date,let date = dateFormatter.date(from: passedDate){
            return  date as NSDate
        }else{
            return  NSDate()
        }
    }
    static func getDateStringFromString(date : String?,requiredFormat : String?,currentFormat: String?) -> String?{
        AppDelegate.getAppDelegate().log.debug("getDateFromString() \(String(describing: date)) \(String(describing: requiredFormat)) \(String(describing: currentFormat))")
        if date == nil || requiredFormat == nil || currentFormat == nil{
            return nil
        }
        let dateObj = getDateFromString(date: date, dateFormat: currentFormat)
        return getDateStringFromNSDate(date: dateObj, dateFormat: requiredFormat!)
    }
    
    static func getTimeStringFromTimeInMillis(timeStamp : Double?,timeFormat : String) -> String?{
        AppDelegate.getAppDelegate().log.debug("getTimeStringFromTimeInMillis() \(String(describing: timeStamp)) \(timeFormat)")
        if timeStamp == nil || timeStamp == 0{
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = timeFormat
        return dateFormatter.string(from: NSDate(timeIntervalSince1970: timeStamp!/1000) as Date)
    }
    
    
    static func getDateStringFromNSDate(date : NSDate? ,dateFormat : String)->String?{
        AppDelegate.getAppDelegate().log.debug("getDateStringFromNSDate() \(String(describing: date)) \(dateFormat)")
        if date == nil{
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat
        return (dateFormatter.string(from: date! as Date))
        
    }
    static func getDoubleFromNSDate(date : NSDate? ,dateFormat : String)->Double?{
        AppDelegate.getAppDelegate().log.debug("getDateStringFromNSDate() \(String(describing: date)) \(dateFormat)")
        if date == nil{
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: date! as Date)
        if dateString.isEmpty == true{
            return nil
        }
        let date = getDateFromString(date: dateString, dateFormat: dateFormat)
        return (date?.getTimeStamp())!
    }
    
    
    static func getTimeStampFromString(dateString : String?, dateFormat : String) -> Double?{
        AppDelegate.getAppDelegate().log.debug("getTimeStampFromString() \(String(describing: dateString)) \(dateFormat)")
        if dateString == nil || dateString!.isEmpty == true{
            return nil
        }
        let date = getDateFromString(date: dateString, dateFormat: dateFormat)
        return (date?.getTimeStamp())!
    }
    static func getNSDateFromTimeStamp(timeStamp : Double?) -> NSDate?{
        AppDelegate.getAppDelegate().log.debug("getNSDateFromTimeStamp() \(String(describing: timeStamp))")
        if timeStamp == nil || timeStamp == 0{
            return nil
        }else{
            return NSDate(timeIntervalSince1970: timeStamp!/1000)
        }
    }
    
    /// Time Utils
    static func getTimeStringFromTime(time : String?, timeFormat : String) -> String?{
        AppDelegate.getAppDelegate().log.debug("getTimeStringFromTime() \(String(describing: time)) \(timeFormat)")
        if time == nil || time!.isEmpty == true{
            return nil
        }else{
            let date = getDateFromString(date: time, dateFormat: DATE_FORMAT_HH_mm_ss)
            if date == nil{
                return nil
            }
            return getDateStringFromNSDate(date: date, dateFormat: timeFormat)
        }
    }
    static func getTimeFromTimeString(time : String?, timeFormat : String) -> String?{
        AppDelegate.getAppDelegate().log.debug("getTimeFromTimeString() \(String(describing: time)) \(timeFormat)")
        if time == nil || time!.isEmpty == true{
            return nil
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = timeFormat
            let date = dateFormatter.date(from: time!)
            dateFormatter.dateFormat = DATE_FORMAT_HH_mm_ss
            return dateFormatter.string(from: date!)
        }
    }
    
    static func getTimStampFromTimeString(timeString: String,timeFormat : String) -> NSDate{
        let currentDate = DateUtils.getDateStringFromNSDate(date: NSDate(), dateFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)
        return getDateFromString(date: currentDate! + timeString, dateFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy+timeFormat)!
    }
    
    static func isTargetTimeWithInBoundary( startTime : Double,boundaryInMins : Double) -> Bool {
        AppDelegate.getAppDelegate().log.debug("isTargetTimeWithInBoundary() \(startTime) \(boundaryInMins)")
        let diffInMins = startTime/60000 - NSDate().timeIntervalSince1970/60
        return diffInMins <= boundaryInMins
    }
    static func getTimeDifferenceInMins(date1 : NSDate,date2 :NSDate) -> Int{
        return Int((date1.timeIntervalSince1970 - date2.timeIntervalSince1970)/60)
    }
    static func getTimeDifferenceInSeconds(date1 : NSDate,date2 :NSDate) -> Int{
        return Int(date1.timeIntervalSince1970 - date2.timeIntervalSince1970)
    }
    static func getDayOfWeek(today:String?)->String?
    {
        if today == nil{
            return nil
        }
        let formatter  = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = DateUtils.DATE_FORMAT_dd_MMM_yy
        let todayDate = formatter.date(from: today!)
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: todayDate!)
        let weekDay = myComponents.weekday
        return getDayForWeekDay(weekDayIndex: weekDay!)
    }
    static func getDayForWeekDay(weekDayIndex : Int) -> String{
        AppDelegate.getAppDelegate().log.debug("getTimeForWeekDay() \(weekDayIndex)")
        switch weekDayIndex{
            
        case 1:
            return Strings.sun
            
        case 2:
            return Strings.mon
            
        case 3:
            return Strings.tue
            
        case 4:
            return Strings.wed
            
        case 5:
            return Strings.thu
            
        case 6:
            return Strings.fri
        case 7:
            return Strings.sat
        default:
            return ""
        }
    }
    static func getTimeZoneOffSet() -> Double
    {
        return Double(TimeZone.current.secondsFromGMT()*1000)
    }
    static func getDateTimeInUTC(date : NSDate) -> NSDate
    {
        return DateUtils.getNSDateFromTimeStamp(timeStamp: (date.getTimeStamp() - Double(TimeZone.current.secondsFromGMT()*1000)))!
    }
    static func getTimeInUTC(time : Double) -> Double
    {
        return time - Double(TimeZone.current.secondsFromGMT()*1000)
    }
    
    static func getLocalTimeFromUTC(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let dt = dateFormatter.date(from: date) else {
            return ""
        }
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: dt)
    }
    
    static func configureRideDateTime(ride: TaxiRidePassenger) -> String {
        let currentDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getCurrentTimeInMillis(), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        let time : Double = ride.startTimeMs ?? 0.0
        let completedRideDate =  AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: time/1000), format: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        if currentDate == completedRideDate {
            return Strings.today
        } else {
            return completedRideDate
        }
    }
    
    static func configureRideDateTime(ride: Ride) -> String {
        let currentDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getCurrentTimeInMillis(), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        let time : Double = ride.startTime
        let rideDate = RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        let completedRideDate =  AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: time/1000), format: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        
        if ride.status == Ride.RIDE_STATUS_COMPLETED {
            if ride.rideType == Ride.PASSENGER_RIDE || ride.rideType == Ride.REGULAR_PASSENGER_RIDE {
                if currentDate == completedRideDate {
                    return Strings.today
                } else {
                    let days = DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: NSDate(timeIntervalSince1970: ride.startTime/1000))
                    if days < 8 {
                        return RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.DATE_FORMAT_EE).uppercased() + ", \(completedRideDate)"
                    } else {
                        return  completedRideDate
                    }
                }
            } else {
                if currentDate == completedRideDate {
                    return Strings.today + ", \(completedRideDate)"
                } else {
                    return completedRideDate
                }
            }
        } else {
            if ride.rideType == Ride.PASSENGER_RIDE || ride.rideType == Ride.REGULAR_PASSENGER_RIDE {
                if currentDate == rideDate {
                    return Strings.today
                } else {
                    let days = DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: NSDate(timeIntervalSince1970: ride.startTime/1000))
                    if days < 8 {
                        return RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.DATE_FORMAT_EE).uppercased() + ", \(rideDate)"
                    } else {
                        return rideDate
                    }
                }
            } else {
                if currentDate == rideDate {
                    return  Strings.today
                } else {
                    let days = DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: NSDate(timeIntervalSince1970: ride.startTime/1000))
                    if days < 8 {
                        
                        return RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.DATE_FORMAT_EEE_dd_MMM).uppercased()
                    } else {
                        return  rideDate
                    }
                }
            }
        }
    }
    static func humanizeTimeDuration(seconds: Int) -> String? {
        
        if seconds <= 10 {
            return nil
        }else if seconds <= 60 {
            return "1 min"
        } else {
            let mins = seconds/60
            if mins <= 59{
                return "\(mins) mins"
            }else{
                let hours = mins/60
                let minMod = hours%60
                if minMod > 0 {
                    return "\(hours) Hr \(minMod) m"
                }else{
                    return "\(hours) Hr"
                }
            }
        }
    }
}
extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        AppDelegate.getAppDelegate().log.debug("isGreaterThanDate() \(dateToCompare)")
        var isGreater = false
        
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        AppDelegate.getAppDelegate().log.debug("isLessThanDate() \(dateToCompare)")
        var isLess = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        AppDelegate.getAppDelegate().log.debug("equalToDate() \(dateToCompare)")
        var isEqualTo = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        AppDelegate.getAppDelegate().log.debug("addDays() \(daysToAdd)")
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.addingTimeInterval(secondsInDays)
        return dateWithDaysAdded
    }
    func addMinutes(minutesToAdd : Int) -> NSDate{
        AppDelegate.getAppDelegate().log.debug("addMinutes() \(minutesToAdd)")
        let secondsInMinutes: TimeInterval = Double(minutesToAdd) * 60
        let dateWithDaysAdded: NSDate = self.addingTimeInterval(secondsInMinutes)
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        AppDelegate.getAppDelegate().log.debug("addHours() \(hoursToAdd)")
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.addingTimeInterval(secondsInHours)
        return dateWithHoursAdded
    }
    func getTimeStamp() -> Double{
        let timeStamp = self.timeIntervalSince1970*1000
        return(Double(StringUtils.getStringFromDouble(decimalNumber: timeStamp)))!
        
    }
    
    
}
extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
