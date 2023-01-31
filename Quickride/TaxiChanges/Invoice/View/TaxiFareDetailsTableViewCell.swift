//
//  TaxiFareDetailsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 7/23/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiFareDetailsTableViewCell: UITableViewCell {
    
    //MARK: fareDEtails
    @IBOutlet weak var tripFareAmtLabel: UILabel!
    @IBOutlet weak var cgstView: UIView!
    @IBOutlet weak var cgstPercentageLabel: UILabel!
    @IBOutlet weak var cgstAmountLabel: UILabel!
    @IBOutlet weak var totalAmtLabel: UILabel!
    @IBOutlet weak var extraPickUpKmLabel: UILabel!
    @IBOutlet weak var extraPickUpAmountLabel: UILabel!
    @IBOutlet weak var extraPickupView: UIView!
    @IBOutlet weak var convenienceFeeView: UIView!
    @IBOutlet weak var convenienceFeeAmountLabel: UILabel!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountAmountLabel: UILabel!
    
    func updateUIWithData(taxiRideInvoice: TaxiRideInvoice) {
        let convenienceFee = taxiRideInvoice.scheduleConvenienceFee + taxiRideInvoice.scheduleConvenienceFeeTax
        var tripFare = (taxiRideInvoice.netAmountPaid ?? 0) - (convenienceFee + taxiRideInvoice.extraPickUpCharges)
        tripFareAmtLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(tripFare.roundToPlaces(places: 1))])
        var netAmountPaid = (taxiRideInvoice.amount ?? 0) - taxiRideInvoice.couponDiscount
        totalAmtLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(netAmountPaid.roundToPlaces(places: 2))])
        if convenienceFee > 0{
            convenienceFeeView.isHidden = false
            convenienceFeeAmountLabel.text = "₹\(convenienceFee)"
        }else{
            convenienceFeeView.isHidden = true
        }
        if (taxiRideInvoice.tax ?? 0) > 0{
            cgstView.isHidden = false
            cgstAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(taxiRideInvoice.tax ?? 0)])
            cgstPercentageLabel.text = "GST(" + StringUtils.getPointsInDecimal(points:  ConfigurationCache.getObjectClientConfiguration().taxiPoolGSTPercentage) + "%)"
        }else{
            cgstView.isHidden = true
        }
        
        if taxiRideInvoice.extraPickUpCharges != 0{
            extraPickupView.isHidden = false
            var perKmExtraPickUpFee = taxiRideInvoice.extraPickUpCharges/taxiRideInvoice.extraPickUpDistance
            extraPickUpKmLabel.text = "Pickup Charges (₹\(perKmExtraPickUpFee.roundToPlaces(places: 1)) x \(taxiRideInvoice.extraPickUpDistance) km)"
            extraPickUpAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(taxiRideInvoice.extraPickUpCharges)])
        }else{
            extraPickupView.isHidden = true
        }
        if taxiRideInvoice.couponDiscount != 0{
            discountView.isHidden = false
            discountAmountLabel.text = "- ₹\(taxiRideInvoice.couponDiscount)"
        }else{
            discountView.isHidden = true
        }
    }
}
