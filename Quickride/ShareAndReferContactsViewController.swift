//
//  ShareAndReferContactsViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 23/01/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation
import UIKit


class ShareAndReferContactsViewController : ContactsViewController,ContactSelectionDelegate{
    
    var selectedContacts = [Double : Contact]()
    
    @IBOutlet weak var selectAllSeperatorView: UIView!
    
    @IBOutlet weak var inviteAllButton: UIButton!
    
    @IBOutlet weak var selectAllButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteAllButton.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
        super.viewWillAppear(animated)
        getMobileContacts()
    }

    func checkTheValidContactsToDisplay(){
        if self.contacts.isEmpty == false{
            var nonQuickRIdeUserContacts = [Contact]()
            for searchResult in searchedResults{
                for contact in contacts{
                    if contact.contactId == searchResult.contactId{
                        nonQuickRIdeUserContacts.append(searchResult)
                        break
                    }
                }
                searchedResults = nonQuickRIdeUserContacts
            }
            return
        }
        if self.contacts.isEmpty{
            self.contacts = self.searchedResults
        }
        var mobileContacts = ""
        for contact in searchedResults{
            mobileContacts = mobileContacts+StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)+","
        }
        
        
        UserDataCache.getInstance()?.getNonQuickRIdeUsersContacts(mobileContacts: mobileContacts) { (nonQuickRIdeUserContacts) in
            if nonQuickRIdeUserContacts != nil && nonQuickRIdeUserContacts!.isEmpty == false{
                self.searchedResults = nonQuickRIdeUserContacts!
            }
            if self.contacts.isEmpty{
                self.contacts = self.searchedResults
            }
            if self.searchedResults.isEmpty == true && self.contacts.isEmpty == true{
                self.selectAllButton.isHidden = true
                self.selectAllSeperatorView.isHidden = true
            }
            self.contactsTableView.reloadData()
        }
        if searchedResults.isEmpty == true && contacts.isEmpty == true{
            selectAllButton.isHidden = true
            selectAllSeperatorView.isHidden = true
        }
     }
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    override func contactsLoaded() {
        checkTheValidContactsToDisplay()
    }
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        AppDelegate.getAppDelegate().log.debug("searchBar() textDidChange() \(searchText)")
        contactsTableView.dataSource = nil
        contactsTableView.delegate = nil
        searchedResults.removeAll()
        if searchText.isEmpty == true{
            searchedResults = contacts
            if searchedResults.isEmpty == true{
                selectAllButton.isHidden = true
                selectAllSeperatorView.isHidden = true
            }
            else{
                selectAllButton.isHidden = false
                selectAllSeperatorView.isHidden = false
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
            super.searchBar(searchBar, textDidChange: searchText)
            if searchedResults.isEmpty == true{
                selectAllButton.isHidden = true
                selectAllSeperatorView.isHidden = true
            }
            else{
                selectAllButton.isHidden = false
                selectAllSeperatorView.isHidden = false
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.row >= searchedResults.count{
            return cell
        }
        
        let contact = searchedResults[indexPath.row]
        var isSelected = false
        if contact.contactNo != nil && self.selectedContacts[contact.contactNo!] != nil{
            isSelected = true
        }
        (cell as! ContactsTableViewCell).inviteButton.tag = indexPath.row
        (cell as! ContactsTableViewCell).initializeMultipleSelection(contactSelectionDelegate: self, isSelected: isSelected)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        AppDelegate.getAppDelegate().log.debug("tableView() didSelectRowAtIndexPath() \(indexPath)")
        let contactCell = tableView.cellForRow(at: indexPath) as! ContactsTableViewCell
        
        let selctedContact = searchedResults[indexPath.row]
        
        if selectedContacts[selctedContact.contactNo!] == nil
        {
            selectedContacts[selctedContact.contactNo!] = selctedContact
            contactCell.userSelected = true
        }else{
            selectedContacts[selctedContact.contactNo!] = nil
            contactCell.userSelected = false
        }
        
        contactCell.userImageTapped()
        validateAndDisplayInviteSelectedContactsButton()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    @IBAction func inviteMultipleContacts(_ sender: Any) {
        self.view.endEditing(true)
        var contactsToInvite = [Contact]()
        for contact in selectedContacts{
            contactsToInvite.append(contact.1)
        }
        navigateToContactInvite(contactsToInvite: contactsToInvite,isWhatAppHidden: true)
    }
    
    func navigateToContactInvite(contactsToInvite : [Contact], isWhatAppHidden : Bool){
        let viewController = UIStoryboard(name: "ShareAndEarn", bundle: nil).instantiateViewController(withIdentifier: "ShareAppThroughContactsOptionsDialouge") as! ShareAppThroughContactsOptionsDialouge
        viewController.initializeDataBeforePresentingView(contactsToInvite: contactsToInvite, isWhatAppHidden: isWhatAppHidden)
        self.navigationController?.view.addSubview(viewController.view)
        self.navigationController?.addChild(viewController)
    }
    
    @IBAction func inviteASingleContact(_ sender: UIButton) {
        self.view.endEditing(true)
        var contactsToInvite = [Contact]()
        let contact = searchedResults[sender.tag]
        contactsToInvite.append(contact)
        navigateToContactInvite(contactsToInvite: contactsToInvite,isWhatAppHidden: false)
        
    }
    
    @IBAction func selectAllClicked(_ sender: Any) {
        self.view.endEditing(true)
        if selectAllButton.currentTitle == Strings.select_all
        {
            selectAllButton.setTitle(Strings.deselect_all, for: .normal)
            for contact in searchedResults{
                selectedContacts[contact.contactNo!] = contact
            }
            contactsTableView.reloadData()
        }
        else{
            
            selectAllButton.setTitle(Strings.select_all, for: .normal)
            selectedContacts.removeAll()
            contactsTableView.reloadData()
        }
        validateAndDisplayInviteSelectedContactsButton()
    }
    func validateAndDisplayInviteSelectedContactsButton(){
        if selectedContacts.isEmpty == false{
            inviteAllButton.isHidden = false
        }
        else{
            inviteAllButton.isHidden = true
        }
    }
    
    func contactSelectedAtIndex(row: Int, contact: Contact) {
        
        selectedContacts[contact.contactNo!] = contact
        validateAndDisplayInviteSelectedContactsButton()
    }
    func contactUnSelectedAtIndex(row: Int, contact: Contact) {
        selectedContacts.removeValue(forKey: contact.contactNo!)
        validateAndDisplayInviteSelectedContactsButton()
        
    }
}
