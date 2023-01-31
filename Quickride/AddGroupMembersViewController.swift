//
//  AddGroupMembersViewController.swift
//  Quickride
//
//  Created by rakesh on 3/12/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class AddGroupMembersViewController : ContactsViewController,ContactSelectionDelegate{

    @IBOutlet weak var addBtn: UIButton!
    
    var selectedContacts = [Double : Contact]()
    var group : Group?
    var delegate : GroupMemberDelegate?
    
    func initializeDataBeforePresenting(group : Group?,delegate : GroupMemberDelegate){
        self.group = group
        self.delegate = delegate
    }

    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 15)!]
        addBtn.isHidden = true
        getRidePartnerContacts()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if searchedResults.endIndex <= indexPath.row{
            return cell
        }
        let contact = searchedResults[indexPath.row]
        (cell as! ContactsTableViewCell).initializeMultipleSelection(contactSelectionDelegate: self, isSelected: selectedContacts[contact.contactNo ?? 0] != nil)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        AppDelegate.getAppDelegate().log.debug("tableView() didSelectRowAtIndexPath() \(indexPath)")
        let contactCell = tableView.cellForRow(at: indexPath) as! ContactsTableViewCell
        
        let selctedContact = searchedResults[indexPath.row]
        guard let contactNo = selctedContact.contactNo else { return }
        
        if selectedContacts[contactNo] == nil
        {
            selectedContacts[contactNo] = selctedContact
            contactCell.userSelected = true
        }else{
            selectedContacts[contactNo] = nil
            contactCell.userSelected = false
        }
        
        contactCell.userImageTapped()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    

    @IBAction func AddAllBtnTapped(_ sender: Any) {
       addSelectedContactsToGroup()
    }
 
    @IBAction func backButtonClicked(_ sender: Any) {
    
        navigationController?.popViewController(animated: false)
    }
    func addSelectedContactsToGroup(){
        var memberIds = ""
        for contact in selectedContacts{
            memberIds = memberIds+StringUtils.getStringFromDouble(decimalNumber: contact.value.contactNo)+","
        }
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.addMemberToGroup(group: group!, memberId: memberIds, viewController: self,handler:  { (responseObject, error) in
        QuickRideProgressSpinner.stopSpinner()
           if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
            
            let groupMembers = Mapper<GroupMember>().mapArray(JSONObject: responseObject!["resultData"])
            self.group!.lastRefreshedTime = NSDate()
            UserDataCache.getInstance()?.addMembersToGroup(groupId: self.group!.id, groupMembers: groupMembers!)
            self.delegate?.groupMemberAdded(group: self.group!)
            self.navigationController?.popViewController(animated: false)
           }else{
              ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
           }
        })

    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        super.searchBar(searchBar, textDidChange: searchText)
        if searchText.isEmpty == false && searchText.count > 7{
            if searchedResults.isEmpty{
                UserRestClient.searchUserForSearchIdentifier(searchIdentifier: searchText, viewController: self, handler: { (responseObject, error) in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                        
                    self.searchedResults = Mapper<Contact>().mapArray(JSONObject: responseObject!["resultData"])!
                        
                        self.contactsTableView.dataSource = nil
                        self.contactsTableView.delegate = nil
                        if self.searchedResults.isEmpty{
                            self.contactsTableView.isHidden = true
                            self.noContactsView.isHidden = false
                        }else{
                            self.contactsTableView.dataSource = self
                            self.contactsTableView.delegate = self
                            self.contactsTableView.isHidden = false
                            self.noContactsView.isHidden = true
                            self.contactsTableView.reloadData()
                        }
                        
                    }
                })
            }
        }
    }
    
    func contactSelectedAtIndex(row: Int, contact: Contact) {
        AppDelegate.getAppDelegate().log.debug("contactSelectedAtIndex() \(row) \(contact)")
        if let contactNo = contact.contactNo{
            selectedContacts[contactNo] = contact
        }
        validateAndDisplayAddMembersButton()
    }
    
    func contactUnSelectedAtIndex(row: Int, contact: Contact) {
        AppDelegate.getAppDelegate().log.debug("contactUnSelectedAtIndex() \(row) \(contact)")
        if let contactNo = contact.contactNo{
            selectedContacts.removeValue(forKey: contactNo)
        }
        validateAndDisplayAddMembersButton()
    }
    
    func validateAndDisplayAddMembersButton(){
        if selectedContacts.isEmpty == false{
            addBtn.isHidden = false
        }
        else{
            addBtn.isHidden = true
        }
    }
 
}
