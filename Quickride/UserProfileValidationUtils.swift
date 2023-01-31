//
//  UserProfileValidationUtils.swift
//  Quickride
//
//  Created by Admin on 01/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserProfileValidationUtils {
    
    static func validateStringForAlphabatic(string : String) -> Bool{
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
            if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                return false
            }
        } catch{
            AppDelegate.getAppDelegate().log.debug("")
        }
        return true
    }
    static func validateStringFromCertainCharacters(string: String, ristrictedCharacters: String) -> Bool{
        let set = CharacterSet(charactersIn: ristrictedCharacters)
        let inverted = set.inverted
        let filtered = string.components(separatedBy: inverted).joined(separator: "nil")
        if string == ""{
            return true
        }else{
           return filtered != string
        }
    }
    static func isOrganisationEmailIdIsValid(orgEmail: String) -> Bool{
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil {
            clientConfiguration = ClientConfigurtion()
        }
        let invalidEmails = clientConfiguration!.publicEmailIds
        if let range = orgEmail.range(of: "@") {
            let userName = orgEmail[orgEmail.startIndex..<range.lowerBound]
            if invalidEmails.contains(userName.lowercased()){
                return false
            }else{
                return true
            }
        }
        return true
    }
}
