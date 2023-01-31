//
//  RiderLocationDetails.swift
//  Quickride
//
//  Created by Admin on 12/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RiderLocationDetails: UIView {
    
    //MARK: Outlets
    @IBOutlet weak var dialogueView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationIconView: UIImageView!
    @IBOutlet weak var locationIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dialogueViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: ViewLifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Methods
    func setETAInfo(participantETAInfo: ParticipantETAInfo) {
        
        if let etaError = participantETAInfo.error, etaError.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR {
            locationIconView.isHidden = true
            locationIconWidthConstraint.constant = 0
            locationIconLeadingConstraint.constant = 3
            dialogueViewHeightConstraint.constant = 45
            dialogueView.layoutIfNeeded()
            timeLabel.isHidden = false
            timeLabel.text = Strings.rider_crossed_pickup
            timeLabel.textColor = UIColor.white
            dialogueView.backgroundColor = UIColor.red
            return
        }
        let timeDifferenceInSeconds = DateUtils.getDifferenceBetweenTwoDatesInSecs(time1: DateUtils.getCurrentTimeInMillis(), time2: participantETAInfo.lastUpdateTime)
        timeLabel.textColor = UIColor.black
        dialogueView.backgroundColor = UIColor.white
        timeLabel.isHidden = false
        if timeDifferenceInSeconds <= 30 {
            dialogueViewHeightConstraint.constant = 35
            dialogueView.layoutIfNeeded()
            let durationInTrafficMinutes = participantETAInfo.durationInTraffic
            if durationInTrafficMinutes <= 59 {
                timeLabel.text = "\(durationInTrafficMinutes) min away"
            } else {
                timeLabel.text = "\(durationInTrafficMinutes/60) hour away"
            }
        }else{
            dialogueViewHeightConstraint.constant = 45
            dialogueView.layoutIfNeeded()
            let timeDifference: String?
            if timeDifferenceInSeconds <= 59 {
                timeDifference = "\(timeDifferenceInSeconds) sec ago"
            } else{
                timeDifference = "\(timeDifferenceInSeconds/60) min ago"
            }
            let distanceInMeters = participantETAInfo.routeDistance
            let distance: String?
            if distanceInMeters > 1000 {
                let distanceInKm = distanceInMeters / 1000
                distance = timeDifference! + "\n" + StringUtils.getStringFromDouble(decimalNumber: distanceInKm) + " km away"
            } else if distanceInMeters > 900 {
                distance = timeDifference! + "\n" +  "1 km away"
            } else if distanceInMeters > 1 {
                distance = timeDifference! + "\n" +  StringUtils.getStringFromDouble(decimalNumber: distanceInMeters) + " m away"
            } else {
                distance = timeDifference! + "\n" +  "1 m away"
            }
            let attributedString = NSMutableAttributedString(string: distance!)
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor.lightGray, textSize: 12), range: (distance! as NSString).range(of: timeDifference!))
            timeLabel.attributedText = attributedString
        }
        setImageToDialogue(timeDifferenceInSeconds: timeDifferenceInSeconds)
    }
    
    private func setImageToDialogue(timeDifferenceInSeconds: Int) {
        locationIconView.isHidden = false
        locationIconWidthConstraint.constant = 15
        locationIconLeadingConstraint.constant = 5
        dialogueView.layoutIfNeeded()
        if timeDifferenceInSeconds > 120 {
            locationIconView.image = UIImage(named: "wifi_img") ?? UIImage()
        } else {
            locationIconView.image = UIImage(named: "clock_grey_new") ?? UIImage()
        }
    }
}
