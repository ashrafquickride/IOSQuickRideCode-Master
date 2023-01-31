//
//  SellingInvoiceTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 27/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SellingInvoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sellingPriceLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    func initailisePaymnetDetails(productOrder: ProductOrder?,productOrderInvoice: ProductOrderInvoice){
        sellingPriceLabel.text = String(productOrder?.finalPrice ?? 0)
        for orderInvoice in productOrderInvoice.invoiceItems{
            if orderInvoice.operation == ProductOrderInvoice.CREDIT && orderInvoice.type == OrderPayment.FINAL{
                totalLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(orderInvoice.amount)])
            }else if orderInvoice.operation == ProductOrderInvoice.CREDIT && orderInvoice.type == OrderPayment.SERVICE_FEE{
                servicePriceLabel.text = "- " + String(orderInvoice.amount)
            }else if orderInvoice.operation == ProductOrderInvoice.CREDIT && orderInvoice.type == OrderPayment.TAX{
                taxLabel.text = "- " + String(orderInvoice.amount)
            }
        }
    }
}
