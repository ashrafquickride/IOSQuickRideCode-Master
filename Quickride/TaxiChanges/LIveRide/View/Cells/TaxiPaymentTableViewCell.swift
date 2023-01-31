//
//  TaxiPaymentTableViewCell.swift
//  Quickride
//
//  Created by HK on 26/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import Lottie

class TaxiPaymentTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var taxiFareLabel: UILabel!
    @IBOutlet weak var fareToBePaidOrPaidLabel: UILabel!
    @IBOutlet weak var extraPickupFeeView: UIView!
    @IBOutlet weak var extraPickUpFeeAmountLabel: UILabel!
    @IBOutlet weak var couponCodeLabel: UILabel!
    @IBOutlet weak var paymentModelabel: UILabel!
    @IBOutlet weak var offerAndExtraChargesShowingView: UIView!
    
    private var tabData = [Strings.inclusions,Strings.exclusions,Strings.facilities]
    var outstationTaxiFareDetails: PassengerFareBreakUp?
    var paymentMode: String?
    var isCellTapped: isCellTapped?
    
    func initialisePaymentCard(outstationTaxiFareDetails: PassengerFareBreakUp?, paymentMode: String?, isCellTapped: @escaping isCellTapped){
        self.isCellTapped = isCellTapped
        self.paymentMode = paymentMode
        self.outstationTaxiFareDetails = outstationTaxiFareDetails
        if paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH {
            paymentModelabel.text = Strings.payment_type_cash
        } else {
            paymentModelabel.text = Strings.payment_type_online
        }
        if let outstationTaxiFareDetails  = outstationTaxiFareDetails,outstationTaxiFareDetails.couponBenefit != 0{
            let discountedFare = (outstationTaxiFareDetails.initialFare ) - (outstationTaxiFareDetails.couponBenefit)
            taxiFareLabel.attributedText = FareChangeUtils.getFareChangeWithStrikeOffOldFare(newFare: "₹\(discountedFare)", actualFare: "₹\(outstationTaxiFareDetails.initialFare )", textColor: .systemBlue,textSize: 16)

        }else{
            taxiFareLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: outstationTaxiFareDetails?.initialFare)])
        }
        offerAndExtraChargesShowingView.isHidden = true
        if let extraPickUpCharges = outstationTaxiFareDetails?.extraPickUpCharges, extraPickUpCharges != 0.0{
            offerAndExtraChargesShowingView.isHidden = false
            extraPickupFeeView.isHidden = false
            extraPickUpFeeAmountLabel.text = "+ ₹\(outstationTaxiFareDetails?.extraPickUpCharges ?? 0) Pickup Fee"
        }else {
            extraPickupFeeView.isHidden = true
        }
        if let couponCode = outstationTaxiFareDetails?.couponCode {
            offerAndExtraChargesShowingView.isHidden = false
            couponCodeLabel.text = "\(couponCode) Applied. " + String(format: Strings.saved_amount, arguments: [StringUtils.getStringFromDouble(decimalNumber: outstationTaxiFareDetails?.couponBenefit)])
        }
    }
    
    @IBAction func extraPickupFeeInfoTapped(_ sender: Any) {
            MessageDisplay.displayInfoViewAlert(title: Strings.extra_pickup_fare, titleColor: nil, message: Strings.extra_pickup_fare_info, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
            }
    }
    
    @IBAction func showFareBreakUpButtonTapped(_ sender: Any) {
        isCellTapped!(true)
      
    }
}
