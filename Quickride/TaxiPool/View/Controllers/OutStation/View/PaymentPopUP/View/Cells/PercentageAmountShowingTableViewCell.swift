//
//  PercentageAmountShowingTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 03/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PercentageAmountShowingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectedShowingImage: UIImageView!
    @IBOutlet weak var payPercentageLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var titleLeadingSpace: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUIForminimumPercentagePaymentCell(estimateFare: Double) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if !clientConfiguration.enableOutStationTaxiFullPayment{
            selectedShowingImage.isHidden = true
            titleLeadingSpace.constant = 15
        }else{
            selectedShowingImage.isHidden = false
            titleLeadingSpace.constant = 40
        }
        subtitleLabel.isHidden = false
        let outStationTaxiAdvancePaymentPercentage = clientConfiguration.outStationTaxiAdvancePaymentPercentage
        payPercentageLabel.text = String(format: Strings.pay_percent, arguments: [String(outStationTaxiAdvancePaymentPercentage)]) + Strings.percentage_symbol
        let calculatedAmount = getPercentageAmount(estimateFare: estimateFare, percentageToCalculate: outStationTaxiAdvancePaymentPercentage)
        amountLabel.text = "₹ \(Int(calculatedAmount.rounded()))"
    }
    
    func updateUIForEstimateFareCell(estimateFare: Double) {
        subtitleLabel.isHidden = true
        payPercentageLabel.text = Strings.total_estimate_fare
        amountLabel.text = "₹ \(Int(estimateFare))"
    }
    
    func getPercentageAmount(estimateFare: Double, percentageToCalculate : Int) -> Double {
        return estimateFare*Double(percentageToCalculate)/100
    }
}
