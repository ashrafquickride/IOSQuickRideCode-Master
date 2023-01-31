//
//  RideHistoryTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 29/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import DropDown

protocol RideHistoryTableViewCellDelegate: class {
   func rideHistoryEditCellButtonTapped(ride: Ride?, senderTag: Int, dropDownView: AnchorView?)
}

class RideHistoryTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak fileprivate var sectionHeaderTimingLabel: UILabel!
    @IBOutlet weak fileprivate var rideTimingLabel: UILabel!
    @IBOutlet weak fileprivate var fromAddressLabel: UILabel!
    @IBOutlet weak fileprivate var toAddressLabel: UILabel!
    @IBOutlet weak fileprivate var rideStatusLabel: UILabel!
    @IBOutlet weak var overflowButton: UIButton!
    @IBOutlet weak var matchedUserDescriptionLabel: UILabel!
    @IBOutlet weak var sectionHeaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var taxiPoolImageView: UIImageView!
    //MARK: Properties
    weak var delegate: RideHistoryTableViewCellDelegate?
    private var ride: Ride?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    //MARK: Methods
    func setupUI() {
        overflowButton.setImage(UIImage(named: "ic_more_vert")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        overflowButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }

    func configureView(ride: Ride) {
        self.ride = ride
        fromAddressLabel.text = ride.startAddress
        toAddressLabel.text = ride.endAddress
        rideTimingLabel.text = RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.TIME_FORMAT_hmm_a)
        sectionHeaderTimingLabel.text = DateUtils.configureRideDateTime(ride: ride)
        checkStatusInfo(for: ride)
        displayJoinedMembersPartOfRide(ride: ride)
    
        if ride.rideType! == Ride.PASSENGER_RIDE  {
            let passengerRide = ride as! PassengerRide
            if passengerRide.taxiRideId == nil || passengerRide.taxiRideId == 0.0  {
                taxiPoolImageView.isHidden = true
            } else {
                taxiPoolImageView.isHidden = false
            }
        } else {
            taxiPoolImageView.isHidden = true
        }
    }
    
    func setSectionHeader(isHeaderShow: Bool, ride: Ride) {
        if isHeaderShow {
            sectionHeaderViewHeightConstraint.constant = 42
            sectionHeaderTimingLabel.text = DateUtils.configureRideDateTime(ride: ride)
        } else {
            sectionHeaderViewHeightConstraint.constant = 0
            sectionHeaderTimingLabel.text = ""
        }
    }
    
    private func checkStatusInfo(for ride: Ride) {
        if Ride.RIDE_STATUS_CANCELLED == ride.status {
            matchedUserDescriptionLabel.text = ""
            rideStatusLabel.textColor = UIColor(netHex: 0xE20000)
            rideStatusLabel.text = Strings.cancelled_status
        } else if Ride.RIDE_STATUS_COMPLETED == ride.status {
            rideStatusLabel.textColor = UIColor(netHex: 0x00B557)
            rideStatusLabel.text = Strings.completed.uppercased()
            matchedUserDescriptionLabel.textColor = UIColor(netHex: 0x00B557)
            matchedUserDescriptionLabel.text = ""
        }
    }

    private func displayJoinedMembersPartOfRide(ride: Ride) {
        if ride.rideType == Ride.PASSENGER_RIDE || ride.rideType == Ride.REGULAR_PASSENGER_RIDE {
            if ride.status == Ride.RIDE_STATUS_COMPLETED {
                if ride.rideType == Ride.PASSENGER_RIDE {
                    if let passengerRide = ride as? PassengerRide {
                        matchedUserDescriptionLabel.text = "\(passengerRide.riderName)"
                    }
                } else {
                    if let regularPassengerRide = ride as? RegularPassengerRide {
                       matchedUserDescriptionLabel.text = "\(regularPassengerRide.riderName ?? "")"
                    }
                }
            }
        }else{
            if ride.status == Ride.RIDE_STATUS_COMPLETED {
                let passengerNameString : String? = getParticipatingPassengerNames(ride: ride)
                if passengerNameString != nil && passengerNameString?.isEmpty == false{
                    matchedUserDescriptionLabel.text = passengerNameString
                } else {
                    var noOfPassengers = 0
                    if ride.rideType == Ride.REGULAR_RIDER_RIDE {
                        noOfPassengers = (ride as! RegularRiderRide).noOfPassengers
                    }else if ride.rideType == Ride.RIDER_RIDE{
                        noOfPassengers = (ride as! RiderRide).noOfPassengers
                    }
                    if noOfPassengers <= 0 {}
                    else if noOfPassengers == 1{
                         matchedUserDescriptionLabel.text = "\(String(noOfPassengers)) \(Strings.passenger)"
                    }else{
                        matchedUserDescriptionLabel.text = "\(String(noOfPassengers)) \(Strings.passengers)"
                    }
                }
            }
        }
    }

    private func getParticipatingPassengerNames(ride : Ride) -> String? {
        let rideParticipants = MyActiveRidesCache.getRidesCacheInstance()?.getRideParicipants(riderRideId: ride.rideId)
        if  rideParticipants == nil || rideParticipants?.isEmpty == true {
            return nil
        } else {
            var passengerNames : String = ""
            if rideParticipants!.count > 2 {
                for rideParticipant in rideParticipants! {
                    if rideParticipant.userId != ride.userId {
                        var passengerDetails = rideParticipant.name!
                        if rideParticipant.noOfSeats > 1{
                            passengerDetails = passengerDetails + " & \(rideParticipant.noOfSeats-1) other"
                        }
                        passengerNames = passengerDetails + " & \(rideParticipants!.count - 2) other"
                        return passengerNames
                    }
                }
            } else {
                for rideParticipant in rideParticipants!{
                    if rideParticipant.userId != ride.userId {
                        var passengerDetails = rideParticipant.name!
                        if rideParticipant.noOfSeats > 1 {
                            passengerDetails = passengerDetails + " & \(rideParticipant.noOfSeats-1) other"
                        }
                        passengerNames = passengerNames+passengerDetails
                        return passengerNames
                    }
                }
                if passengerNames.count > 2 {
                    let myIndex = passengerNames.endIndex
                    let endIndex = passengerNames.index(myIndex, offsetBy: -2)
                    passengerNames = passengerNames.substring(to: endIndex)
                }
                return passengerNames
            }
            return passengerNames
        }
    }
    //MARK: Action
    @IBAction func overflowButtonTapped(_ sender: UIButton) {
        delegate?.rideHistoryEditCellButtonTapped(ride: ride, senderTag: sender.tag, dropDownView: overflowButton)
    }
}

