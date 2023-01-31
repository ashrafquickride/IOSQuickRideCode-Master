//
//  HomepageTaxiCardTableViewCell.swift
//  Quickride
//
//  Created by HK on 05/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HomepageTaxiCardTableViewCell: UITableViewCell {

    @IBOutlet weak var taxiAmountLabel: UILabel!
    
    var ride : Ride?
    
    func initialiseTaxiView(detailEstimatedFare : DetailedEstimateFare,ride: Ride? = nil){
        self.ride = ride
        let points = TaxiUtils.getTaxiPoints(detailedEstimatedFare: detailEstimatedFare,taxiType: TaxiPoolConstants.TAXI_TYPE_CAR)
        if points != 0{
            taxiAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: points)])
        }
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundTapped(_:))))
        
    }
    
    @objc func backGroundTapped(_ gesture: UITapGestureRecognizer){
        bookNow()
    }
    @IBAction func bookNowTapped(_ sender: Any) {
        bookNow()
    }
    func bookNow(){
        if let passengerRide = ride as? PassengerRide {
            let taxiPoolVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideCreationMapViewController") as! TaxiRideCreationMapViewController
            taxiPoolVC.initialiseData(passengerRide: passengerRide)
            self.parentViewController?.navigationController?.pushViewController(taxiPoolVC, animated: false)
        }else if let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRide() as? PassengerRide {
            let taxiPoolVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideCreationMapViewController") as! TaxiRideCreationMapViewController
            taxiPoolVC.initialiseData(passengerRide: passengerRide)
            self.parentViewController?.navigationController?.pushViewController(taxiPoolVC, animated: false)
        }
    }
}
