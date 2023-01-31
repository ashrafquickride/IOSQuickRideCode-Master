//
//  EndorsementListViewModel.swift
//  Quickride
//
//  Created by Vinutha on 07/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Contacts
import ObjectMapper

class EndorsementListViewModel {
    
    //MARK: Properties
    var endorsableUsers = [EndorsableUser]()
    var searchedEndorsableUsers = [EndorsableUser]()
    
    //MARK: Methods
    func fetchEndorasableUser() {
        ContactUtils.requestForAccess { (status) in
            if status{
                let store = CNContactStore()
                var contacts = [CNContact]()
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey,CNContactMiddleNameKey,CNContactThumbnailImageDataKey,CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                do {
                    try store.enumerateContacts(with: request){ (contact, stopingPointer) in
                        contacts.append(contact)
                    }
                }
                catch {}
                var contactNumbers = [String]()
                for cnContact in contacts {
                    if cnContact.phoneNumbers.isEmpty {
                        continue
                    }
                    let contactNo = Double(EmergencyContactUtils.getFormattedEmergencyContactNumber(contactNumber: (cnContact.phoneNumbers.map( {$0.value} )[0].stringValue)))
                    if let contactNo = contactNo {
                        contactNumbers.append(StringUtils.getStringFromDouble(decimalNumber: contactNo))
                    } else {
                        continue
                    }
                }
                contactNumbers.append(contentsOf: self.getAllRidePartners())
                self.getAllEndorsableUser(contactList: contactNumbers.joined(separator: ","))
            }
        }
    }
    
    private func getAllEndorsableUser(contactList: String) {
        QuickRideProgressSpinner.startSpinner()
        ProfileVerificationRestClient.getAllEndorsableUsers(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", contactList: contactList) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.searchedEndorsableUsers = Mapper<EndorsableUser>().mapArray(JSONObject: responseObject!["resultData"]) ?? [EndorsableUser]()
                self.endorsableUsers = self.searchedEndorsableUsers
                NotificationCenter.default.post(name: .reloadEndoserTableView, object: self)
            }
        }
    }
    
    private func getAllRidePartners() -> [String] {
        var ridePartnerContactNo = [String]()
        guard let ridePartners = UserDataCache.getInstance()?.getRidePartnerContacts() else {
            return ridePartnerContactNo
        }
        for ridePartner in ridePartners {
            if UserDataCache.getInstance()?.isBlockedUser(userId: Double(ridePartner.contactId ?? "") ?? 0) == true{
                continue
            }
            if let contactNo = ridePartner.contactNo, ridePartner.contactType == Contact.RIDE_PARTNER {
                ridePartnerContactNo.append(StringUtils.getStringFromDouble(decimalNumber: contactNo))
            }
        }
        return ridePartnerContactNo
    }
}
