//
//  DetailsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 9/25/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

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
    
    func setUpTaxiDetailUI(selectedTaxiData: AvailableOutstationTaxi) {
        detailTypeImageView.isHidden = false
        detailImageViewHeightConstarint.constant = 30
        detailTypeImageViewWidthConstraint.constant = 30
        setImageAsPerVehicleClass(taxiClass: selectedTaxiData.vehicleClass ?? "")
        rightDetailLabel.isHidden = true
        titleLabel.text = GetTaxiShareMinMaxFare.EXCLUSIVE_TAXI + "-\(selectedTaxiData.vehicleClass ?? ""),\(selectedTaxiData.seatCapacity ?? 0) Seater"
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
        detailTypeImageView.isHidden = true
        rightDetailLabel.isHidden = true
    }
    
    func facilitiesUI(data: String) {
        detailTypeImageView.isHidden = true
        titleLabel.text = data.replace( target: "\\u20B9", withString: " ₹")
        rightDetailLabel.isHidden = true
    }
    
    func setDataForTripDetails(taxiShareInfoForInvoice : TaxiShareInfoForInvoice) {
        detailTypeImageView.isHidden = false
        detailImageViewHeightConstarint.constant = 30
        detailTypeImageViewWidthConstraint.constant = 30
        setImageAsPerVehicleClass(taxiClass: taxiShareInfoForInvoice.vehicleClass ?? "")
        rightDetailLabel.isHidden = true
        titleLabel.text = GetTaxiShareMinMaxFare.EXCLUSIVE_TAXI + " -\(taxiShareInfoForInvoice.vehicleClass ?? ""), \(taxiShareInfoForInvoice.seatCapacity ?? 0) Seater"
        separatorView.isHidden = true
    }
    
    private func setImageAsPerVehicleClass(taxiClass: String) {
        switch taxiClass {
        case OutStationTaxiShowingTableViewCell.TAXI_TYPE_SUV:
            detailTypeImageView.image = UIImage(named: "outstation_SUV")
        case OutStationTaxiShowingTableViewCell.TAXI_TYPE_TEMPO:
            detailTypeImageView.image = UIImage(named: "TEMPO")
        default:
            detailTypeImageView.image = UIImage(named: "sedan_taxi")
        }
    }
}
