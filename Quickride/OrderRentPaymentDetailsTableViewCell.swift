//
//  OrderRentPaymentDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class OrderRentPaymentDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var adavanceAmountLabel: UILabel!
    @IBOutlet weak var adavanceInfo: UILabel!
    @IBOutlet weak var advanceTextLabel: UILabel!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var balanceAmountLabel: UILabel!
    @IBOutlet weak var balanceOrBalancePaidLabel: UILabel!
    @IBOutlet weak var balanceInfo: UILabel!
    
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var refundView: UIView!
    @IBOutlet weak var refundAmountLabel: UILabel!
    @IBOutlet weak var refundSubTextLabel: UILabel!
    @IBOutlet weak var refundInitiatedView: UIView!
    @IBOutlet weak var refundOrRefundCompletedLabel: UILabel!
    @IBOutlet weak var payAdvanceButton: QRCustomButton!
    @IBOutlet weak var payBalanceButton: QRCustomButton!
    @IBOutlet weak var refundingTypesLabel: UILabel!
    
    private var advance = 0.0
    private var deposite = 0.0
    
    func initialiseRentPaymentDetails(productOrder: ProductOrder?,orderPayment: OrderPayment,invoice: ProductOrderInvoice){
        payAdvanceButton.isHidden = true
        payBalanceButton.isHidden = true
        if productOrder?.status != Order.CLOSED{
            for paymentStatus in orderPayment.paymentStatus{
                if paymentStatus.type == OrderPayment.BOOKING && (paymentStatus.status == OrderPayment.COMPLETE || paymentStatus.paymentInProgress){
                    advance = paymentStatus.amount
                    advanceTextLabel.text = Strings.advance_paid
                    advanceTextLabel.textColor = .black
                    adavanceAmountLabel.text = String(paymentStatus.amount)
                    adavanceInfo.text = Strings.booking_amount_refund_info
                    if productOrder?.paymentMode == RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE{
                        let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: (productOrder?.toTimeInMs ?? 0)/1000), date2: NSDate(timeIntervalSince1970: (productOrder?.fromTimeInMs ?? 0)/1000))
                        balanceView.isHidden = false
                        let totalAmount = (Int(productOrder?.pricePerDay ?? 0) * rentalDays) + (productOrder?.deposit ?? 0)
                        balanceAmountLabel.text = String(Double(totalAmount) - paymentStatus.amount)
                        balanceAmountLabel.textColor = UIColor(netHex: 0xE20000)
                        balanceOrBalancePaidLabel.text = Strings.balance
                        balanceOrBalancePaidLabel.textColor = UIColor(netHex: 0xE20000)
                        balanceInfo.text = Strings.balance_amount_info
                    }
                }else if paymentStatus.type == OrderPayment.BOOKING && paymentStatus.status == OrderPayment.OPEN && !paymentStatus.paymentInProgress{
                    advance = paymentStatus.pending
                    payAdvanceButton.isHidden = false
                    adavanceAmountLabel.text = String(advance)
                    adavanceAmountLabel.textColor = UIColor(netHex: 0xE20000)
                    advanceTextLabel.text = Strings.advance_failed
                    advanceTextLabel.textColor = UIColor(netHex: 0xE20000)
                    adavanceInfo.text = Strings.booking_amount_refund_info
                    if productOrder?.paymentMode == RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE{
                        let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: (productOrder?.toTimeInMs ?? 0)/1000), date2: NSDate(timeIntervalSince1970: (productOrder?.fromTimeInMs ?? 0)/1000))
                        balanceView.isHidden = false
                        let totalAmount = (Int(productOrder?.pricePerDay ?? 0) * rentalDays) + (productOrder?.deposit ?? 0)
                        balanceAmountLabel.text = String(Double(totalAmount) - paymentStatus.amount)
                        balanceAmountLabel.textColor = UIColor(netHex: 0xE20000)
                        balanceOrBalancePaidLabel.text = Strings.balance
                        balanceOrBalancePaidLabel.textColor = UIColor(netHex: 0xE20000)
                        balanceInfo.text = Strings.balance_amount_info
                    }
                }else if paymentStatus.type == OrderPayment.DEPOSIT && paymentStatus.status == OrderPayment.COMPLETE{
                    deposite = paymentStatus.amount
                }else if paymentStatus.type == OrderPayment.RENT && (paymentStatus.status == OrderPayment.COMPLETE || paymentStatus.paymentInProgress){
                    if productOrder?.paymentMode == RequestProduct.PAY_FULL_AMOUNT{
                        advanceTextLabel.text = Strings.advance_paid
                        advanceTextLabel.textColor = .black
                        adavanceAmountLabel.text = String(deposite + paymentStatus.amount)
                        adavanceInfo.text = Strings.booking_amount_refund_info
                        balanceView.isHidden = true
                        totalView.isHidden = false
                        totalAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(deposite+paymentStatus.amount)])
                    }else{
                        balanceView.isHidden = false
                        balanceOrBalancePaidLabel.text = Strings.balance_paid
                        balanceOrBalancePaidLabel.textColor = .black
                        balanceAmountLabel.text = String(paymentStatus.amount + deposite)
                        balanceAmountLabel.textColor = .black
                        adavanceInfo.text = ""
                        balanceInfo.text = ""
                        totalView.isHidden = false
                        totalAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(advance+paymentStatus.amount+deposite)])
                    }
                }else if paymentStatus.type == OrderPayment.RENT && paymentStatus.status == OrderPayment.OPEN && !paymentStatus.paymentInProgress{
                    if productOrder?.paymentMode == RequestProduct.PAY_FULL_AMOUNT{
                        payAdvanceButton.isHidden = false
                        advanceTextLabel.text = Strings.pending_amount
                        advanceTextLabel.textColor = UIColor(netHex: 0xE20000)
                        adavanceAmountLabel.text = String(paymentStatus.pending)
                        adavanceInfo.text = Strings.booking_amount_refund_info
                        balanceInfo.text = Strings.balance_amount_info
                        balanceView.isHidden = true
                        totalView.isHidden = true
                    }else{
                        payBalanceButton.isHidden = false
                        balanceView.isHidden = false
                        balanceOrBalancePaidLabel.text = Strings.pending_amount
                        balanceOrBalancePaidLabel.textColor = .black
                        balanceAmountLabel.text = String(paymentStatus.pending)
                        balanceAmountLabel.textColor = .black
                        adavanceInfo.text = ""
                        balanceInfo.text = Strings.balance_amount_info
                        totalView.isHidden = true
                    }
                }
            }
        }
        showRefundViewIfAvailable(productOrder: productOrder,invoice: invoice)
    }
    
    private func showRefundViewIfAvailable(productOrder: ProductOrder?,invoice: ProductOrderInvoice){
        if productOrder?.status == Order.CLOSED{
            var initiatedDeposite = 0.0
            var initiatedReturnedRent = 0.0 // user paid for 7 days rent but retuned within 2 days so user will get rent back
            var refundedDeposite = 0.0
            var returnedRent = 0.0
            var advancePaid = 0.0
            var balancePaid = 0.0
            for invoiceItem in invoice.invoiceItems{
                if invoiceItem.type == OrderPayment.BOOKING && invoiceItem.operation == ProductOrderInvoice.DEBIT{
                    advancePaid = invoiceItem.amount
                }else if invoiceItem.type == OrderPayment.RENT && invoiceItem.operation == ProductOrderInvoice.DEBIT{
                    balancePaid += invoiceItem.amount
                }else if invoiceItem.type == OrderPayment.DEPOSIT && invoiceItem.operation == ProductOrderInvoice.DEBIT{
                    balancePaid += invoiceItem.amount
                }else if invoiceItem.type == OrderPayment.DEPOSIT && invoiceItem.status == OrderPayment.OPEN && invoiceItem.operation == ProductOrderInvoice.CREDIT{
                    initiatedDeposite = invoiceItem.amount
                } else if invoiceItem.type == OrderPayment.RENT && invoiceItem.operation == ProductOrderInvoice.CREDIT && invoiceItem.status == OrderPayment.OPEN && invoiceItem.userId == Int(UserDataCache.getInstance()?.userId ?? ""){
                    initiatedReturnedRent = invoiceItem.amount
                }else if invoiceItem.type == OrderPayment.DEPOSIT && invoiceItem.operation == ProductOrderInvoice.CREDIT && invoiceItem.status == OrderPayment.COMPLETE{
                    refundedDeposite = invoiceItem.amount
                }else if invoiceItem.type == OrderPayment.RENT && invoiceItem.operation == ProductOrderInvoice.CREDIT && invoiceItem.status == OrderPayment.COMPLETE && invoiceItem.userId == Int(UserDataCache.getInstance()?.userId ?? ""){
                    returnedRent = invoiceItem.amount
                }
            }
            showRefundedAmount(initiatedDeposite: initiatedDeposite, initiatedReturnedRent: initiatedReturnedRent, refundedDeposite: refundedDeposite, returnedRent: returnedRent, damageCharges: productOrder?.damageAmount ?? 0, deposite: productOrder?.deposit ?? 0)
            if productOrder?.paymentMode == RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE{
                advanceTextLabel.text = Strings.advance_paid
                advanceTextLabel.textColor = .black
                adavanceAmountLabel.text = String(advancePaid)
                adavanceAmountLabel.textColor = .black
                balanceView.isHidden = false
                balanceOrBalancePaidLabel.text = Strings.balance_paid
                balanceOrBalancePaidLabel.textColor = .black
                balanceAmountLabel.text = String(balancePaid)
                balanceAmountLabel.textColor = .black
                totalView.isHidden = false
                balanceAmountLabel.textColor = .black
                totalAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(advancePaid+balancePaid)])
            }else{
                balanceView.isHidden = true
                advanceTextLabel.text = Strings.advance_paid
                advanceTextLabel.textColor = .black
                adavanceAmountLabel.text = String(balancePaid)
                adavanceAmountLabel.textColor = .black
                totalView.isHidden = false
                totalAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(advancePaid+balancePaid)])
            }
        }else{
            refundView.isHidden = true
        }
    }
    
    private func showRefundedAmount(initiatedDeposite: Double,initiatedReturnedRent: Double,refundedDeposite: Double,returnedRent: Double,damageCharges: Double,deposite: Int){
        if refundedDeposite != 0{
            refundOrRefundCompletedLabel.text = Strings.refunded
            refundView.isHidden = false
            refundAmountLabel.text = String(refundedDeposite+returnedRent)
            refundInitiatedView.isHidden = true
            refundSubTextLabel.text = ""
            refundingTypesLabel.text = String(format: Strings.deposite_and_extra_rent_paid, arguments: [String(deposite)])
            if returnedRent != 0{
                refundingTypesLabel.text = (refundingTypesLabel.text ?? "") + " + Extra paid rent(₹\(String(returnedRent)))"
            }
            if damageCharges != 0.0{
                refundingTypesLabel.text = (refundingTypesLabel.text ?? "") + " - Damage charges(₹\(damageCharges))"
            }
        }else if initiatedDeposite != 0{
            refundOrRefundCompletedLabel.text = Strings.refund
            refundView.isHidden = false
            refundInitiatedView.isHidden = false
            refundAmountLabel.text = String(initiatedDeposite+initiatedReturnedRent)
            refundSubTextLabel.attributedText = ViewCustomizationUtils.getAttributedString(string: Strings.security_deposite_refund, rangeofString: "support@quickmarket.in", textColor: UIColor.init(netHex: 0x007AFF), textSize: 12)
            refundSubTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMail(_:))))
            refundingTypesLabel.text = String(format: Strings.deposite_and_extra_rent_paid, arguments: [String(deposite)])
            if initiatedReturnedRent != 0{
                refundingTypesLabel.text = (refundingTypesLabel.text ?? "") + " + Extra paid rent(₹\(String(returnedRent)))"
            }
            if damageCharges != 0.0{
                refundingTypesLabel.text = (refundingTypesLabel.text ?? "") + " - Damage charges(₹\(damageCharges))"
            }
        }else{
            refundView.isHidden = true
        }
    }
    
    @objc func openMail(_ sender :UITapGestureRecognizer){
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: parentViewController ?? UIViewController(), subject: Strings.sub_for_supportmail_from , toRecipients: [AppConfiguration.support_email],ccRecipients: [],mailBody: "")
    }
    
    @IBAction func payAdvanceTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .showPendingAmount, object: nil)
    }
    
    @IBAction func payBalanceTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .showPendingAmount, object: nil)
    }
    
}
extension OrderRentPaymentDetailsTableViewCell: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
