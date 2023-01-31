//
//  NewJoinShimmerViewController.swift
//  Quickride
//
//  Created by Ashutos on 7/29/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class NewJoinShimmerViewController: UIViewController {
    
    @IBOutlet weak var newRideView: QuickRideCardView!
    @IBOutlet weak var rideDateTimeShowingLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var whyQRTaxiTypeLabel: UILabel!
    @IBOutlet weak var taxiMessageLabel: UILabel!
    @IBOutlet weak var taxiFeatureImage: UIImageView!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var titleShimmerView: ShimmerView!
    @IBOutlet weak var subTitleShimmerView: ShimmerView!
    
    @IBOutlet weak var bookingTypeImage: UIImageView!
    @IBOutlet weak var bookingLabel: UILabel!
    
    private var shareType: String?
    private var startTime: Double?
    private var isOldTaxiRide = true
    private var taxiType = TaxiPoolConstants.TAXI_TYPE_CAR
    
    func  initLiseData(shareType: String?,startTime: Double?,isOldTaxiRide: Bool,taxiType: String) {
        self.shareType = shareType
        self.startTime = startTime
        self.isOldTaxiRide = isOldTaxiRide
        self.taxiType = taxiType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isOldTaxiRide{
            checkCurrentRideIsInstantOrNot()
        }
        if taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
            bookingLabel.text = String(format: Strings.booking_taxi_type, arguments: ["auto"])
            bookingTypeImage.image = UIImage(named: "Auto_icon")
        }else if taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE{
            bookingTypeImage.image = UIImage(named: "bike_taxi_pool")
            bookingLabel.text = String(format: Strings.booking_taxi_type, arguments: ["bike"])
        }else{
            bookingTypeImage.image = UIImage(named: "booking_taxi")
            bookingLabel.text = String(format: Strings.booking_taxi_type, arguments: ["taxi"])
        }
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func checkCurrentRideIsInstantOrNot(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: startTime, time2: NSDate().getTimeStamp()) > clientConfiguration.taxiPoolInstantBookingThresholdTimeInMins{
            isOldTaxiRide = true
        }
    }
    
    private func setUpUI() {
        rideDateTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: startTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aa) ?? ""
        if isOldTaxiRide{
            loadingView.isHidden = false
            newRideView.isHidden = true
            titleShimmerView.startAnimating()
            subTitleShimmerView.startAnimating()
        }else{
            loadingView.isHidden = true
            newRideView.isHidden = false
            animationView.animation = Animation.named("lnstant_booking")
            animationView.play()
            animationView.loopMode = .loop
            animationView.contentMode = .scaleAspectFill
            if taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
                taxiMessageLabel.text = "Hire at tap of a button. No more hassle to hire auto"
                taxiFeatureImage.image = UIImage(named: "auto_instant1")
                whyQRTaxiTypeLabel.text = "Why Quick Ride Auto"
            }else{
                taxiMessageLabel.text = "Fares are lower and consistent. No surge like 2x, 3x."
                taxiFeatureImage.image = UIImage(named: "taxi_instant5")
                whyQRTaxiTypeLabel.text = "Why Quick Ride Taxi"
            }
        }
    }
}
