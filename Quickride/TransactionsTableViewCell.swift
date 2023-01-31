//
//  TransactionsTableViewCell.swift
//  PlacesLookup
//
//  Created by Swagat Kumar Bisoyi on 10/25/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {

  @IBOutlet weak var lblID: UILabel!
  @IBOutlet weak var lblDetail: UILabel!
  @IBOutlet weak var lblPoints: UILabel!
  @IBOutlet weak var lblTime: UILabel!
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var transationIconImageView: CircularImageView!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var coTransactionUserImage: UIImageView!
  @IBOutlet weak var nameHeightCon: NSLayoutConstraint!
  @IBOutlet weak var balenceRewardPointsLbl: UILabel!
  @IBOutlet weak var seperatorView: UIView!

    private var accountTransaction: AccountTransaction?

    func initializeCellData(accountTransaction: AccountTransaction){
        self.accountTransaction = accountTransaction
        setTransactionDateAndTime()
        setTransactionTypeImage()
        setCotransactionUserImage()
    }

    private func setTransactionDateAndTime(){
       guard let accountTransaction = accountTransaction, let points = accountTransaction.value, let date = accountTransaction.date else { return }
        balanceLabel.text = "Balance: " + StringUtils.getPointsInDecimal(points: accountTransaction.balance)
        if accountTransaction.transactiontype! == Account.DEBIT{
            lblPoints.textColor = .black
            lblPoints.text = "- " + StringUtils.getPointsInDecimal(points: points) + "Pts"
        }else{
            lblPoints.textColor = UIColor(netHex: 0x00B557)
            lblPoints.text = StringUtils.getPointsInDecimal(points: points) + "Pts"
        }

        lblTime.text =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: date, timeFormat: DateUtils.DATE_FORMAT_D_MMM_YYYY_h_mm_a)

        lblDetail.text = accountTransaction.desc
        lblID.text = Strings.id + String(accountTransaction.transactionId!).components(separatedBy:  ".")[0]

        if AccountTransaction.ACCOUNT_TRANSACTION_TYPE_CREDIT == accountTransaction.transactiontype && AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_EARNED == accountTransaction.sourceType  || AccountTransaction.ACCOUNT_TRANSACTION_TYPE_DEBIT == accountTransaction.transactiontype && AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_SPENT == accountTransaction.sourceType {
            lblDetail.textColor = UIColor(netHex: 0x007AFF)
            
        }
        if accountTransaction.userName != nil {
            nameHeightCon.constant = 20
            userName.text = accountTransaction.userName
        }else if AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_REFUND_CREDIT_EXTERNAL_WALLET == accountTransaction.sourceType {
            userName.text = "Refund Processed"
            nameHeightCon.constant = 20
        }else{
            nameHeightCon.constant = 0
        }
    }


    private func setTransactionTypeImage(){
        guard let accountTransaction = accountTransaction else { return }
        switch accountTransaction.txnWallet {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_INAPP:
            transationIconImageView.image = UIImage(named : "app_icon_small")
            balanceLabel.isHidden = false
        case  AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            transationIconImageView.image = UIImage(named : "paytm_logo")
            balanceLabel.isHidden = true
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            transationIconImageView.image = UIImage(named: "simpl_logo_with_text")
            balanceLabel.isHidden = true
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            transationIconImageView.image = UIImage(named: "lazypay_logo_with_text")
            balanceLabel.isHidden = true
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            transationIconImageView.image = UIImage(named: "amazon_pay")
            balanceLabel.isHidden = true
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            transationIconImageView.image = UIImage(named: "mobikwik_logo_with_text")
            balanceLabel.isHidden = true
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            transationIconImageView.image = UIImage(named : "tmw")
            balanceLabel.isHidden = true
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI,AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE,AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_ANDROID,AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_PHONEPE_ANDROID:
            transationIconImageView.image = UIImage(named : "UPI_Image")
            balanceLabel.isHidden = true
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            transationIconImageView.image = UIImage(named: "frecharge_with_text")
            balanceLabel.isHidden = true
        default:
            transationIconImageView.isHidden = true
            balanceLabel.isHidden = true
        }
    }

    private func setCotransactionUserImage(){
        if let gender = accountTransaction?.gender{
            ImageCache.getInstance().setImageToView(imageView: coTransactionUserImage, imageUrl: accountTransaction?.imageURI, gender: gender,imageSize: ImageCache.DIMENTION_TINY)
        } else if accountTransaction?.sourceApp == AccountTransaction.SOURCE_APP_TYPE_CARPOOL {
            coTransactionUserImage.image = UIImage(named: "carpool_backgrond_green_icon")
        } else if accountTransaction?.sourceApp == AccountTransaction.SOURCE_APP_TYPE_TAXIPOOL {
            coTransactionUserImage.image = UIImage(named: "taxipool_backgroung_yellow_icon")
        } else {
            coTransactionUserImage.image = UIImage(named: "my_payments_icon")
        }
    }
}
