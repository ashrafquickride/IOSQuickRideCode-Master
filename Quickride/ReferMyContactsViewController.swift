//
//  ReferMyContactsViewController.swift
//  Quickride
//
//  Created by Halesh on 12/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReferMyContactsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var myContactsTableView: UITableView!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var selectedAndUnselectedImage: UIImageView!
    @IBOutlet weak var inviteAllButton: UIButton!
    @IBOutlet weak var noContactsView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: Variables
    private var referMyContactsViewModel = ReferMyContactsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.changeBackgroundColorBasedOnSelection()
        bottomView.addShadow()
        bottomView.isHidden = true
        searchBar.delegate = self
        referMyContactsViewModel.getMobileContacts(viewController: self, delegate: self)
    }
    
    @IBAction func inviteAllButtonTapped(_ sender: Any) {
        referMyContactsViewModel.referToSelecetdContacts(viewController: self, delegate: self)
    }
    
    @IBAction func selectAndDisSelectAll(_ sender: Any) {
        if referMyContactsViewModel.allContactsSelected{
            for (index,contact) in referMyContactsViewModel.searchedContactList.enumerated(){
                referMyContactsViewModel.searchedContactList[index].isContactSelected = false
            }
            referMyContactsViewModel.allContactsSelected = false
            selectedAndUnselectedImage.image = UIImage(named: "uncheck")
            inviteAllButton.isHidden = true
            myContactsTableView.reloadData()
        }else{
            for (index,contact) in referMyContactsViewModel.searchedContactList.enumerated(){
                referMyContactsViewModel.searchedContactList[index].isContactSelected = true
            }
            referMyContactsViewModel.allContactsSelected = true
            selectedAndUnselectedImage.image = UIImage(named: "check")
            inviteAllButton.isHidden = false
            myContactsTableView.reloadData()
        }
    }
    
    @IBAction func bacButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func showInviteSuccessAlert(){
        let animationAlertController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimationAlertController") as! AnimationAlertController
        animationAlertController.initializeDataBeforePresenting(activatedMessage: String(format: Strings.referral_contact_success_msg, arguments: [String(referMyContactsViewModel.referredContactsCount)]), isFromLinkedWallet: true, handler: nil)
        ViewControllerUtils.addSubView(viewControllerToDisplay: animationAlertController)
    }
    
}
//MARK:UITableViewDataSource
extension ReferMyContactsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return referMyContactsViewModel.searchedContactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyContactsTableViewCell", for: indexPath) as! MyContactsTableViewCell
        cell.initializeCell(contact: referMyContactsViewModel.searchedContactList[indexPath.row])
        return cell
    }
}
//MARK:UITableViewDelegate
extension ReferMyContactsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("tableView() didSelectRowAtIndexPath() \(indexPath)")
        if referMyContactsViewModel.searchedContactList.count <= indexPath.row{
            return
        }
        if referMyContactsViewModel.searchedContactList[indexPath.row].isContactSelected{
            referMyContactsViewModel.searchedContactList[indexPath.row].isContactSelected = false
        }else{
            referMyContactsViewModel.searchedContactList[indexPath.row].isContactSelected = true
        }
        handleInviteAllButton()
        myContactsTableView.reloadData()
    }
    
    private func handleInviteAllButton(){
        var selectedCount = 0
        for contact in referMyContactsViewModel.searchedContactList{
            if contact.isContactSelected{
                selectedCount += 1
            }
        }
        if selectedCount > 0{
            inviteAllButton.isHidden = false
        }else{
           inviteAllButton.isHidden = true
        }
    }
    private func sortContactsBasedName(){
        var withoutNameContacts = [ContactRegistrationStatus]()
        referMyContactsViewModel.searchedContactList.removeAll()
        for contact in referMyContactsViewModel.unRegisteredContactList{
            if contact.contactName != nil && contact.contactName?.isEmpty == false{
                referMyContactsViewModel.searchedContactList.append(contact)
            }else{
                withoutNameContacts.append(contact)
            }
        }
        referMyContactsViewModel.searchedContactList.sort(by: { $0.contactName! < $1.contactName!})
        referMyContactsViewModel.searchedContactList.append(contentsOf: withoutNameContacts)
    }
}
//MARK:UnregisteredContactsDelegate
extension ReferMyContactsViewController: SyncContactsAndGetUnregisteredContactsDelagate{
    func contactsSyncingFailed(errorMessage: String,positiveBtn: String?,negativeBtn: String?){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: errorMessage, message2: nil, positiveActnTitle: positiveBtn, negativeActionTitle : negativeBtn,linkButtonText: nil, viewController: self, handler: { (result) in
            if result == Strings.go_to_settings_caps{
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }else{
               self.navigationController?.popViewController(animated: false)
            }
        })
    }
    
    func recievedUnRegisteredContscts() {
        selectedAndUnselectedImage.image = UIImage(named: "check")
        bottomView.isHidden = false
        sortContactsBasedName()
        myContactsTableView.dataSource = self
        myContactsTableView.delegate = self
        myContactsTableView.reloadData()
    }
}

//MARK:ReferPhoneBookSelectedContactDelegate
extension ReferMyContactsViewController: ReferPhoneBookSelectedContactDelegate{
    func handleSuccussResponse() {
        showInviteSuccessAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
//MARK: UISearchBarDelegate
extension ReferMyContactsViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.text = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        AppDelegate.getAppDelegate().log.debug("searchBar() textDidChange() \(searchText)")
        referMyContactsViewModel.searchedContactList.removeAll()
        if searchText.isEmpty == true{
            sortContactsBasedName()
        }else{
            for contact in referMyContactsViewModel.unRegisteredContactList{
                if contact.contactName!.localizedCaseInsensitiveContains(searchText){
                    referMyContactsViewModel.searchedContactList.append(contact)
                }
            }
        }
        if referMyContactsViewModel.searchedContactList.isEmpty{
            noContactsView.isHidden = false
            myContactsTableView.isHidden = true
        }else{
            noContactsView.isHidden = true
            myContactsTableView.isHidden = false
            myContactsTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked()")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
}
