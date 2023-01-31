//
//  CallHistoryViewController.swift
//  Quickride
//
//  Created by Admin on 09/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CallHistoryViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var callHistoryTableView: UITableView!
    @IBOutlet weak var noCallHistoryView: UIView!
    
    //MARK: Properties
    var callHistoryViewModel = CallHistoryViewModel()
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callHistoryViewModel.delegate = self
        callHistoryViewModel.getCallHistory(viewController: self)
    }

}

//MARK: ViewModelDelegate
extension CallHistoryViewController: CallHistoryViewModelDelegate {
    func receivedCallHistory() {
        guard let callHistoryList = callHistoryViewModel.callHistoryList , callHistoryList.count > 0 else {
            noCallHistoryView.isHidden = false
            callHistoryTableView.isHidden = true
            return
        }
        noCallHistoryView.isHidden = true
        callHistoryTableView.isHidden = false
        callHistoryTableView.reloadData()
    }
}

//MARK: UITableViewDelegate
extension CallHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let callHistory = callHistoryViewModel.callHistoryList?[indexPath.row],let securityPreference =  UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences(),let receiverId = callHistoryViewModel.getTheReceiverID(callDetail: callHistory) else { return }
        
        AppUtilConnect.getPhoneNumberAndCall(receiverId: StringUtils.getStringFromDouble(decimalNumber: receiverId), targetViewController: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

//MARK: UITableViewDataSource
extension CallHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callHistoryViewModel.callHistoryList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallHistoryTableViewCell", for: indexPath) as! CallHistoryTableViewCell
        guard let callHistory = callHistoryViewModel.callHistoryList?[indexPath.row] else { return cell }
        cell.setData(callHistory: callHistory)
        return cell
    }
}
