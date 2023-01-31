//
//  DriverDetailsAndFareBrekupTableViewCell.swift
//  Quickride
//
//  Created by HK on 27/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class DriverDetailsAndFareBrekupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var carModelLabel: UILabel!
    @IBOutlet weak var savedAmountLabel: UILabel!
    @IBOutlet weak var walletsLabel: UILabel!
    
    //MARK: Variables
    var taxiTripReportViewModel = TaxiTripReportViewModel()
    private var taxiRideInvoice: TaxiRideInvoice?
    private var estimateFareData = [fareDetailsOutStatioonTaxi]()
    var isCellTapped: isCellTapped?
    
    func initialiseDriverDetails(taxiRideInvoice: TaxiRideInvoice?,taxiTripReportViewModel: TaxiTripReportViewModel, isCellTapped: @escaping isCellTapped) {
        self.taxiRideInvoice = taxiRideInvoice
        self.taxiTripReportViewModel = taxiTripReportViewModel
        self.isCellTapped = isCellTapped
        let totalAmount = (taxiRideInvoice?.amount ?? 0) - (taxiRideInvoice?.couponDiscount ?? 0)
        amountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(totalAmount)])
        driverNameLabel.text = taxiRideInvoice?.toUserName?.capitalized ?? ""
        if taxiRideInvoice?.vehicleClass != TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            carModelLabel.text = "Sharing," + (taxiRideInvoice?.vehicleModel?.capitalized ?? "")
        }else{
            carModelLabel.text = (taxiRideInvoice?.vehicleClass ?? "") + "," + (taxiRideInvoice?.vehicleModel?.capitalized ?? "")
        }
       
        ImageCache.getInstance().setImageToView(imageView: driverImage, imageUrl:  taxiRideInvoice?.driverImageURI ?? "", placeHolderImg: UIImage(named: "default_taxi_driver"),imageSize: ImageCache.DIMENTION_SMALL)
        if let paymentType = taxiTripReportViewModel.taxiRide?.paymentType,!paymentType.isEmpty{
            let wallets = paymentType.replacingOccurrences(of: AccountTransaction.TRANSACTION_WALLET_TYPE_INAPP, with: Strings.quickride_wallet, options: .literal, range: nil)
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
    @IBAction func fareBreakupTapped(_ sender: Any) {
        isCellTapped?(true)
    }
    
    
}

