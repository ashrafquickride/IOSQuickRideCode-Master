//
//  TaxiTripPassengerFeedbackFiveRatingTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 28/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiTripPassengerFeedbackFiveRatingTableViewCell: UITableViewCell {

    @IBOutlet weak var ratingInAppStoreButtonTapped: UIButton!
    
    private var taxiTripPassengerFeedbackViewModel = TaxiTripPassengerFeedbackViewModel()
    
    func initializeData(taxiTripPassengerFeedbackViewModel: TaxiTripPassengerFeedbackViewModel){
        self.taxiTripPassengerFeedbackViewModel = taxiTripPassengerFeedbackViewModel
    }
    
    @IBAction func ratingInAppStoreButtonTapped(_ sender: Any) {
        taxiTripPassengerFeedbackViewModel.submitRatingAndFeedBack(feedback: nil)
        self.parentViewController?.view.removeFromSuperview()
        self.parentViewController?.removeFromParent()
        moveToAppStore()
    }
    
    private func moveToAppStore(){
        AppDelegate.getAppDelegate().log.debug("moveToAppStore()")
        let url = NSURL(string: AppConfiguration.application_link)
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.please_upgrade_from_app_store, duration: 3.0, position: .center)
        }
    }
}
