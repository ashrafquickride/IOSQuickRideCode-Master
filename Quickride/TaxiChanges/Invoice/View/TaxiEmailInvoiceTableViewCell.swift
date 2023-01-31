//
//  TaxiEmailInvoiceTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/10/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias isInvoiceClicked = (_ showInvoiceView : Bool) -> Void

class TaxiEmailInvoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var paidWalletLabel: UILabel!
  
    var isInvoiceClicked: isInvoiceClicked?
    
    func initialiseDriverDetails(paymentType: String?, isInvoiceClicked: @escaping isInvoiceClicked){
        
        self.isInvoiceClicked = isInvoiceClicked
        if let paymentType = paymentType,!paymentType.isEmpty{
            let wallets = paymentType.replacingOccurrences(of: AccountTransaction.TRANSACTION_WALLET_TYPE_INAPP, with: Strings.quickride_wallet, options: .literal, range: nil)
            paidWalletLabel.text = String(format: Strings.bill_paid_through_taxipool, arguments: [wallets])
        }
    }
    
    @IBAction func emailInvoiceTapped(_ sender: Any) {
        isInvoiceClicked?(true)
    }
    
}
