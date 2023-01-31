//
//  RentalTaxiDriverDetailsTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 31/10/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalTaxiDriverDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var otpView: QuickRideCardView!
    @IBOutlet weak var changeDriverButton: UIButton!
    @IBOutlet weak var vehicleModelLabel: UILabel!
    @IBOutlet weak var changeDriverRequestedButton: UIButton!
    @IBOutlet weak var driverRatingLabel: UILabel!
    @IBOutlet weak var driverRatingView: UIView!
    @IBOutlet weak var customerAlertSupport: UIButton!
    @IBOutlet weak var startOdometerReadingLabel: UILabel!
    @IBOutlet weak var endOdometerReadingLabel: UILabel!
    
    private var viewModel: TaxiPoolLiveRideViewModel?
        
    func initialiseDriverView(viewModel: TaxiPoolLiveRideViewModel){
        self.viewModel = viewModel
        if let pickupOtp = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupOtp,!viewModel.isTaxiStarted(){
            otpView.isHidden = false
           otpLabel.text =  pickupOtp
        }else if let dropOtp = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.dropOtp {
            otpView.isHidden = false
            otpLabel.text =  dropOtp
        }else {
            otpView.isHidden = true
        }
       
        driverNameLabel.text = viewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverName?.capitalized
        ImageCache.getInstance().setImageToView(imageView: driverImage, imageUrl:  viewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverImageURI ?? "", gender: User.USER_GENDER_MALE, imageSize: ImageCache.DIMENTION_SMALL)
        vehicleModelLabel.text = (viewModel.taxiRidePassengerDetails?.taxiRideGroup?.vehicleModel?.capitalized ?? "")
        vehicleNumberLabel.text = (viewModel.taxiRidePassengerDetails?.taxiRideGroup?.vehicleNumber?.uppercased() ?? "")
        setupUI()
        displayDriverRatingIfAvailable()
    }
    
    func setupUI(){
        if let viewModel = viewModel{
            if !viewModel.isTaxiStarted() {
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
            if let startOdometerReading = viewModel.outstationTaxiFareDetails?.startOdometerReading, startOdometerReading != 0 {
                startOdometerReadingLabel.text = StringUtils.getStringFromDouble(decimalNumber: startOdometerReading)
            }
            
            if let endOdometerReading = viewModel.outstationTaxiFareDetails?.endOdometerReading, endOdometerReading != 0 {
                endOdometerReadingLabel.text = StringUtils.getStringFromDouble(decimalNumber: endOdometerReading)
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
    
    private func updateUIBasedOnStatus(driverNameLabelTextColor: UIColor, isChangeDriverButtonEnabled: Bool, isChangeDriverRequestedButtonHidden: Bool){
        driverNameLabel.textColor = driverNameLabelTextColor
        changeDriverButton.isUserInteractionEnabled = isChangeDriverButtonEnabled
        changeDriverButton.isHidden = !isChangeDriverButtonEnabled
        changeDriverRequestedButton.isHidden = isChangeDriverRequestedButtonHidden
    }
    @IBAction func customerReasonsAlert(_ sender: Any) {
        
        let customerAlertViewController = UIStoryboard(name: StoryBoardIdentifiers.customerReason_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CustomerAlertViewController") as! CustomerAlertViewController
        customerAlertViewController.initialiseDataBfrPresentingView(taxiRidePassenger: viewModel?.taxiRidePassengerDetails, isTaxiStarted: true, completionHandler: { [weak self] (customerReason, type) in
            if let taxiPassengerDetails = self?.viewModel?.taxiRidePassengerDetails, let customerReason = customerReason, let type = type {
                let raisedUserType = "Customer"
                self?.viewModel?.sendCustomerReason(customerReason: customerReason, taxiRideGroupId: taxiPassengerDetails.taxiRidePassenger?.taxiGroupId ?? 0, taxiRidePassengerId: taxiPassengerDetails.taxiRidePassenger?.id ?? 0, raisedByRefId: Double(UserDataCache.getInstance()?.userId ?? "") ?? 0, type: type,raisedUserType: raisedUserType)
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: customerAlertViewController)
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        guard let taxiRideGroup = viewModel?.taxiRidePassengerDetails?.taxiRideGroup,let taxiRidePassenger = viewModel?.taxiRidePassengerDetails?.taxiRidePassenger, let viewController = parentViewController else { return }
        if TaxiRideGroup.ZYPY == taxiRideGroup.taxiPartnerCode && taxiRideGroup.partnerId != 0{
            AppUtilConnect.callTaxiDriver(receiverId: String(taxiRideGroup.partnerId), refId: "\(taxiRideGroup.taxiType)- \(taxiRidePassenger.id)", name: taxiRideGroup.driverName ?? "", targetViewController: viewController)
        }else{
            AppUtilConnect.dialNumber(phoneNumber: taxiRideGroup.driverContactNo ?? "", viewController: viewController)
        }
    }
    
}
