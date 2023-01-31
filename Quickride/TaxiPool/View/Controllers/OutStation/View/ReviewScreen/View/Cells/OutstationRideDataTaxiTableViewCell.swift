//
//  OutstationRideDataTaxiTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 9/25/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class OutstationRideDataTaxiTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerHeightConstarint: NSLayoutConstraint!
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var endAddressLabel: UILabel!
    @IBOutlet weak var startTimeShowingLabel: UILabel!
    @IBOutlet weak var endTimeShowingLabel: UILabel!
    @IBOutlet weak var dropUpImageView: UIImageView!
    @IBOutlet weak var estimateFareLabel: UILabel!
    @IBOutlet weak var endTripCenterConstarint: NSLayoutConstraint!
    
    private var outstationTaxiAvailabilityInfo: OutstationTaxiAvailabilityInfo?
    private var taxiShareRide: TaxiShareRide?
    private var journeyType = 0
    private var currentRide: Ride?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(startAddress: String,endAddress: String,startTime: Double?, endTime: Double?,journeyType: Int,isViewAllVisiable: Bool,estimateFare: Double?,taxiShareRide: TaxiShareRide?,currentRide: Ride?,outstationTaxiAvailabilityInfo: OutstationTaxiAvailabilityInfo?) {
        self.taxiShareRide = taxiShareRide
        self.journeyType = journeyType
        self.currentRide = currentRide
        self.outstationTaxiAvailabilityInfo = outstationTaxiAvailabilityInfo
        startAddressLabel.text = startAddress
        endAddressLabel.text = endAddress
        if let startTime = startTime {
            startTimeShowingLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: startTime/1000), format: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
        }
        if journeyType != 0  {
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
        headerLabel.isHidden = !isViewAllVisiable
        if isViewAllVisiable {
            headerLabel.text = Strings.taxi_trip_details
            headerLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            headerHeightConstarint.constant = 30.0
        }else{
            headerHeightConstarint.constant = 0.0
        }
        if let estimateFare = estimateFare {
            estimateFareLabel.text = "₹ \(Int(estimateFare))"
        }else{
            estimateFareLabel.text = ""
        }
    }
}
