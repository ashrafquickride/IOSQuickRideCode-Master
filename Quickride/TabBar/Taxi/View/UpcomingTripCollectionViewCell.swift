//
//  UpcomingTripCollectionViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 11/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UpcomingTripCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var taxiPoolDataShowingView: UIView!
    @IBOutlet weak var taxipoolInfoShowingLabel: UILabel!
    @IBOutlet weak var taxiPoolPassengerInfoShowingStackView: UIStackView!
    @IBOutlet weak var firstSeatImageTaxiPool: UIImageView!
    @IBOutlet weak var secondSeatImageTaxiPool: UIImageView!
    @IBOutlet weak var thirdSeatImageTaxiPool: UIImageView!
    @IBOutlet weak var fourthSeatImageTaxiPool: UIImageView!
    @IBOutlet weak var taxiDetailsShowingView: UIView!
    @IBOutlet weak var taxiNumberShowingLabel: UILabel!
    @IBOutlet weak var outStationDataShowingView: UIView!
    @IBOutlet weak var outStationDetailsLabel: UILabel!
    @IBOutlet weak var taxiIconImageView: UIImageView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var rideTimingLabel: UILabel!
    @IBOutlet weak var fromToAddressView: UIView!
    @IBOutlet weak var dayTitleForNextRideLabel: UILabel!
    @IBOutlet weak var homeOfficeAddressView: UIView!
    @IBOutlet weak var homeAddressLabel: UILabel!
    @IBOutlet weak var officeAddressLabel: UILabel!
    @IBOutlet weak var rideNotificationView: UIView!
    @IBOutlet weak var rideNotificationImageView: UIImageView!
    @IBOutlet weak var rideRequestInfoLabel: UILabel!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet weak var taxiTypeImageView: UIImageView!

    //MARK: Variables
    private var numberOfSeatsImageArray = [UIImageView]()
    private var taxiRidePassenger: TaxiRidePassenger?

    func initialiseTripDetails(taxiRidePassenger: TaxiRidePassenger) {
        self.taxiRidePassenger = taxiRidePassenger
        setRideStartDateForCardView(ride: taxiRidePassenger)
        checkStatusInfo(taxiRidePassenger: taxiRidePassenger)
        rideTimingLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: taxiRidePassenger.startTimeMs! / 1000), format: DateUtils.TIME_FORMAT_hmm_a)
        configureAddressInfo(taxiRidePassenger: taxiRidePassenger)
    }

    func checkStatusInfo(taxiRidePassenger: TaxiRidePassenger) {
        TaxiRideDetailsCache.getInstance().getTaxiRideDetailsFromCache(rideId: taxiRidePassenger.id!) { (restResponse) in
            if let taxiRidePassengerDetails = restResponse.result {
                self.handleTaxiPoolUI(taxiRidePassengerDetails: taxiRidePassengerDetails)
            }
        }

    }

    func setRideStartDateForCardView(ride: TaxiRidePassenger) {
        dayTitleForNextRideLabel.text = DateUtils.configureRideDateTime(ride: ride)
    }

    func configureAddressInfo(taxiRidePassenger: TaxiRidePassenger) {
        if let userCache = UserDataCache.getInstance(), let _ = userCache.getHomeLocation(), let _ = userCache.getOfficeLocation() {
            setHomeOfficeAddressView(taxiRidePassenger: taxiRidePassenger)
        } else {

            if taxiRidePassenger.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
                fromToAddressView.isHidden = true
                homeOfficeAddressView.isHidden = true
                outStationDataShowingView.isHidden = false
                outStationDetailsLabel.text = String(format: taxiRidePassenger.journeyType == TaxiShareRide.ONE_WAY ? Strings.one_way_trip_to : Strings.round_trip_to_myride, arguments: [taxiRidePassenger.endAddress ?? ""])


            } else {
                setRideaddress(startAddress: taxiRidePassenger.startAddress!, endAddress: taxiRidePassenger.endAddress!)
            }
        }

    }

    func setHomeOfficeAddressView(taxiRidePassenger: TaxiRidePassenger) {
        homeOfficeAddressView.isHidden = false
        fromToAddressView.isHidden = true
        outStationDataShowingView.isHidden = true
        if let cacheInstance = UserDataCache.getInstance() {
            if let homeLocation = cacheInstance.getHomeLocation(), let officeLocation = cacheInstance.getOfficeLocation() {
                if taxiRidePassenger.startAddress == homeLocation.address, taxiRidePassenger.endAddress == officeLocation.address {
                    homeAddressLabel.text = Strings.home
                    officeAddressLabel.text = Strings.office
                    return
                }
                if taxiRidePassenger.startAddress == officeLocation.address, taxiRidePassenger.endAddress == homeLocation.address {
                    homeAddressLabel.text = Strings.office
                    officeAddressLabel.text = Strings.home
                    return
                }
                setRideaddress(startAddress: taxiRidePassenger.startAddress!, endAddress: taxiRidePassenger.endAddress!)
            } else {
                setRideaddress(startAddress: taxiRidePassenger.startAddress!, endAddress: taxiRidePassenger.endAddress!)
            }
        }
    }

    private func setRideaddress(startAddress: String, endAddress: String) {
        homeOfficeAddressView.isHidden = true
        fromToAddressView.isHidden = false
        outStationDataShowingView.isHidden = true
        fromAddressLabel.text = startAddress
        if taxiRidePassenger?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL, let taxiGroupId = taxiRidePassenger?.taxiGroupId {
            TaxiRideDetailsCache.getInstance().getAllRentalStopPoints(taxiGroupId: taxiGroupId) { response, responseError, error in
                if let rentalStopPoints = response, let lastStopPointAddress = rentalStopPoints.last?.stopPointAddress {
                    self.toAddressLabel.text = lastStopPointAddress
                } else {
                    self.toAddressLabel.text = "Enter Destination"
                }
            }
        } else {
            toAddressLabel.text = endAddress
        }

    }

    private func handleTaxiPoolUI(taxiRidePassengerDetails: TaxiRidePassengerDetails) {
        if taxiRidePassengerDetails.taxiRidePassenger?.getShareType() != TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            numberOfSeatsImageArray = [firstSeatImageTaxiPool, secondSeatImageTaxiPool, thirdSeatImageTaxiPool, fourthSeatImageTaxiPool]
            let noOfPassengers = noOfPassengersInTrip(taxiRidePassengerDetails: taxiRidePassengerDetails)
            setImageForTaxiPool(noOfPassengers: noOfPassengers)
            taxiIconImageView.image = UIImage(named: "taxiPool_icon")
            taxiTypeImageView.isHidden = true
            taxiPoolDataShowingView.isHidden = false
            taxipoolInfoShowingLabel.isHidden = true
            taxiPoolPassengerInfoShowingStackView.isHidden = false
        } else {
            taxiPoolDataShowingView.isHidden = true
            taxiTypeImageView.isHidden = false
            taxiTypeImageView.image = TaxiUtils.getTaxiTypeIcon(taxiType: taxiRidePassengerDetails.taxiRidePassenger?.taxiType)
        }

        if isPaymentPending(taxiRidePassengerDetails: taxiRidePassengerDetails) {
            rideNotificationView.isHidden = true
            rideNotificationImageView.isHidden = true
            rideRequestInfoLabel.textColor = .orange
            rideRequestInfoLabel.text = Strings.payment_pending_title
        } else {
            updateTaxiRideStatus(taxiRidePassengerDetails: taxiRidePassengerDetails)
        }
    }

    private func noOfPassengersInTrip(taxiRidePassengerDetails: TaxiRidePassengerDetails) -> Int {
        guard let noOfPassengers = taxiRidePassengerDetails.taxiRideGroup?.noOfPassengers else {
            return 0
        }
        return noOfPassengers
    }

    private func isPaymentPending(taxiRidePassengerDetails: TaxiRidePassengerDetails) -> Bool {

        if let error = taxiRidePassengerDetails.exception?.error, error.errorCode == TaxiDemandManagementException.PAYMENT_REQUIRED_BEFORE_JOIN_TAXI {
            return true
        }
        return false
    }

    private func updateTaxiRideStatus(taxiRidePassengerDetails: TaxiRidePassengerDetails) {
        if TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE != taxiRidePassengerDetails.taxiRidePassenger!.getShareType() && taxiRidePassengerDetails.taxiRideGroup!.noOfPassengers! < 2 {
            rideNotificationView.isHidden = true
            rideNotificationImageView.isHidden = true
            rideRequestInfoLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            rideRequestInfoLabel.text = Strings.one_seat_to_confirm_taxi_pool

        } else {
            rideNotificationView.isHidden = false
            rideNotificationImageView.isHidden = false
            rideRequestInfoLabel.textColor = UIColor(netHex: 0x00B557)
            rideRequestInfoLabel.text = TaxiUtils.getTaxiTripStatus(taxiRidePassengerDetails: taxiRidePassengerDetails)
        }
        if let vehicleNumber = taxiRidePassengerDetails.taxiRideGroup?.vehicleNumber, vehicleNumber != "" {
            taxiDetailsShowingView.isHidden = false
            taxiNumberShowingLabel.text = vehicleNumber
        } else {
            taxiDetailsShowingView.isHidden = true
        }
    }

    private func setImageForTaxiPool(noOfPassengers: Int) {
        for (index, imageView) in numberOfSeatsImageArray.enumerated() {
            if (index < noOfPassengers) {
                imageView.isHidden = false
                imageView.image = UIImage(named: "seat_occupied")
            } else {
                imageView.isHidden = true
            }
        }
    }
}
