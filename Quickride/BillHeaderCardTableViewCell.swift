//
//  BillHeaderCardTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 05/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol BillHeaderCardTableViewCellDelegate: class {
    func backButtonTapped()
    func menuButtonTapped()
}

class BillHeaderCardTableViewCell: UITableViewCell{
    
    //MARK: Outlets
    @IBOutlet weak var rideCompletedLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var backButtom: UIButton!
    @IBOutlet weak var menuButton: CustomUIButton!
    @IBOutlet weak var backView: UIView!
    
    //MARK: Variables
    private weak var delegate : BillHeaderCardTableViewCellDelegate?
    
    func initializeHeaderView(rideType: String,rideDate: Double,seats: String,isFromClosedRidesOrTransaction: Bool,isTaxiShareRide: Bool, isCancelRide: Bool,isOutStationTaxi: Bool, delegate: BillHeaderCardTableViewCellDelegate,rideTackerName: String?){
        self.delegate = delegate
        if isCancelRide{
            backView.backgroundColor = UIColor(netHex: 0xD04C4C)
            rideCompletedLabel.text = Strings.ride_cancelled
            headerImage.image = UIImage(named: "ride_cancelled_icon")
            menuButton.isHidden = true
        }else{
            if rideType == Ride.RIDER_RIDE{
                headerImage.image = UIImage(named: "badge1")
                if let rideTackerName = rideTackerName {
                    if seats == "0"{
                        rideCompletedLabel.text = "Carpool Completed"
                    }else{
                        rideCompletedLabel.text = "Carpool Completed"
                    }
                } else {
                    if seats == "0"{
                        rideCompletedLabel.text = String(format: Strings.ride_completed_with_rideTaker, arguments: [seats])
                    }else {
                        rideCompletedLabel.text = String(format: Strings.ride_completed_with_rideTakers, arguments: [seats])
                    }
                }
            }else{
                if isTaxiShareRide && !isOutStationTaxi {
                    headerImage.image = UIImage(named: "half_taxi_icon")
                    rideCompletedLabel.text = Strings.taxi_pool_invoice
                }else if isOutStationTaxi {
                    headerImage.image = UIImage(named: "out_station_taxi_selected")
                    rideCompletedLabel.text = Strings.trip_completed_outstation
                }else{
                    headerImage.image = UIImage(named: "noun_carpool")
                    rideCompletedLabel.text = "Carpool Completed!"
                }
            }
            
            if rideType == Ride.PASSENGER_RIDE{
                dateAndTimeLabel.text = "Thank you for Sharing & Saving environment"
            } else {
                dateAndTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideDate, timeFormat: DateUtils.DATE_FORMAT_EEE_dd_MMM_h_mm_a)
            }
        }
            if !isFromClosedRidesOrTransaction{
                backButtom.isHidden = true
            }
        
        }

    
    func initialiseDataForTaxiPool(taxiRideInvoice: TaxiRideInvoice?,isFromClosedRidesOrTransaction: Bool,delegate: BillHeaderCardTableViewCellDelegate) {
        if let taxiRideInvoice = taxiRideInvoice {
            self.delegate = delegate
            dateAndTimeLabel.text = "Today, " + (DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRideInvoice.startTimeMs, timeFormat: DateUtils.TIME_FORMAT_hmm_a) ?? "")
                headerImage.image = UIImage(named: "badge1")
            if let tripType = taxiRideInvoice.tripType {
                rideCompletedLabel.text = tripType + " " + Strings.trip_completed_outstation
            } else {
                rideCompletedLabel.text = Strings.trip_completed_outstation
            }
        }
        if !isFromClosedRidesOrTransaction{
            backButtom.isHidden = true
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate?.backButtonTapped()
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        delegate?.menuButtonTapped()
    }
}
