//
//  OutstationTaxiTripDataTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 9/25/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class OutstationTaxiTripDataTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var endAddressLabel: UILabel!
    @IBOutlet weak var startTimeShowingLabel: UILabel!
    @IBOutlet weak var endTimeShowingLabel: UILabel!
    @IBOutlet weak var dropUpImageView: UIImageView!
    @IBOutlet weak var estimateFareLabel: UILabel!
    @IBOutlet weak var endTripCenterConstarint: NSLayoutConstraint!
    @IBOutlet weak var topDriverView: UIView!
    @IBOutlet weak var supportView: UIView!
    @IBOutlet weak var cleanCarsView: UIView!
    
    private var taxiRidePassenger: TaxiRidePassenger?
    private var journeyType: String?
    private var currentRide: Ride?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpUI(startAddress: String,endAddress: String,startTime: Double?, endTime: Double?,journeyType: String,estimateFare: Double?,taxiRidePassenger: TaxiRidePassenger?) {
        self.taxiRidePassenger = taxiRidePassenger
        self.journeyType = journeyType
        startAddressLabel.text = startAddress
        endAddressLabel.text = endAddress
        if let startTime = startTime {
            startTimeShowingLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: startTime/1000), format: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
        }
        if journeyType == TaxiPoolConstants.JOURNEY_TYPE_ROUND_TRIP  {
            dropUpImageView.isHidden = false
            endTimeShowingLabel.isHidden = false
            endTripCenterConstarint.constant = 0
            if let endtime = endTime {
                endTimeShowingLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: endtime/1000), format: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
            }
        }else{
            endTripCenterConstarint.constant = 20
            dropUpImageView.isHidden = true
            endTimeShowingLabel.isHidden = true
        }
        addShadowToImageView()
    }
    func addShadowToImageView(){
        topDriverView.layer.cornerRadius = 6
        topDriverView.layer.borderWidth = 1
        topDriverView.layer.borderColor = UIColor(netHex:  0xAFAFAF).cgColor
        topDriverView.clipsToBounds = true
        
        supportView.layer.cornerRadius = 6
        supportView.layer.borderWidth = 1
        supportView.layer.borderColor = UIColor(netHex:  0xAFAFAF).cgColor
        supportView.clipsToBounds = true
        
        cleanCarsView.layer.cornerRadius = 6
        cleanCarsView.layer.borderWidth = 1
        cleanCarsView.layer.borderColor = UIColor(netHex:  0xAFAFAF).cgColor
        cleanCarsView.clipsToBounds = true
    }
}
