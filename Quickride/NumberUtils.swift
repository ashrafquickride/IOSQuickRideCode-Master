//
//  NumberUtils.swift
//  Quickride
//
//  Created by KNM Rao on 30/12/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CommonCrypto

class NumberUtils {
    
    static let CHARACTER_SET = CharacterSet(charactersIn: "0123456789")
   
    static let MINIMUM_CONTACTNO_LENGTH = 10
    
    static func getMaskedMobileNumber(mobileNumber : Double?) -> String{

        if let appStartUpData = SharedPreferenceHelper.getAppStartUpData(),!appStartUpData.enableNumberMasking{
            return StringUtils.getStringFromDouble(decimalNumber: mobileNumber)
        }
        
        let mobileNumer = StringUtils.getStringFromDouble(decimalNumber: mobileNumber)
        
        let startingIndex = mobileNumer.index(mobileNumer.startIndex, offsetBy: 2)
        let endingIndex = mobileNumer.index(mobileNumer.endIndex, offsetBy: -2)
        let stars = String(repeating: "*", count: mobileNumer.count - 4)
        
        return mobileNumer.replacingCharacters(in: startingIndex..<endingIndex,
                                               with: stars)
    }
    
    static func validateTextFieldForSpecialCharacters(textField : UITextField,viewController : UIViewController) -> Bool{
    
        if textField.text?.rangeOfCharacter(from: NumberUtils.CHARACTER_SET.inverted) != nil{
            MessageDisplay.displayAlert(messageString: Strings.specialCharactersEntered, viewController: viewController, handler: nil)
            return true
        }
    return false
  }
    
   static func randomNumberInString(length: Int) -> String {
        let numbers = "0123456789"
        return String((0..<length).map{ _ in numbers.randomElement()! })
    }
    
    static func getSha256Hash(data: Data) -> String {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = digest.withUnsafeMutableBytes { (digestBytes) in
            data.withUnsafeBytes { (stringBytes) in
                CC_SHA256(stringBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return (digest.map { String(format: "%02hhx", $0) }.joined())
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func printValue(places:Int) -> String {
        let components = String(self).components(separatedBy: ".")
        if components.count == 1 || components[1] == "0"{
            return components[0]
        }else{
            let divisor = pow(10.0, Double(places))
            let value = Darwin.round(self * divisor) / divisor
            let components = String(value).components(separatedBy: ".")
            if components.count == 1 || components[1] == "0"{
                return components[0]
            }
            return String(value)
        }
    }
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
  func getDecimalValueWithOutRounding(places : Int) -> Double{
    let formatter = NumberFormatter()
    formatter.roundingMode = .down
    formatter.maximumFractionDigits = places
    let string = formatter.string(from: NSNumber(value: self))
    if string != nil
    {
      let doubleValue = Double(string!)
      if doubleValue != nil{
        return doubleValue!
      }
      
    }
   return 0
  }
 
}
