//
//  StringUtils.swift
//  Quickride
//
//  Created by KNM Rao on 29/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class StringUtils {
  
  
  
  public static func getStringFromDouble(decimalNumber : Double?) -> String {
    if decimalNumber == nil {
      return ""
    }
    return String(decimalNumber!).components(separatedBy: ".")[0]
  }
  public static func getStringFromDouble(decimalNumber : Float?) -> String {
    if decimalNumber == nil {
      return ""
    }
    return String(decimalNumber!).components(separatedBy: ".")[0]
  }
  public static func encodeUrlString(urlString : String) -> String{
    var url = urlString
    url = url.replacingOccurrences(of: ":", with: "%3A")
    url = url.replacingOccurrences(of: "/", with: "%2F")
    url = url.replacingOccurrences(of: "?", with: "%3F")
    url = url.replacingOccurrences(of: ",", with: "%2C")
    url = url.replacingOccurrences(of: "=", with: "%3D")
    url = url.replacingOccurrences(of: "&", with: "%26")
    url = url.replacingOccurrences(of: " ", with: "%20")
    return url
  }
  
  public static func getPointsInDecimal(points : Double) -> String
  {
    let components = String(points).components(separatedBy: ".")
    if components.isEmpty{
      return String(points)
    }else if (components.count == 1){
      return components[0]
    }else{
      if components[1] == "0"{
        return components[0]
      }else{
        var roundedPoints = points
        return String(roundedPoints.roundToPlaces(places: 2))
      }
    }
  }
    
  static func getSupportCallInt( supportCallString : String) -> String{
    
    if Strings.Joined_ride_partners == supportCallString{
      return UserProfile.SUPPORT_CALL_AFTER_JOINED
      
    }else if Strings.No_calls_please == supportCallString{
      return UserProfile.SUPPORT_CALL_NEVER
      
    }else{
      return UserProfile.SUPPORT_CALL_ALWAYS
      
    }
    
  }
  
  
  static func getSupportCallString( supportCallInt  : String)-> String
  {
    if UserProfile.SUPPORT_CALL_AFTER_JOINED == supportCallInt{
      return Strings.Joined_ride_partners
    }else if UserProfile.SUPPORT_CALL_NEVER == supportCallInt{
      return Strings.No_calls_please
    }else{
      return Strings.From_anyone
    }
  }
  
  
  static func getDisplayableStringForPreferredVehicle( storableString :String)->String
  {
    if RidePreferences.PREFERRED_VEHICLE_BOTH == storableString{
      return Strings.any
    }else if RidePreferences.PREFERRED_VEHICLE_BIKE == storableString{
      return Strings.bike
    }else{
      return Strings.Car
    }
  }
  
  
  static func getStorableStringForPreferredVehicle( displayString : String?)-> String
  {
    if Strings.any == displayString{
      return RidePreferences.PREFERRED_VEHICLE_BOTH
    }else if Strings.bike == displayString{
      return RidePreferences.PREFERRED_VEHICLE_BIKE
    }else{
      return RidePreferences.PREFERRED_VEHICLE_CAR;
    }
  }
  
  static func getDisplayableStringForPreferredRole( storableRole :String) -> String
  {
    if UserProfile.PREFERRED_ROLE_BOTH == storableRole{
      return Strings.Both
    }else if UserProfile.PREFERRED_ROLE_PASSENGER == storableRole{
      return Strings.find_ride
    }else{
      return Strings.offer_ride
    }
  }
  
  
  
  
  static func getStorableStringForPreferredRole(displayableRole :String?)->String{
    if Strings.Both == displayableRole{
      return UserProfile.PREFERRED_ROLE_BOTH
    }else if Strings.find_ride == displayableRole{
      return UserProfile.PREFERRED_ROLE_PASSENGER
    }else{
      return UserProfile.PREFERRED_ROLE_RIDER;
    }
  }
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
       
  
}
extension String{
    func substring(start : Int , end : Int) -> String{
        var endIndex = end
        let startingIndex = self.index(self.startIndex, offsetBy: start)
        if endIndex > self.count-1{
            endIndex = self.count-1
        }
        let endingIndex = self.index(self.startIndex, offsetBy: endIndex)
        let myRange = startingIndex..<endingIndex
        return self.substring(with: myRange)
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    
    func toDouble() -> Double {
        let nsString = self as NSString
        return nsString.doubleValue
    }
    
    func withBoldText(text: String, font: UIFont? = nil) -> NSAttributedString {
      let _font = font ?? UIFont.systemFont(ofSize: 17, weight: .regular)
      let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: _font])
      let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: _font.pointSize)]
      let range = (self as NSString).range(of: text)
      fullString.addAttributes(boldFontAttribute, range: range)
      return fullString
    }
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}


