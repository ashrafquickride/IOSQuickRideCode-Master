//
//  NextStepTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 9/23/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class NextStepTableViewCell: UITableViewCell {
    @IBOutlet weak var fullSeparatorView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var circularImageView: CircularImageView!
    @IBOutlet weak var nextStepLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(taxiRidePassengerDetails: TaxiRidePassengerDetails?, index: Int,headerString: String, subTitle: String) {
        priceLabel.isHidden = true
        titleLabel.text = headerString
        indexLabel.text = "\(index+1)"
        setStatusToView(taxiRidePassengerDetails: taxiRidePassengerDetails, index: index)
        if taxiRidePassengerDetails?.taxiRideGroup?.shareType == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            if index == 0{
                setExclusivePickUpAndPriceLabel(taxiRidePassengerDetails: taxiRidePassengerDetails)
            }else{
                subTitleLabel.text = subTitle
            }
        }else{
            titleLabel.text = headerString
            switch index {
            case 0:
                setSharingAndPrice(taxiRidePassengerDetails: taxiRidePassengerDetails)
            case 1:
                setNumberOfseatData(taxiRidePassengerDetails: taxiRidePassengerDetails)
            default:
                subTitleLabel.text = subTitle
            }
        }
    }
    
    private func setExclusivePickUpAndPriceLabel(taxiRidePassengerDetails: TaxiRidePassengerDetails?) {
        priceLabel.isHidden = false
        priceLabel.text = "₹\(Int(taxiRidePassengerDetails?.taxiRidePassenger?.initialFare ?? 0))"
        subTitleLabel.text = String(format: Strings.driver_details_will_share_at, arguments: [DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassengerDetails?.taxiRidePassenger?.pickupTimeMs, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!])
    }
    
    private func setNumberOfseatData(taxiRidePassengerDetails: TaxiRidePassengerDetails?) {
        subTitleLabel.text = String(format: Strings.seat_fills, arguments: ["1"])
    }
    
    private func setSharingAndPrice(taxiRidePassengerDetails: TaxiRidePassengerDetails?) {
        subTitleLabel.text =  Strings.sharing + ", ₹\(Int(taxiRidePassengerDetails?.taxiRidePassenger?.initialFare ?? 0))"
    }
    
    private func setStatusToView(taxiRidePassengerDetails: TaxiRidePassengerDetails?,index: Int) {
        let status = getTaxiStatus(taxiRidePassengerDetails: taxiRidePassengerDetails!)
        updateStatusAndUI(index: index, status: status)
        if taxiRidePassengerDetails?.taxiRideGroup?.shareType == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            if index == 2{
                fullSeparatorView.isHidden = true
                topSeparatorView.isHidden = false
            }else{
                if index == 0{
                    topSeparatorView.isHidden = true
                }else{
                    topSeparatorView.isHidden = false
                }
                fullSeparatorView.isHidden = false
            }
        }else{
            if index == 3{
                fullSeparatorView.isHidden = true
                topSeparatorView.isHidden = false
            }else{
                if index == 0{
                    topSeparatorView.isHidden = true
                }else{
                    topSeparatorView.isHidden = false
                }
                fullSeparatorView.isHidden = false
            }
        }
    }
    
    private func updateStatusAndUI(index: Int,status: Int) {
        nextStepLabel.isHidden = true
        if index <= status {
            setImage(status: true, isbackGrooundGreen: true)
            titleLabel.textColor = .black
            subTitleLabel.textColor = .black
            if index == status{
                nextStepLabel.isHidden = false
                setImage(status: false, isbackGrooundGreen: true)
            }
        }else{
            setImage(status: false, isbackGrooundGreen: false)
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            subTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    private func setImage(status: Bool,isbackGrooundGreen: Bool) {
        if status {
            circularImageView.image = UIImage(named: "gray_tick")
            indexLabel.isHidden = true
        }else{
            indexLabel.isHidden = false
            circularImageView.image = nil
            if isbackGrooundGreen {
                circularImageView.backgroundColor = UIColor(netHex: 0x00B557)
            }else{
                circularImageView.backgroundColor = UIColor(netHex: 0xD0D0D0)
            }
        }
    }
    
    private func getTaxiStatus(taxiRidePassengerDetails: TaxiRidePassengerDetails) -> Int {
        if let shareType = taxiRidePassengerDetails.taxiRidePassenger?.getShareType(), shareType != TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            if  taxiRidePassengerDetails.isTaxiStarted() {
                return 4
            }else if taxiRidePassengerDetails.isTaxiAllotted() {
                return 3
            }else if taxiRidePassengerDetails.isTaxiConfirmed() {
                return  2
            }else {
                return 1
            }
        }else {
            if  taxiRidePassengerDetails.isTaxiStarted() {
                return 3
            }else if taxiRidePassengerDetails.isTaxiAllotted() {
                return 2
            }else{
                return 1
            }
        }
    }
}
