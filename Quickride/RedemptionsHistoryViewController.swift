//
//  RedemptionsHistoryViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 30/08/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import UIKit

class RedemptionsHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var noRedemptionsView: UIView!
    
    @IBOutlet weak var pastRedemptionsTableView: UITableView!
    
    var userId : String?
    var redemptionDetails : [RedemptionRequest] = [RedemptionRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userId = QRSessionManager.getInstance()!.getUserId()
        getRedemptionsHistory()
        pastRedemptionsTableView.estimatedRowHeight = 94
       pastRedemptionsTableView.rowHeight = UITableView.automaticDimension
         pastRedemptionsTableView.register(UINib(nibName: "RedemptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "RedemptionsTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func letsStartClicked(_ sender: Any) {
        ContainerTabBarViewController.indexToSelect = 1
        self.navigationController?.popToRootViewController(animated: false)
        
    }
    
    
    @IBAction func backButtnTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: false)
    }
    
    func getRedemptionsHistory()
    {
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getPastRedemptions(accountid: userId!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if (responseObject != nil) && (responseObject!["result"] as! String == "SUCCESS"){
                self.redemptionDetails = Mapper<RedemptionRequest>().mapArray(JSONObject: responseObject!["resultData"])!
                self.redemptionDetails.sort(by: { $0.requestedTime! < $1.requestedTime!})
                if self.redemptionDetails.isEmpty
                {
                    self.noRedemptionsView.isHidden = false
                    self.pastRedemptionsTableView.isHidden = true
                }
                else
                {
                    self.noRedemptionsView.isHidden = true
                    self.pastRedemptionsTableView.isHidden = false
                    self.redemptionDetails = self.redemptionDetails.reversed()
                    self.pastRedemptionsTableView.delegate = self
                    self.pastRedemptionsTableView.dataSource = self
                    self.pastRedemptionsTableView.reloadData()
                }
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var title = " "
        var description = Strings.redemption_status_pending
        let redumptionStatus = redemptionDetails[indexPath.row]
        if redumptionStatus.status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_PROCESSED
        {
            title = Strings.redemption_processed
            if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PAYTM || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_TMW || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PEACH || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
            {
                description = String(format: Strings.redemption_processed_wallet_description, redumptionStatus.type!)
            }
            else if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY
            {
                description = String(format: Strings.amazon_redemption_processed_description, redumptionStatus.type!)
            }else if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_SODEXO || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_HP_PAY{
                description = String(format: Strings.sodexo_redemption_processed_desc, redumptionStatus.type!)
            }else if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
                description = Strings.bank_account_redemption_processed_desc
            }else if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD{
                description = Strings.sell_redemption_processed_description
            }else{
                description = Strings.redemption_processed_description
            }
            displayMessage(title: title,description: description)
            
        }
        else if redumptionStatus.status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_REVIEW
        {
            title = Strings.redemption_under_review
            if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PAYTM || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_TMW || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
            {
                description = String(format: Strings.redemption_under_review_description, redumptionStatus.type!,Strings.wallet)
            }
            else if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_SODEXO || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_HP_PAY
            {
                description = String(format: Strings.amazon_redemption_under_review_description, redumptionStatus.type!)
                
            }else if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
                description = Strings.bank_redemption_under_review_description
            }else
            {
                description = String(format: Strings.redemption_under_review_description, redumptionStatus.type!,Strings.card)
            }
            displayMessage(title: title,description: description)
            
        }
        else if redumptionStatus.status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_APPROVED
        {
            title = Strings.redemption_approved
            if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PAYTM || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_TMW || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
            {
                
                description = String(format: Strings.redemption_approved_description, redumptionStatus.type!,Strings.wallet)
            }
            else if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_SODEXO || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_HP_PAY
            {
                description = String(format: Strings.amazon_redemption_approved_description, redumptionStatus.type!)
            }else if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
                description = Strings.bank_redemption_approved_description
            }
            else
            {
                description = String(format: Strings.redemption_approved_description, redumptionStatus.type!,Strings.card)
            }
            displayMessage(title: title,description: description)
        }
        else if redumptionStatus.status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_CANCELLED
        {
            title = Strings.redemption_cancelled
            if redumptionStatus.reason != nil
            {
            description = String(format: Strings.redemption_cancelled_description_with_reason, redumptionStatus.reason!)
            }
            else
            {
             description = Strings.redemption_cancelled_description_without_reason
            }
            displayMessage(title: title, description: description)
        }
        else if redumptionStatus.status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_REJECTED
        {
            title = Strings.redemption_rejected
            description = Strings.redemption_rejected_description
            displayMessage(title: title,description: description)
        }
        else if redumptionStatus.status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_PENDING
        {
            title = Strings.redemption_under_pending
            if redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PAYTM || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_SODEXO || redumptionStatus.type == RedemptionRequest.REDEMPTION_TYPE_HP_PAY
            {
                description = String(format: Strings.redemption_under_pending_description, redumptionStatus.type!)
            }
            displayMessage(title: title,description: description)
        }
        else if redumptionStatus.status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_UNKNOWN{
            title = Strings.redemption_failed
            description = Strings.redemption_unknown_error_description
            displayMessage(title: title,description: description)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func displayMessage(title: String,description: String) {
        
        MessageDisplay.displayErrorAlertWithAction(title: title, isDismissViewRequired: true, message1: description, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self, handler: { (result) in
            
        })
        
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RedemptionsTableViewCell", for: indexPath) as! RedemptionsTableViewCell
        let redemptionDetails = redemptionDetails[indexPath.row]
        cell.intialisingData(redemptionDetails: redemptionDetails)
         return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.redemptionDetails.count
    }
   
}
