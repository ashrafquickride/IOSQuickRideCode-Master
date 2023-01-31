//
//  SelectContactViewController.swift
//  Quickride
//
//  Created by KNM Rao on 27/09/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol SelectContactDelegate {
  func selectedContact(contact : Contact)
}
public enum Contacts{
    case mobileContacts
    case rideParticipants
    case both
}
class SelectContactViewController: ContactsViewController {
  
  var selectContactDelegate :SelectContactDelegate?
  var requiredContacts = Contacts.mobileContacts
    
    func initializeDataBeforePresenting(selectContactDelegate :SelectContactDelegate?, requiredContacts: Contacts){
        self.selectContactDelegate = selectContactDelegate
        self.requiredContacts = requiredContacts
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if requiredContacts == Contacts.mobileContacts{
            getMobileContacts()
        }else if requiredContacts == Contacts.rideParticipants{
            getRidePartnerContacts()
        }else{
            getContacts()
        }
    }
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectContactDelegate?.selectedContact(contact: searchedResults[indexPath.row])
    self.dismiss(animated: false, completion: nil)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.dismiss(animated: false, completion: nil)
  }
  override func contactsLoaded() {
    QuickRideProgressSpinner.stopSpinner()
  }
}
