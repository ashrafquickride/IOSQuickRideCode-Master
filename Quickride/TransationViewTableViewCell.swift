//
//  TransationViewTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/06/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TransationViewTableViewCell: UITableViewCell {
    
    var isFromRewardHistory: Bool?
    
    @IBOutlet weak var typeOfHistoryLbl: UILabel!
    @IBOutlet weak var viewAllBtn: UIButton!
    
    
    
    func intialisingDataForUpdateUi(isFromRewardHistory:Bool){
        self.isFromRewardHistory = isFromRewardHistory
        if isFromRewardHistory {
            typeOfHistoryLbl.text = "REWARDS HISTORY"
        } else {
        typeOfHistoryLbl.text = "TRANSACTION HISTORY"
        }
    }
    
    
    
    @IBAction func viewAllTapped(_ sender: Any) {
        let transactionVC : TransactionViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        if isFromRewardHistory == true {
            transactionVC.intialisingData(isFromRewardHistory: true)
        } else {
            transactionVC.intialisingData(isFromRewardHistory: false)
        }
        self.parentViewController?.navigationController?.pushViewController(transactionVC, animated: false)
    }
    
}
