//
//  ProductPaymentDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductPaymentDetailsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var balanceAmountLabel: UILabel!
    @IBOutlet weak var balanceOrBalancePaidLabel: UILabel!
    @IBOutlet weak var balanceSubTextLabel: UILabel!
    
    @IBOutlet weak var advanceView: UIView!
    @IBOutlet weak var advanceTextLabel: UILabel!
    @IBOutlet weak var adavanceAmountLabel: UILabel!
    @IBOutlet weak var adavanceSubTextLabel: UILabel!
    
    @IBOutlet weak var totalPaidView: UIView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var payAdvanceButton: QRCustomButton!
    @IBOutlet weak var payBalanceButton: QRCustomButton!
    private var advance = 0.0
    
    func initialiseSellPaymentDetails(productOrder: ProductOrder?,orderPayment: OrderPayment){
        payAdvanceButton.isHidden = true
        payBalanceButton.isHidden = true
        for paymentStatus in orderPayment.paymentStatus{
            if paymentStatus.type == OrderPayment.BOOKING && (paymentStatus.status == OrderPayment.COMPLETE || paymentStatus.paymentInProgress){
                advance = paymentStatus.amount
                advanceTextLabel.text = Strings.advance_paid
                advanceTextLabel.textColor = .black
                adavanceAmountLabel.text = String(paymentStatus.amount)
                adavanceAmountLabel.textColor = .black
                adavanceSubTextLabel.text = Strings.booking_amount_refund_info
                if productOrder?.paymentMode == RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE{
                    balanceView.isHidden = false
                    balanceSubTextLabel.text = Strings.balance_amount_info
                    balanceAmountLabel.text = String((productOrder?.finalPrice ?? 0) - paymentStatus.amount)
                    balanceAmountLabel.textColor = UIColor(netHex: 0xE20000)
                    balanceOrBalancePaidLabel.text = Strings.balance
                    balanceOrBalancePaidLabel.textColor = UIColor(netHex: 0xE20000)
                }
            }else if paymentStatus.type == OrderPayment.BOOKING && paymentStatus.status == OrderPayment.OPEN && !paymentStatus.paymentInProgress{
                payAdvanceButton.isHidden = false
                adavanceAmountLabel.text = String(paymentStatus.pending)
                adavanceAmountLabel.textColor = UIColor(netHex: 0xE20000)
                advanceTextLabel.text = Strings.advance_failed
                advanceTextLabel.textColor = UIColor(netHex: 0xE20000)
                adavanceSubTextLabel.text = Strings.booking_amount_refund_info
                if productOrder?.paymentMode == RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE{
                    balanceView.isHidden = false
                    balanceSubTextLabel.text = Strings.balance_amount_info
                    balanceAmountLabel.text = String((productOrder?.finalPrice ?? 0) - paymentStatus.amount)
                    balanceAmountLabel.textColor = UIColor(netHex: 0xE20000)
                    balanceOrBalancePaidLabel.text = Strings.balance
                    balanceOrBalancePaidLabel.textColor = UIColor(netHex: 0xE20000)
                }
            }else if paymentStatus.type == OrderPayment.FINAL && (paymentStatus.status == OrderPayment.COMPLETE || paymentStatus.paymentInProgress){
                if productOrder?.paymentMode == RequestProduct.PAY_FULL_AMOUNT{
                    balanceView.isHidden = true
                    advanceTextLabel.text = Strings.advance_paid
                    advanceTextLabel.textColor = .black
                    adavanceAmountLabel.text = String(paymentStatus.amount)
                    adavanceAmountLabel.textColor = .black
                    adavanceSubTextLabel.text = Strings.booking_amount_refund_info
                    totalPaidView.isHidden = false
                    totalAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(paymentStatus.amount)])
                }else{
                    balanceAmountLabel.text = String(paymentStatus.amount)
                    balanceAmountLabel.textColor = .black
                    balanceOrBalancePaidLabel.text = Strings.balance_paid
                    balanceOrBalancePaidLabel.textColor = .black
                    adavanceSubTextLabel.text = ""
                    balanceSubTextLabel.text = ""
                    totalPaidView.isHidden = false
                    totalAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(advance+paymentStatus.amount)])
                }
            }else if paymentStatus.type == OrderPayment.FINAL && paymentStatus.status == OrderPayment.OPEN && !paymentStatus.paymentInProgress{
                balanceView.isHidden = false
                payBalanceButton.isHidden = false
                balanceAmountLabel.text = String(paymentStatus.pending)
                balanceAmountLabel.textColor = UIColor(netHex: 0xE20000)
                balanceOrBalancePaidLabel.text = Strings.pending_amount
                balanceOrBalancePaidLabel.textColor = UIColor(netHex: 0xE20000)
                balanceSubTextLabel.text = Strings.balance_amount_info
                totalPaidView.isHidden = true
            }
        }
    }
    
    @IBAction func payAdvanceTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .showPendingAmount, object: nil)
    }
    @IBAction func payBalanceTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .showPendingAmount, object: nil)
    }
}
