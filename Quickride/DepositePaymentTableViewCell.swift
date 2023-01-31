//
//  DepositePaymentTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class DepositePaymentTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var payBookingFeeOrDepositeFeeRadio: UIImageView!
    @IBOutlet weak var payBookingOrDepositeFeeLabel: UILabel!
    @IBOutlet weak var payeFullAmountRadio: UIImageView!
    @IBOutlet weak var payfullAmountLabel: UILabel!
    @IBOutlet weak var payadvancePercentageLabel: UILabel!
    @IBOutlet weak var securityAmountLabel: UILabel!
    @IBOutlet weak var advanceView: UIView!
    @IBOutlet weak var totalView: UIView!
    
    private var fullAmount = 0
    let minimumAmount = 200
        
    func initialisePaymentView(productRequest: RequestProduct,selectedProduct: AvailableProduct){
        calculateFullAmountAndShow(productRequest: productRequest, selectedProduct: selectedProduct)
        if fullAmount < minimumAmount{
            selectPaymentType(type: RequestProduct.PAY_FULL_AMOUNT)
            advanceView.isHidden = true
        }else{
            selectPaymentType(type: RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE)
            advanceView.isHidden = false
        }
    }
    
    private func selectPaymentType(type: String){
        var userSelectedType: String?
        if type == RequestProduct.PAY_FULL_AMOUNT{
            payBookingFeeOrDepositeFeeRadio.image = UIImage(named: "radio_button_1")
            payeFullAmountRadio.image = UIImage(named: "ic_radio_button_checked")
            userSelectedType = RequestProduct.PAY_FULL_AMOUNT
        }else{
            payeFullAmountRadio.image = UIImage(named: "radio_button_1")
            payBookingFeeOrDepositeFeeRadio.image = UIImage(named: "ic_radio_button_checked")
            userSelectedType = RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE
        }
        var userInfo = [String : String]()
        userInfo["paymentWay"] = userSelectedType
        NotificationCenter.default.post(name: .userSelectedPaymentWay, object: nil, userInfo: userInfo)
    }
    
    private func calculateFullAmountAndShow(productRequest: RequestProduct,selectedProduct: AvailableProduct){
        if productRequest.tradeType == Product.RENT{
            let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: productRequest.toTime/1000), date2: NSDate(timeIntervalSince1970: productRequest.fromTime/1000))
            let totalAmount = (Int(productRequest.requestingPricePerDay ?? "") ?? 0) * rentalDays
            fullAmount =  totalAmount + selectedProduct.deposit
            payfullAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(fullAmount)])
            let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: productRequest.categoryCode ?? "")
            let advance = (totalAmount*(category?.bookingAmountForRent ?? 0))/100
            securityAmountLabel.text = Strings.pay_total
            payBookingOrDepositeFeeLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(advance)])
            payadvancePercentageLabel.text = String(format: Strings.advance, arguments: [String(category?.bookingAmountForRent ?? 0),Strings.percentage_symbol])
        }else{
            fullAmount =  Int(selectedProduct.finalPrice)
            payfullAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(fullAmount)])
            payBookingOrDepositeFeeLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(selectedProduct.bookingFee)])
            payadvancePercentageLabel.isHidden = true
            securityAmountLabel.isHidden = true
        }
    }
    
    @IBAction func payBookingOrDepositeTapped(_ sender: Any) {
        selectPaymentType(type: RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE)
    }
    @IBAction func payFullAmountTapped(_ sender: Any) {
        selectPaymentType(type: RequestProduct.PAY_FULL_AMOUNT)
    }
}
