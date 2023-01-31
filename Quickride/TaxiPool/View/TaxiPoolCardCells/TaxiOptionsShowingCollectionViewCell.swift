//
//  TaxiOptionsShowingCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 4/20/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class TaxiOptionsShowingCollectionViewCell: UICollectionViewCell {
    //MARK: OutLets
    @IBOutlet weak var backgroundCardView: QuickRideCardView!
    @IBOutlet weak var seatLeftShowingLabel: UILabel!
    @IBOutlet weak var numberOfSharingInfoShowingLabel: UILabel!
    @IBOutlet weak var priceShowingLabel: UILabel!
    @IBOutlet weak var oneSeatImageView: UIImageView!
    @IBOutlet weak var twoSeatImageView: UIImageView!
    @IBOutlet weak var threeSeatImageView: UIImageView!
    @IBOutlet weak var fourSeatImageView: UIImageView!
    @IBOutlet weak var pickUpTimeShowingLabel: UILabel!
    @IBOutlet weak var joinButtonBGView: QuickRideCardView!
    @IBOutlet weak var joinstatusLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
        
    private var numberOfSeatsImageArray = [UIImageView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfSeatsImageArray = [oneSeatImageView,twoSeatImageView,threeSeatImageView,fourSeatImageView]
    }

    func updataUIWithData(data: MatchedShareTaxi) {
        numberOfSharingInfoShowingLabel.text = data.shareType ?? ""
        priceShowingLabel.text = "₹\(Int(data.minPoints ?? 0))"
        let availableSeats = Int(data.availableSeats!)
        if availableSeats > 1 {
            seatLeftShowingLabel.text = String(format: Strings.seats_available,arguments: [String(data.availableSeats ?? 0)])
        } else {
            seatLeftShowingLabel.text = Strings.seat_available
        }
        setOccupiedSeats(availableSeats: data.availableSeats ?? 0, capacity: data.capacity ?? 0)
        let addedTimeRangeTime = DateUtils.addMinutesToTimeStamp(time: data.pkTime!, minutesToAdd: ConfigurationCache.getObjectClientConfiguration().taxiPickUpTimeRangeInMins)
        pickUpTimeShowingLabel.text  = DateUtils.getTimeStringFromTimeInMillis(timeStamp: data.pkTime, timeFormat: DateUtils.TIME_FORMAT_hh_mm)! + "-" + DateUtils.getTimeStringFromTimeInMillis(timeStamp: addedTimeRangeTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
    }
    
    private func setOccupiedSeats(availableSeats: Int, capacity: Int) {
        for (index, imageView) in numberOfSeatsImageArray.enumerated() {
            imageView.isHidden = !(index < capacity)
            imageView.image = index < capacity - availableSeats ? UIImage(named: "seat_occupied") : UIImage(named: "seat_not_occu_taxi")
        }
    }
}
