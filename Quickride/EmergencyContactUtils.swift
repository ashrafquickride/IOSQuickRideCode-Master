//
//  EmergencyContactUtils.swift
//  Quickride
//
//  Created by QuickRideMac on 29/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import AddressBookUI

class EmergencyContactUtils {
    
    static func getFormattedEmergencyContactNumber(contactNumber : String) -> String{
      let okayChars  = "1234567890"
      let number = String(contactNumber.filter {okayChars.contains($0) })
      if number.count >= 10
      {
        let myIndex = number.endIndex
        let requiredString = number.substring(from: number.index(myIndex, offsetBy: -10))
        return requiredString
      }
      else
      {
        return number
      }
    }
    static func getEmergencyContactNumberWithName(contact : Contact) -> String{
      AppDelegate.getAppDelegate().log.debug("getEmergencyContactNumberWithName()")
        return contact.contactName+"("+StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)+")"
    }
    static func getEmergencyContactNumber(contact : Contact) -> String{
        AppDelegate.getAppDelegate().log.debug("getEmergencyContactNumberWithName()")
        return StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)
    }
    static func getContactFromPerson(person : ABRecord)->Contact{
        AppDelegate.getAppDelegate().log.debug("getContactFromPerson()")
        let index = 0 as CFIndex;
        //Get Name
        var firstName:String?
        let firstNameObj = ABRecordCopyValue(person, kABPersonFirstNameProperty)
        if(firstNameObj != nil) {
            firstName = firstNameObj?.takeRetainedValue() as? String
        } else {
            firstName = ""
        }
        
        var lastName:String?;
        let lastNameObj = ABRecordCopyValue(person, kABPersonLastNameProperty)
        if(lastNameObj != nil) {
            lastName = lastNameObj?.takeRetainedValue() as? String
        } else {
            lastName = ""
        }
        
        //Get Phone Number
        var phoneNumber:String?
        let unmanagedPhones:Unmanaged? = ABRecordCopyValue(person, kABPersonPhoneProperty)
        if(unmanagedPhones != nil) {
            let phoneNumbers = unmanagedPhones?.takeRetainedValue()
            if(ABMultiValueGetCount(phoneNumbers) > index) {
                phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbers, index).takeRetainedValue() as? String
                if phoneNumber != nil{
                    phoneNumber = getFormattedEmergencyContactNumber(contactNumber: phoneNumber!)
                }else{
                    phoneNumber = ""
                }
                
            } else {
                phoneNumber = ""
            }
        }
        return Contact(contactId: phoneNumber!,contactName :firstName!+lastName! )
    }
}
