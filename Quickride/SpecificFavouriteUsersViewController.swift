//
//  SpecificFavouriteUsersViewController.swift
//  Quickride
//
//  Created by Halesh on 04/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class SpecificFavouriteUsersViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NocontactListShowingView: UIView!
    
    var ridePreferences : RidePreferences?
    private var ContactListVM: ContactListViewModel?
    
    override func viewDidLoad(){
        super.viewDidLoad()
         definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        setUpUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func setUpUI() {
        ContactListVM = ContactListViewModel()
        let ContactList = ContactListVM?.getContactList()
        NocontactListShowingView.isHidden = true
        tableView.register(UINib(nibName: "AutoConfirmContactListTableViewCell", bundle: nil), forCellReuseIdentifier: "AutoConfirmContactListTableViewCell")
        if ContactList?.count != 0{
            tableView.isHidden = false
            tableView.reloadData()
        }else{
            tableView.isHidden = true
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
}


extension SpecificFavouriteUsersViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactListVM?.getContactList().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoConfirmContactListTableViewCell") as! AutoConfirmContactListTableViewCell 
        cell.detailsButton.tag = indexPath.row
        cell.detailsButton.addTarget(self, action: #selector(detailsBtnTapped(_:)), for: .touchUpInside)
        cell.updateCellData(data:ContactListVM!.getContactList()[indexPath.row])
        return cell
    }
    
    @objc private func detailsBtnTapped(_ sender: AnyObject) {
        ShowAlertSheet(sender: sender.tag)
    }
    
    
    private func ShowAlertSheet(sender: Int) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.auto_match, style: .default) { action -> Void in
            print("Match Pressed")
            self.updateStatusData(sender: sender, enableStatus: true)
        }
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.auto_donotmatch, style: .default) { action -> Void in
            print("unMatch Pressed")
            self.updateStatusData(sender: sender, enableStatus: false)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true) {
        }
    }
    
    private func updateStatusData(sender: Int,enableStatus: Bool) {
        let contactDetails = self.ContactListVM!.getContactList()[sender]
        var enableAutoState = ""
        if enableStatus{
            enableAutoState = AutoConfirmPartner.AUTO_CONFIRM_STATUS_ENABLE
        }else{
            enableAutoState = AutoConfirmPartner.AUTO_CONFIRM_STATUS_DISABLE
        }
        
        let AutoData = AutoConfirmPartner.init(enableAutoConfirm: enableAutoState, userId: self.ridePreferences?.userId ?? 0.0, partnerId: String(contactDetails.contactId!), partnerName: contactDetails.contactName, partnerGender: contactDetails.contactGender, imageURI: contactDetails.contactImageURI ?? "", partnerType: contactDetails.contactType)
        let AutoDataArray = [AutoData]
        guard let autoData = try? JSONSerialization.data(withJSONObject: AutoDataArray.toJSON(), options: []) else { return }
        let autoDataString = String(data: autoData, encoding: String.Encoding.utf8)
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updateAutoConfirmPartnerStatus(userId: self.ridePreferences?.userId ?? 0.0, partners: autoDataString ?? "", viewController: self,completionHandler: { responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                for ridePartner in self.ContactListVM!.getContactList(){
                    if ridePartner.contactId == contactDetails.contactId!{
                        if enableStatus{
                            ridePartner.autoConfirmStatus =  Contact.AUTOCONFIRM_FAVOURITE
                        }else{
                            ridePartner.autoConfirmStatus =  Contact.AUTOCONFIRM_UNFAVOURITE
                        }
                        UserDataCache.getInstance()?.storeRidePartnerContact(contact: ridePartner)
                        self.setUpUI()
                    }
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
}
