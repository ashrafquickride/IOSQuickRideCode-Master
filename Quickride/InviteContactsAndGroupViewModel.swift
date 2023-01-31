//
//  InviteContactsAndGroupViewModel.swift
//  Quickride
//
//  Created by Vinutha on 03/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Contacts
import ObjectMapper

class InviteContactsAndGroupViewModel{
    var ridePartners = [Contact]()
    var searchedRidePartners = [Contact]()
    var phoneBookContacts = [Contact]()
    var searchedPhoneBookContacts = [Contact]()
    var myContacts = [Double: Contact]()
    var userGroups = [Group]()
    var searchedUserGroups = [Group]()
    var isContactsLoaded = false
    var ride: Ride?
    var isRequiredToShowAllRidePartners = false
    var isRequiredToShowAllGroups = false
    var isUserDisableContactPermission = false
    var taxiRide: TaxiRidePassenger?
    
    init(ride: Ride?,taxiRide: TaxiRidePassenger?) {
        self.ride = ride
        self.taxiRide = taxiRide
    }
    
    init() {
        
    }
    
    func getAllRidePartners(){
        self.ridePartners = ContactUtils.getRidePartnerContacts()
        searchedRidePartners = ridePartners
    }
    
    func getAllJoinedGroups(){
        let groups = UserDataCache.getInstance()!.getAllJoinedGroups()
        var userGroups = [Group]()
        var groupsWithNotName = [Group]()
        
        for userGroup in groups{
            if userGroup.members.count != 1 && userGroup.currentUserStatus != GroupMember.MEMBER_STATUS_PENDING{
                if userGroup.name != nil{
                    userGroups.append(userGroup)
                }else{
                    groupsWithNotName.append(userGroup)
                }
            }
        }
        userGroups.sort(by: { $0.name! < $1.name!})
        userGroups.append(contentsOf: groupsWithNotName)
        self.userGroups = userGroups
        searchedUserGroups = userGroups
    }
    
    func fetchPhoneBookContacts(viewController: UIViewController){
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
                    NotificationCenter.default.post(name: .contactsFetchingFailed, object: self)
                }
                var cantactsCount = 0
                var contactsString = ""
                for cnContact in contacts {
                    let contact = Contact()
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
                    
                    contact.contactNo = Double(EmergencyContactUtils.getFormattedEmergencyContactNumber(contactNumber: (cnContact.phoneNumbers.map( {$0.value} )[0].stringValue)))
                    contact.contactId = StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)
                    contact.contactType = Contact.NEW_USER
                    if let contactNo = contact.contactNo{
                        contactsString = contactsString + StringUtils.getStringFromDouble(decimalNumber: contactNo) + ","
                        self.myContacts[contactNo] = contact
                        cantactsCount += 1
                        if cantactsCount == 500{
                            self.sendAllMycontactsToServerToGetRegistrationStatus(contacts: contactsString, viewController: viewController)
                            contactsString = ""
                            cantactsCount = 0
                        }
                    }else{
                        continue
                    }
                }
                if self.myContacts.isEmpty{
                    NotificationCenter.default.post(name: .noContactsToDisplay, object: self)
                    self.isContactsLoaded = true
                }else if cantactsCount != 0{
                    self.sendAllMycontactsToServerToGetRegistrationStatus(contacts: contactsString, viewController: viewController)
                }
            }else{
                self.isUserDisableContactPermission = true
                self.isContactsLoaded = true
            }
        }
    }
    
    private func sendAllMycontactsToServerToGetRegistrationStatus(contacts: String,viewController: UIViewController){
        UserRestClient.getContactStatusForReferral(contactList: contacts){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let unRegContacts = Mapper<ContactRegistrationStatus>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ContactRegistrationStatus]()
                for contact in unRegContacts{
                    let phoneBookContact = self.myContacts[Double(contact.contactNo ?? "") ?? 0]
                    phoneBookContact?.status = contact.userStatus
                    phoneBookContact?.contactId = StringUtils.getStringFromDouble(decimalNumber: contact.userId)
                    self.phoneBookContacts.append(phoneBookContact ?? Contact())
                }
                self.isContactsLoaded = true
                self.phoneBookContacts.sort(by: {$0.contactName < $1.contactName})
                self.searchedPhoneBookContacts = self.phoneBookContacts
                NotificationCenter.default.post(name: .contactsLoaded, object: self)
            }
        }
    }
    
    
    func getRidePartnerNoOfRows() -> Int{
        if searchedRidePartners.count > 5 && !isRequiredToShowAllRidePartners{
            return 5
        }else{
            return searchedRidePartners.count
        }
    }
    
    func getGroupsNoOfRows() -> Int{
        if searchedUserGroups.count > 2 && !isRequiredToShowAllGroups{
            return 2
        }else{
            return searchedUserGroups.count
        }
    }
    
    func getPhonebookContactsNoOfRows() -> Int{
        if isUserDisableContactPermission || !isContactsLoaded{
            return 1
        }else{
            return searchedPhoneBookContacts.count
        }
    }
    var accountUtils :  AccountUtils?
    func inviteContacts(contact: Contact,viewController: UIViewController,paymentType: String, complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("inviteSelectedContact()")
        if let _ = taxiRide{
            taxipoolInviteToContacts(contact: contact)
        }else{
            var contactToInvite = [Contact]()
            contactToInvite.append(contact)
            let contactString = contactToInvite.toJSONString() ?? ""
            self.continueInvitingSelecetdContact(contact: contact,contactString: contactString, viewController: viewController, paymentType: paymentType){ (responseObject, error) in
                complitionHandler(responseObject, error)
            }
        }
    }
    
    private func continueInvitingSelecetdContact(contact: Contact,contactString: String, viewController: UIViewController, paymentType: String, complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        RideMatcherServiceClient.sendInvitationToContact(rideId: ride?.rideId ?? 0, rideType: ride?.rideType ?? "", contact: contactString, paymentType: paymentType, viewController: viewController) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let contactInvitesResponse = Mapper<ContactInviteResponse>().mapArray(JSONObject: responseObject!["resultData"])
                if contactInvitesResponse != nil && contactInvitesResponse!.isEmpty == false{
                    var rideInvites = [RideInvitation]()
                    for contactInviteResponse in contactInvitesResponse!{
                        if contactInviteResponse.success && contactInviteResponse.rideInvite!.rideInvitationId != 0{
                            rideInvites.append(contactInviteResponse.rideInvite!)
                        }else if contactInviteResponse.success && contact.contactType == Contact.NEW_USER{
                            var invitedContacts = SharedPreferenceHelper.getInvitedPhoneBookContacts(rideId: self.ride?.rideId ?? 0)
                            invitedContacts.append(contact.contactId ?? "")
                            SharedPreferenceHelper.storeInvitedPhoneBookContacts(rideId: self.ride?.rideId ?? 0, contacts: invitedContacts)
                        }else{
                            var userInfo = [String : Any]()
                            userInfo["responseError"] = contactInviteResponse.error
                            NotificationCenter.default.post(name: .contactInviteResponse, object: self, userInfo: userInfo)
                            return
                        }
                    }
                    for invite in rideInvites{
                        RideInviteCache.getInstance().saveNewInvitation(rideInvitation: invite)
                        if contact.contactType == Contact.NEW_USER{
                            var invitedContacts = SharedPreferenceHelper.getInvitedPhoneBookContacts(rideId: self.ride?.rideId ?? 0)
                            invitedContacts.append(contact.contactId ?? "")
                            SharedPreferenceHelper.storeInvitedPhoneBookContacts(rideId: self.ride?.rideId ?? 0, contacts: invitedContacts)
                        }
                    }
                }
                NotificationCenter.default.post(name: .inviteContactSuccess, object: self)
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{ // need to handle error
                complitionHandler(responseObject, error)
            }else{
                var userInfo = [String : Any]()
                userInfo["NSDictionary"] = responseObject
                userInfo["NSError"] = error
                NotificationCenter.default.post(name: .inviteContactfailed, object: self, userInfo: userInfo)
            }
        }
    }
    private func taxipoolInviteToContacts(contact: Contact){
        var contactToInvite = [Contact]()
        contactToInvite.append(contact)
        let contactString = contactToInvite.toJSONString() ?? ""
        TaxiSharingRestClient.taxipoolInviteByContact(taxiRidePassengerId: taxiRide?.id ?? 0, taxiGroupId: taxiRide?.taxiGroupId ?? 0, contacts: contactString) { responseObject, error in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let contactInvitesResponse = Mapper<ContactTaxiRideInviteResponse>().mapArray(JSONObject: responseObject!["resultData"])
                if contactInvitesResponse != nil && contactInvitesResponse!.isEmpty == false{
                    var rideInvites = [TaxiPoolInvite]()
                    for contactInviteResponse in contactInvitesResponse!{
                        if let taxiRideInvite = contactInviteResponse.taxiRideInvite,contactInviteResponse.success && taxiRideInvite.id != nil{
                            rideInvites.append(taxiRideInvite)
                            MyActiveTaxiRideCache.getInstance().updateTaxipoolInvite(taxiInvite: taxiRideInvite)
                        }else if contactInviteResponse.success && contact.contactType == Contact.NEW_USER{
                            var invitedContacts = SharedPreferenceHelper.getInvitedPhoneBookContacts(rideId: self.ride?.rideId ?? 0)
                            invitedContacts.append(contact.contactId ?? "")
                            SharedPreferenceHelper.storeInvitedPhoneBookContacts(rideId: self.ride?.rideId ?? 0, contacts: invitedContacts)
                        }else{
                            var userInfo = [String : Any]()
                            userInfo["responseError"] = contactInviteResponse.error
                            NotificationCenter.default.post(name: .contactInviteResponse, object: self, userInfo: userInfo)
                            return
                        }
                    }
                }
                NotificationCenter.default.post(name: .inviteContactSuccess, object: self)
            }else{
                var userInfo = [String : Any]()
                userInfo["NSDictionary"] = responseObject
                userInfo["NSError"] = error
                NotificationCenter.default.post(name: .inviteContactfailed, object: self, userInfo: userInfo)
            }
        }
    }
}
