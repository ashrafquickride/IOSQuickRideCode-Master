//
//  PoolMyTaxiTableViewCell.swift
//  Quickride
//
//  Created by HK on 04/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PoolMyTaxiTableViewCell: UITableViewCell {

    @IBOutlet weak var preferencesSwitch: UISwitch!
    
    private var viewModel = TaxiPoolLiveRideViewModel()
    
    func showUserPreference(viewModel: TaxiPoolLiveRideViewModel){
        self.viewModel = viewModel
        preferencesSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        if viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.allocateTaxiIfPoolNotConfirmed == true{
            preferencesSwitch.setOn(true, animated: true)
        }else{
            preferencesSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func knowMoreButtonTapped(_ sender: Any) {
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolHowItWorkViewController") as! TaxipoolHowItWorkViewController
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
    }
    
    @IBAction func preferenceSwitchTapped(_ sender: UISwitch){
        QuickRideProgressSpinner.startSpinner()
        viewModel.updatePoolMyTaxi(allocateTaxiIfPoolNotConfirmed: sender.isOn) { [weak self] (result) in
            QuickRideProgressSpinner.stopSpinner()
            if !result{
                self?.preferencesSwitch.setOn(!sender.isOn, animated: true)
            }
        }
    }
}
