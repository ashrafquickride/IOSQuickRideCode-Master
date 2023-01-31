//
//  ReferMyContactsViewModel.swift
//  Quickride
//
//  Created by Halesh on 13/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import Contacts

protocol SyncContactsAndGetUnregisteredContactsDelagate{
    func contactsSyncingFailed(errorMessage: String,positiveBtn: String?,negativeBtn: String?)
    func recievedUnRegisteredContscts()
}

protocol ReferPhoneBookSelectedContactDelegate {
    func handleSuccussResponse()
}

class ReferMyContactsViewModel {
    var allContacts = [String: ContactRegistrationStatus]()
    var contactsFromServer = [ContactRegistrationStatus]()
    var unRegisteredContactList = [ContactRegistrationStatus]()
    var allContactsSelected = true
    var referredContactsCount = 0
    var searchedContactList = [ContactRegistrationStatus]()
    
    func getMobileContacts(viewController: UIViewController,delegate: SyncContactsAndGetUnregisteredContactsDelagate){
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
                catch {
                    delegate.contactsSyncingFailed(errorMessage: Strings.contact_sync_failed, positiveBtn: Strings.ok_caps, negativeBtn: nil)
                }
                var cantactsCount = 0
                var isSpinnerRequired = true
                var contactsString = ""
                for cnContact in contacts {
                    var contact = ContactRegistrationStatus()
                    var name = cnContact.givenName
                    if cnContact.middleName.isEmpty == false{
                        name = name+" "+cnContact.middleName
                    }
                    if cnContact.familyName.isEmpty == false{
                        name = name+" "+cnContact.familyName
                    }
                    contact.contactName = name
                    if cnContact.phoneNumbers.map( {$0.value} ).isEmpty == true{
                        continue
                    }
                    
                    contact.contactNo = EmergencyContactUtils.getFormattedEmergencyContactNumber(contactNumber: (cnContact.phoneNumbers.map( {$0.value} )[0].stringValue))
                    if let contactNo = contact.contactNo, contactNo != ""{
                        contactsString = contactsString + (contactNo) + ","
                        self.allContacts[contactNo] = contact
                        cantactsCount += 1
                        if cantactsCount == 500{
                            self.sendAllMycontactsToServerToGetRegistrationStatus(contacts: contactsString, isSpinnerRequired: isSpinnerRequired, viewController: viewController, delegate: delegate)
                            contactsString = ""
                            isSpinnerRequired = false
                            cantactsCount = 0
                        }
                    }else{
                        continue
                    }
                }
                if self.allContacts.values.isEmpty{
                    delegate.contactsSyncingFailed(errorMessage: Strings.no_contacts_found_to_display, positiveBtn: Strings.ok_caps, negativeBtn: nil)
                }else if cantactsCount != 0{
                    self.sendAllMycontactsToServerToGetRegistrationStatus(contacts: contactsString, isSpinnerRequired: true, viewController: viewController, delegate: delegate)
                }
                AppDelegate.getAppDelegate().log.debug("Contacts from phoneBook :\(contacts.count), Prepared contacts :\(self.allContacts.count)")
                
            }else{
                viewController.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    
    private func sendAllMycontactsToServerToGetRegistrationStatus(contacts: String,isSpinnerRequired: Bool,viewController: UIViewController,delegate: SyncContactsAndGetUnregisteredContactsDelagate){
        if isSpinnerRequired{
            QuickRideProgressSpinner.startSpinner()
        }
        UserRestClient.getContactStatusForReferral(contactList: contacts){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let unRegContacts = Mapper<ContactRegistrationStatus>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ContactRegistrationStatus]()
                self.contactsFromServer.append(contentsOf: unRegContacts)
                self.getUnregisteredContactDetails(serverContacts: unRegContacts, delegate: delegate)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    func referToSelecetdContacts(viewController: UIViewController,delegate:ReferPhoneBookSelectedContactDelegate){
        let contactsTosend = prepareSelectedContactString()
        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.sendContactsToSerever(contactList: contactsTosend,referralUrl: urlString){ (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    delegate.handleSuccussResponse()
                } else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            }
        }
    }
    
    private func getUnregisteredContactDetails(serverContacts: [ContactRegistrationStatus],delegate: SyncContactsAndGetUnregisteredContactsDelagate){
        for contact in serverContacts{
            if contact.userStatus == ContactRegistrationStatus.NOT_REGISTERED, let contact = allContacts[contact.contactNo ?? ""]{
                unRegisteredContactList.append(contact)
            }
        }
        delegate.recievedUnRegisteredContscts()
    }
    
    private func prepareSelectedContactString() -> String{
        var contactsToInvite = ""
        for contact in searchedContactList{
            if contact.isContactSelected{
                referredContactsCount += 1
                 contactsToInvite  = contactsToInvite + (contact.contactNo ?? "") + ","
            }
        }
        return contactsToInvite
    }
}
