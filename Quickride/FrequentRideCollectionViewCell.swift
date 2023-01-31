//
//  FrequentRideCollectionViewCell.swift
//  Quickride
//
//  Created by Vinutha on 02/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class FrequentRideCollectionViewCell: UICollectionViewCell {
    //MARK: OUTLETS
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var destinationLocationLabel: UILabel!
    @IBOutlet weak var dateShowingLabel: UILabel!
    @IBOutlet weak var findOrOfferRideButton: UIButton!
    @IBOutlet weak var editRideButton: UIButton!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var frequentRideView: UIView!
    @IBOutlet weak var rideTypeBackGround: UIView!
    @IBOutlet weak var rideTypeImage: UIImageView!
    
    
    //MARK: Methods
    func updateUI(rideToShow: Ride) {
        frequentRideView.addShadow()
        ViewCustomizationUtils.addCornerRadiusToView(view: rideTypeBackGround, cornerRadius: 25)
        ViewCustomizationUtils.addCornerRadiusToView(view: findOrOfferRideButton, cornerRadius: 15)
        startLocationLabel.text = rideToShow.startAddress
        destinationLocationLabel.text = rideToShow.endAddress
        rideToShow.startTime = NSDate().getTimeStamp()
        dateShowingLabel.text = RideViewUtils.getRideStartTime(ride: rideToShow, format: DateUtils.DATE_FORMAT_dd_MMM_h_mm)
        if Ride.RIDER_RIDE == rideToShow.rideType {
            rideTypeImage.image = UIImage(named: "icon_find_ride_white")
            findOrOfferRideButton.setTitle(Strings.offer_pool.uppercased(), for: .normal)
            seatsLabel.isHidden = true
        }else{
            rideTypeImage.image = UIImage(named: "vehicle_type_car_white")
            seatsLabel.isHidden = false
            if let passengerRide = MyClosedRidesCache.getClosedRidesCacheInstance().closedPassengerRides?[rideToShow.rideId] {
                let noOfSeats = passengerRide.noOfSeats
                if noOfSeats > 1 {
                    seatsLabel.text = String(noOfSeats) + " Seats"
                }else{
                    seatsLabel.text = String(noOfSeats) + " Seat"
                }
                
            }else{
                seatsLabel.text = "1 Seat"
            }
            findOrOfferRideButton.setTitle(Strings.find_pool.uppercased(), for: .normal)
        }
    }
}
