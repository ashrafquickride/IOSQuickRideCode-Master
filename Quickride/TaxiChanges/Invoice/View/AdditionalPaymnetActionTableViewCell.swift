//
//  AdditionalPaymnetActionTableViewCell.swift
//  Quickride
//
//  Created by HK on 28/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AdditionalPaymnetActionTableViewCell: UITableViewCell {

    @IBOutlet weak var chargesAddedByMeButton: UIButton!
    @IBOutlet weak var chargesAddedByDriverButton: UIButton!


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var outstationTaxiFareDetails: PassengerFareBreakUp?

    func initialisingData(outstationTaxiFareDetails: PassengerFareBreakUp?) {
        self.outstationTaxiFareDetails = outstationTaxiFareDetails
        if outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.isEmpty == true{
            chargesAddedByMeButton.isHidden = true
        }
        if outstationTaxiFareDetails?.taxiTripExtraFareDetails.isEmpty == true{
            chargesAddedByDriverButton.isHidden = true
        }
    }

    @IBAction func driverChargesTapped(_ sender: Any) {
        showList(driverAddedCharges: true)
    }

    @IBAction func chargesAddedMeTapped(_ sender: Any) {
        showList(driverAddedCharges: false)
    }

    private func showList(driverAddedCharges: Bool){
        guard let outstationDetails = outstationTaxiFareDetails else { return }
        let outstationExtraChargesViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OutstationExtraChargesViewController") as! OutstationExtraChargesViewController
        outstationExtraChargesViewController.initialiseCharges(outstationTaxiFareDetails: outstationDetails, showDriverAddedChanges: driverAddedCharges)
        self.parentViewController?.present(outstationExtraChargesViewController, animated: false, completion: nil)
    }
}
