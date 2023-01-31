//
//  FeedbackReminderNotificationViewController.swift
//  Quickride
//
//  Created by Rajesab on 07/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class FeedbackReminderNotificationViewController: UIViewController {
    
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var oneRatingBtn: UIButton!
    @IBOutlet weak var twoRatingBtn: UIButton!
    @IBOutlet weak var threeRatingBtn: UIButton!
    @IBOutlet weak var fourRatingBtn: UIButton!
    @IBOutlet weak var fiveRatingBtn: UIButton!
    @IBOutlet weak var ratingTitleLAbel: UILabel!
    @IBOutlet weak var rideDetailInfoLabel: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var tripStartTimeLabel: UILabel!
    @IBOutlet weak var feedbackTopView: UIView!
    
    private var feedbackReminderNotificationViewModel = FeedbackReminderNotificationViewModel()
    private var ratingButtonArray = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func initialiseDriverData(taxiFeedBackNotification: TaxiFeedBackNotification) {
        feedbackReminderNotificationViewModel = FeedbackReminderNotificationViewModel(taxiFeedBackNotification: taxiFeedBackNotification)
    }
    func setupUI(){
        ratingButtonArray = [oneRatingBtn,twoRatingBtn,threeRatingBtn,fourRatingBtn,fiveRatingBtn]
        ratingTitleLAbel.text = String(format: Strings.rate_your_ride_with, arguments: [feedbackReminderNotificationViewModel.taxiFeedBackNotification?.driverName ?? ""])
        rideDetailInfoLabel.text = String(format: Strings.your_trip_to , arguments: [feedbackReminderNotificationViewModel.taxiFeedBackNotification?.endAddress ?? ""])
        tripStartTimeLabel.text = String(format: Strings.on_time, arguments: [DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(feedbackReminderNotificationViewModel.taxiFeedBackNotification?.endTimeInMs ?? ""), timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!])
        ImageCache.getInstance().setImageToView(imageView: driverImage, imageUrl: feedbackReminderNotificationViewModel.taxiFeedBackNotification?.driverImgUri ?? "", placeHolderImg: UIImage(named: "default_taxi_driver"),imageSize: ImageCache.DIMENTION_SMALL)
    }
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        setRating(selectedRating: sender.tag + 1)
    }
    private func setRating(selectedRating: Int){
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
        let taxiTripPassengerFeedbackVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripPassengerFeedbackViewController") as! TaxiTripPassengerFeedbackViewController
        taxiTripPassengerFeedbackVC.initialiseData(rating: Double(selectedRating), taxiFeedBackNotification: feedbackReminderNotificationViewModel.taxiFeedBackNotification, isFromNotification: true)
        ViewControllerUtils.addSubView(viewControllerToDisplay: taxiTripPassengerFeedbackVC)
        closeView()
    }
}
