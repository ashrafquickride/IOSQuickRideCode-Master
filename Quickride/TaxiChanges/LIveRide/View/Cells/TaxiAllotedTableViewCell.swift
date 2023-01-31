//
//  TaxiAllotedTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 01/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiAllotedTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var otpView: QuickRideCardView!
    @IBOutlet weak var changeDriverButton: UIButton!
    @IBOutlet weak var vehicleModelLabel: UILabel!
    @IBOutlet weak var changeDriverRequestedButton: UIButton!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var driverRatingLabel: UILabel!
    @IBOutlet weak var driverRatingView: UIView!
    @IBOutlet weak var customerAlertSupport: UIButton!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var evChangingImage: UIImageView!
    @IBOutlet weak var customerRisedAlertView: UIView!

    private var viewModel: TaxiPoolLiveRideViewModel?


    var handlerTappedOnChangedDestination: handlerTappedOnChangedDestination?

    func initialiseDriverView(viewModel: TaxiPoolLiveRideViewModel,handlerTappedOnChangedDestination : @escaping handlerTappedOnChangedDestination){
        self.handlerTappedOnChangedDestination = handlerTappedOnChangedDestination
        self.viewModel = viewModel
        self.viewModel?.getResloveRiskReasons(taxiGroupId: viewModel.taxiRidePassengerDetails?.taxiRideGroup?.id ?? 0)
        if !viewModel.isRentalTrip(), let pickupOtp = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupOtp, !viewModel.isTaxiStarted() {
            otpView.isHidden = false
           otpLabel.text =  pickupOtp
        }else{
            otpView.isHidden = true
        }


        if let etaResponse = viewModel.etaResponse{
            if let details = viewModel.taxiRidePassengerDetails, (details.isDriverStartedToPickup() || details.isTaxiReached()) {
                pickupLabel.isHidden = true
                destinationLabel.isHidden = true
                etaLabel.isHidden = false
                speedLabel.isHidden = false
                if let lastUpdateTime = etaResponse.lastUpdateTime, NSDate().getTimeStamp() - lastUpdateTime >= 30*1000 {
                    if let distanceStr = LocationClientUtils.humanizeDistance(meters: Int(etaResponse.distanceInKM)*1000){
                        etaLabel.text = distanceStr+" away"
                    }else{
                        etaLabel.text = "Reached Pickup"
                    }
                }else if let etaStr = DateUtils.humanizeTimeDuration(seconds: etaResponse.timeTakenInSec){
                    etaLabel.text = etaStr+" away"
                }else{
                    etaLabel.text = "Reached Pickup"
                }
                if viewModel.currentSpeed > 0 ,viewModel.currentSpeed < 100{
                    speedLabel.isHidden = false
                    speedLabel.text =  "Coming at the speed of \(StringUtils.getStringFromDouble(decimalNumber: viewModel.currentSpeed)) km/h"
                }else if let speed = etaResponse.speed, speed > 0, speed < 100 {
                    speedLabel.isHidden = false
                    speedLabel.text =  "Coming at the speed of \(StringUtils.getStringFromDouble(decimalNumber: speed)) km/h"
                }else{
                    speedLabel.isHidden = true
                }
                destinationLabel.isHidden = true
            }else{
                pickupLabel.isHidden = false
                destinationLabel.isHidden = true
                etaLabel.isHidden = true
                speedLabel.isHidden = true
                let time = DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: etaResponse.timeTakenInSec/60)
                if let ridePickupTime = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupTimeMs, time > ridePickupTime{
                    let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
                    pickupLabel.text = "Pickup at " + (date ?? "")
                }
            }

        }else if (viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupTimeMs ?? 0) < NSDate().getTimeStamp(){
            pickupLabel.isHidden = false
            etaLabel.isHidden = true
            speedLabel.isHidden = true
            let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().getTimeStamp(), timeFormat: DateUtils.TIME_FORMAT_hmm_a)
            pickupLabel.text = "Pickup at " + (date ?? "")
        }else{
            pickupLabel.isHidden = false
            etaLabel.isHidden = true
            speedLabel.isHidden = true
            let pickupTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupTimeMs, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
            pickupLabel.text = "Pickup at " + (pickupTime ?? "")
        }
        driverNameLabel.text = viewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverName?.capitalized
        let driveImage = viewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverImageURI ?? ""
        ImageCache.getInstance().getImageFromCache(imageUrl: driveImage, imageSize: ImageCache.DIMENTION_SMALL, handler: {(image,imageUrl) in
            if imageUrl == driveImage {
                self.driverImage.image = image
            }
        })
        if viewModel.taxiRidePassengerDetails?.taxiRideGroup?.vehicleFuelType == TaxiRideGroup.FIELD_VEHICLE_FUEL_ELECTRIC {
            self.evChangingImage.isHidden = false
            self.vehicleModelLabel.isHidden = true
        } else {
            vehicleModelLabel.text = viewModel.taxiRidePassengerDetails?.taxiRideGroup?.vehicleModel?.capitalized ?? ""
            self.evChangingImage.isHidden = true
        }
        vehicleNumberLabel.text = (viewModel.taxiRidePassengerDetails?.taxiRideGroup?.vehicleNumber?.uppercased() ?? "")
        setupUI()
        displayDriverRatingIfAvailable()
        if viewModel.isRentalTrip() {
            destinationLabel.isHidden = true
        } else if viewModel.isTaxiStarted() {
            destinationLabel.isHidden = false
            if let destinationAddress = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endAddress, destinationAddress != "NA"{
                destinationLabel.text = destinationAddress
            } else {
                destinationLabel.text = "Enter Destination"
            }
            destinationLabel.isUserInteractionEnabled = true
            destinationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeDestinationTapped(_:))))
        } else if viewModel.taxiRidePassengerDetails!.isDriverStartedToPickup(){
            destinationLabel.isHidden = true
        }
        else {
            if let pickupAddress = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startAddress, pickupAddress != "NA"{
                destinationLabel.text = pickupAddress
            } else {
                destinationLabel.text = "Enter Pickup"
            }
            destinationLabel.isHidden = true
        }
        if self.viewModel?.rideRiskAssessment?.count == nil {
            customerRisedAlertView.isHidden = true
        } else {
            customerRisedAlertView.isHidden = false
        }
    }

    @objc func changeDestinationTapped(_ gesture : UITapGestureRecognizer){
        handlerTappedOnChangedDestination!(true)
    }

    func setupUI(){
        if let viewModel = viewModel{
            if !viewModel.isTaxiStarted(), viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.shareType == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
                if viewModel.taxiRidePassengerDetails?.taxiRideDriverChangeInfo?.driverChangeStatus ==  TaxiTripChangeDriverInfo.DRIVER_CHANGE_STATUS_REQUESTED{
                    if viewModel.taxiRidePassengerDetails?.taxiRideDriverChangeInfo?.status ==  TaxiTripChangeDriverInfo.FIELD_DRIVER_CHANGE_STATUS_CANCELLED {
                        updateUIBasedOnStatus(driverNameLabelTextColor: .black, isChangeDriverButtonEnabled: true, isChangeDriverRequestedButtonHidden: true)
                    }else {
                        updateUIBasedOnStatus(driverNameLabelTextColor: .black, isChangeDriverButtonEnabled: false, isChangeDriverRequestedButtonHidden: false)
                    }
                }else if viewModel.taxiRidePassengerDetails?.taxiRideDriverChangeInfo?.driverChangeStatus ==  TaxiTripChangeDriverInfo.DRIVER_CHANGE_STATUS_NEW_DRIVER_ALLOTTED{
                    if let allocationCount = viewModel.taxiRidePassengerDetails?.taxiRideDriverChangeInfo?.allocationCount, let maxTimesAllowed = viewModel.taxiRidePassengerDetails?.taxiRideDriverChangeInfo?.maxTimesAllowed, allocationCount < maxTimesAllowed  {
                        updateUIBasedOnStatus(driverNameLabelTextColor: .black, isChangeDriverButtonEnabled: true, isChangeDriverRequestedButtonHidden: true)
                    } else{
                        updateUIBasedOnStatus(driverNameLabelTextColor: .black, isChangeDriverButtonEnabled: false, isChangeDriverRequestedButtonHidden: true)
                    }
                }
            }else {
                updateUIBasedOnStatus(driverNameLabelTextColor: .black, isChangeDriverButtonEnabled: false, isChangeDriverRequestedButtonHidden: true)
            }
        }

    }


    private func displayDriverRatingIfAvailable(){
        if let driverRating =  viewModel?.taxiRidePassengerDetails?.taxiRideGroup?.driverRating, driverRating > 0 {
            driverRatingView.isHidden = false
            driverRatingLabel.text = driverRating.printValue(places: 1)
        }else {
            driverRatingView.isHidden = true
        }
    }

    @IBAction func callButtonTapped(_ sender: Any) {
        guard let taxiRideGroup = viewModel?.taxiRidePassengerDetails?.taxiRideGroup,let taxiRidePassenger = viewModel?.taxiRidePassengerDetails?.taxiRidePassenger, let viewController = parentViewController else { return }
        if TaxiRideGroup.ZYPY == taxiRideGroup.taxiPartnerCode && taxiRideGroup.partnerId != 0{
            AppUtilConnect.callTaxiDriver(receiverId: String(taxiRideGroup.partnerId), refId: "\(taxiRideGroup.taxiType)- \(taxiRidePassenger.id)", name: taxiRideGroup.driverName ?? "", targetViewController: viewController)
        }else{
            AppUtilConnect.dialNumber(phoneNumber: taxiRideGroup.driverContactNo ?? "", viewController: viewController)
        }
    }


    @IBAction func missedAlertTapped(_ sender: Any) {
        let resolveRiskAlertViewController = UIStoryboard(name: StoryBoardIdentifiers.customerReason_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ResolveRiskAlertViewController") as! ResolveRiskAlertViewController
        guard let taxiGroupId = viewModel?.taxiRidePassengerDetails?.taxiRideGroup?.id else { return }
            guard let rideRiskAssessment = self.viewModel?.rideRiskAssessment else { return }
                resolveRiskAlertViewController.initialiseDataPresentingView(taxiGroupId: taxiGroupId, rideRiskAssessment: rideRiskAssessment)

        ViewControllerUtils.addSubView(viewControllerToDisplay: resolveRiskAlertViewController)
    }

    @IBAction func changeDriverButtonTapped(_ sender: Any) {
        let changeDriverReasonsVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChangeDriverReasonsViewController") as! ChangeDriverReasonsViewController
        changeDriverReasonsVC.prepareData(taxiRidePassenger: viewModel?.taxiRidePassengerDetails?.taxiRidePassenger, complitionHandler: { (result) in
            self.viewModel?.taxiRidePassengerDetails = result
            NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil)
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: changeDriverReasonsVC)
    }
    @IBAction func changeDriverRequestedButtonTapped(_ sender: Any) {
        let changeDriverRequestVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChangeDriverRequestViewController") as! ChangeDriverRequestViewController
        changeDriverRequestVC.initialiseDataBfrPresentingView(taxiRidePassenger: viewModel?.taxiRidePassengerDetails?.taxiRidePassenger, complitionHandler: { (result) in
            self.viewModel?.taxiRidePassengerDetails = result
            var userInfo = [String : Any]()
            userInfo["taxiRidePassengerDetails"] = result
            NotificationCenter.default.post(name: .updateTaxiLiveRideUI, object: nil)
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: changeDriverRequestVC)
    }

    @IBAction func quickRideCustomerSupport(_ sender: Any) {
        let customerAlertViewController = UIStoryboard(name: StoryBoardIdentifiers.customerReason_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CustomerAlertViewController") as! CustomerAlertViewController
        customerAlertViewController.initialiseDataBfrPresentingView(taxiRidePassenger: viewModel?.taxiRidePassengerDetails, isTaxiStarted: false, completionHandler: { [weak self] (customerReason, type) in

            if let taxiPassengerDetails = self?.viewModel?.taxiRidePassengerDetails, let customerReason = customerReason, let type = type {
                let raisedUserType = "Customer"
                self?.viewModel?.sendCustomerReason(customerReason: customerReason, taxiRideGroupId: taxiPassengerDetails.taxiRidePassenger?.taxiGroupId ?? 0, taxiRidePassengerId: taxiPassengerDetails.taxiRidePassenger?.id ?? 0, raisedByRefId: Double(UserDataCache.getInstance()?.userId ?? "") ?? 0, type: type, raisedUserType: raisedUserType)
                self?.viewModel?.getResloveRiskReasons(taxiGroupId: taxiPassengerDetails.taxiRideGroup?.id ?? 0)
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: customerAlertViewController)
    }


    private func updateUIBasedOnStatus(driverNameLabelTextColor: UIColor, isChangeDriverButtonEnabled: Bool, isChangeDriverRequestedButtonHidden: Bool){
        driverNameLabel.textColor = driverNameLabelTextColor
        changeDriverButton.isUserInteractionEnabled = isChangeDriverButtonEnabled
        changeDriverButton.isHidden = !isChangeDriverButtonEnabled
        changeDriverRequestedButton.isHidden = isChangeDriverRequestedButtonHidden
    }
}
