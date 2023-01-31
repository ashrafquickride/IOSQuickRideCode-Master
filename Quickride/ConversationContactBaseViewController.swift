//
//  ConversationContactBaseViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 5/16/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
protocol ContactSelectionReceiver
{
    func contactSelected(contact : Contact)
}

class ConversationContactBaseViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, ContactRefreshListener{
    
    @IBOutlet weak var contactNameSearchBar: UISearchBar!
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    @IBOutlet weak var noContactsView: UIView!
        
    @IBOutlet weak var startSharingRidesText: UIButton!
   
    @IBOutlet weak var ContactSearchBarHeightConstraint: NSLayoutConstraint!
   

    
    var topViewController : ConversationSegmentedViewController?

    var recentChats = [Contact]()
    var rideParticipants = [Contact]()
    
    var recentchatsSearchResutls = [Contact]()
    var ridePartnersSearchResults = [Contact]()
    
    var requireConversationContacts = true
    var requireRidePartners = true
    var moveToContacts = false
    var isNavBarRequired = false
    var contactSelectionReceiver : ContactSelectionReceiver?
    var isCallAndChatEnabled = [Int : Bool]()
    
    func initializeDataBeforePresentingView(requireConversationContacts : Bool, requireRidePartners : Bool,isNavBarRequired : Bool, moveToContacts : Bool,receiver : ContactSelectionReceiver?){
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresentingView()")
        self.requireConversationContacts = requireConversationContacts
        self.requireRidePartners = requireRidePartners
        self.isNavBarRequired = isNavBarRequired
        self.moveToContacts = moveToContacts
        self.contactSelectionReceiver = receiver
    }
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ConversationContactBaseViewController.handleSwipes(_:)))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        contactNameSearchBar.delegate = self
    }
    
    @objc func handleSwipes(_ sender : UISwipeGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("handleSwipes()")
        contactNameSearchBar.endEditing(true)
        resignFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
    
        if isNavBarRequired{
          self.navigationController?.isNavigationBarHidden = false
          self.contactNameSearchBar.isHidden = true
          ContactSearchBarHeightConstraint.constant = 0
       }else{
            self.contactNameSearchBar.isHidden = false
            ContactSearchBarHeightConstraint.constant = 56
            self.navigationController?.isNavigationBarHidden = false

        }
        if moveToContacts == true{
            topViewController?.changeTitle(title : Strings.contacts_title)
        }else{
            topViewController?.changeTitle(title : Strings.conversation_title)
        }
        let chatContacts = UserDataCache.getInstance()?.getRidePartnerContacts()
        if chatContacts == nil || chatContacts!.isEmpty{
            self.contactsTableView.isHidden = true
            self.noContactsView.isHidden = false
        }else{
            self.contactsTableView.isHidden = false
            self.noContactsView.isHidden = true
            self.reArrangeTheContactList(contactsList: chatContacts!)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.text = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        AppDelegate.getAppDelegate().log.debug("searchBar() textDidChange() \(searchText)")
        contactsTableView.delegate = nil
        contactsTableView.dataSource = nil
        
        recentchatsSearchResutls.removeAll()
        ridePartnersSearchResults.removeAll()
        if searchText.isEmpty == true{
            recentchatsSearchResutls = recentChats
            ridePartnersSearchResults = rideParticipants
        }else{
            for contact in recentChats{
                if contact.contactName.localizedCaseInsensitiveContains(searchText){
                    recentchatsSearchResutls.append(contact)
                }
            }
                for contact in rideParticipants{
                    if contact.contactName.localizedCaseInsensitiveContains(searchText){
                        ridePartnersSearchResults.append(contact)
                    }
            }
        }
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        if recentchatsSearchResutls.isEmpty == true && ridePartnersSearchResults.isEmpty == true{
            noContactsView.isHidden = false
            contactsTableView.isHidden = true
        }else{
            noContactsView.isHidden = true
            contactsTableView.isHidden = false
            self.contactsTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked()")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return recentchatsSearchResutls.count
        }
        else{
            return ridePartnersSearchResults.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationContactCell", for: indexPath as IndexPath) as! ConversationContactCell
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func receiveDataFromCacheFailed(responseObject: NSDictionary?, error: NSError?) {
        
        AppDelegate.getAppDelegate().log.debug("receiveDataFromCacheFailed()")
        QuickRideProgressSpinner.stopSpinner()
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    
    @IBAction func startSharingRidesClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("startSharingRidesClicked()")
        if MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides().isEmpty == false || MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRides().isEmpty == false{
            moveToProperVC(selectedIndex: 1)
        }else{
           moveToProperVC(selectedIndex: 0)
        }
    }
    
    private func moveToProperVC(selectedIndex: Int) {
        ContainerTabBarViewController.indexToSelect = selectedIndex
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func reArrangeTheContactList(contactsList : [Contact])
    {
        recentChats.removeAll()
        recentchatsSearchResutls.removeAll()
        ridePartnersSearchResults.removeAll()
        rideParticipants.removeAll()
        for contact in contactsList{
            guard let contactIDStr = contact.contactId, let contactId = Double(contactIDStr) else { return }
            if let userDataCache = UserDataCache.getInstance(), userDataCache.isFavouritePartner(userId: contactId){
                recentChats.append(contact)
            }else{
                rideParticipants.append(contact)
            }
        }
        recentChats.sort(by: { $0.contactName < $1.contactName})
        rideParticipants.sort(by: { $0.contactName < $1.contactName})
        recentchatsSearchResutls = recentChats
        ridePartnersSearchResults = rideParticipants
        recentChats = recentchatsSearchResutls
        ridePartnersSearchResults = rideParticipants
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        self.contactsTableView.reloadData()
    }
    
    func refershContacts() {
       let chatContacts = UserDataCache.getInstance()?.getRidePartnerContacts()
        if chatContacts == nil || chatContacts!.isEmpty{
                self.contactsTableView.isHidden = true
                self.noContactsView.isHidden = false
            }else{
                self.contactsTableView.isHidden = false
                self.noContactsView.isHidden = true
            self.reArrangeTheContactList(contactsList: chatContacts!)
            }
    }
    
  func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == contactsTableView{
            
            if section == 0 && recentchatsSearchResutls.count > 0{
                return Strings.favouritePartner
            }
            else if section == 1 && ridePartnersSearchResults.count > 0{
                return Strings.ride_partners_contact
            }
        }
        return nil
    }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
      }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && recentchatsSearchResutls.isEmpty == false {
            return 30
        }else if section == 1 && ridePartnersSearchResults.isEmpty == false{
            return 30
        }else{
            return 0
        }
    }
}
