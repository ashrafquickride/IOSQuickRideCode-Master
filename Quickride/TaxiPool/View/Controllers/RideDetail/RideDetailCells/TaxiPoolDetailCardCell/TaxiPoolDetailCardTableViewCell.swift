//
//  TaxiPoolDetailCardTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 5/17/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

protocol TaxiPoolDetailCardTableViewCellDelegate {
    func joinBtnPressed(index: Int)
    func notificationJoinBtnPressed()
    func joinInvitePressed()
    func rejectInvitePressed()
}

class TaxiPoolDetailCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backGroundView: QuickRideCardView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    @IBOutlet weak var seatLeftShowingLabel: UILabel!
    @IBOutlet weak var sharingShowingLabel: UILabel!
    @IBOutlet weak var amountShowingLabel: UILabel!
    
    @IBOutlet weak var oneSeatImageView: UIImageView!
    @IBOutlet weak var twoSeatImageView: UIImageView!
    @IBOutlet weak var thirdSeatImageView: UIImageView!
    @IBOutlet weak var fourthSeatImageView: UIImageView!
    
    @IBOutlet weak var pickUpTimeShowingLabel: UILabel!
    
    @IBOutlet weak var joinButton: QRCustomButton!
    @IBOutlet weak var seatDetailsStackView: UIStackView!
    @IBOutlet weak var taxiHeaderForNotificationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextStepBtn: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var joinBtnViewForNotification: UIView!
    @IBOutlet weak var notificationJoinBtn: QRCustomButton!
    @IBOutlet weak var notificationJoinBtnHeightConstarints: NSLayoutConstraint!
    
    @IBOutlet weak var headerLabel: UILabel!
    //TaxiPoolInvite
    @IBOutlet weak var inviteButtonsShowingView: UIView!
    @IBOutlet weak var acceptInviteBtn: QRCustomButton!
    @IBOutlet weak var declineInviteBtn: QRCustomButton!
    @IBOutlet weak var inviteButtonsShowingViewHeightConstarints: NSLayoutConstraint!
    var delegate: TaxiPoolDetailCardTableViewCellDelegate?
    private var numberOfSeatsImageArray = [UIImageView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfSeatsImageArray = [oneSeatImageView,twoSeatImageView,thirdSeatImageView,fourthSeatImageView]
        // Initialization code
    }
    
    func updateUI(data: MatchedShareTaxi?,analyticsData: AnalyticNotificationHandlerModel?,inviteData: TaxiInviteEntity?) {
        if let data = data {
            headerView.isHidden = true
            taxiHeaderForNotificationHeightConstraint.constant = 0
            joinBtnViewForNotification.isHidden = true
            inviteButtonsShowingView.isHidden = true
            inviteButtonsShowingViewHeightConstarints.constant = 0
            notificationJoinBtnHeightConstarints.constant = 0
            seatDetailsStackView.isHidden = false
            joinButton.isHidden = false
            sharingShowingLabel.text = data.shareType ?? ""
            amountShowingLabel.text = "₹\(Int(data.minPoints ?? 0))"
            let availableSeats = Int(data.availableSeats!)
            if availableSeats > 1 {
                seatLeftShowingLabel.text = String(format: Strings.seats_available,arguments: [String(data.availableSeats ?? 0)])
            } else {
                seatLeftShowingLabel.text = Strings.seat_available
            }
            setOccupiedSeats(availableSeats: data.availableSeats ?? 0, capacity: data.capacity ?? 0)
            let addedTimeRangeTime = DateUtils.addMinutesToTimeStamp(time: data.pkTime!, minutesToAdd: ConfigurationCache.getObjectClientConfiguration().taxiPickUpTimeRangeInMins)
            pickUpTimeShowingLabel.text  = DateUtils.getTimeStringFromTimeInMillis(timeStamp: data.pkTime, timeFormat: DateUtils.TIME_FORMAT_hh_mm)! + "-" + DateUtils.getTimeStringFromTimeInMillis(timeStamp: addedTimeRangeTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            if inviteData != nil {
                headerView.isHidden = false
                taxiHeaderForNotificationHeightConstraint.constant = 70
                joinButton.isHidden = true
                inviteButtonsShowingView.isHidden = false
                inviteButtonsShowingViewHeightConstarints.constant = 45
                headerLabel.text = String(format: Strings.taxi_pool_invite_detail_header, arguments: [(inviteData?.invitingUserName ?? "")])
            }
        } else if analyticsData != nil {
            leftView.isHidden = true
            rightView.isHidden = true
            headerView.isHidden = false
            inviteButtonsShowingView.isHidden = true
            inviteButtonsShowingViewHeightConstarints.constant = 0
            taxiHeaderForNotificationHeightConstraint.constant = 70
            joinBtnViewForNotification.isHidden = false
            notificationJoinBtnHeightConstarints.constant = 45
            seatDetailsStackView.isHidden = true
            joinButton.isHidden = true
            sharingShowingLabel.text = analyticsData?.shareType
            if Int(analyticsData?.minFare ?? 0) == Int(analyticsData?.maxFare ?? 0) {
                amountShowingLabel.text = "₹\(Int(analyticsData?.minFare ?? 0))"
            }else{
                amountShowingLabel.text = "₹\(Int(analyticsData?.minFare ?? 0))" + "-\(Int(analyticsData?.maxFare ?? 0))"
            }
            let addedTimeRangeTime = DateUtils.addMinutesToTimeStamp(time: analyticsData?.rideStartTime ?? 0.0, minutesToAdd: ConfigurationCache.getObjectClientConfiguration().taxiPickUpTimeRangeInMins)
            pickUpTimeShowingLabel.text  = DateUtils.getTimeStringFromTimeInMillis(timeStamp: analyticsData?.rideStartTime ?? 0.0, timeFormat: DateUtils.TIME_FORMAT_hh_mm)! + "-" + DateUtils.getTimeStringFromTimeInMillis(timeStamp: addedTimeRangeTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }
    }
    
    @IBAction func joinBtnPressed(_ sender: UIButton) {
        delegate?.joinBtnPressed(index: sender.tag)
    }
    
    
    @IBAction func nextStepBtnPressed(_ sender: UIButton) {
        let taxiPoolIntroduction = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolIntroductionViewController") as! TaxiPoolIntroductionViewController
        taxiPoolIntroduction.initialisationBeforeShowing(ride: nil, taxiSharedRide: nil)
        parentViewController?.navigationController?.pushViewController(taxiPoolIntroduction, animated: false)
    }
    
    @IBAction func notificationJoinBtnPressed(_ sender: UIButton) {
        delegate?.notificationJoinBtnPressed()
    }
    
    //MARK: Invite flow
    @IBAction func acceptBtnPressed(_ sender: UIButton) {
        delegate?.joinInvitePressed()
    }
    
    @IBAction func declineBtnPressed(_ sender: UIButton) {
        delegate?.rejectInvitePressed()
    }
    
    private func setOccupiedSeats(availableSeats: Int, capacity: Int) {
        for (index, imageView) in numberOfSeatsImageArray.enumerated() {
            imageView.isHidden = !(index < capacity)
            if !(index < capacity) {
                break
            }
            imageView.image = index < capacity - availableSeats ? UIImage(named: "seat_occupied") : UIImage(named: "seat_not_occu_taxi")
        }
    }
}
