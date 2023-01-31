//
//  ContactsViewController.swift
//  Quickride
//
//  Created by KNM Rao on 27/09/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
//
import Foundation
import UIKit
import ObjectMapper
import Contacts


class ContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    var contacts:[Contact] = [Contact]()
    var searchedResults : [Contact] = [Contact]()
    var contactImages : [String : UIImage] = [String : UIImage]()
    var allContacts = [Contact]()
    
    @IBOutlet weak var contactsSearchBar: UISearchBar!
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    @IBOutlet var enableContactsButton: UIButton!
  
    @IBOutlet weak var enableContactsView: UIView!
    
    @IBOutlet weak var enableContactsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var enableContactsViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noContactsView: UIView!
    
    var isKeyBoardVisible = false
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        enableContactsButton.setTitleColor(Colors.defaultTextColor, for: .normal)
        if contactsSearchBar != nil{
            self.contactsSearchBar.delegate = self
            self.contactsSearchBar.backgroundImage = UIImage()
            self.contactsSearchBar.setImage( UIImage(named: "ic_search-1"), for: .search, state: .normal)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            enableContactsViewBottomSpaceConstraint.constant = keyBoardSize.height
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        enableContactsViewBottomSpaceConstraint.constant = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillDisappear()")
        if contactsSearchBar != nil{
            contactsSearchBar.endEditing(false)
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.showsCancelButton = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        AppDelegate.getAppDelegate().log.debug("searchBar() textDidChange() \(searchText)")
        contactsTableView.dataSource = nil
        contactsTableView.delegate = nil
        searchedResults.removeAll()
        if searchText.isEmpty == true{
            if allContacts.isEmpty == false{
               searchedResults = allContacts
            }else{
               searchedResults = contacts
            }
           if searchedResults.isEmpty == true{
                contactsTableView.isHidden = true
                noContactsView.isHidden = false
            }else{
                contactsTableView.dataSource = self
                contactsTableView.delegate = self
                contactsTableView.isHidden = false
                noContactsView.isHidden = true
                self.contactsTableView.reloadData()
            }
        }else{
        
           for contact in allContacts{
                    if  contact.contactName.localizedCaseInsensitiveContains(searchText) || (contact.contactNo != nil && String(contact.contactNo!).starts(with: searchText)){
                        self.searchedResults.append(contact)
                    }
                }
            if allContacts.isEmpty{
                for contact in contacts{
                    if  contact.contactName.localizedCaseInsensitiveContains(searchText) || (contact.contactNo != nil && String(contact.contactNo!).starts(with: searchText)){
                        self.searchedResults.append(contact)
                    }
                }
            }
            self.processContacts()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked() \(searchBar)")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppDelegate.getAppDelegate().log.debug("tableView() numberOfRowsInSection() \(section)")
        return searchedResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        AppDelegate.getAppDelegate().log.debug("cellForRowAtIndexPath() \(indexPath.row) : \(self.searchedResults.count)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact_cell", for: indexPath as IndexPath) as! ContactsTableViewCell
        if indexPath.row >= searchedResults.count{
            return cell
        }
        let contact = searchedResults[indexPath.row]
        let image = contactImages[contact.contactId!]
        cell.initializeViews(contact: contact, image: image, row: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("tableView() didSelectRowAtIndexPath() \(indexPath)")
        if indexPath.row <= searchedResults.count{
            return
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    func getRidePartnerContacts() {
        let chatContacts = UserDataCache.getInstance()?.getRidePartnerContacts()
        if chatContacts != nil && !chatContacts!.isEmpty{
            var ridePartnerContacts = [Contact]()
            for ridePartner in chatContacts!{
                if (UserDataCache.getInstance()!.isBlockedUser(userId: Double(ridePartner.contactId!)!)) {
                    continue
                }
                
                if ridePartner.contactNo != nil && ridePartner.contactType == Contact.RIDE_PARTNER{
                    ridePartnerContacts.append(ridePartner)
                }
            }
            ridePartnerContacts.sort(by: { $0.contactName < $1.contactName})
            self.contacts.insert(contentsOf: ridePartnerContacts, at: 0)
            self.searchedResults.append(contentsOf: self.contacts)
        }
        processContacts()
    }
    
    func getContacts(){
        AppDelegate.getAppDelegate().log.debug("getContacts()")
        contacts.removeAll()
        searchedResults.removeAll()
        getRidePartnerContacts()
        getMobileContacts()
        self.processContacts()

    }

  
  func getMobileContacts(){
    ContactUtils.requestForAccess { (status) in
      if status{
        self.enableContactsView.isHidden = true
        self.enableContactsViewHeightConstraint.constant = 0
        self.enableContactsViewBottomSpaceConstraint.constant = 0
        var phoneContacts = [Double :Contact]()
        let store = CNContactStore()
        var cnContacts = [CNContact]()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey,CNContactMiddleNameKey,CNContactThumbnailImageDataKey,CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        do {
            try store.enumerateContacts(with: request){ (contact, stopingPointer) in
                cnContacts.append(contact)
            }
        }catch{
            self.processContacts()
        }
          for cnContact in cnContacts {
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
              if contact.contactNo == nil || phoneContacts.keys.contains(contact.contactNo!){
                continue
              }
              
              contact.contactId = StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)
              contact.contactType = Contact.NEW_USER
            if (cnContact.thumbnailImageData != nil){
              let image : UIImage? = UIImage(data: cnContact.thumbnailImageData!)
                if image != nil && contact.contactId != nil {
                  
                  self.contactImages[contact.contactId!] = image
                }
              }
              
              phoneContacts[contact.contactNo!] = contact
            }
            self.searchedResults.append(contentsOf:phoneContacts.values.sorted(by: { $0.contactName < $1.contactName}))
            self.allContacts = self.searchedResults
            self.processContacts()
      }else{
        self.enableContactsView.isHidden = false
        self.enableContactsViewHeightConstraint.constant = 50
        self.enableContactsViewBottomSpaceConstraint.constant = 20
        self.processContacts()
      }
    }
  }
    func fetchContacts(requiredContacts: String){
        getMobileContacts()
  }

    func processContacts(){
        AppDelegate.getAppDelegate().log.debug("processContacts()")
      DispatchQueue.main.async {
        
            if self.searchedResults.isEmpty == true{
                self.contactsTableView.delegate = nil
                self.contactsTableView.dataSource = nil
                self.contactsTableView.isHidden = true
                self.noContactsView.isHidden = false
            }else{
                self.contactsTableView.delegate = self
                self.contactsTableView.dataSource = self
                self.contactsTableView.isHidden = false
                self.noContactsView.isHidden = true
                self.contactsTableView.reloadData()
            }
            self.contactsLoaded()
      }
      
    }
    func  contactsLoaded() {
        
    }

    @IBAction func enableContactsClicked(_ sender: Any) {
        let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
      if settingsUrl != nil && UIApplication.shared.canOpenURL(settingsUrl! as URL){
        UIApplication.shared.openURL(settingsUrl! as URL)
      }
    }
}
