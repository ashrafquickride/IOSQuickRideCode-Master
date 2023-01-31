//
//  TaxiDetailsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 9/25/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var detailTypeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightDetailLabel: UILabel!
    @IBOutlet weak var detailImageViewHeightConstarint: NSLayoutConstraint!
    @IBOutlet weak var detailTypeImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpTaxiDetailUI(fareForVehicleClass: FareForVehicleClass) {
        detailTypeImageView.isHidden = false
        detailImageViewHeightConstarint.constant = 30
        detailTypeImageViewWidthConstraint.constant = 30
        setImageAsPerVehicleClass(taxiClass: fareForVehicleClass.vehicleClass ?? "")
        rightDetailLabel.isHidden = true
        titleLabel.text = GetTaxiShareMinMaxFare.EXCLUSIVE_TAXI + "-\(fareForVehicleClass.vehicleClass ?? ""),\(fareForVehicleClass.seatCapacity ?? 0) Seater"
        separatorView.isHidden = true
    }
    
    func updateUIForFare(title: String, price: String) {
        detailTypeImageView.isHidden = true
        rightDetailLabel.isHidden = false
        titleLabel.text = title
        rightDetailLabel.text = price
    }
    
    func updateUIForInterCityRules(data: String){
        if data == Strings.cancel_policy {
            let firstString = Strings.for_cancel_policy_out_station
            let lastString = Strings.cancel_policy
            let stringValue = firstString + lastString
            let finalString = NSMutableAttributedString(string: stringValue)
            finalString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0,length:firstString.count))
            finalString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(netHex: 0x007AFF), range: NSRange(location:firstString.count,length:lastString.count))
            self.titleLabel.attributedText = finalString
        }else{
            titleLabel.text = data
        }
        detailTypeImageView.isHidden = false
        rightDetailLabel.isHidden = true
    }
    
    func facilitiesUI(data: String) {
        detailTypeImageView.isHidden = true
        titleLabel.text = data.replace( target: "\\u20B9", withString: " ₹")
        rightDetailLabel.isHidden = true
    }
    
    func setDataForTripDetails(taxiRideInvoice : TaxiRideInvoice) {
        detailTypeImageView.isHidden = false
        detailImageViewHeightConstarint.constant = 30
        detailTypeImageViewWidthConstraint.constant = 30
        setImageAsPerVehicleClass(taxiClass: taxiRideInvoice.vehicleClass ?? "")
        rightDetailLabel.isHidden = true
        titleLabel.text = GetTaxiShareMinMaxFare.EXCLUSIVE_TAXI + " -\(taxiRideInvoice.vehicleClass ?? ""), \(taxiRideInvoice.seatCapacity ?? 0) Seater"
        separatorView.isHidden = true
    }
    
    private func setImageAsPerVehicleClass(taxiClass: String) {
        switch taxiClass {
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_HATCH_BACK:
            detailTypeImageView.image = UIImage(named: "icon_hatchback")
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SEDAN:
            detailTypeImageView.image = UIImage(named: "sedan_taxi")
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV:
            detailTypeImageView.image = UIImage(named: "outstation_SUV")
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_CROSS_OVER:
            detailTypeImageView.image = UIImage(named: "outstation_SUV")
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_TT:
            detailTypeImageView.image = UIImage(named: "Tempo")
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_BIKE:
            detailTypeImageView.image = UIImage(named: "bike_taxi_pool")
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_AUTO:
            detailTypeImageView.image = UIImage(named: "auto")
        case TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_ANY:
            detailTypeImageView.image = UIImage(named: "sharing")
        default:
            detailTypeImageView.image = UIImage(named: "sedan_taxi")
        }
    }
}
