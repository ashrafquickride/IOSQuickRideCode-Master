//
//  RentInvoiceTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 27/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentInvoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var totalRentLabel: UILabel!
    @IBOutlet weak var extraRentView: UIView!
    @IBOutlet weak var extraRentLabel: UILabel!
    @IBOutlet weak var damageView: UIView!
    @IBOutlet weak var damageChargeLabel: UILabel!
    @IBOutlet weak var serviceFeeLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    func initailisePaymnetDetails(productOrder: ProductOrder?,productOrderInvoice: ProductOrderInvoice){
        let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: (productOrder?.toTimeInMs ?? 0)/1000), date2: NSDate(timeIntervalSince1970: (productOrder?.fromTimeInMs ?? 0)/1000))
        let total = Int(productOrder?.pricePerDay ?? 0) * rentalDays
        var rent = 0.0
        var serviceFee = 0.0
        var gst = 0.0
        var damageAmount = 0.0
        for orderInvoice in productOrderInvoice.invoiceItems{
            if orderInvoice.operation == ProductOrderInvoice.CREDIT && orderInvoice.type == OrderPayment.DAMAGE{
                damageView.isHidden = false
                damageChargeLabel.text = String(orderInvoice.amount)
                damageAmount = orderInvoice.amount
            }else if orderInvoice.operation == ProductOrderInvoice.CREDIT && orderInvoice.type == OrderPayment.SERVICE_FEE{
                serviceFee += orderInvoice.amount
            }else if orderInvoice.operation == ProductOrderInvoice.CREDIT && orderInvoice.type == OrderPayment.TAX{
                gst += orderInvoice.amount
            }else if orderInvoice.operation == ProductOrderInvoice.CREDIT && orderInvoice.type == OrderPayment.RENT && orderInvoice.userId == Int(UserDataCache.getInstance()?.userId ?? ""){
                rent += orderInvoice.amount
            }
        }
        var serviceFeeAndGst = serviceFee+gst
        totalAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(rent.roundToPlaces(places: 2) + damageAmount.roundToPlaces(places: 2))])
        var extraRent = rent - (Double(total) - serviceFeeAndGst)
        serviceFeeLabel.text = "- " + String(serviceFee)
        taxLabel.text = "- " + String(gst)
        if extraRent > 0{
            extraRentView.isHidden = false
            extraRentLabel.text = String(extraRent.roundToPlaces(places: 2))
            totalRentLabel.text = String(total)
        }else{
            extraRentView.isHidden = true
            totalRentLabel.text = String(rent.roundToPlaces(places: 2) + serviceFeeAndGst.roundToPlaces(places: 2))
        }
    }
}
