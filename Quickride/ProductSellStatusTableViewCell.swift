//
//  ProductSellStatusTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class ProductSellStatusTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title1InfoLabel: UILabel!
    @IBOutlet weak var status1ImageView: UIImageView!
    @IBOutlet weak var requestedDateLabel: UILabel!
    
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title2InfoLabel: UILabel!
    @IBOutlet weak var status2ImageView: UIImageView!
    @IBOutlet weak var acceptedDateLabel: UILabel!
    
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var title3InfoLabel: UILabel!
    @IBOutlet weak var status3ImageView: UIImageView!
    @IBOutlet weak var payButton: QRCustomButton!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var collectedDateLabel: UILabel!
    
    private var productOrder: ProductOrder?
    func initailseOrderStatusForSell(productOrder: ProductOrder?,postedProduct: PostedProduct?){
        self.productOrder = productOrder
        if productOrder?.paymentMode == RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE{
            title3InfoLabel.text = Strings.pay_pending_get_otp_to_share
        }else{
            title3InfoLabel.text = Strings.get_otp_to_share
        }
        requestedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.creationDateInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        acceptedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.acceptedTimeInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        collectedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.handOverTimeInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        switch productOrder?.status {
        case Order.PLACED:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
        case Order.ACCEPTED:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            title1InfoLabel.text = ""
            payButton.isHidden = false
            if productOrder?.remainingAmount != 0.0{
                payButton.setTitle(String(format: Strings.pay_amount, arguments: [String(productOrder?.remainingAmount ?? 0)]), for: .normal)
            }
            otpView.isHidden = true
        case Order.PICKUP_IN_PROGRESS:
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            if productOrder?.pickUpOtp?.isEmpty == false{
                otpView.isHidden = false
                otpLabel.text = String(format: Strings.pickUp_otp, arguments: [(productOrder?.pickUpOtp ?? "")])
                payButton.isHidden = true
                otpView.drawDashedLineArroundView(view: otpView, color: UIColor.black)
            }else{
                otpView.isHidden = true
                payButton.isHidden = false
            }
        case Order.PICKUP_COMPETE:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            status3ImageView.isHidden = false
            title3Label.textColor = Colors.green
            otpView.isHidden = true
            payButton.isHidden = true
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
        case Order.CLOSED:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            status3ImageView.isHidden = false
            title3Label.textColor = Colors.green
            otpView.isHidden = true
            payButton.isHidden = true
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            title3InfoLabel.text = ""
        default:
            break
        }
    }
    
    @IBAction func payButtonTapped(_ sender: Any) {
       payRemainingBalance()
    }
    private func payRemainingBalance(){
        QuickShareSpinner.start()
        QuickShareRestClient.getPickUpOtp(orderId: productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let productOtpResponse = Mapper<ProductOtpResponse>().map(JSONObject: responseObject!["resultData"])
                var userInfo = [String : String]()
                userInfo["pickupOtp"] = productOtpResponse?.otp
                NotificationCenter.default.post(name: .pickupOtpReceived, object: nil, userInfo: userInfo)
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                QuickShareSpinner.stop()
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if responseError?.errorCode == RideValidationUtils.INSUFFICIENT_BALANCE_FOR_BUY_OR_RENT
                    || responseError?.errorCode == RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE{
                    RideValidationUtils.handleBalanceInsufficientError(viewController:  self.parentViewController, title: Strings.low_bal_in_account, errorMessage: Strings.add_money_for_product, primaryAction: "", secondaryAction: nil, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.payRemainingBalance()
                    })
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
}
