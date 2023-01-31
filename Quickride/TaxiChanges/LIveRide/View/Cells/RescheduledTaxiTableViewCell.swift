//
//  RescheduledTaxiTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 01/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class RescheduledTaxiTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var bookedInfoLabel: UILabel!
    @IBOutlet weak var taxiTypeLabel: UILabel!
    @IBOutlet weak var taxiTypeImage: UIImageView!
    
    func allocatingDriverView(viewModel: TaxiPoolLiveRideViewModel){
        animationView.animation = Animation.named("lnstant_booking")
        animationView.play()
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        if viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
            taxiTypeLabel.text = String(format: Strings.taxi_booked, arguments: ["Auto"])
            taxiTypeImage.image = UIImage(named: "auto")
        }else if viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE{
            taxiTypeLabel.text = String(format: Strings.taxi_booked, arguments: ["Bike"])
            taxiTypeImage.image = UIImage(named: "bike_taxi_pool")
        }else{
            taxiTypeImage.image = UIImage(named: "taxi")
            taxiTypeLabel.text = String(format: Strings.taxi_booked, arguments: ["Taxi"])
        }
    }
    @IBAction func callSupportTapped(_ sender: Any) {
        AppUtilConnect.callSupportNumber(phoneNumber: ConfigurationCache.getObjectClientConfiguration().quickRideSupportNumberForTaxi, targetViewController: self.parentViewController ?? ViewControllerUtils.getCenterViewController())
    }
}
