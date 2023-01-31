//
//  TaxiStartedTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 01/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import SDWebImage

typealias handlerTappedOnChangedDestination = (_ completed : Bool) -> Void

class TaxiStartedTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    @IBOutlet weak var vehicleModel: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var endOTPView: QuickRideCardView!
    @IBOutlet weak var driverNameLbl: UILabel!
    @IBOutlet weak var driverRatingLabel: UILabel!
    @IBOutlet weak var driverRatingView: UIView!
    @IBOutlet weak var customerRisedAlertView: UIView!

    var viewModel: TaxiPoolLiveRideViewModel?
    var handlerTappedOnChangedDestination: handlerTappedOnChangedDestination?

    func initialiseDriverView(viewModel: TaxiPoolLiveRideViewModel, handlerTappedOnChangedDestination : @escaping handlerTappedOnChangedDestination){
        self.viewModel = viewModel
        self.handlerTappedOnChangedDestination = handlerTappedOnChangedDestination
        self.viewModel?.getResloveRiskReasons(taxiGroupId: viewModel.taxiRidePassengerDetails?.taxiRideGroup?.id ?? 0)
        setDropEta()
        vehicleNumberLabel.text = viewModel.taxiRidePassengerDetails?.taxiRideGroup?.vehicleNumber?.uppercased() ?? ""
        ImageCache.getInstance().setImageToView(imageView: driverImage, imageUrl:  viewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverImageURI ?? "", gender: User.USER_GENDER_MALE, imageSize: ImageCache.DIMENTION_SMALL)
        vehicleModel.text = viewModel.taxiRidePassengerDetails?.taxiRideGroup?.vehicleModel?.capitalized ?? ""
        driverNameLbl.text = viewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverName?.capitalized
        if let dropOtp = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.dropOtp{
            endOTPView.isHidden = false
            otpLabel.text = "Drop OTP " + dropOtp
        }else{
            endOTPView.isHidden = true
        }
        if viewModel.isRentalTrip(), let destinationAddress = viewModel.rentalStopPointList?.last?.stopPointAddress, destinationAddress != "NA"{
            destinationAddressLabel.text = destinationAddress
        }else if let destinationAddress = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endAddress, destinationAddress != "NA"{
            destinationAddressLabel.text = destinationAddress
        } else {
            destinationAddressLabel.text = "Enter Destination"
        }
        destinationAddressLabel.isUserInteractionEnabled = true
        destinationAddressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeDestinationTapped(_:))))
        displayDriverRatingIfAvailable(viewModel: viewModel)

        if self.viewModel?.rideRiskAssessment?.count ?? 0 < 0 {
            customerRisedAlertView.isHidden = true
        } else {
            customerRisedAlertView.isHidden = false
        }

    }

    private func setDropEta(){
        if  viewModel?.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION, (viewModel?.isTaxiStarted() ?? false) {
            etaLabel.isHidden = true
            return
        }
        let dropTime =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: viewModel?.taxiRidePassengerDetails?.taxiRidePassenger?.dropTimeMs, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        etaLabel.text = "ETA " + (dropTime ?? "")
        if let etaResponse = viewModel?.etaResponse{
            let time = DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: etaResponse.timeTakenInSec/60)
            let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
            etaLabel.text = "ETA " + (date ?? "")
        }else if (viewModel?.taxiRidePassengerDetails?.taxiRidePassenger?.dropTimeMs ?? 0) < NSDate().getTimeStamp(){
            let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().getTimeStamp(), timeFormat: DateUtils.TIME_FORMAT_hmm_a)
            etaLabel.text = "ETA " + (date ?? "")
        }
    }

    private func displayDriverRatingIfAvailable(viewModel: TaxiPoolLiveRideViewModel){
        if let driverRating =  viewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverRating, driverRating > 0 {
            driverRatingView.isHidden = false
            driverRatingLabel.text = driverRating.printValue(places: 1)
        }else {
            driverRatingView.isHidden = true
        }
    }

    @objc func changeDestinationTapped(_ gesture : UITapGestureRecognizer){
        handlerTappedOnChangedDestination!(true)
    }

    @IBAction func customerReasonsAlert(_ sender: Any) {
        let customerAlertViewController = UIStoryboard(name: StoryBoardIdentifiers.customerReason_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CustomerAlertViewController") as! CustomerAlertViewController
        customerAlertViewController.initialiseDataBfrPresentingView(taxiRidePassenger: viewModel?.taxiRidePassengerDetails, isTaxiStarted: true, completionHandler: { [weak self] (customerReason, type) in
            if let taxiPassengerDetails = self?.viewModel?.taxiRidePassengerDetails, let customerReason = customerReason, let type = type {
                let raisedUserType = "Customer"
                self?.viewModel?.sendCustomerReason(customerReason: customerReason, taxiRideGroupId: taxiPassengerDetails.taxiRidePassenger?.taxiGroupId ?? 0, taxiRidePassengerId: taxiPassengerDetails.taxiRidePassenger?.id ?? 0, raisedByRefId: Double(UserDataCache.getInstance()?.userId ?? "") ?? 0, type: type,raisedUserType: raisedUserType)
                self?.viewModel?.getResloveRiskReasons(taxiGroupId: self?.viewModel?.taxiRidePassengerDetails?.taxiRideGroup?.id ?? 0)
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: customerAlertViewController)
    }

    @IBAction func risedAlertReasons(_ sender: Any) {
        let resolveRiskAlertViewController = UIStoryboard(name: StoryBoardIdentifiers.customerReason_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ResolveRiskAlertViewController") as! ResolveRiskAlertViewController
        guard let taxiGroupId = viewModel?.taxiRidePassengerDetails?.taxiRideGroup?.id else { return }
            guard let rideRiskAssessment = self.viewModel?.rideRiskAssessment else { return }
                resolveRiskAlertViewController.initialiseDataPresentingView(taxiGroupId: taxiGroupId, rideRiskAssessment: rideRiskAssessment)

        ViewControllerUtils.addSubView(viewControllerToDisplay: resolveRiskAlertViewController)
    }
    
    
    @IBAction func callOptionTapped(_ sender: Any) {
        guard let taxiRideGroup = viewModel?.taxiRidePassengerDetails?.taxiRideGroup,let taxiRidePassenger = viewModel?.taxiRidePassengerDetails?.taxiRidePassenger, let viewController = parentViewController else { return }
        if TaxiRideGroup.ZYPY == taxiRideGroup.taxiPartnerCode && taxiRideGroup.partnerId != 0{
            AppUtilConnect.callTaxiDriver(receiverId: String(taxiRideGroup.partnerId), refId: "\(taxiRideGroup.taxiType)- \(taxiRidePassenger.id)", name: taxiRideGroup.driverName ?? "", targetViewController: viewController)
        }else{
            AppUtilConnect.dialNumber(phoneNumber: taxiRideGroup.driverContactNo ?? "", viewController: viewController)
        }
        
    }
    

}
