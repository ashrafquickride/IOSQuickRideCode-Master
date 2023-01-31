//
//  ContactListViewModel.swift
//  Quickride
//
//  Created by Ashutos on 25/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation


class ContactListViewModel {
    func getContactList() -> [Contact]{
        return UserDataCache.getInstance()?.getRidePartnerContacts() ?? []
    }
}
