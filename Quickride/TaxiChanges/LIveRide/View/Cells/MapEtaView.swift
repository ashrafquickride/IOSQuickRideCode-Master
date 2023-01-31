//
//  MapEtaView.swift
//  Quickride
//
//  Created by QR Mac 1 on 05/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class MapEtaView: UIView {
    
    @IBOutlet weak var currentEtaView: QuickRideCardView!
    @IBOutlet weak var lastUpdatedView: QuickRideCardView!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var minuteOrHoursAwayLabel: UILabel!
    @IBOutlet weak var etaView: UIView!
    
    @IBOutlet weak var lastUpdatedTime: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func setETAInfo(participantETAInfo: ParticipantETAInfo) {
        let timeDifferenceInSeconds = DateUtils.getDifferenceBetweenTwoDatesInSecs(time1: DateUtils.getCurrentTimeInMillis(), time2: participantETAInfo.lastUpdateTime)
        if timeDifferenceInSeconds <= 30 {
            currentEtaView.isHidden = false
            lastUpdatedView.isHidden = true
            ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: etaView, cornerRadius: 8, corner1: .topLeft, corner2: .bottomLeft)
            let durationInTrafficMinutes = participantETAInfo.durationInTraffic
            if durationInTrafficMinutes <= 59 {
                if durationInTrafficMinutes == 0{
                    etaLabel.text = "1"
                }else{
                    etaLabel.text = String(durationInTrafficMinutes)
                }
                minuteOrHoursAwayLabel.text = "Minute away"
            } else {
                etaLabel.text = String(durationInTrafficMinutes/60)
                minuteOrHoursAwayLabel.text = "Hour away"
            }
        }else{
            currentEtaView.isHidden = true
            lastUpdatedView.isHidden = false
            if timeDifferenceInSeconds <= 59 {
                lastUpdatedTime.text = "\(timeDifferenceInSeconds) sec ago"
            } else{
                lastUpdatedTime.text = "\(timeDifferenceInSeconds/60) min ago"
            }
            let distanceInMeters = participantETAInfo.routeDistance
            if distanceInMeters > 1000 {
                let distanceInKm = distanceInMeters / 1000
                distanceLabel.text = StringUtils.getStringFromDouble(decimalNumber: distanceInKm) + " km away"
            } else if distanceInMeters > 900 {
                distanceLabel.text = "1 km away"
            } else if distanceInMeters > 1 {
                distanceLabel.text = StringUtils.getStringFromDouble(decimalNumber: distanceInMeters) + " m away"
            } else {
                distanceLabel.text = "1 m away"
            }
        }
    }
}
