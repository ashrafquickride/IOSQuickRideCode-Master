//
//  TaxiTripPassengerFeedbackRatingTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 27/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiTripPassengerFeedbackRatingTableViewCell: UITableViewCell {
    @IBOutlet weak var oneRatingBtn: UIButton!
    @IBOutlet weak var twoRatingBtn: UIButton!
    @IBOutlet weak var threeRatingBtn: UIButton!
    @IBOutlet weak var fourRatingBtn: UIButton!
    @IBOutlet weak var fiveRatingBtn: UIButton!
    @IBOutlet weak var ratingTitleLAbel: UILabel!
    @IBOutlet weak var rideDetailInfoLabel: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var tripStartTimeLabel: UILabel!
    
    //MARK: Variables
    private var taxiHomePageViewModel = TaxiHomePageViewModel()
    private var ratingButtonArray = [UIButton]()
    
    func initialiseDriverData(taxiHomePageViewModel: TaxiHomePageViewModel){
        self.taxiHomePageViewModel = taxiHomePageViewModel
        ratingButtonArray = [oneRatingBtn,twoRatingBtn,threeRatingBtn,fourRatingBtn,fiveRatingBtn]
        ratingTitleLAbel.text = String(format: Strings.rate_your_ride_with, arguments: [taxiHomePageViewModel.taxiRideInvoice?.toUserName ?? ""])
        rideDetailInfoLabel.text = String(format: Strings.your_trip_to, arguments: [taxiHomePageViewModel.taxiRideInvoice?.endLocation ?? ""])
        if let startTimeMs = taxiHomePageViewModel.taxiRideInvoice?.startTimeMs{
            tripStartTimeLabel.text = String(format:  Strings.on_time, arguments: [DateUtils.getTimeStringFromTimeInMillis(timeStamp: startTimeMs, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? ""])
        }
        ImageCache.getInstance().setImageToView(imageView: driverImage, imageUrl:  taxiHomePageViewModel.taxiRideInvoice?.driverImageURI ?? "", placeHolderImg: UIImage(named: "default_taxi_driver"),imageSize: ImageCache.DIMENTION_SMALL)
    }
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        let taxiTripPassengerFeedbackVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripPassengerFeedbackViewController") as! TaxiTripPassengerFeedbackViewController
        taxiTripPassengerFeedbackVC.initializeData(taxiRideInvoice: taxiHomePageViewModel.taxiRideInvoice, rating: Double(sender.tag + 1), taxiRidePassenger: taxiHomePageViewModel.recentCompletedTaxiRide)
        ViewControllerUtils.addSubView(viewControllerToDisplay: taxiTripPassengerFeedbackVC)
    }
}
