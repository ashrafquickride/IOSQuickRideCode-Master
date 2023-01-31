//
//  OutstationInfoTableViewCell.swift
//  Quickride
//
//  Created by HK on 11/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OutstationInfoTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var viewModel = TaxiPoolLiveRideViewModel()
    
    @IBAction func addHereTapped(_ sender: Any) {
        let addOutstationAddtionalPaymentsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddOutstationAddtionalPaymentsViewController") as! AddOutstationAddtionalPaymentsViewController
        addOutstationAddtionalPaymentsViewController.addPaymentHere(taxiRidePassengerDetails: viewModel.taxiRidePassengerDetails)
        ViewControllerUtils.addSubView(viewControllerToDisplay: addOutstationAddtionalPaymentsViewController)
    }
}
