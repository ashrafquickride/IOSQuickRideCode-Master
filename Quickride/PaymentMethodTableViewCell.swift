//
//  PaymentMethodTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 18/12/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {
    @IBOutlet weak var paymentMethodImage: UIImageView!
    @IBOutlet weak var paymentMethodTypeLabel: UILabel!
    @IBOutlet weak var paymentNamesSubtitleLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var defaultLabel: UILabel!
    
    func initialiseData(paymentTypeInfo: PaymentTypeInfo, arrowImage: UIImage, showDefaultLabel: Bool){
        self.paymentMethodImage.image = paymentTypeInfo.paymentTypeImage
        self.paymentMethodTypeLabel.text = paymentTypeInfo.paymentType
        
        if paymentTypeInfo.paymentType != Strings.pay_By_Other_Modes, paymentTypeInfo.paymentType != Strings.payment_type_cash {
            self.paymentNamesSubtitleLabel.isHidden = false
            self.paymentNamesSubtitleLabel.text = paymentTypeInfo.paymentNamesList
            self.arrowImage.transform = (imageView?.transform.rotated(by: .pi * 0.5))!
        }else if paymentTypeInfo.paymentType == Strings.pay_By_Other_Modes  {
            self.paymentNamesSubtitleLabel.isHidden = false
            self.arrowImage.transform = (imageView?.transform.rotated(by: 0))!
            self.paymentNamesSubtitleLabel.text = paymentTypeInfo.paymentNamesList
        }else {
            self.paymentNamesSubtitleLabel.isHidden = true
            self.arrowImage.transform = (imageView?.transform.rotated(by: 0))!
        }
        self.arrowImage.image = arrowImage
        if showDefaultLabel, paymentTypeInfo.paymentType.uppercased() == TaxiRidePassenger.PAYMENT_MODE_CASH {
            defaultLabel.isHidden = false
        } else {
            defaultLabel.isHidden = true
        }
    }
}
struct PaymentTypeInfo {
    var paymentTypeImage: UIImage
    var paymentType: String
    var paymentNamesList: String
    
    init(paymentTypeImage: UIImage, paymentType: String, paymentNamesList: String){
        self.paymentTypeImage = paymentTypeImage
        self.paymentType = paymentType
        self.paymentNamesList = paymentNamesList
    }
}
