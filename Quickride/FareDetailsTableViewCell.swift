//
//  FareDetailsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 04/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol FareDetailsTableViewCellDelegate: class {
    func routeMapButtonTapped(data: Bool)
    func insuranceInfoTapped()
}

class FareDetailsTableViewCell: UITableViewCell {
    //MARK: RouteDetailOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verifiedimageView: UIImageView!
    @IBOutlet weak var companyDeginationlabel: UILabel!
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var endAddressLabel: UILabel!
    @IBOutlet weak var routeMapBtn: UIButton!
    //MARK: FareUIOutlets
    @IBOutlet weak var serviceFeeLabel: UILabel!
    @IBOutlet weak var insuranceView: UIView!
    @IBOutlet weak var insuranceViewHeight: NSLayoutConstraint!
    @IBOutlet weak var insuranceAmountShowingLabel: UILabel!
    @IBOutlet weak var buttomSeperatorView: UIView!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var dateShowingLabel: UILabel!
    //MARK: Rider count Image Outlet
    @IBOutlet weak var rideTypeLabel: UILabel!
    @IBOutlet weak var serviceFeeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var serviceFeeView: UIView!
    @IBOutlet weak var verifiedImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dotSeperatorView: UIView!
    @IBOutlet weak var carpoolPointsLabel: UILabel!
   @IBOutlet weak var reimbursedToNameLabel: UILabel!
    @IBOutlet weak var fareDetailViewHeightConstraint: NSLayoutConstraint!
    
    var delegate: UserDetailsTableViewCellDelegate?
    var rideTakerimage: [UIImageView]?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    

    @IBAction func InsuranceInfoBtnPressed(_ sender: UIButton) {
        delegate?.showInsuranceView()
    }
    
    func updateCellUIWithPassengerBillDetails(rideBillingDetails: RideBillingDetails?, companyName: String?, verificationProfile: UIImage?) {
        dateShowingLabel.text = "\(DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(rideBillingDetails?.startTimeMs ?? 0) , timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy) ?? "")" + " | \(DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(rideBillingDetails?.startTimeMs ?? 0), timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "" )"
        startAddressLabel.text = rideBillingDetails?.startLocation
        endAddressLabel.text = rideBillingDetails?.endLocation
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        guard let distanceTravelled = rideBillingDetails?.distance else { return }
        routeMapBtn.setTitle(StringUtils.getStringFromDouble(decimalNumber: distanceTravelled)+"Kms", for: .normal)
        reimbursedToNameLabel.text = "Carpool points reimbursed to "  + (rideBillingDetails?.fromUserName ?? "")
        carpoolPointsLabel.text = StringUtils.getPointsInDecimal(points: rideBillingDetails?.rideFare ?? 0.0)
        buttomSeperatorView.addDashedView(color: UIColor.darkGray.cgColor)
        seperatorView.addDashedView(color: UIColor.darkGray.cgColor)
        dotSeperatorView.addDashedView(color: UIColor.darkGray.cgColor)
        let platformFeeWithTax = (rideBillingDetails?.rideTakerPlatformFeeGst ?? 0) + (rideBillingDetails?.rideTakerPlatformFee ?? 0)
        let feeWithTax =  platformFeeWithTax + (rideBillingDetails?.rideFareGst ?? 0)
        if platformFeeWithTax > 0 {
            serviceFeeView.isHidden = false
            serviceFeeHeightConstraint.constant = 30
           serviceFeeLabel.text = StringUtils.getPointsInDecimal(points: feeWithTax)
        } else {
            serviceFeeView.isHidden = true
            serviceFeeHeightConstraint.constant = 0
        }
        if let insurancePoints = rideBillingDetails?.insurancePoints, insurancePoints > 0 {
            insuranceViewHeight.constant = 35
            insuranceView.isHidden = false
            insuranceAmountShowingLabel.text = StringUtils.getPointsInDecimal(points: rideBillingDetails?.insurancePoints ?? 0)
        }else{
            insuranceViewHeight.constant = 0
            insuranceView.isHidden = true
        }
        nameLabel.text = rideBillingDetails?.toUserName
        displayRiderDetailse(companyName: companyName, verificationProfile: verificationProfile)
    }
    func displayRiderDetailse(companyName: String?, verificationProfile: UIImage?){
        if let companyName = companyName, companyName != "Null" , let verificationProfile = verificationProfile {
            companyDeginationlabel.isHidden = false
            verifiedimageView.isHidden = false
            companyDeginationlabel.text = companyName
            verifiedimageView.image = verificationProfile
        }else {
            companyDeginationlabel.isHidden = true
            verifiedimageView.isHidden = true
        }
    }
    func getServiceFeesFromAllBills(tripReport: TripReport?) -> Double{
        var serviceFee : Double = 0
        for iteratedBill in tripReport?.bills ?? [] {
            serviceFee = serviceFee + iteratedBill.serviceFee!
        }
        return serviceFee
    }
}

