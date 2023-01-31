//
//  AppUtil.swift
//  Quickride
//
//  Created by KNM Rao on 6/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit


class AppUtil: NSObject {
  class func getTimeAndDateFromTimeStamp(date:NSDate, format : String) -> String{
     AppDelegate.getAppDelegate().log.debug("getTimeAndDateFromTimeStamp()")
    let mydateFormatter = DateFormatter()
    mydateFormatter.locale = Locale(identifier: "en_US_POSIX")
    mydateFormatter.dateFormat = format
    let dateInString:String = mydateFormatter.string(from: date as Date)
    return dateInString
  }
    
  class func getDateFromTimeStamp(date:NSDate) -> String{
        AppDelegate.getAppDelegate().log.debug("getTimeAndDateFromTimeStamp()")
        let mydateFormatter = DateFormatter()
        mydateFormatter.locale = Locale(identifier: "en_US_POSIX")
        mydateFormatter.dateFormat = "dd MMM yy"
        let dateInString:String = mydateFormatter.string(from: date as Date)
        return dateInString
    }
    class func getTimeInTimeStamp(date:NSDate) -> String{
        AppDelegate.getAppDelegate().log.debug("getTimeAndDateFromTimeStamp()")
        let mydateFormatter = DateFormatter()
        mydateFormatter.locale = Locale(identifier: "en_US_POSIX")
        mydateFormatter.dateFormat = "hh:mm a"
        let dateInString:String = mydateFormatter.string(from: date as Date)
        return dateInString
    }
    


  static func getDateStringFromNSDate(date : NSDate) -> String{
     AppDelegate.getAppDelegate().log.debug("getDateStringFromNSDate()")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ddMMyyyyHHmm"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter.string(from: date as Date)
  }
  static func getDateFromString(date : String) -> NSDate{
     AppDelegate.getAppDelegate().log.debug("getDateFromString() \(date)")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ddMMyyyyHHmm"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return (dateFormatter.date(from: date))! as NSDate
  }
  static func getDateStringFromTimeInterval( seconds : Double) -> String{
     AppDelegate.getAppDelegate().log.debug("getDateStringFromTimeInterval() \(seconds)")
    return getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: seconds))
  }
  static func getDateStringFromTimeIntervalInMillis( milliSeconds : Double) -> String{
     AppDelegate.getAppDelegate().log.debug("getDateStringFromTimeIntervalInMillis() \(milliSeconds)")
    return getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: milliSeconds/1000))
  }
  
  
  class func getTimeFromTimeStamp(date:NSDate) -> String{
     AppDelegate.getAppDelegate().log.debug("getTimeFromTimeStamp()")
    let mydateFormatter = DateFormatter()
    mydateFormatter.dateStyle = DateFormatter.Style.medium
    mydateFormatter.timeStyle = DateFormatter.Style.short
    mydateFormatter.locale = Locale(identifier: "en_US_POSIX")
    let dateInString:String = mydateFormatter.string(from: date as Date)
    return dateInString
    
  }
  static func getTimeFromTimeIntervalInMillis(timeInterval :Double) -> String{
     AppDelegate.getAppDelegate().log.debug("getTimeFromTimeIntervalInMillis() \(timeInterval)")
    let date = NSDate(timeIntervalSince1970: timeInterval/1000)
    let mydateFormatter = DateFormatter()
    mydateFormatter.locale = Locale(identifier: "en_US_POSIX")
    mydateFormatter.dateFormat = "H:mm a"
    return mydateFormatter.string(from: date as Date)
  }
    static func getTimeFromTimeIntervalInMillisWithFormat(timeFormat : String,timeInterval :Double) -> String{
        AppDelegate.getAppDelegate().log.debug("getTimeFromTimeIntervalInMillis() \(timeInterval)")
        let date = NSDate(timeIntervalSince1970: timeInterval/1000)
        let mydateFormatter = DateFormatter()
        mydateFormatter.locale = Locale(identifier: "en_US_POSIX")
        mydateFormatter.dateFormat = timeFormat
        return mydateFormatter.string(from: date as Date)
  }
   
    static func getTimeFromString(timeInterval :String) -> NSDate{
        AppDelegate.getAppDelegate().log.debug("getTimeFromTimeIntervalInMillis() \(timeInterval)")
        let dateFmt = DateFormatter()
        dateFmt.timeZone = NSTimeZone.default
        dateFmt.dateFormat =  "H:mm a"
        let date = dateFmt.date(from: timeInterval)
        return date! as NSDate
        }
    static func createNSDate(dateString : String?) -> NSDate?{
        if dateString == nil{
            return nil
        }
        AppDelegate.getAppDelegate().log.debug("createNSDate() \(String(describing: dateString))")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss aaa"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        var date = dateFormatter.date(from: dateString!)
        if date == nil{
            dateFormatter.dateFormat = "MMM dd, yyyy, hh:mm:ss aaa"
            date = dateFormatter.date(from: dateString!)
        }
        let timeStamp:NSDate? = date! as NSDate
        return timeStamp!
    }
    
  static func getDateAndTimeStringFromString(dateString : String) -> String{
     AppDelegate.getAppDelegate().log.debug("getDateAndTimeStringFromString() \(dateString)")
    let date = createNSTime(dateString: dateString)
    return getDateStringFromTimeInterval(seconds: date!.getTimeStamp())
  }
    static func createNSTime(dateString:String?) -> NSDate?{
        if dateString == nil{
            return nil
        }
        AppDelegate.getAppDelegate().log.debug("createNSDate() \(String(describing: dateString))")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let timeStamp:NSDate? = dateFormatter.date(from: dateString!) as NSDate?
        return timeStamp!
    }
  static func getTimestampFromDateString(stringRepresentationOfDate : String) -> Double? {
     AppDelegate.getAppDelegate().log.debug("getTimestampFromDateString() \(stringRepresentationOfDate)")
    let date = createNSDate(dateString: stringRepresentationOfDate)
    return date!.getTimeStamp()
  }
  
  static func getCurrentDateAndTimeAsString(format : String) -> String? {
     AppDelegate.getAppDelegate().log.debug("getCurrentDateAndTimeAsString() \(format)")
    let date = NSDate()
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = format
    return formatter.string(from: date as Date)
    
  }
  
  class func saveImage(url:String)->String{
     AppDelegate.getAppDelegate().log.debug("saveImage")
    let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
    
    var strings = url.components(separatedBy: "/")
    let count = strings.count
    let filePath = (path as String)  + "/\(strings[count-1])"
    
    let imageData = NSData(contentsOf: NSURL(string: url)! as URL)
    
    imageData?.write(toFile: filePath as String, atomically: true)
    
    return filePath
  }
  
    static func isValidPhoneNo(phoneNo : String,countryCode : String?) -> Bool {
     AppDelegate.getAppDelegate().log.debug("isValidPhoneNo() \(phoneNo)")
    let phoneRegEx = "^\\d{4,14}$"
    
    let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
    var valid = phoneTest.evaluate(with: phoneNo)
    if countryCode != nil && countryCode == AppConfiguration.DEFAULT_COUNTRY_CODE_IND{
        if phoneNo.count != 10{
            valid = false
        }
    }
    return valid
  }
  
  static func isValidEmailId (emailId : String) -> Bool {
     AppDelegate.getAppDelegate().log.debug("\(emailId)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    
    return emailTest.evaluate(with: emailId)
  }

    static func isValidURL(url : String) -> Bool{
       
       let urlRegEx = "((\\w|-)+)(([.]|[/])((\\w|-)+))+"
       
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
       
        return urlTest.evaluate(with: url)
    
    }
  
    static func getCurrentAppVersionName() -> String
    {
      let currentAppVersionName =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return currentAppVersionName!
    }
    
}
