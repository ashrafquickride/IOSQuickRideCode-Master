//
//  ScheduleReturnTaxiTableViewCell.swift
//  Quickride
//
//  Created by HK on 02/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ScheduleReturnTaxiTableViewCell: UITableViewCell {

    @IBOutlet weak var returnLabel: UILabel!
    @IBOutlet weak var bookNowButton: QRCustomButton!
    @IBOutlet weak var bookNowButtonHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var taxiRide: TaxiRidePassenger?
    func initialiseCell(taxiRide: TaxiRidePassenger?){
        self.taxiRide = taxiRide
        returnLabel.text = "Taxi to \(taxiRide?.startAddress ?? "")"
        if taxiRide?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL{
            bookNowButton.isHidden = true
            bookNowButtonHeight.constant = 0
        }
    }
    
    @IBAction func bookNowTapped(_ sender: Any) {
        guard let taxiRidePassenger = taxiRide else { return }
        let taxiPoolVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideCreationMapViewController") as! TaxiRideCreationMapViewController
        taxiPoolVC.initialiseTaxiRidePassengerRide(taxiRidePassenger: taxiRidePassenger)
        self.parentViewController?.navigationController?.pushViewController(taxiPoolVC, animated: false)
    }
    
}
