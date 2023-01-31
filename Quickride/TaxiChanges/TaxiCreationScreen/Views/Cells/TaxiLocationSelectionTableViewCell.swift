//
//  TaxiLocationSelectionTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 15/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol TaxiLocationSelectionTableViewCellDelegate {
    func fromLocationPressed()
    func toLocationPressed()
    func swapBtnPressed()
    func taxiPressed()
    func outstationPressed()
    func oneWayPressed()
    func roundTripPressed()
    func fromDatePressed()
    func toDatePressed()
    func fromDateUpdated(date: Double)
}

class TaxiLocationSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fromLocationView: UIView!
    @IBOutlet weak var toLocationView: UIView!
    @IBOutlet weak var oneWayView: UIView!
    @IBOutlet weak var oneWayImageView: UIImageView!
    @IBOutlet weak var roundTripIMageView: UIImageView!
    @IBOutlet weak var roundTripView: UIView!
    @IBOutlet weak var roundTripBottomView: QuickRideCardView!
    @IBOutlet weak var oneWayViewSeparator: QuickRideCardView!
    @IBOutlet weak var oneWayLabel: UILabel!
    @IBOutlet weak var roundTripLabel: UILabel!
    @IBOutlet weak var infoButtonView: UIView!
    
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var dropLocationButton: UIButton!
    @IBOutlet weak var journeyTypeView: UIView!
    @IBOutlet weak var journeyTypeHeightConstarints: NSLayoutConstraint!
    //MARK: Date Selection
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var todateView: UIView!
    @IBOutlet weak var todateLabel: UILabel!
    @IBOutlet weak var pickUpImage: UIImageView!
    @IBOutlet weak var pickUpClockWidth: NSLayoutConstraint!
    @IBOutlet weak var pickupClockHeight: NSLayoutConstraint!
    
    private var delegate : TaxiLocationSelectionTableViewCellDelegate?
    private var isRoundTripSelected = false
    private var rideType: String?
    private var rideTypes = [CommuteSubSegment(name: Strings.local_taxi, type: TaxiPoolConstants.TRIP_TYPE_LOCAL),CommuteSubSegment(name: Strings.out_station, type: TaxiPoolConstants.TRIP_TYPE_OUTSTATION)]
    private var timer : Timer?
    private var fromTime: Double?
    private var toTime: Double = NSDate().getTimeStamp()
    var isTollIncluded: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func registerCell() {
        oneWayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(oneWayPressed(_:))))
        roundTripView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(roundTripPressed(_:))))
    }
    
    func setUpUI(startLocation: Location?, endLocation: Location?,rideType: String?,isRoundtrip : Bool, delegate: TaxiLocationSelectionTableViewCellDelegate?, fromTime: Double,toTime: Double, isRequiredToShowAnimationForTime: Bool, isTollIncluded: Bool?) {
        setStartLocation(startLocation: startLocation)
        setEndLocation(endLocation: endLocation)
        self.isRoundTripSelected = isRoundtrip
        self.delegate = delegate
        self.rideType = rideType
        self.fromTime = fromTime
        self.toTime = toTime
        self.isTollIncluded = isTollIncluded
        if rideType == TaxiPoolConstants.TRIP_TYPE_LOCAL {
            journeyTypeHeightConstarints.constant = 0
            pickupClockHeight.constant = 20
            pickUpClockWidth.constant = 20
            pickUpImage.image = UIImage(named: "time_clock_blue_icon")
            journeyTypeView.isHidden = true
            todateView.isHidden = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateToCurrentTime), userInfo: nil, repeats: true)
        }else {
            journeyTypeHeightConstarints.constant = 40
            pickupClockHeight.constant = 15
            pickUpClockWidth.constant = 15
            pickUpImage.image = UIImage(named: "new_time_icon")
            journeyTypeView.isHidden = false
            setJourneyTypeOutStation()
        }
        for index in 0..<rideTypes.count {
            rideTypes[index].selected = rideTypes[index].type == rideType ? true : false
        }
        fromDateView.frame.origin.x = 0
        if isRequiredToShowAnimationForTime {
            updateTripStartTimeOnVehicleType()
        } else{
            showTime()
        }
    }
    private func showTime(){
        if ((DateUtils.getTimeStringFromTimeInMillis(timeStamp: fromTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yy)!).compare(DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().getTimeStamp(), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yy)!)) == ComparisonResult.orderedSame{
            if DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: fromTime, time2: NSDate().getTimeStamp()) < 1{
                fromDateLabel.text = "Now"
                fromDateLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            }else {
                fromDateLabel.text = "Today, " + DateUtils.getTimeStringFromTimeInMillis(timeStamp: fromTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)!
                fromDateLabel.font = UIFont(name: "HelveticaNeue", size: 16)
            }
        }else{
            fromDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: fromTime, timeFormat: DateUtils.DATE_FORMAT_EEE_dd_h_mm_aaa)
            fromDateLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        }
    }
    
    private func setStartLocation(startLocation: Location?){
        if let address = startLocation?.completeAddress, !address.isEmpty {
            startLocationButton.setTitle(address, for: .normal)
            startLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        } else {
            startLocationButton.setTitle(Strings.enter_start_location, for: .normal)
            startLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        }
    }
    
   private func updateTripStartTimeOnVehicleType(){
        UIView.animate(withDuration: 0.8, delay: 0, options: [.transitionCurlUp],
                       animations: {
                        self.fromDateView.frame.origin.x = 0 - self.fromDateView.bounds.width
                       }, completion: { done in
                        if done{
                            self.showTime()
                            self.fromDateView.frame.origin.x = self.fromLocationView.bounds.width + 40
                            self.loadUpdatedStarttime()
                        }
                       })
    }
   private func loadUpdatedStarttime(){
        UIView.animate(withDuration: 0.8, delay: 0, options: [.transitionCurlUp],
                       animations: {
                        self.fromDateView.frame.origin.x = 0
                       }, completion: nil)
    }
    
    private func setEndLocation(endLocation: Location?) {
        if let address = endLocation?.completeAddress, !address.isEmpty {
            dropLocationButton.setTitle(address, for: .normal)
            dropLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        }else{
            dropLocationButton.setTitle(Strings.enter_end_location, for: .normal)
            dropLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        }
    }
    
    @IBAction func swapLocationBtnPressed(_ sender: UIButton) {
        delegate?.swapBtnPressed()
    }
    
    @IBAction func startLocationBtnPressed(_ sender: UIButton) {
        delegate?.fromLocationPressed()
    }

    @IBAction func DropLocationBtnPressed(_ sender: UIButton) {
        delegate?.toLocationPressed()
    }
    
    @IBAction func fromDateButtonTapped(_ sender: Any) {
        delegate?.fromDatePressed()
    }
    
    @IBAction func toDateButtonTapped(_ sender: Any) {
        delegate?.toDatePressed()
    }
    
    @objc private func oneWayPressed(_ gesture : UITapGestureRecognizer) {
        isRoundTripSelected = false
        setJourneyTypeOutStation()
        delegate?.oneWayPressed()
    }
    
    @objc func roundTripPressed(_ gesture : UITapGestureRecognizer) {
        isRoundTripSelected = true
        setJourneyTypeOutStation()
        delegate?.roundTripPressed()
    }
    
    @objc private func updateToCurrentTime() {
        if fromTime ?? 0  < NSDate().getTimeStamp(){
            fromTime = NSDate().getTimeStamp()
            fromDateLabel.text = "Now"
            fromDateLabel.font = UIFont(name: "HelveticaNeue-Medium" , size: 16)
            delegate?.fromDateUpdated(date: NSDate().getTimeStamp())
        }
    }
    @IBAction func infoButtonTapped(_ sender: Any) {
        let taxiExtraChargesInfoViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiExtraChargesInfoViewController") as! TaxiExtraChargesInfoViewController
        taxiExtraChargesInfoViewController.initialissData(isTollIncluded: isTollIncluded)
        ViewControllerUtils.addSubView(viewControllerToDisplay: taxiExtraChargesInfoViewController)
    }
    
    private func setJourneyTypeOutStation() {
        if !self.isRoundTripSelected {//OneWaySelected
            oneWayLabel.textColor = UIColor(netHex: 0x00B557)
            oneWayViewSeparator.backgroundColor = UIColor(netHex: 0x00B557)
            roundTripLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            roundTripBottomView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            todateView.isHidden = true
            roundTripIMageView.image = UIImage(named: "activated_icon_gray")
            oneWayImageView.image = UIImage(named: "activated_icon_green")
        }else{//RoundTripSelected
            roundTripLabel.textColor = UIColor(netHex: 0x00B557)
            roundTripBottomView.backgroundColor = UIColor(netHex: 0x00B557)
            oneWayLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            oneWayViewSeparator.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            oneWayImageView.image = UIImage(named: "activated_icon_gray")
            roundTripIMageView.image = UIImage(named: "activated_icon_green")
            todateView.isHidden = false
            if toTime != 0.0 {
                self.todateLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: toTime/1000), format: DateUtils.DATE_FORMAT_EEE_dd_h_mm_aaa)
            }else{
                self.todateLabel.text = Strings.outstation_taxi_end_date_place_holder
            }
        }
    }
}
