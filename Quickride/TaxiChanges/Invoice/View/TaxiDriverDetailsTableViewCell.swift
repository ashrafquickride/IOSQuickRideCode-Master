//
//  TaxiDriverDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 05/02/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiDriverDetailsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var usersImage: UIImageView!
    @IBOutlet weak var viewFareBreakUpBtn: UIButton!
    @IBOutlet weak var invoiceIdLabel: UILabel!
    @IBOutlet weak var totalFareLabel: UILabel!
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    @IBOutlet weak var savedAmountLabel: UILabel!
    @IBOutlet weak var walletsLabel: UILabel!
    
    //MARK: Variables
    private var taxiRideInvoice: TaxiRideInvoice?
    private var estimateFareData = [fareDetailsOutStatioonTaxi]()
    var taxiBillViewModel = TaxiBillViewModel()
    var isCellTapped: isCellTapped?
    
    func initialiseDriverDetails(isExpandable: Bool,taxiRideInvoice: TaxiRideInvoice?, isCellTapped: @escaping isCellTapped) {
        self.taxiRideInvoice = taxiRideInvoice
        self.isCellTapped = isCellTapped
        if let taxiRideInvoice = taxiRideInvoice {
            ImageCache.getInstance().setImageToView(imageView: usersImage, imageUrl:  taxiRideInvoice.driverImageURI ?? "", placeHolderImg: UIImage(named: "default_taxi_driver"),imageSize: ImageCache.DIMENTION_SMALL)
            totalFareLabel.isHidden = false
            let totalPaid = (taxiRideInvoice.amount ?? 0) - (taxiRideInvoice.couponDiscount)
            totalFareLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(totalPaid)])
            userNameLabel.text = taxiRideInvoice.toUserName?.capitalized ?? ""
            vehicleNumberLabel.text = (taxiRideInvoice.vehicleClass ?? "") + "," + (taxiRideInvoice.vehicleModel?.capitalized ?? "")
            invoiceIdLabel.text = String(format: Strings.invoice_number, StringUtils.getStringFromDouble(decimalNumber: taxiRideInvoice.id))
        }
        if let paymentType = taxiBillViewModel.taxiRide?.paymentType,!paymentType.isEmpty{
            let wallets = paymentType.replacingOccurrences(of: AccountTransaction.TRANSACTION_WALLET_TYPE_INAPP, with: Strings.quickride_wallet, options: .literal, range: nil)
            walletsLabel.isHidden = false
            walletsLabel.text = String(format: Strings.bill_paid_through_taxipool, arguments: [wallets]).uppercased()
        }else{
            walletsLabel.isHidden = true
        }
        if taxiRideInvoice?.couponDiscount != 0{
            let amount = StringUtils.getStringFromDouble(decimalNumber: taxiRideInvoice?.couponDiscount)
            savedAmountLabel.text = String(format: Strings.saved_amount, arguments: [amount])
            savedAmountLabel.isHidden = false
        }else{
            savedAmountLabel.isHidden = true
        }
    }
    
    
    @IBAction func viewFareBreakUpTapped(_ sender: UIButton) {
        isCellTapped?(true)
    }
}
