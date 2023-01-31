//
//  TaxiFarePaidTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 21/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit


typealias handlingRidePaymentDetails = (_ isFareTapped : Bool) -> Void

class TaxiFarePaidTableViewCell: UITableViewCell {

    
    @IBOutlet weak var paidByWallet: UILabel!
    @IBOutlet weak var taxiFareBtn: UIButton!
    @IBOutlet weak var paymentDetailsStackView: UIStackView!
    var handler: handlingRidePaymentDetails?
  
    
    
    func showOnlinePaymentDetail(taxiRidePaymentDetail: TaxiRidePaymentDetails?, isRequiredToShowDate: Bool, handler: handlingRidePaymentDetails?){
       self.handler = handler
        if taxiRidePaymentDetail?.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI || taxiRidePaymentDetail?.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE{
            paidByWallet.text = "By UPI - \(taxiRidePaymentDetail?.walletInfo ?? "")" + "|" + (DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(taxiRidePaymentDetail?.txnUpdatedTimeMs ?? 0), timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A) ?? "")
        }else if taxiRidePaymentDetail?.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_INAPP{
            paidByWallet.text = "By Quick Ride Wallet" + "|" + (DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(taxiRidePaymentDetail?.txnUpdatedTimeMs ?? 0), timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A) ?? "")
        }else{
            paidByWallet.text = "By \(taxiRidePaymentDetail?.walletType ?? "")" + "|" + (DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(taxiRidePaymentDetail?.txnUpdatedTimeMs ?? 0), timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A) ?? "")
        }
        
        let amount = "-" + String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiRidePaymentDetail?.amount)])
        taxiFareBtn.setTitle(amount, for: .normal)
        paymentDetailsStackView.isHidden = !isRequiredToShowDate
    }
    
    @IBAction func taxiFareBtnTapped(_ sender: Any) {
        handler?(true)
    }
    
    
}
