//
//  PendingLinkWalletTransactionsTableViewCell.swift
//  Quickride
//
//  Created by Admin on 05/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PendingLinkWalletTransactionsTableViewCell : UITableViewCell{
    
    @IBOutlet weak var dayDateMonthView: UIView!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    
    func initializeViews(linkedWalletPendingTransaction : LinkedWalletPendingTransaction){
       self.dayLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: linkedWalletPendingTransaction.startTime!/1000), format : DateUtils.DATE_FORMAT_EE).uppercased()
        self.dateLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: linkedWalletPendingTransaction.startTime!/1000), format : DateUtils.DATE_FORMAT_dd)
        self.monthLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: linkedWalletPendingTransaction.startTime!/1000), format : DateUtils.DATE_FORMAT_MMM).uppercased()
        self.nameLabel.text = linkedWalletPendingTransaction.riderName
        self.amountLabel.text = String(linkedWalletPendingTransaction.amount!)
        ViewCustomizationUtils.addCornerRadiusToView(view: dayDateMonthView, cornerRadius: 10.0)
        ViewCustomizationUtils.addBorderToView(view: dayDateMonthView, borderWidth: 1, color: UIColor.lightGray)
    }
    
    
}
