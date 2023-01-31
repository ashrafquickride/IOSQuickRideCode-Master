//
//  CashPaymentsTableViewCell.swift
//  Quickride
//
//  Created by HK on 01/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CashPaymentsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addPaymentsButton: UIButton!
    @IBOutlet weak var disputedButton: UIButton!
    
    private var taxiRidePassengerDetails: TaxiRidePassengerDetails?
    
    func updateUIForFare(title: String, amount: String,isRequiredShowDisputed: Bool,isRequiredShowAddPayment: Bool,taxiRidePassengerDetails: TaxiRidePassengerDetails?) {
        self.taxiRidePassengerDetails = taxiRidePassengerDetails
        titleLabel.text = title
        amountLabel.text = amount
        if isRequiredShowDisputed{
            disputedButton.isHidden = false
        }else{
           disputedButton.isHidden = true
        }
        if isRequiredShowAddPayment{
            addPaymentsButton.isHidden = false
        }else{
            addPaymentsButton.isHidden = true
        }
    }
    
    @IBAction func addPaymentsButtonTapped(_ sender: Any) {
        let addOutstationAddtionalPaymentsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddOutstationAddtionalPaymentsViewController") as! AddOutstationAddtionalPaymentsViewController
        addOutstationAddtionalPaymentsViewController.addPaymentHere(taxiRidePassengerDetails: self.taxiRidePassengerDetails)
        ViewControllerUtils.addSubView(viewControllerToDisplay: addOutstationAddtionalPaymentsViewController)
    }
}
