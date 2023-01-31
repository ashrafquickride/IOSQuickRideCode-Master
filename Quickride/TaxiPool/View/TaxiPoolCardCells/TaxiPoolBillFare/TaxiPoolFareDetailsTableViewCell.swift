//
//  TaxiPoolFareDetailsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 7/23/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol TaxiPoolFareDetailsTableViewCellDelegate {
    func routeMapButtonTapped(data: Bool)
}

class TaxiPoolFareDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var endAddressLabel: UILabel!
    @IBOutlet weak var routeMapBtn: UIButton!
    @IBOutlet weak var shareTypeLabel: UILabel!
    @IBOutlet weak var numberOfSeatsLabel: UILabel!
    //MARK: fareDEtails
    @IBOutlet weak var tripFareAmtLabel: UILabel!
    @IBOutlet weak var cgstPercentageLabel: UILabel!
    @IBOutlet weak var cgstAmountLabel: UILabel!
    @IBOutlet weak var totalAmtLabel: UILabel!
    @IBOutlet weak var paidByWalletLabel: UILabel!
    
    var delegate: TaxiPoolFareDetailsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Initialization code
    }

    private func setUpUI() {
    ViewCustomizationUtils.addCornerRadiusWithBorderToView(view: routeMapBtn, cornerRadius: 15.0, borderWidth: 1.0, color: UIColor(netHex: 0x2196f3))
    }
    
    @IBAction func routeMapBtnPressed(_ sender: UIButton) {
        delegate?.routeMapButtonTapped(data: true)
    }
    
    func updateUIWithData(rideBillingDetails: RideBillingDetails?,taxiShareInfoForInvoice: TaxiShareInfoForInvoice?) {
        startAddressLabel.text = rideBillingDetails?.startLocation
        endAddressLabel.text = rideBillingDetails?.endLocation
        tripFareAmtLabel.text = "₹" + StringUtils.getPointsInDecimal(points: rideBillingDetails?.rideFare ?? 0.0)
        totalAmtLabel.text = "₹" + StringUtils.getPointsInDecimal(points: (rideBillingDetails?.rideTakerTotalAmount ?? 0.0))
        cgstAmountLabel.text = "₹" + StringUtils.getPointsInDecimal(points: rideBillingDetails?.rideFareGst ?? 0.0)
        cgstPercentageLabel.text = "GST(" + StringUtils.getPointsInDecimal(points:  ConfigurationCache.getObjectClientConfiguration().taxiPoolGSTPercentage) + "%)"
        paidByWalletLabel.text = String(format: Strings.bill_paid_through_taxipool, arguments: ["\(rideBillingDetails?.paymentType ?? "")"])
        if rideBillingDetails?.noOfSeat == 1 {
            numberOfSeatsLabel.text = String(format: Strings.single_seat, arguments: ["\(rideBillingDetails?.noOfSeat ?? 0 )"])
        } else {
            numberOfSeatsLabel.text = String(format: Strings.multi_seat, arguments: ["\(rideBillingDetails?.noOfSeat ?? 0)"])
        }
        
        if taxiShareInfoForInvoice != nil {
            shareTypeLabel.text = taxiShareInfoForInvoice?.shareType
        }
    }
    
}

