//
//  PaymentBreakUpTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 03/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PaymentBreakUpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var perDayOrSellPriceText: UILabel!
    @IBOutlet weak var perDayOrSellPrice: UILabel!
    @IBOutlet weak var noOfDaysView: UIView!
    @IBOutlet weak var noOfDaysLabel: UILabel!
    @IBOutlet weak var totalRentView: UIView!
    @IBOutlet weak var totalRentLabel: UILabel!
    @IBOutlet weak var totalRentOrBookingFeeTextLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var depositeView: UIView!
    @IBOutlet weak var depositeAmountLabel: UILabel!
    
    func initialiseAmountDetailsView(perDayPrice: Double?,noOfDays: Int,deposite: Int?){
            perDayOrSellPriceText.text = Strings.rentalPerDay
            perDayOrSellPrice.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: perDayPrice)])
            noOfDaysView.isHidden = false
            noOfDaysLabel.text = String(noOfDays)
            totalRentOrBookingFeeTextLabel.text = String(format: Strings.total_rent, arguments: [StringUtils.getStringFromDouble(decimalNumber: perDayPrice),String(noOfDays)])
            totalRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(Int(perDayPrice ?? 0)*noOfDays)])
        let totalAmount = (Int(perDayPrice ?? 0)*noOfDays) + (deposite ?? 0)
            totalAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(totalAmount)])
        if deposite != nil{
            depositeView.isHidden = false
            depositeAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(deposite ?? 0)])
        }else{
            depositeView.isHidden = true
        }
    }
}
