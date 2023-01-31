//
//  RedemptionsTableViewCell.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 30/08/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import Foundation

class RedemptionsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var redemptionDescription: UILabel!
    @IBOutlet weak var redeemPoints: UILabel!
    @IBOutlet weak var redeemStatusImage: UIImageView!
    @IBOutlet weak var processedOnLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    
    func intialisingData(redemptionDetails: RedemptionRequest){
    
        guard let status = redemptionDetails.status, let redemptionType = redemptionDetails.type else {
            return
        }
        
        redeemPoints.text = StringUtils.getPointsInDecimal(points: redemptionDetails.amount ?? 0)
        
        let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: redemptionDetails.requestedTime, timeFormat: DateUtils.DATE_FORMAT_D_MMM_YYYY_h_mm_a)
        dateLabel.text = String(format: Strings.at_caps, date!)
        
        if redemptionType == RedemptionRequest.REDEMPTION_TYPE_PAYTM {
            redeemStatusImage.image = UIImage(named: "paytm_new")
        } else if redemptionType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL {
            redeemStatusImage.image = UIImage(named: "paytm_fuel_Icon_new")
        } else if redemptionType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY {
            redeemStatusImage.image = UIImage(named: "amazonpay_giftcard_icon_with_border")
        }else if redemptionType == RedemptionRequest.REDEMPTION_TYPE_HP_PAY || redemptionType == RedemptionRequest.REDEMPTION_TYPE_HP_CARD {
            redeemStatusImage.image = UIImage(named: "hp_icon_with_border")
        }else if redemptionType == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
            redeemStatusImage.image = UIImage(named: "Bank_Transfer_Icon")
        }else if redemptionType == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD{
            redeemStatusImage.image = UIImage(named: "shell_icon_with_border")
        }else if redemptionType == RedemptionRequest.REDEMPTION_TYPE_IOCL{
            redeemStatusImage.image = UIImage(named: "IOCL_Icon_new")
        }else{
            redeemStatusImage.image = nil
        }
        redeemPoints.textColor = UIColor.black.withAlphaComponent(0.8)
        dateLabel.textColor = UIColor(netHex: 0x000000)
        redemptionDescription.textColor = UIColor(netHex: 0x000000)
        pointsLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        processedOnLabel.isHidden = true
        
        
        if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_PROCESSED {
            if redemptionType == RedemptionRequest.REDEMPTION_TYPE_PAYTM || redemptionType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL || redemptionType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY || redemptionType == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD || redemptionType == RedemptionRequest.REDEMPTION_TYPE_HP_PAY || redemptionType == RedemptionRequest.REDEMPTION_TYPE_HP_CARD ||  redemptionType == RedemptionRequest.REDEMPTION_TYPE_IOCL {
                redemptionDescription.text = String(format: Strings.redemption_by_wallet, setRedemptionType(redemptionType: redemptionType))
            } else if redemptionType == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER {
                redemptionDescription.text = Strings.redemption_to_bank

            } else {
                redemptionDescription.text = String(format: Strings.redemption_by_card, redemptionType)
            }
            if let processedTime = redemptionDetails.processedTime {
                processedOnLabel.isHidden = false
                processedOnLabel.text = String(format: Strings.processed_on, DateUtils.getTimeStringFromTimeInMillis(timeStamp: processedTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yy)!)
            }
        } else if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_REVIEW {
            redeemPoints.textColor = UIColor(netHex: 0xE85D01)
            pointsLabel.textColor = UIColor(netHex: 0xE85D01)
            dateLabel.textColor = UIColor(netHex: 0xE85D01)
            redemptionDescription.textColor = UIColor(netHex: 0xE85D01)
            redemptionDescription.text = Strings.redemption_under_review
        } else if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_FAILED {
            redemptionDescription.text = Strings.redemption_failed
        } else if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_UNKNOWN {
            redemptionDescription.text = Strings.redemption_failed
            processedOnLabel.isHidden = false
            processedOnLabel.text = Strings.redemption_cancelled_description_with_reason
        } else if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_CANCELLED {
            redeemPoints.textColor = UIColor(netHex: 0xCC0000)
            pointsLabel.textColor = UIColor(netHex: 0xCC0000)
            dateLabel.textColor = UIColor(netHex: 0xCC0000)
            redemptionDescription.textColor = UIColor(netHex: 0xCC0000)
            redemptionDescription.text = Strings.redemption_cancelled
            processedOnLabel.isHidden = false
            processedOnLabel.text = Strings.redemption_points
        } else if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_REJECTED {
            redemptionDescription.text = Strings.redemption_rejected
        } else if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_PENDING {
            redemptionDescription.text = Strings.redemption_under_pending
        } else if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_INITIATED || status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_OPEN  {
            redemptionDescription.text = Strings.redemption_intiated
        }else if status == RedemptionRequest.REDEMPTION_REQUEST_STATUS_APPROVED {
            redemptionDescription.text = String(format: Strings.redemption_by_wallet, setRedemptionType(redemptionType: redemptionType))
        }
    }
    
    func setRedemptionType(redemptionType: String) -> String {
            switch redemptionType {
            case RedemptionRequest.REDEMPTION_TYPE_PAYTM:
                return Strings.paytm_wallet
            case RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL:
                return Strings.paytm_fuel_wallet
            case RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY:
                return Strings.amazon_Wallet
            case RedemptionRequest.REDEMPTION_TYPE_HP_PAY:
                return Strings.hp_pay
            case RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER:
                return Strings.bank_account
            case RedemptionRequest.REDEMPTION_TYPE_IOCL:
                return Strings.iocl_pay
            case RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD:
                return Strings.shell
            case RedemptionRequest.REDEMPTION_TYPE_HP_CARD:
                return Strings.hp
            default:
                return ""
            }
        }
    
}








